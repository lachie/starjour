#
#  PasteJour.rb
#  starjour
#
#  Created by Lachie Cox on 21/06/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'Jour'

class PasteJour < OSX::NSObject
  include Jour
  service_name 'paste'
  nib_name 'PasteJour'
  
  kvc_accessor :pasted

  def setup
    (from, to) = *@service.name.split('-')
  
    @text = "from #{from}"
    @text << " to #{to}" if to
  end
  
  def paste(sender)
    # self.pasted = ` '#{@service.name}'`
    system("/usr/bin/env pastejour | pbcopy")
  end
end
