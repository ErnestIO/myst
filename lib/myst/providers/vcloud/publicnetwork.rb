# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class PublicNetwork
        attr_reader :ref, :client, :network

        def initialize(args)
          @ref = args[:ref]
          @client = args[:client]
          load if ref
        end

        def load
          @network = ExternalNetwork.getExternalNetworkByReference(client, ref)
        end
      end
    end
  end
end
