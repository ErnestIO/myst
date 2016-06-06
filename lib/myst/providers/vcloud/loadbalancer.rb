# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      # Change to LoadBalancerPool

      class LoadBalancer
        attr_reader :gateway_features, :load_balancer

        def initialize(args = {})
          # Must be created with at least one server in pool!
          return unless args[:gateway_config]

          gateway = GatewayType.new
          gateway.setConfiguration(args[:gateway_config])
          @gateway_features = gateway.getConfiguration.getEdgeGatewayServiceConfiguration
          gateway_features.getNetworkService.select { |service| puts service.getName.toString }
          @load_balancer = gateway_features.getNetworkService.find do |service|
            service.getName.toString == '{http://www.vmware.com/vcloud/v1.5}LoadBalancerService'
          end.getValue
        end

        def instantiate
          # Split contents of function out
          @gateway_features = GatewayFeaturesType.new
          object_factory = ObjectFactory.new
          @load_balancer = LoadBalancerServiceType.new
          load = object_factory.createLoadBalancerService(load_balancer)
          gateway_features.getNetworkService.add(load)
        end

        def pool(name)
          load_balancer.getPool # redundant? definitely
          load_balancer.getPool.find { |lb| lb.name == name }
        end

        def servers(pool)
          pool.getMember.map(&:ipAddress)
        end

        def add_pool(name, service, healthcheck, servers)
          pool = LoadBalancerPoolType.new
          pool.setDescription('Pool Desc')
          pool.setName(name)
          pool.setOperational(true)
          lb_pool_health_check = LBPoolHealthCheckType.new
          lb_pool_health_check.setHealthThreshold(healthcheck[:health_threshold])
          lb_pool_health_check.setUnhealthThreshold(healthcheck[:unhealth_threshold])
          lb_pool_health_check.setInterval(healthcheck[:interval])
          lb_pool_health_check.setMode(healthcheck[:mode])
          lb_pool_health_check.setTimeout(healthcheck[:timeout])
          lb_pool_health_check.setUri(healthcheck[:uri])
          lb_pool_service_port = LBPoolServicePortType.new
          lb_pool_service_port.setIsEnabled(true)
          lb_pool_service_port.setAlgorithm(service[:algorithm])
          lb_pool_service_port.setHealthCheckPort(service[:healthcheck_port])
          lb_pool_service_port.getHealthCheck.add(lb_pool_health_check)
          lb_pool_service_port.setProtocol(service[:protocol])
          lb_pool_service_port.setPort(service[:port])
          pool.getServicePort.add(lb_pool_service_port)
          servers.each do |server|
            add_server(pool, server[:ip_address], server[:weight], service[:port], service[:protocol])
          end
          load_balancer.getPool.add(pool)
        end

        def add_server(pool, ip_address, weight, port, protocol)
          lb_pool_service_port = LBPoolServicePortType.new
          lb_pool_service_port.setHealthCheckPort(port)
          lb_pool_service_port.setProtocol(protocol)
          lb_pool_service_port.setPort(port)
          lb_pool_member = LBPoolMemberType.new
          lb_pool_member.setIpAddress(ip_address)
          lb_pool_member.setWeight(weight)
          lb_pool_member.getServicePort.add(lb_pool_service_port)
          pool.getMember.add(lb_pool_member)
        end

        # public_network is a reference type.
        def add_vip(pool, name, ip_address, public_network, persistence, protocol, port)
          load_balancer_virtual_server = LoadBalancerVirtualServerType.new
          load_balancer_virtual_server.setDescription('desc')
          load_balancer_virtual_server.setIsEnabled(true)

          load_balancer_virtual_server.setIpAddress(ip_address)
          load_balancer_virtual_server.setName(name)
          load_balancer_virtual_server.setPool(pool)
          load_balancer_virtual_server.setLogging(true)
          load_balancer_virtual_server.setInterface(public_network)

          lb_virtual_server_service_profile = LBVirtualServerServiceProfileType.new
          lb_virtual_server_service_profile.setProtocol(protocol)
          lb_virtual_server_service_profile.setPort(port)
          lb_virtual_server_service_profile.setIsEnabled(true)

          lb_persistence = LBPersistenceType.new
          if persistence
            lb_persistence.setCookieMode('INSERT')
            lb_persistence.setCookieName('CookieName2')
            lb_persistence.setMethod('COOKIE')
          end
          lb_virtual_server_service_profile.setPersistence(lb_persistence)

          load_balancer_virtual_server.getServiceProfile.add(lb_virtual_server_service_profile)
          load_balancer.getVirtualServer.add(load_balancer_virtual_server)
          load_balancer.setIsEnabled(true)
        end

        def remove_server(pool, ip_address)
          index = nil
          pool.getMember.each_with_index { |m, i| index = i if m.ipAddress == ip_address }
          pool.getMember.remove(index)
        end
      end
    end
  end
end
