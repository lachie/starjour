#
#  AppDelegate.rb
#  starjour
#
#  Created by Lachie Cox on 13/06/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class AppDelegate < OSX::NSObject
  
  def applicationShouldTerminateAfterLastWindowClosed(app)
    true
  end
	
end
