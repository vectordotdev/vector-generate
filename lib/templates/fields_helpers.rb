class Templates
	module FieldsHelpers
		def fields(fields, filters: true, heading_depth: 3, path: nil)
	    if !fields.is_a?(Array)
	      raise ArgumentError.new("Fields must be an Array")
	    end

	    render("#{partials_path}/_fields.md", binding).strip
	  end

	  def fields_example(fields, event_type, root_key: nil)
	    if !fields.is_a?(Array)
	      raise ArgumentError.new("Fields must be an Array")
	    end

	    render("#{partials_path}/_fields_example.md", binding).strip
	  end

	  def fields_hash(fields, root_key: nil)
	    hash = {}

	    fields.each do |field|
	      if field.children?
	        hash[field.name] = fields_hash(field.children_list)
	      else
	        example = field.examples.first

	        if example.is_a?(Hash)
	          hash.merge!(example)
	        else
	          hash[field.name] = example
	        end
	      end
	    end

	    if root_key
	      {root_key => hash}
	    else
	      hash
	    end
	  end
	end
end