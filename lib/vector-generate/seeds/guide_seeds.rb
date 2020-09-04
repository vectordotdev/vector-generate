module VectorGenerate
	module Seeds
		module GuideSeeds
			extend self

			BLACKLISTED_SINKS = ["vector"]
			BLACKLISTED_SOURCES = ["vector"]

			def seed_platforms!(metadata, guides_dir)
				metadata.installation.platforms_list.each do |platform|
				  template_path = "#{guides_dir}/integrate/platforms/#{platform.name}.md.erb"
				  strategy = platform.strategies.first
				  source = metadata.sources.send(strategy.source)

				  Seeds.write_new_file(
				    template_path,
				    <<~EOF
				    <%- platform = metadata.installation.platforms.send("#{platform.name}") -%>
				    <%= integration_guide(platform: platform) %>
				    EOF
				  )

				  metadata.sinks_list.
				    select do |sink|
				      source.can_send_to?(sink) &&
				        !sink.function_category?("test") &&
				        !BLACKLISTED_SINKS.include?(sink.name)
				    end.
				    each do |sink|
				      template_path = "#{guides_dir}/integrate/platforms/#{platform.name}/#{sink.name}.md.erb"

				      Seeds.write_new_file(
				        template_path,
				        <<~EOF
				        <%- platform = metadata.installation.platforms.send("#{platform.name}") -%>
				        <%- sink = metadata.sinks.send("#{sink.name}") -%>
				        <%= integration_guide(platform: platform, sink: sink) %>
				        EOF
				      )
				    end
				end
			end

			def seed_sources!(metadata, guides_dir)
				metadata.sources_list.
				  select do |source|
				    !source.for_platform? &&
				      !source.function_category?("test") &&
				      !BLACKLISTED_SOURCES.include?(source.name)
				  end.
				  each do |source|
				    template_path = "#{guides_dir}/integrate/sources/#{source.name}.md.erb"

				    Seeds.write_new_file(
				      template_path,
				      <<~EOF
				      <%- source = metadata.sources.send("#{source.name}") -%>
				      <%= integration_guide(source: source) %>
				      EOF
				    )

				    metadata.sinks_list.
				      select do |sink|
				        source.can_send_to?(sink) &&
				          !sink.function_category?("test") &&
				          !BLACKLISTED_SINKS.include?(sink.name)
				      end.
				      each do |sink|
				        template_path = "#{guides_dir}/integrate/sources/#{source.name}/#{sink.name}.md.erb"

				        Seeds.write_new_file(
				          template_path,
				          <<~EOF
				          <%- source = metadata.sources.send("#{source.name}") -%>
				          <%- sink = metadata.sinks.send("#{sink.name}") -%>
				          <%= integration_guide(source: source, sink: sink) %>
				          EOF
				        )
				      end
				  end
			end

			def seed_sinks!(metadata, guides_dir)
				metadata.sinks_list.
				  select do |sink|
				    !sink.function_category?("test") &&
				      !BLACKLISTED_SINKS.include?(sink.name)
				  end.
				  each do |sink|
				    template_path = "#{guides_dir}/integrate/sinks/#{sink.name}.md.erb"

				    Seeds.write_new_file(
				      template_path,
				      <<~EOF
				      <%- sink = metadata.sinks.send("#{sink.name}") -%>
				      <%= integration_guide(sink: sink) %>
				      EOF
				    )
				  end
			end
		end
	end
end