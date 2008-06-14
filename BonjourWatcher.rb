require 'osx/cocoa'

class BonjourWatcher < OSX::NSObject
  include OSX
  
  kvc_array_accessor :messages
  attr_reader :known_services
  
  kvc_accessor :status
  
  def init
		if super_init
			@messages = NSMutableArray.alloc.init
			return self
		end
	end
	
	def awakeFromNib
	  self.status = 'setting up...'
	  setup_known_services
	  load_rc
		browse
		self.status = ''
	end
	
	def setup_known_services
    @known_services = {}
    @service_browsers = {}
    @service_messages = {}
    
    service('git') do |service|
      [ "gitjour", "git clone #{service.name}", lambda {|msg|} ]
    end
    
    service('pastejour') do |service|
      (from, to) = *service.name.split('-')
      
      message = "Paste from #{from}"
      message << " to #{to}" if to
      
      ['pastejour', message, lambda {|msg| system("/opt/local/bin/pastejour '#{msg[:service].name}' | pbcopy"); 'copied to pasteboard'}]
    end
    
    service('rubygems') do |service|
      ['gemjour', "gem server #{service.name}", lambda {|msg|}]
    end
  end
  
  def load_rc
    rcfile = "#{ENV['HOME']}/.jourrc"
    if File.exist?(rcfile)
      instance_eval(File.read(rcfile))
    end
  end
  
  def service(name,srv_class=nil,&block)
    known_services[name.to_s] = srv_class || block
  end
	
	def browse
	  @known_services.each_key do |name|
	    @service_browsers[name] = browser = NSNetServiceBrowser.alloc.init
			browser.setDelegate self
  	  browser.searchForServicesOfType_inDomain("_#{name}._tcp","")
  	end
  end
  
  
  def messageClicked(selectedObjects)
    message = selectedObjects.first
    
    if message.respond_to?(:run)
      self.status = message.run
    elsif message.respond_to?(:key?) && message[:runner] && message[:runner].respond_to?(:call)
      self.status = message[:runner].call(message)
    end
  end
	
	def netServiceBrowserWillSearch(ns)
		puts "starting search"
	end

	def netServiceBrowser_didNotSearch(nsb,errorDict)
		puts "didn't start searching due to error #{errorDict.to_ruby.inspect}"
	end
	
	def service_key(service)
	  service.name.to_ruby + service.oc_type.to_ruby
	end
	
	def netServiceBrowser_didFindService_moreComing(nsb,service,more)
    name = service.oc_type.to_ruby[/_([^\.]+)\._tcp/,1]
    
    if srv = @known_services[name]
      if srv.respond_to?(:call)
        service_name,text,runner = srv.call(service)
        message = {:service_name => service_name, :text => text, :runner => runner, 
            :service => service, :image => NSWorkspace.sharedWorkspace.iconForFile('/')}
      else
        message = srv.alloc.initWithService(service)
      end
      
      index = @messages.size
      insertObject_inMessagesAtIndex(message, index)
      @service_messages[service_key(service)] = message
    end
	end

	def netServiceBrowser_didRemoveService_moreComing(nsb,service,more)
		puts "removing service #{service.name}"
		if message = @service_messages[service_key(service)]
		  index = @messages.index(message)
		  removeObjectFromMessagesAtIndex(index)
	  end
	end
	
	
end