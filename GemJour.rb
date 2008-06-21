#
#  GemJour.rb
#  starjour
#
#  Created by Lachie Cox on 21/06/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'Jour'

class GemJour < OSX::NSObject
  include Jour
  
  service_name 'gem'
  
  def setup
    @text = @service.name
  end
  
  
  # def resolved!
    # system "gem list -r --source=http://#{host.host}:#{host.port}"
  # end
end
