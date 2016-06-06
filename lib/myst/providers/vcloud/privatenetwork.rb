# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class PrivateNetwork
        attr_reader :ref, :client, :network

        def initialize(args = {})
          @ref = args[:ref]
          @client = args[:client]
          load if ref
        end

        def load
          @network = OrgVdcNetwork.getOrgVdcNetworkByReference(client, ref)
        end

        def instantiate(router, name, ranges, netmask, gateway, dns)
          new_org_vdc_network = org_vdc_network(name)
          new_network_config = network_config
          new_ip_ranges = ip_ranges(ranges[:start_address], ranges[:end_address])
          new_ip_scope = ip_scope(netmask, gateway, dns)
          new_ip_scopes = ip_scopes

          new_ip_scope.setIpRanges(new_ip_ranges)

          new_ip_scopes.getIpScope.add(new_ip_scope)

          new_network_config.setIpScopes(new_ip_scopes)

          new_org_vdc_network.setEdgeGateway(router.ref)
          new_org_vdc_network.setConfiguration(new_network_config)
          new_org_vdc_network
        end

        private

        def org_vdc_network(name)
          org_vdc_network_params = OrgVdcNetworkType.new
          org_vdc_network_params.setName(name)
          org_vdc_network_params.setDescription('Org vdc network')
          org_vdc_network_params
        end

        def network_config
          net_config = NetworkConfigurationType.new
          net_config.setRetainNetInfoAcrossDeployments(true)
          net_config.setFenceMode(FenceModeValuesType.const_get('NATROUTED').value)
          net_config
        end

        def ip_scope(netmask, gateway, dns)
          ip_scope = IpScopeType.new
          ip_scope.setNetmask(netmask)
          ip_scope.setGateway(gateway)
          ip_scope.setIsEnabled(true)
          ip_scope.setDns1(dns[0])
          ip_scope.setDns2(dns[1])
          ip_scope.setIsInherited(true)
          ip_scope
        end

        def ip_scopes
          IpScopesType.new
        end

        def ip_ranges(start_address, end_address)
          ip_ranges = IpRangesType.new
          ip_range_type = IpRangeType.new
          ip_range_type.setStartAddress(start_address)
          ip_range_type.setEndAddress(end_address)
          ip_ranges.getIpRange.add(ip_range_type)
          ip_ranges
        end
      end
    end
  end
end
