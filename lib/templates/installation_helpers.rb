class Templates
	module InstallationHelpers
		def deployment_strategy(strategy, describe: true, platform: nil, sink: nil, source: nil)
	    render("#{partials_path}/deployment_strategies/_#{strategy.name}.md", binding).strip
	  end

	  def docker_docs
	    render("#{partials_path}/_docker_docs.md")
	  end

	  def downloads_urls(downloads)
	    render("#{partials_path}/_downloads_urls.md", binding)
	  end

	  def fetch_interfaces(interface_names)
	    interface_names.collect do |name|
	      metadata.installation.interfaces.send(name)
	    end
	  end

	  def fetch_strategies(strategy_references)
	    strategy_references.collect do |reference|
	      name = reference.is_a?(Hash) ? reference.name : reference
	      strategy = metadata.installation.strategies.send(name).clone
	      if reference.respond_to?(:source)
	        strategy[:source] = reference.source
	      end
	      strategy
	    end
	  end

	  def fetch_strategy(strategy_reference)
	    fetch_strategies([strategy_reference]).first
	  end

	  def install_command(prompts: true)
	    "curl --proto '=https' --tlsv1.2 -sSf https://sh.vector.dev | sh#{prompts ? "" : " -s -- -y"}"
	  end

	  def installation_target_links(targets)
	    targets.collect do |target|
	      "[#{target.name}][docs.#{target.id}]"
	    end
	  end

	  def installation_tutorial(interfaces, strategies, platform: nil, heading_depth: 3, show_deployment_strategy: true)
	    render("#{partials_path}/_installation_tutorial.md", binding).strip
	  end

	  def manual_installation_next_steps(type)
	    if type != :source && type != :archives
	      raise ArgumentError.new("type must be one of :source or :archives")
	    end

	    distribution_dir = type == :source ? "distribution" : "etc"

	    render("#{partials_path}/_manual_installation_next_steps.md", binding).strip
	  end

	  def strategies(strategies)
	    render("#{partials_path}/_strategies.md", binding).strip
	  end

	  def topologies
	    render("#{partials_path}/_topologies.md", binding).strip
	  end
	end
end