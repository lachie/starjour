require 'osx/cocoa'

class BonjourWatcher < OSX::NSObject
  include OSX
  
  kvc_accessor :servicekinds
  kvc_array_accessor :servicekinds
  
  kvc_accessor :status
  
  ib_outlet :detail_view
  ib_outlet :outline_view
  
  def init
		if super_init
		  @servicekinds  = NSMutableArray.alloc.init
      @selectedItems = NSMutableArray.alloc.init
			return self
		end
	end
	
	def awakeFromNib
	  self.status = 'setting up...'
	  
	  setup_known_services
	  load_rc
	  
		browse
		self.status = ''
		
	  @outline_view.expandItem_expandChildren(nil,true)
	end
	
	def setup_known_services
    service('pastejour', PasteJour)
    service('http'     , AppJour  )
    service('git'      , GitJour  )
    service('rubygems' , GemJour  )
    
    # service('git'      , GitJour  )
    # service('rubygems' , GemJour  )
    # service('http'     , AppJour  )
    
    # service('git') do |service|
    #       [ "gitjour", "git clone #{service.name}", lambda {|msg|} ]
    #     end
    #     
    #     service('pastejour') do |service|
    #       (from, to) = *service.name.split('-')
    #       
    #       message = "Paste from #{from}"
    #       message << " to #{to}" if to
    #       
    #       ['pastejour', message, lambda {|msg| system("/opt/local/bin/pastejour '#{msg[:service].name}' | pbcopy"); 'copied to pasteboard'}]
    #     end
    #     
    #     service('rubygems') do |service|
    #       ['gemjour', "gem server #{service.name}", lambda {|msg|}]
    #     end
    # 
    #     service('http') do |service|
    #       ['appjour', "appjour #{service.name}", lambda {|msg|}]
    #     end
  end
  
  
  def load_rc
    rcfile = "#{ENV['HOME']}/.jourrc"
    if File.exist?(rcfile)
      instance_eval(File.read(rcfile))
    end
  end
  
  def service(name,klass)    
    srv = ServiceKind.alloc.initWithName_andClass(name,klass)
    insertObject_inServicekindsAtIndex(srv, @servicekinds.size)
  end
	
	def browse
	  servicekinds.each do |srv|
	    browser = NSNetServiceBrowser.alloc.init
			browser.delegate = self
  	  browser.searchForServicesOfType_inDomain(srv.service_type, "")
  	end
  end
  
  
  # def selectedItems; @selectedItems end
  def selectedItems=(selectedItems)
    @selectedItems = selectedItems
    
    if !selectedItems or selectedItems.length < 1
      @detail_view.subviews.each {|sv| sv.removeFromSuperview}
      return
    end
    
    path = selectedItems.first
    if path.length == 2
      srv_index  = path.indexAtPosition(0)
      jour_index = path.indexAtPosition(1)
      
      srv = @servicekinds[srv_index]
      jour = srv.children[jour_index]
      
      puts "jour.text: #{jour.text}"
      update_view(jour)
    end

  end
  kvc_accessor :selectedItems
  
  def update_view(jour)
    return unless jour.view?
    
    @detail_view.subviews.each {|sv| sv.removeFromSuperview}
    @detail_view.addSubview jour.view
    jour.view.frame = @detail_view.bounds
  end
	
	def netServiceBrowserWillSearch(ns)
		puts "starting search"
	end

	def netServiceBrowser_didNotSearch(nsb,errorDict)
		puts "didn't start searching due to error #{errorDict.to_ruby.inspect}"
	end
	
	def netServiceBrowser_didFindService_moreComing(nsb,service,more)
    ServiceKind.found(service)
	  @outline_view.expandItem_expandChildren(nil,true)
	end

	def netServiceBrowser_didRemoveService_moreComing(nsb,service,more)
		puts "lost service #{service.name}"
	  ServiceKind.lost(service)
	  @outline_view.expandItem_expandChildren(nil,true)
	end
  
  
  # olv delegate
  def outlineView_isGroupItem(outlineView,item)
    item.representedObject.is_a?(ServiceKind)
  end
  
  def outlineView_shouldSelectItem(outlineView,item)
    !item.representedObject.is_a?(ServiceKind)
  end
  
  def outlineView_shouldCollapseItem(outline_view,item)
    item.representedObject.is_a?(ServiceKind)
  end
  
  def pcOutlineView_shouldShowDisclosureTriangleForItem(outline_view,item)
    item.representedObject.is_a?(ServiceKind)
  end
    
end