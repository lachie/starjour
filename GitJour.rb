#
#  GitJour.rb
#  starjour
#
#  Created by Lachie Cox on 21/06/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

  
require 'osx/cocoa'
require 'Jour'

class GitJour < OSX::NSObject
  include Jour

  service_name 'git'
  
  def setup
    @text = @service.name
  end

end
