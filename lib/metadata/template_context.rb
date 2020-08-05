class Metadata
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
end