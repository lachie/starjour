#
#  AppController.rb
#  starjour
#
#  Created by Dr Nic on 14/06/08.
#  Copyright (c) 2008 Dr Nic Academy Pty Ltd. All rights reserved.
#

require 'osx/cocoa'

class AppController < OSX::NSObject
  def applicationShouldTerminateAfterLastWindowClosed(app)
    true
  end
end
