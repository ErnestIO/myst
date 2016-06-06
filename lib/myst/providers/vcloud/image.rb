# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      attr_reader :ref, :client, :template

      class Image
        def initialize(args)
          @ref = args[:ref]
          @client = args[:client]
          load
        end

        def load
          @template = VappTemplate.getVappTemplateByReference(@client, ref)
        end
      end
    end
  end
end
