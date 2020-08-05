require_relative "config_helpers/config_spec"

class Templates
	module ConfigHelpers
		def config_example(options, array: false, group: nil, key_path: [], table_path: [], &block)
	    if !options.is_a?(Array)
	      raise ArgumentError.new("Options must be an Array")
	    end

	    example = ConfigWriters::ExampleWriter.new(options, array: array, group: group, key_path: key_path, table_path: table_path, &block)
	    example.to_toml
	  end

	  def config_spec(options, opts = {})
	    if !options.is_a?(Array)
	      raise ArgumentError.new("Options must be an Array")
	    end

	    opts[:titles] = true unless opts.key?(:titles)

	    spec = ConfigSpec.new(options)
	    content = render("#{partials_path}/_config_spec.toml", binding).strip

	    if opts[:path]
	      content
	    else
	      content.gsub("\n  ", "\n")
	    end
	  end

	  def full_config_spec
	    render("#{partials_path}/_full_config_spec.toml", binding).strip.gsub(/ *$/, '')
	  end
	end
end