# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

include Java
require 'java'
require_relative 'vcloud/VMware-vCloudDirector-JavaSDK/SDK-5.5.0/libs/amqp-client-2.8.6.jar'
require_relative 'vcloud/VMware-vCloudDirector-JavaSDK/SDK-5.5.0/libs/commons-codec-1.6.jar'
require_relative 'vcloud/VMware-vCloudDirector-JavaSDK/SDK-5.5.0/libs/commons-logging-1.1.1.jar'
require_relative 'vcloud/VMware-vCloudDirector-JavaSDK/SDK-5.5.0/libs/httpclient-4.2.jar'
require_relative 'vcloud/VMware-vCloudDirector-JavaSDK/SDK-5.5.0/libs/httpcore-4.2.jar'
require_relative 'vcloud/VMware-vCloudDirector-JavaSDK/SDK-5.5.0/rest-api-schemas-5.5.0.jar'
require_relative 'vcloud/VMware-vCloudDirector-JavaSDK/SDK-5.5.0/vcloud-java-sdk-5.5.0.jar'

module Myst
  module Providers
    module VCloud
      import 'java.io.IOException'
      import 'java.security.KeyManagementException'
      import 'java.security.KeyStoreException'
      import 'java.security.NoSuchAlgorithmException'
      import 'java.security.UnrecoverableKeyException'
      import 'java.security.cert.CertificateException'
      import 'java.util.List'
      import 'java.util.concurrent.TimeoutException'
      import 'java.util.HashSet'
      import 'java.util.LinkedHashMap'
      import 'java.util.Set'
      import 'java.util.logging.Level'

      import 'com.vmware.vcloud.api.rest.schema.CatalogType'
      import 'com.vmware.vcloud.api.rest.schema.CapacityWithUsageType'
      import 'com.vmware.vcloud.api.rest.schema.ComputeCapacityType'
      import 'com.vmware.vcloud.api.rest.schema.CreateVdcParamsType'
      import 'com.vmware.vcloud.api.rest.schema.GatewayConfigurationType'
      import 'com.vmware.vcloud.api.rest.schema.GatewayInterfaceType'
      import 'com.vmware.vcloud.api.rest.schema.GatewayInterfacesType'
      import 'com.vmware.vcloud.api.rest.schema.GatewayType'
      import 'com.vmware.vcloud.api.rest.schema.IpRangeType'
      import 'com.vmware.vcloud.api.rest.schema.IpRangesType'
      import 'com.vmware.vcloud.api.rest.schema.IpScopeType'
      import 'com.vmware.vcloud.api.rest.schema.IpScopesType'
      import 'com.vmware.vcloud.api.rest.schema.NetworkConfigurationType'
      import 'com.vmware.vcloud.api.rest.schema.OrgEmailSettingsType'
      import 'com.vmware.vcloud.api.rest.schema.OrgGeneralSettingsType'
      import 'com.vmware.vcloud.api.rest.schema.OrgLeaseSettingsType'
      import 'com.vmware.vcloud.api.rest.schema.OrgSettingsType'
      import 'com.vmware.vcloud.api.rest.schema.OrgVdcNetworkType'
      import 'com.vmware.vcloud.api.rest.schema.ReferenceType'
      import 'com.vmware.vcloud.api.rest.schema.SubnetParticipationType'
      import 'com.vmware.vcloud.api.rest.schema.UserType'
      import 'com.vmware.vcloud.api.rest.schema.VdcStorageProfileParamsType'
      import 'com.vmware.vcloud.api.rest.schema.ControlAccessParamsType'
      import 'com.vmware.vcloud.api.rest.schema.VAppNetworkConfigurationType'
      import 'com.vmware.vcloud.api.rest.schema.NetworkConfigSectionType'
      import 'com.vmware.vcloud.api.rest.schema.SourcedVmInstantiationParamsType'
      import 'com.vmware.vcloud.api.rest.schema.InstantiationParamsType'
      import 'com.vmware.vcloud.api.rest.schema.InstantiateVAppTemplateParamsType'
      import 'com.vmware.vcloud.api.rest.schema.ovf.MsgType'
      import 'com.vmware.vcloud.api.rest.schema.ObjectFactory'
      import 'com.vmware.vcloud.api.rest.schema.AdminOrgType'
      import 'com.vmware.vcloud.api.rest.schema.GatewayFeaturesType'
      import 'com.vmware.vcloud.api.rest.schema.LoadBalancerServiceType'
      import 'com.vmware.vcloud.api.rest.schema.LoadBalancerPoolType'
      import 'com.vmware.vcloud.api.rest.schema.LBPoolHealthCheckType'
      import 'com.vmware.vcloud.api.rest.schema.LBPoolServicePortType'
      import 'com.vmware.vcloud.api.rest.schema.LoadBalancerVirtualServerType'
      import 'com.vmware.vcloud.api.rest.schema.LBVirtualServerServiceProfileType'
      import 'com.vmware.vcloud.api.rest.schema.LBPoolMemberType'
      import 'com.vmware.vcloud.api.rest.schema.LBPersistenceType'

      import 'com.vmware.vcloud.sdk.Task'
      import 'com.vmware.vcloud.sdk.VCloudException'
      import 'com.vmware.vcloud.sdk.Response'
      import 'com.vmware.vcloud.sdk.VcloudClient'
      import 'com.vmware.vcloud.sdk.Organization'
      import 'com.vmware.vcloud.sdk.Vdc'
      import 'com.vmware.vcloud.sdk.AllocatedIpAddress'
      import 'com.vmware.vcloud.sdk.Vapp'
      import 'com.vmware.vcloud.sdk.VappTemplate'
      import 'com.vmware.vcloud.sdk.CatalogItem'
      import 'com.vmware.vcloud.sdk.VappNetwork'
      import 'com.vmware.vcloud.sdk.Metadata'
      import 'com.vmware.vcloud.sdk.TaskList'
      import 'com.vmware.vcloud.sdk.Catalog'
      import 'com.vmware.vcloud.sdk.OrgVdcNetwork'
      import 'com.vmware.vcloud.sdk.VM'

      import 'com.vmware.vcloud.sdk.admin.AdminOrganization'
      import 'com.vmware.vcloud.sdk.admin.AdminVdc'
      import 'com.vmware.vcloud.sdk.admin.ProviderVdc'
      import 'com.vmware.vcloud.sdk.admin.ExternalNetwork'
      import 'com.vmware.vcloud.sdk.admin.EdgeGateway'
      import 'com.vmware.vcloud.sdk.admin.VcloudAdmin'

      import 'com.vmware.vcloud.sdk.constants.AllocationModelType'
      import 'com.vmware.vcloud.sdk.constants.FenceModeValuesType'
      import 'com.vmware.vcloud.sdk.constants.GatewayBackingConfigValuesType'
      import 'com.vmware.vcloud.sdk.constants.GatewayEnums'

      # Disks
      import 'com.vmware.vcloud.sdk.VirtualDisk'
      import 'com.vmware.vcloud.sdk.constants.BusSubType'
      import 'com.vmware.vcloud.sdk.constants.BusType'

      # Nics
      import 'com.vmware.vcloud.sdk.VirtualNetworkCard'
      import 'com.vmware.vcloud.sdk.constants.IpAddressAllocationModeType'
      import 'com.vmware.vcloud.sdk.constants.NetworkAdapterType'

      import 'com.vmware.vcloud.sdk.Expression'
      import 'com.vmware.vcloud.sdk.Filter'
      import 'com.vmware.vcloud.api.rest.schema.DhcpServiceType'

      import 'com.vmware.vcloud.api.rest.schema.AllocatedIpAddressType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAllocatedExternalAddressRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminAllocatedExternalAddressRecordType'
      import 'com.vmware.vcloud.api.rest.schema.AllocatedIpAddressesType'
      import 'com.vmware.vcloud.sdk.AllocatedIpAddress'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAllocatedExternalAddressField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminAllocatedExternalAddressField'
      import 'com.vmware.vcloud.sdk.constants.AllocatedIpAddressAllocationType'

      # Firewall Crap
      import 'com.vmware.vcloud.api.rest.schema.FirewallServiceType'
      import 'com.vmware.vcloud.api.rest.schema.FirewallRuleType'
      import 'com.vmware.vcloud.api.rest.schema.FirewallRuleProtocols'
      import 'com.vmware.vcloud.sdk.constants.FirewallDirectionType'
      import 'com.vmware.vcloud.sdk.constants.FirewallPolicyType'

      # Nat Crap
      import 'com.vmware.vcloud.api.rest.schema.NatRuleType'
      import 'com.vmware.vcloud.api.rest.schema.NatServiceType'
      import 'com.vmware.vcloud.api.rest.schema.GatewayFeaturesType'
      import 'com.vmware.vcloud.api.rest.schema.GatewayInterfaceType'
      import 'com.vmware.vcloud.api.rest.schema.GatewayNatRuleType'

      # Query Types
      import 'com.vmware.vcloud.sdk.constants.query.ExpressionType'
      import 'com.vmware.vcloud.sdk.constants.query.SortType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminVdcRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVAppOrgNetworkRelationRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultGroupRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminCatalogRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultRoleRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultMediaRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultOrgVdcStorageProfileRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminOrgVdcStorageProfileRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVMRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultServiceOfferingRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultStrandedUserRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminFileDescriptorRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultStrandedItemRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultApiFilterRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultHostRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultOrgVdcResourcePoolRelationRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminServiceRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminEventRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminTaskRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultResourcePoolVMRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVAppTemplateRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminOrgNetworkRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultLicensingReportSampleRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultResourceClassActionRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultCatalogItemRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVMWProviderVdcRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultCellRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultServiceLinkRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminApiDefinitionRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminVAppTemplateRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAllocatedExternalAddressRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVAppNetworkRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminGroupRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultRecordsType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAclRuleRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultNetworkRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVdcServiceOfferingRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultNetworkPoolRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultUserRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultDiskRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultApiDefinitionRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVAppOrgVdcNetworkRelationRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultOrgNetworkRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminUserRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVAppRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultResourceClassRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultProviderVdcResourcePoolRelationRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminServiceOfferingInstanceRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultProviderVdcStorageProfileRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVmDiskRelationRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultEdgeGatewayRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultCatalogRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultEventRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultLicensingVirtualMachineRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultBlockingTaskRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultFileDescriptorRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminCatalogItemRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryListType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminAllocatedExternalAddressRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminMediaRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminVmDiskRelationRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminVMRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultServiceExtensionRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultPortgroupRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminVAppNetworkRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultLicensingReportRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultOrgRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultRightRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultDvSwitchRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultExternalLocalizationRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminVAppRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminShadowVMRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVirtualCenterRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultTaskRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultVmServiceOfferingInstanceRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultServiceResourceRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultOrgVdcNetworkRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminEventCBMRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultLicensingManagedServerRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultDatastoreRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultServiceOfferingInstanceRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultDatastoreProviderVdcRelationRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultConditionRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultServiceRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultAdminDiskRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultOrgVdcRecordType'
      import 'com.vmware.vcloud.api.rest.schema.QueryResultResourcePoolRecordType'
      import 'com.vmware.vcloud.sdk.constants.query.QueryServiceLinkField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryApiDefinitionField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryEventField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryReferenceType'
      import 'com.vmware.vcloud.sdk.constants.query.QueryApiFilterField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryStrandedItemField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminApiDefinitionField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryOrgVdcResourcePoolRelationField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryOrgVdcNetworkField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminUserField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryDatastoreField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryVAppNetworkField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryServiceField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryVAppTemplateField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryOrgField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminGroupField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAllocatedExternalAddressField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryOrgVdcField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryPortgroupField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAclRuleField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryBlockingTaskField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryProviderVdcResourcePoolRelationField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryReferenceField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryCatalogItemField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryOrgVdcGatewayField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryVAppOrgVdcNetworkRelationField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryResourcePoolField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryTaskField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryRecordType'
      import 'com.vmware.vcloud.sdk.constants.query.QueryVAppOrgNetworkRelationField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminServiceField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryExternalLocalizationField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminOrgVdcStorageProfileField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryFileDescriptorField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminOrgNetworkField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminVAppTemplateField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryRightField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminVAppField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryVAppField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryCatalogField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryDvSwitchField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryNetworkField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryDatastoreProviderVdcRelationField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryServiceResourceField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryConditionField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminVAppNetworkField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryUserField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminCatalogField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminVdcField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryVirtualCenterField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminCatalogItemField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminVmDiskRelationField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryResourcePoolVMField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminMediaField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryCellField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryVMField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryEdgeGatewayField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminVMField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryGroupField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryVmDiskRelationField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryMediaField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminEventField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminTaskField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryNetworkPoolField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminFileDescriptorField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryVMWProviderVdcField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryDiskField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryOrgNetworkField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryHostField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminDiskField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryResourceClassActionField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminAllocatedExternalAddressField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryAdminShadowVMField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryOrgVdcStorageProfileField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryProviderVdcStorageProfileField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryRoleField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryResourceClassField'
      import 'com.vmware.vcloud.sdk.constants.query.QueryStrandedUserField'

      import 'com.vmware.vcloud.sdk.constants.UndeployPowerActionType'
      import 'com.vmware.vcloud.sdk.admin.extensions.ExtensionQueryService'
      import 'com.vmware.vcloud.sdk.admin.extensions.service.ExtensionServiceConstants$QueryConstants'
      import 'com.vmware.vcloud.sdk.admin.AdminQueryService'
      import 'com.vmware.vcloud.sdk.QueryService'
      import 'com.vmware.vcloud.sdk.VcloudConstants$QueryConstants$SpecializedQuery'
      import 'com.vmware.vcloud.sdk.QueryParams'
      import 'com.vmware.vcloud.sdk.VcloudConstants$QueryConstants$Params'

      # Client
      import 'com.vmware.vcloud.sdk.constants.Version'

      class CustomSSLSocketFactory
        import 'javax.net.ssl.SSLContext'
        import 'javax.net.ssl.TrustManager'
        import 'javax.net.ssl.TrustManagerFactory'
        import 'org.apache.http.conn.ssl.SSLSocketFactory'

        attr_reader :sslContext

        def initialize
          @sslContext = SSLContext.getInstance('TLS')
          @sslContext.init(nil, nil, nil)
          SSLContext.setDefault(@sslContext)
        end

        def getInstance
          SSLSocketFactory.new(sslContext)
        end
      end
    end
  end
end

# Require additional classes...

require_relative 'vcloud/image.rb'
require_relative 'vcloud/router.rb'
require_relative 'vcloud/loadbalancer.rb'
require_relative 'vcloud/firewall.rb'
require_relative 'vcloud/nat.rb'
require_relative 'vcloud/networkinterface.rb'
require_relative 'vcloud/publicnetwork.rb'
require_relative 'vcloud/privatenetwork.rb'
require_relative 'vcloud/attachedstorage.rb'
require_relative 'vcloud/computeinstance.rb'
require_relative 'vcloud/datacenter.rb'
require_relative 'vcloud/provider.rb'
