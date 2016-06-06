# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class AttachedStorage
        attr_reader :ref, :disk, :size, :id, :client

        def initialize(args)
          @ref = args[:ref]
          @client = args[:client]
          @size = args[:size]
          @id = args[:id]

          if ref
            load
          elsif size
            instantiate
          end
        end

        def load
          @disk = VirtualDisk.getVirtualDiskByReference(client, ref)
          # Add values for this
          @size = nil
          @id = nil
        end

        def instantiate
          # BusSubType.const_get("PARA_VIRTUAL")
          @disk = VirtualDisk.new(size, BusType.const_get('SCSI'), BusSubType.const_get('LSI_LOGIC'), 0, id)
        end
      end
    end
  end
end
