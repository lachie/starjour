#
#  Jour.rb
#  starjour
#
#  Created by Lachie Cox on 21/06/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

module Jour
  
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      kvc_accessor :text
    end
  end
  
  def initWithService(service)
    if init
      puts "starting #{self.class} with #{service.oc_type}"
      @service = service
      setup if respond_to?(:setup)
    end
    self
  end
  
  module ClassMethods
    def service_name(name=nil)
      @service_name = name if name
      @service_name
    end
    
    def nib_name(nib_name=nil)
      self.nib_path OSX::NSBundle.mainBundle.pathForResource_ofType(nib_name,'nib')
    end
    
    def nib_path(nib_path=nil)
      if nib_path
        @nib_path = nib_path
      else
        @nib_path
      end
    end
    
  end
  
  def view?
    begin
      view
      true
    rescue
      false
    end
  end
  
  def view
    unless @view
      raise "no nib path set... set the class nib path first" unless self.class.nib_path
      
      @vc = OSX::NSViewController.alloc.initWithNibName_bundle(nil,nil)
      nib = OSX::NSNib.alloc.initWithContentsOfURL(OSX::NSURL.fileURLWithPath(self.class.nib_path))
      
      nib.instantiateNibWithOwner_topLevelObjects(@vc, nil)
      
      puts "nib... #{@vc}"
      
      @vc.representedObject = self
      @view = @vc.view
    end
    
    @view
  end
  
  def children; [] end
  def leaf; true end
  
  # service resolution
	def netServiceDidResolveAddress(service)
	  resolved! if respond_to?(:resolved!)
  end
  
  def netService_didNotResolve(service,reason)
    puts "netService_didNotResolve #{service_key(service)}"
    p reason
  end
end
