# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class Firewall
        attr_reader :gateway_features, :firewall

        def initialize(args = {})
          return unless args[:gateway_config]

          gateway = GatewayType.new
          gateway.setConfiguration(args[:gateway_config])
          @gateway_features = gateway.getConfiguration.getEdgeGatewayServiceConfiguration
          @firewall = gateway_features.getNetworkService.find do |service|
            service.getName.toString == '{http://www.vmware.com/vcloud/v1.5}FirewallService'
          end.getValue
        end

        def instantiate
          @gateway_features = GatewayFeaturesType.new
          object_factory = ObjectFactory.new
          @firewall = FirewallServiceType.new

          firewall.setIsEnabled(true)
          firewall.setDefaultAction(FirewallPolicyType.const_get('DROP').value)
          firewall.setLogDefaultAction(false)

          fw = object_factory.createFirewallService(firewall)
          gateway_features.getNetworkService.add(fw)
        end

        def purge_rules
          firewall.getFirewallRule.clear
        end

        # Accepts a hash for each
        def add_rule(source, destination, protocol, _policy = 'ALLOW')
          proto = proto(protocol)
          rule = FirewallRuleType.new
          rule.setIsEnabled(true)
          rule.setSourceIp(source[:ip])
          rule.setSourcePort(source[:port])
          rule.setSourcePortRange(source[:port_range])
          rule.setDestinationIp(destination[:ip])
          rule.setDestinationPortRange(destination[:port_range])
          rule.setProtocols(proto)
          firewall.getFirewallRule.add(rule)
        end

        private

        def proto(protocol)
          proto = FirewallRuleProtocols.new
          case protocol
          when :tcp
            proto.setTcp(true)
          when :udp
            proto.setUdp(true)
          when :icmp
            proto.setUdp(true)
          when :any
            proto.setAny(true)
          end
          proto
        end
      end
    end
  end
end
