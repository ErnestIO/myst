# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class NetworkInterface
        attr_reader :ref, :interface, :network, :ipaddress, :primary, :id, :client

        def initialize(args)
          @ref = args[:ref]
          @client = args[:client]
          @network = args[:network]
          @ipaddress = args[:ipaddress]
          @primary = args[:primary]
          @id = args[:id]

          if ref
            load
          else
            instantiate
          end
        end

        def load
          @interface = VirutalNetworkCard.getVirtualNetworkCardByReference(client, ref)
          # Add in values later
          @network = nil
          @ipaddress = nil
          @primary = nil
          @id = nil
        end

        def instantiate
          @interface = VirtualNetworkCard.new(id,
                                              true,
                                              network,
                                              primary,
                                              IpAddressAllocationModeType.const_get('MANUAL'),
                                              ipaddress,
                                              NetworkAdapterType.const_get('VMXNET3'))
        end
      end
    end
  end
end
