require 'front_matter_parser'

module VectorGenerate
  module DataLoaders
    module HighlightsLoader
    	extend self

    	def load!(dir)
    		Dir.
          glob("#{dir}/**/*.md").
          filter { |path| File.read(path).start_with?("---\n") }.
          collect { |path| parse_file!(dir, path) }.
          sort_by { |hash| [ hash.fetch("date"), hash.fetch("id") ] }
    	end

    	private
    		def parse_file!(dir, path)
    			parsed = FrontMatterParser::Parser.parse_file(path)
    			path_parts = File.basename(path).split("-", 4)

    			content = File.read(path)
        	date = "#{path_parts.fetch(0)}-#{path_parts.fetch(1)}-#{path_parts.fetch(2)}"
      		front_matter = parsed.front_matter
      		id = path.sub(dir + "/", "").sub(/\.md$/, "")
    			permalink = "#{HIGHLIGHTS_PATH}/#{id}/"

      		front_matter.clone.merge({
      			"content" => content,
      			"date" => date,
      			"id" => id,
      			"permalink" => permalink
      		})#.validate_schema!(dir)
    		end
    end
  end
end