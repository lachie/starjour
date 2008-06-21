#
#  AppJour.rb
#  starjour
#
#  Created by Lachie Cox on 21/06/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'Jour'

class AppJour < OSX::NSObject
  include Jour
  
  service_name 'app'
  nib_name 'AppJour'
  
  kvc_accessor :url
  
  def setup
    @text = @service.name
    @url = 'resolving'
  end
  
  def resolved!
    self.url = "http://#{@service.hostName}:#{@service.port}"
    
  end
  
  def open(sender)
    return unless self.url
    system "open '#{self.url}'"
  end
end
