require "erb"
require "toml-rb"

module DataLoaders
  module MetaLoader
  	extend self

  	class TemplateContext
  		attr_accessor :meta_dir

  		def initialize(meta_dir)
  			@meta_dir = meta_dir
  		end

  		def render(path, args = {})
  			context = binding

        args.each do |key, value|
          context.local_variable_set("#{key}", value)
        end

        full_path = path.start_with?("/") ? path : "#{meta_dir}/#{path}"

        if !File.exists?(full_path) && File.exists?("#{full_path}.erb")
          full_path = "#{full_path}.erb"
        end

        body = File.read(full_path)
        renderer = ERB.new(body, nil, '-')

        renderer.result(context)
  		end
  	end

  	def load!(dir)
  		template_context = TemplateContext.new(dir)

      contents =
        Dir.glob("#{dir}/**/[^_]*.{toml,toml.erb}").
          sort.
          unshift("#{dir}/root.toml"). # move to the front
          uniq.
          collect do |file|
            begin
              template_context.render(file)
            rescue Exception => e
              raise(
                <<~EOF
                The following metadata file failed to load:

                  #{file}

                The error received was:

                #{e.message.indent(2)}
                #{e.backtrace.join("\n  ").indent(2)}
                EOF
              )
            end
          end

      content = contents.join("\n")
      TomlRB.parse(content).validate_schema!(dir)
  	end
  end
end