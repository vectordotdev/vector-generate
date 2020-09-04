module VectorGenerate
	class Templates
		module ComponentHelpers
			def common_component_links(type, limit = 5)
		    components = metadata.send("#{type.to_s.pluralize}_list")

		    links =
		      components.select(&:common?)[0..limit].collect do |component|
		        "[#{component.name}][#{component_short_link(component)}]"
		      end

		    num_leftover = components.size - links.size

		    if num_leftover > 0
		      links << "and [#{num_leftover} more...][docs.#{type.to_s.pluralize}]"
		    end

		    links.join(", ")
		  end

			def component_config_example(component, advanced: true)
		    groups = []

		    if component.option_groups.empty?
		      groups << AccessibleHash.new({
		        label: "Common",
		        group_name: nil,
		        option_filter: lambda do |option|
		          !advanced || option.common?
		        end
		      })

		      if advanced
		        groups << AccessibleHash.new({
		          label: "Advanced",
		          group_name: nil,
		          option_filter: lambda do |option|
		            true
		          end
		        })
		      end
		    else
		      component.option_groups.each do |group_name|
		        groups << AccessibleHash.new({
		          label: group_name,
		          group_name: group_name,
		          option_filter: lambda do |option|
		            option.group?(group_name) && (!advanced || option.common?)
		          end
		        })

		        if advanced
		          groups << AccessibleHash.new({
		            label: "#{group_name} (adv)",
		            group_name: group_name,
		            option_filter: lambda do |option|
		              option.group?(group_name)
		            end
		          })
		        end
		      end
		    end

		    render("#{partials_path}/_component_config_example.md", binding).strip
		  end

		  def component_default(component)
		    render("#{partials_path}/_component_default.md.erb", binding).strip
		  end

		  def component_examples(component)
		    render("#{partials_path}/_component_examples.md", binding).strip
		  end

		  def component_fields(component, heading_depth: 2)
		    render("#{partials_path}/_component_fields.md", binding)
		  end

		  def component_header(component)
		    render("#{partials_path}/_component_header.md", binding).strip
		  end

		  def component_requirements(component)
		    render("#{partials_path}/_component_requirements.md", binding).strip
		  end

		  def component_sections(component)
		    render("#{partials_path}/_component_sections.md", binding).strip
		  end

		  def component_short_description(component)
		    send("#{component.type}_short_description", component)
		  end

		  def component_short_link(component)
		    "docs.#{component.type.to_s.pluralize}.#{component.name}"
		  end

		  def components_table(components)
		    if !components.is_a?(Array)
		      raise ArgumentError.new("Options must be an Array")
		    end

		    render("#{partials_path}/_components_table.md", binding).strip
		  end

		  def component_warnings(component)
		    warnings(component.warnings)
		  end

		  def outputs_link(component)
		    "outputs #{event_type_links(component.output_types).to_sentence} events"
		  end

		  def permissions(permissions, heading_depth: nil)
		    if !permissions.is_a?(Array)
		      raise ArgumentError.new("Permissions must be an Array")
		    end

		    render("#{partials_path}/_permissions.md", binding).strip
		  end

		  def sink_short_description(sink)
		    strip <<~EOF
		    #{write_verb_link(sink)} #{event_type_links(sink.input_types).to_sentence} events to #{sink.write_to_description}.
		    EOF
		  end

		  def source_short_description(source)
		    strip <<~EOF
		    Ingests data through #{source.through_description} and #{outputs_link(source)}.
		    EOF
		  end

		  def transform_short_description(transform)
		    if transform.input_types == transform.output_types
		      strip <<~EOF
		      Accepts and #{outputs_link(transform)}, allowing you to #{transform.allow_you_to_description}.
		      EOF
		    else
		      strip <<~EOF
		      Accepts #{event_type_links(transform.input_types).to_sentence} events, but #{outputs_link(transform)}, allowing you to #{transform.allow_you_to_description}.
		      EOF
		    end
		  end

		  def write_verb_link(sink)
		    if sink.batching?
		      "[#{sink.plural_write_verb.humanize}](#buffers--batches)"
		    elsif sink.streaming?
		      "[#{sink.plural_write_verb.humanize}](#streaming)"
		    elsif sink.exposing?
		      "[#{sink.plural_write_verb.humanize}](#exposing--scraping)"
		    else
		      raise "Unhandled sink egress method: #{sink.egress_method.inspect}"
		    end
		  end
		end
	end
end
