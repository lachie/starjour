#
#  ServiceKind.rb
#  starjour
#
#  Created by Lachie Cox on 21/06/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class ServiceKind < OSX::NSObject
  include OSX
  
	attr_reader :name
	attr_reader :klass
	
	attr_reader :children
	kvc_array_accessor :children
	
	def leaf; false end
	
	def self.service_lookup
	  @service_lookup ||= {}	    
  end
	
	def initWithName_andClass(name,klass)
	  if init
	    puts "service kind #{name} with #{klass}"
	    @name  = name
	    @klass = klass
	    @children = NSMutableArray.alloc.init
	    
	    self.class.service_lookup[name] = self
	    @jours = {}
	  end
	  self
  end
  
  def text
    begin
      @klass.service_name
    rescue
      @name
    end.upcase
  end
  
  def service_key(service)
	  service.name.to_ruby + service.oc_type.to_ruby
	end
	
	def self.service_basename(service)
	  service.oc_type.to_ruby[/_([^\.]+)\._tcp/,1]
  end
  
  def service_type
    "_#{name}._tcp"
  end
  
  def self.resolve_path(sc_index,jour_index)
    
  end
  
  def self.found(service)
    puts "found service #{service.oc_type}"
    
    if srv = service_lookup[service_basename(service)]
      srv.found(service)
    end
  end
  
  def found(service)
    puts "lets go"

    if jour = klass.alloc.initWithService(service)
      service.delegate = jour
      service.resolveWithTimeout(60)

      index = @children.size
      insertObject_inChildrenAtIndex(jour, index)
      @jours[service_key(service)] = jour
    end
  end
  
  def self.lost(service)
    if srv = service_lookup[service_basename(service)]
      srv.lost(service)
    end
  end
  
  def lost(service)
    if jour = @jours[service_key(service)]
		  index = @children.index(jour)
		  removeObjectFromChildrenAtIndex(index)
	  end
  end
end
