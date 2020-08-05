require_relative "interface_helpers/interface_start"

class Templates
	module InterfaceHelpers
		def interface_installation_tutorial(interface, sink: nil, source: nil, heading_depth: 3)
	    if !sink && !source
	      raise ArgumentError.new("You must supply at lease a source or sink")
	    end

	    # Default to common sources so that the tutorial flows. Otherwise,
	    # the user is not prompted with a Vector configuration example.
	    if source.nil?
	      source =
	        if sink.logs?
	          metadata.sources.file
	        elsif sink.metrics?
	          metadata.sources.statsd
	        else
	          nil
	        end
	    end

	    render("#{partials_path}/interface_installation_tutorial/_#{interface.name}.md", binding).strip
	  end

	  def interface_logs(interface)
	    render("#{partials_path}/interface_logs/_#{interface.name}.md", binding).strip
	  end

	  def interface_reload(interface)
	    render("#{partials_path}/interface_reload/_#{interface.name}.md", binding).strip
	  end

	  def interface_start(interface, requirements: nil)
	    interface_start =
	      case interface.name
	      when "docker-cli"
	        InterfaceStart::DockerCLI.new(interface, requirements)
	      end

	    render("#{partials_path}/interface_start/_#{interface.name}.md", binding).strip
	  end

	  def interface_stop(interface)
	    render("#{partials_path}/interface_stop/_#{interface.name}.md", binding).strip
	  end

	  def interfaces_logs(interfaces, size: nil)
	    render("#{partials_path}/_interfaces_logs.md", binding).strip
	  end

	  def interfaces_reload(interfaces, requirements: nil, size: nil)
	    render("#{partials_path}/_interfaces_reload.md", binding).strip
	  end

	  def interfaces_start(interfaces, requirements: nil, size: nil)
	    render("#{partials_path}/_interfaces_start.md", binding).strip
	  end

	  def interfaces_stop(interfaces, size: nil)
	    render("#{partials_path}/_interfaces_stop.md", binding).strip
	  end
	end
end