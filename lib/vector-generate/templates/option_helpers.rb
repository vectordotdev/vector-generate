module VectorGenerate
	class Templates
		module OptionHelpers
			def encoding_description(encoding)
		    case encoding
		    when "json"
		      "The payload will be encoded as a single JSON payload."
		    when "ndjson"
		      "The payload will be encoded in new line delimited JSON payload, each line representing a JSON encoded event."
		    when "text"
		      "The payload will be encoded as new line delimited text, each line representing the value of the `\"message\"` key."
		    when nil
		      "The encoding type will be dynamically chosen based on the explicit structuring of the event. If the event has been explicitly structured (parsed, keys added, etc), then it will be encoded in the `json` format. If not, it will be encoded as `text`."
		    else
		      raise("Unhandled compression: #{encoding.inspect}")
		    end
		  end

			def option_description(option)
		    description = option.description.strip

		    if option.templateable?
		      description << " This option supports dynamic values via [Vector's template syntax][docs.reference.templating]."
		    end

		    if option.relevant_when
		      word = option.required? ? "required" : "relevant"
		      description << " Only #{word} when #{option.relevant_when_kvs.to_sentence(two_words_connector: " or ")}."
		    end

		    description
		  end

		  def option_tags(option, default: true, enum: true, example: false, optionality: true, relevant_when: true, type: true, short: false, unit: true)
		    tags = []

		    if optionality
		      if option.required?
		        tags << "required"
		      else
		        tags << "optional"
		      end
		    end

		    if example
		      if option.default.nil? && (!option.enum || option.enum.keys.length > 1)
		        tags << "example"
		      end
		    end

		    if default
		      if !option.default.nil?
		        if short
		          tags << "default"
		        else
		          tags << "default: #{option.default.inspect}"
		        end
		      elsif option.optional?
		        tags << "no default"
		      end
		    end

		    if type
		      if short
		        tags << option.type
		      else
		        tags << "type: #{option.type}"
		      end
		    end

		    if unit && !option.unit.nil?
		      if short
		        tags << option.unit
		      else
		        tags << "unit: #{option.unit}"
		      end
		    end

		    if enum && option.enum
		      if short && option.enum.keys.length > 1
		        tags << "enum"
		      else
		        escaped_values = option.enum.keys.collect { |enum| enum.to_toml }
		        if escaped_values.length > 1
		          tags << "enum: #{escaped_values.to_sentence(two_words_connector: " or ")}"
		        else
		          tag = "must be: #{escaped_values.first}"
		          if option.optional?
		            tag << " (if supplied)"
		          end
		          tags << tag
		        end
		      end
		    end

		    if relevant_when && option.relevant_when
		      word = option.required? ? "required" : "relevant"
		      tag = "#{word} when #{option.relevant_when_kvs.to_sentence(two_words_connector: " or ")}"
		      tags << tag
		    end

		    tags
		  end

		  def option_names(options)
		    options.collect { |option| "`#{option.name}`" }
		  end
		end
	end
end
