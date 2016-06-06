# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class Nat
        attr_reader :gateway_features, :nat

        def initialize(args = {})
          return unless args[:gateway_config]

          gateway = GatewayType.new
          gateway.setConfiguration(args[:gateway_config])
          @gateway_features = gateway.getConfiguration.getEdgeGatewayServiceConfiguration
          @nat = gateway_features.getNetworkService.find do |service|
            service.getName.toString == '{http://www.vmware.com/vcloud/v1.5}NatService'
          end.getValue
        end

        def instantiate
          @gateway_features = GatewayFeaturesType.new
          object_factory = ObjectFactory.new

          @nat = NatServiceType.new
          nat.setIsEnabled(true)

          nt = object_factory.createNetworkService(nat)
          gateway_features.getNetworkService.add(nt)
        end

        def purge_rules
          nat.getNatRule.clear
        end

        # Accepts a hash for each
        def add_rule(type, origin, translation, protocol, interface_ref)
          gateway_rule = GatewayNatRuleType.new
          gateway_rule.setProtocol(protocol)
          gateway_rule.setOriginalIp(origin[:ip])
          gateway_rule.setOriginalPort(origin[:port])
          gateway_rule.setTranslatedIp(translation[:ip])
          gateway_rule.setTranslatedPort(translation[:port])
          gateway_rule.setInterface(interface_ref)

          rule = NatRuleType.new
          rule.setIsEnabled(true)
          rule.setRuleType(type)
          rule.setGatewayNatRule(gateway_rule)

          nat.getNatRule.add(rule)
        end
      end
    end
  end
end
