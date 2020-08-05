class Templates
	module EventHelpers
		def event_types(types)
	    types.collect do |type|
	      "`#{type}`"
	    end
	  end

	  def event_type_links(types)
	    types.collect do |type|
	      "[`#{type}`][docs.data-model.#{type}]"
	    end
	  end
	end
end