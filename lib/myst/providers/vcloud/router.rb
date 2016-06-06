# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class Router
        attr_reader :ref, :client, :edge_gateway

        def initialize(args = {})
          @ref = args[:ref]
          @client = args[:client]
          load if ref
        end

        def load
          @edge_gateway = EdgeGateway.getEdgeGatewayByReference(client, ref)
        end

        def instantiate(name, external_network, size)
          gateway_params = gateway_params(name)
          gateway_config = gateway_configuration(size)
          gateway_interface = gateway_interface(external_network)
          gateway_interfaces.getGatewayInterface.add(gateway_interface)
          gateway_config.setGatewayInterfaces(gateway_interfaces)
          gateway_params.setConfiguration(gateway_config)
          gateway_params
        end

        def add_loadbalancer(loadbalancer_request)
          update_services(loadbalancer_request)
        end

        def loadbalancer
          LoadBalancer.new(gateway_config: edge_gateway.getResource.getConfiguration)
        end

        def firewall
          Firewall.new(gateway_config: edge_gateway.getResource.getConfiguration)
        end

        def nat
          Nat.new(gateway_config: edge_gateway.getResource.getConfiguration)
        end

        def interface_ip(network_name)
          interface(network_name).getSubnetParticipation.first.getIpAddress
        end

        def interface_network_reference(network_name)
          interface(network_name).getNetwork
        end

        def interface_ip_allocations(network_name)
          # Just filthy
          ip_addresses = []
          unless interface(network_name).getSubnetParticipation.first.getIpRanges.nil?
            interface(network_name).getSubnetParticipation.first.getIpRanges.getIpRange.each do |range|
              start_address = range.getStartAddress
              end_address = range.getEndAddress
              rng = start_address.split('.')
              (rng.last.to_i..end_address.split('.').last.to_i).to_a.each do |ip|
                ip_addresses << rng.take(3).push(ip).join('.')
              end
            end
          end
          ip_addresses
        end

        def allocate_external_ip(network_name, ip, gateway = nil, netmask = nil)
          gateway_resource = edge_gateway.getResource
          gateway_config = gateway_resource.getConfiguration
          interfaces = gateway_config.getGatewayInterfaces
          interface_collection = interfaces.getGatewayInterface
          interface = interface_collection.find { |i| i.getName == network_name }
          interface_index = interface_collection.index(interface)
          subnet_participations = interface.getSubnetParticipation

          # unless subnet_participations.length == 0
          #  puts "no subnet_allocations"
          subnet_participation = SubnetParticipationType.new
          subnet_participation.setGateway(gateway)
          subnet_participation.setNetmask(netmask)
          ip_ranges = IpRangesType.new
          # else
          #  subnet_participation = subnetparticipations.first
          #  ip_ranges = subnet_participation.getIpRanges()
          # end

          ip_range = IpRangeType.new
          ip_range.setStartAddress(ip)
          ip_range.setEndAddress(ip)
          ip_ranges.getIpRange.add(ip_range)

          subnet_participation.setIpRanges(ip_ranges)

          # if subnet_participations.length == 0
          subnet_participations.add(subnet_participation)
          # else
          #  subnet_participations.set(int, subnet_participation)
          # end

          interface_collection.set(interface_index, interface)
          gateway_config.setGatewayInterfaces(interfaces)
          gateway_resource.setConfiguration(gateway_config)

          task = edge_gateway.updateEdgeGateway(gateway_resource)
          task.waitForTask(0, 1000)
        end

        # dns = Array
        def dhcp(start_range, end_range, dns)
          # emergency hack
          gateway = GatewayType.new
          gateway.setConfiguration(edge_gateway.getResource.getConfiguration)
          gateway_features = gateway.getConfiguration.getEdgeGatewayServiceConfiguration

          object_factory = ObjectFactory.new
          dhcp_service = DhcpServiceType.new
          dhcp_service.setDefaultLeaseTime(0)
          dhcp_service.setIpRange(ip_range(start_range, end_range))
          dhcp_service.setIsEnabled(true)
          dhcp_service.setPrimaryNameServer(dns[0])
          dhcp_service.setSubMask('255.255.255.0')
          dhcp_service.setDefaultLeaseTime(3600)
          dhcp_service.setMaxLeaseTime(7200)
          dhcp = object_factory.createDhcpService(dhcp_service)

          gateway_features.getNetworkService.add(dhcp)
          task = edge_gateway.configureServices(gateway_features)
          task.waitForTask(0, 1000)
        end

        def update_service(service)
          task = edge_gateway.configureServices(service.gateway_features)
          task.waitForTask(0, 1000)
        end

        def wait_for_tasks
          edge_gateway.getTasks.each do |task|
            task.waitForTask(0, 1000)  # No Timeout, poll every half a second
          end
        end

        private

        def interface(network_name)
          gateway_resource = edge_gateway.getResource
          gateway_config = gateway_resource.getConfiguration
          interfaces = gateway_config.getGatewayInterfaces
          interface_collection = interfaces.getGatewayInterface
          interface_collection.find { |i| i.getName == network_name }
        end

        def ip_range(start_range, end_range)
          ip_range = IpRangeType.new
          ip_range.setStartAddress(start_range)
          ip_range.setEndAddress(end_range)
          ip_range
        end

        def gateway_params(name)
          gateway_params = GatewayType.new
          gateway_params.setName(name)
          gateway_params.setDescription(name)
          gateway_params
        end

        def gateway_configuration(size)
          gateway_config = GatewayConfigurationType.new
          gateway_config.setGatewayBackingConfig(GatewayBackingConfigValuesType.const_get(size).value)
          gateway_config
        end

        def gateway_interface(external_network)
          gateway_interface = GatewayInterfaceType.new
          gateway_interface.setDisplayName('gateway interface')
          gateway_interface.setNetwork(external_network.ref)
          gateway_interface.setInterfaceType(GatewayEnums.const_get('UPLINK').value)
          gateway_interface.setUseForDefaultRoute(true)
          gateway_interface
        end

        def gateway_interfaces
          @gateway_interfaces ||= GatewayInterfacesType.new
        end
      end
    end
  end
end
