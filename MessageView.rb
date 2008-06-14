#
#  MessageView.rb
#  starjour
#
#  Created by Dr Nic on 14/06/08.
#  Copyright (c) 2008 Dr Nic Academy Pty Ltd. All rights reserved.
#

require 'osx/cocoa'

class MessageView <  OSX::NSView
  include OSX
  
  def initWithFrame(frame)
    super_initWithFrame(frame)
    # Initialization code here.
    return self
  end

  def drawRect(rect)
    # NSColor.lightGrayColor.set
    # NSRectFill(bounds)

    super_drawRect rect
  end

end
