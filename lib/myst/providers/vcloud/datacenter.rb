# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class Datacenter
        attr_reader :ref, :client, :vdc

        def initialize(args)
          @ref = args[:ref]
          @client = args[:client]
          load
        end

        def load
          @vdc = Vdc.getVdcByReference(client, ref)
        end

        def private_network(name)
          network_ref = vdc.getAvailableNetworkRefByName(name)
          PrivateNetwork.new(ref: network_ref, client: client)
        end

        def compute_instances
          vdc.getVappRefs.map(&:getName)
        end

        def compute_instance(name)
          instance_ref = vdc.getVappRefByName(name)
          ComputeInstance.new(ref: instance_ref, client: client)
        end

        def router(name)
          # Has to be a better way?
          router_ref = vdc.getEdgeGatewayRefs.getReferences.find { |ref| ref.name == name }
          Router.new(client: client, ref: router_ref)
        end

        def add_compute_instance(instance, name, network, image)
          vapp = vdc.instantiateVappTemplate(instance.instantiate(name, network, image))
          vapp.getTasks.each do |task|
            task.waitForTask(0, 1000)  # No Timeout, poll every half a second
          end
          instance.ref = vapp.getReference
          instance.load
          instance.name = name
        end

        def add_private_network(private_network_request)
          private_network = vdc.createOrgVdcNetwork(private_network_request)
          private_network.getTasks.each do |task|
            task.waitForTask(0, 1000)  # No Timeout, poll every half a second
          end
        end
      end
    end
  end
end
