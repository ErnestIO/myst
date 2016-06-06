# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class Provider
        attr_reader :client, :endpoint, :username, :password, :organisation, :org

        def initialize(args)
          @endpoint = args[:endpoint]
          @username = args[:username]
          @password = args[:password]
          @organisation = args[:organisation]
          authenticate
        end

        def authenticate
          @client = VcloudClient.new(endpoint, Version::V5_5)
          client.registerScheme('https', 443, CustomSSLSocketFactory.new.getInstance)
          client.login("#{username}@#{organisation}", "#{password}")
          org(organisation) if organisation != 'system'
        end

        def org(_name = @organisation)
          @org = Organization.getOrganizationByReference(client, client.getOrgRefByName(organisation))
        end

        def datacenter(name)
          Datacenter.new(ref: org.getVdcRefByName(name), client: client)
        end

        def image(name, catalog_name)
          catalog_reference = org.getCatalogRefs.find { |catalog| catalog.getName == catalog_name }
          catalog = Catalog.getCatalogByReference(client, catalog_reference)
          image_ref = CatalogItem.getCatalogItemByReference(client,
                                                            catalog.getCatalogItemRefByName(name)).entityReference
          Image.new(ref: image_ref, client: @client)
        end

        def query(type, field = nil, filter = nil, limit = 100, page = 1)
          query_params = QueryParams.new
          if field && filter
            fields = HashSet.new
            fields.add(field)
            expression = Expression.new(field, filter, ExpressionType.const_get('EQUALS'))
            query_filter = Filter.new(expression)
            query_params.setFilter(query_filter)
          end
          query_params.setPageSize(limit)
          query_params.setPage(page)
          query_service.queryReferences(QueryReferenceType.const_get(type), query_params)
        end

        def public_network(name)
          network_ref = admin_client.getExternalNetworkRefByName(name)
          PublicNetwork.new(client: client, ref: network_ref)
        end

        def public_network_ref(name)
          q = query('EXTERNALNETWORK', QueryNetworkField.const_get('NAME'), name)
          q.getReferences.first
        end

        def create_org(name, full_name)
          admin_org_type = AdminOrgType.new
          org_settings = OrgSettingsType.new
          org_profile(name, full_name, admin_org_type)
          populate_org_settings(org_settings)
          admin_org_type.setSettings(org_settings)
          admin_client.createAdminOrg(admin_org_type)
        end

        def create_user(org, username, password, email)
          admin_org = admin_org(org)
          user = UserType.new
          user.setName(username)
          user.setPassword(password)
          user.setIsEnabled(true)
          user.setRole(admin_client.getRoleRefByName('Organization Administrator'))
          user.setFullName(username)
          user.setEmailAddress(email)
          admin_org.createUser(user)
          admin_org.getTasks.each do |task|
            task.waitForTask(0, 1000)  # No Timeout, poll every half a second
          end
        end

        # Rename and move private functions to datacenter class

        def create_datacenter(org, name, pvdc, network_pool, network_quota, quotas, reservations, capacity)
          admin_org = admin_org(org)
          new_admin_vdc = new_admin_vdc(name, pvdc, quotas, reservations, capacity, network_pool, network_quota)
          admin_vdc = admin_org.createAdminVdc(new_admin_vdc)
          admin_vdc.getTasks.each do |task|
            task.waitForTask(0, 1000)  # No Timeout, poll every half a second
          end
        end

        def add_router(org, vdc, router_request)
          admin_vdc = admin_vdc(org, vdc)
          edge_gateway = admin_vdc.createEdgeGateway(router_request)
          edge_gateway.getTasks.each do |task|
            task.waitForTask(0, 1000)  # No Timeout, poll every half a second
          end
        end

        def admin_router(org, vdc, router_name)
          admin_vdc = admin_vdc(org, vdc)
          router_ref = admin_vdc.getEdgeGatewayRefs.getReferences.find { |ref| ref.name == router_name }
          Router.new(client: client, ref: router_ref)
        end

        private

        def query_service
          client.getQueryService
        end

        def admin_client
          client.getVcloudAdmin
        end

        def admin_org(org)
          org_ref = admin_client.getAdminOrgRefsByName.get(org)
          AdminOrganization.getAdminOrgByReference(client, org_ref)
        end

        def admin_vdc(org, vdc)
          admin_org = admin_org(org)
          vdc_ref = admin_org.getAdminVdcRefsByName.get(vdc)
          AdminVdc.getAdminVdcByReference(client, vdc_ref)
        end

        # rubocop:disable Metrics/MethodLength
        def new_admin_vdc(name, pvdc, quotas, reservations, capacity, network_pool, network_quota)
          # Split this into seperate functions
          admin_vdc = CreateVdcParamsType.new
          admin_vdc.setName(name)
          admin_vdc.setDescription('An OVDC!')
          admin_vdc.setNetworkQuota(quotas[:networks])
          admin_vdc.setNicQuota(quotas[:nics])
          admin_vdc.setAllocationModel(AllocationModelType.const_get('ALLOCATIONVAPP').value)
          admin_vdc.setComputeCapacity(compute_capacity(capacity))
          admin_vdc.setIsEnabled(true)
          admin_vdc.setResourceGuaranteedCpu(reservations[:cpu])
          admin_vdc.setResourceGuaranteedMemory(reservations[:ram])
          admin_vdc.setIsThinProvision(true)

          # Set Provider DC
          provider_vdc_ref = admin_client.getProviderVdcRefByName(pvdc)
          admin_vdc.setProviderVdcReference(provider_vdc_ref)
          provider_vdc = ProviderVdc.getProviderVdcByReference(client, provider_vdc_ref)

          # Set Network Pool
          net_pool_ref = provider_vdc.getVMWNetworkPoolRefByName(network_pool)
          admin_vdc.setNetworkPoolReference(net_pool_ref)
          admin_vdc.setNetworkQuota(network_quota)

          # Storage Profile
          vdc_storage_profile = VdcStorageProfileParamsType.new
          vdc_storage_profile.setDefault(true)
          vdc_storage_profile.setEnabled(true)
          vdc_storage_profile.setLimit(0)
          vdc_storage_profile.setUnits('MB')
          provider_vdc_storage_profile_ref = provider_vdc.getProviderVdcStorageProfileRefs.iterator.next
          vdc_storage_profile.setProviderVdcStorageProfile(provider_vdc_storage_profile_ref)
          admin_vdc.getVdcStorageProfile.add(vdc_storage_profile)
          admin_vdc
        end

        def compute_capacity(capacity)
          compute_capacity = ComputeCapacityType.new
          compute_capacity.setCpu(capacity(capacity[:cpu]))
          compute_capacity.setMemory(capacity(capacity[:ram]))
          compute_capacity
        end

        def capacity(capacity)
          capacity_with_usage = CapacityWithUsageType.new
          capacity_with_usage.setAllocated(capacity[:allocated])
          capacity_with_usage.setLimit(capacity[:limit])
          capacity_with_usage.setUsed(capacity[:used])
          capacity_with_usage.setOverhead(capacity[:overhead])
          capacity_with_usage.setUnits(capacity[:units])
          capacity_with_usage
        end

        def org_profile(name, full_name, admin_org_type)
          admin_org_type.setFullName(full_name)
          admin_org_type.setDescription('Created using MYST')
          admin_org_type.setName(name)
          admin_org_type.setIsEnabled(true)
        end

        def populate_org_settings(org_settings)
          org_general_settings_type = OrgGeneralSettingsType.new

          org_general_settings_type.setCanPublishCatalogs(false)

          org_email_settings = OrgEmailSettingsType.new
          org_email_settings.setIsDefaultSmtpServer(true)
          org_email_settings.setFromEmailAddress('maintainers@r3labs.io')
          org_email_settings.setDefaultSubjectPrefix('Vcloud Organisation')
          org_email_settings.getAlertEmailTo.add('maintainers@r3labs.io')
          org_settings.setOrgEmailSettings(org_email_settings)

          # policies
          org_general_settings_type.setDeployedVMQuota(100)
          org_general_settings_type.setStoredVmQuota(0)
          org_settings.setOrgGeneralSettings(org_general_settings_type)
          org_lease_settings = OrgLeaseSettingsType.new
          org_lease_settings.setDeploymentLeaseSeconds(0)
          org_lease_settings.setStorageLeaseSeconds(0)
          org_settings.setVAppLeaseSettings(org_lease_settings)
        end
      end
    end
  end
end
