require "ostruct"

module VectorGenerate
	class Metadata
		class Links
			class Resolver
				VECTOR_REPO_URL = "https://github.com/timberio/vector".freeze
			  VECTOR_COMMIT_URL = "#{VECTOR_REPO_URL}/commit".freeze
			  VECTOR_ISSUES_URL = "#{VECTOR_REPO_URL}/issues".freeze
			  VECTOR_MILESTONES_URL = "#{VECTOR_REPO_URL}/milestone".freeze
			  VECTOR_PRS_URL = "#{VECTOR_REPO_URL}/pull".freeze
			  TEST_HARNESS_URL = "https://github.com/timberio/vector-test-harness".freeze

				def initialize(permalinks)
					@permalinks = permalinks
					@values = {}
				end

				def resolve!(parsed_id)
					value =
						case parsed_id.category
						when "urls"
							fetch_url!(parsed_id)
						else
							fetch_permalink!(parsed_id)
						end

			    value = [value, parsed_id.query].compact.join("?")
			    value = [value, parsed_id.anchor].compact.join("#")
			    @values[parsed_id.id] ||= value
			    value
			  end

			  private
			  	def fetch_permalink!(parsed_id)
			  		category_permalinks = @permalinks.fetch(parsed_id.category)

			      found_permalinks =
			        category_permalinks.select do |permalink|
			          permalink.gsub("-", "_").gsub(/\/$/, "").end_with?(parsed_id.normalized_name)
			        end

			      if found_permalinks.length == 1
			        found_permalinks.first
			      elsif found_permalinks.length == 0
			        raise KeyError.new(
			          <<~EOF
			          Unknown link name!

			            #{parsed_id.category}.#{parsed_id.name}

			          This link does not match any documents.
			          EOF
			        )
			      else
			        raise KeyError.new(
			          <<~EOF
			          Ambiguous link name!

			            #{parsed_id.category}.#{parsed_id.name}

			          This link matches more than 1 doc:

			          * #{found_permalinks.join("\n  * ").indent(2)}

			          Please use something more specific that will match only a single document.
			          EOF
			        )
			      end
			    end

			  	def fetch_url!(parsed_id)
			      case parsed_id.name
			      when /^(.*)_(sink|source|transform)_issues$/
			        name = $1
			        type = $2
			        query = "is:open is:issue label:\"#{type}: #{name}\""
			        VECTOR_ISSUES_URL + "?" + {"q" => query}.to_query

			      when /^(.*)_(sink|source|transform)_(bugs|enhancements)$/
			        name = $1
			        type = $2
			        issue_type = $3.singularize
			        query = "is:open is:issue label:\"#{type}: #{name}\" label:\"Type: #{issue_type}\""
			        VECTOR_ISSUES_URL + "?" + {"q" => query}.to_query

			      when /^(.*)_(sink|source|transform)_source$/
			        name = $1
			        name_parts = name.split("_")
			        name_prefix = name_parts.first
			        suffixed_name = name_parts[1..-1].join("_")
			        type = $2
			        "#{VECTOR_REPO_URL}/tree/master/src/#{type.pluralize}/#{name}.rs"

			      when /^(.*)_test$/
			        "#{TEST_HARNESS_URL}/tree/master/cases/#{$1}"

			      when /^commit_([a-z0-9]+)$/
			        "#{VECTOR_COMMIT_URL}/#{$1}"

			      when /^compare_([a-z0-9_\.]*)\.\.\.([a-z0-9_\.]*)$/
			        "https://github.com/timberio/vector/compare/#{$1}...#{$2}"

			      when /^issue_([0-9]+)$/
			        "#{VECTOR_ISSUES_URL}/#{$1}"

			      when /^milestone_([0-9]+)$/
			        "#{VECTOR_MILESTONES_URL}/#{$1}"

			      when /^new_(.*)_(sink|source|transform)_issue$/
			        name = $1
			        type = $2
			        label = "#{type}: #{name}"
			        VECTOR_ISSUES_URL + "/new?" + {"labels" => [label]}.to_query

			      when /^new_(.*)_(sink|source|transform)_(bug|enhancement)$/
			        name = $1
			        type = $2
			        issue_type = $3.singularize
			        component_label = "#{type}: #{name}"
			        type_label = "Type: #{issue_type}"
			        VECTOR_ISSUES_URL + "/new?" + {"labels" => [component_label, type_label]}.to_query

			      when /^pr_([0-9]+)$/
			        "#{VECTOR_PRS_URL}/#{$1}"

			      when /^release_notes_([a-z0-9_\.]*)$/
			        "#{HOST}/releases/#{$1}/"

			      when /^v([a-z0-9\-\.]+)$/
			        "#{HOST}/releases/#{$1}/download/"

			      when /^v([a-z0-9\-\.]+)_branch$/
			        "#{VECTOR_REPO_URL}/tree/v#{$1}"

			      when /^vector_downloads\.?(.*)$/
			        path = $1 == "" ? nil : $1
			        ["https://packages.timber.io/vector", path].compact.join("/")
			      else
			        raise KeyError.new(
			          <<~EOF
			          Unknown link!

			            urls.#{parsed_id.name}

			          URL links must match a link defined in ./meta/links.toml or it
			          must match a supported dynamic link, such as `urls.issue_541`.
			          EOF
			        )
			      end
			    end
			end
		end
	end
end