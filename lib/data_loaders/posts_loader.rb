require 'front_matter_parser'

module DataLoaders
  module PostsLoader
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
  			path_parts = path.split("-", 3)
      	date = "#{path_parts.fetch(0)}-#{path_parts.fetch(1)}-#{path_parts.fetch(2)}"
  	    description = parsed.content.split("\n\n").first.remove_markdown_links

    		front_matter = parsed.front_matter
    		id = path.sub(dir + "/", "").sub(/\.md$/, "")
  	    permalink = "#{POSTS_PATH}/#{id}/"

    		front_matter.clone.merge({
    			"date" => date,
    			"description" => description,
    			"id" => id,
    			"permalink" => permalink
    		}).validate_schema!(dir)
  		end
  end
end