require_relative "guide_helpers/integration_guide"

class Templates
	module GuideHelpers
		def integration_guide(platform: nil, source: nil, sink: nil)
	    if platform && source
	      raise ArgumentError.new("You cannot pass both a platform and a source")
	    end

	    interfaces = []
	    strategy = nil

	    if platform
	      interfaces = fetch_interfaces(platform.interfaces)
	      strategy = fetch_strategy(platform.strategies.first)
	      source = metadata.sources.send(strategy.source)
	    elsif source
	      interfaces = [metadata.installation.interfaces.send("vector-cli")]
	      strategy = fetch_strategy(source.strategies.first)
	    elsif sink
	      interfaces = [metadata.installation.interfaces.send("vector-cli")]
	      strategy = metadata.installation.strategies_list.first
	    end

	    guide =
	      IntegrationGuide.new(
	        strategy,
	        platform: platform,
	        source: source,
	        sink: sink
	      )

	    render("#{partials_path}/_integration_guide.md", binding).strip
	  end
	end
end