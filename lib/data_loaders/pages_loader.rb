require 'front_matter_parser'

module DataLoaders
  module PagesLoader
  	extend self

  	def load!(dir)
  		Dir.
        glob("#{dir}/**/*.js").
        reject { |p| File.directory?(p) }.
        collect { |path| parse_file!(dir, path) }.
        sort_by { |hash| [ hash.fetch("id") ] }
  	end

  	private
  		def parse_file!(dir, path)
    		id = path.sub(dir, '').sub(/\.js$/, "")
  			permalink = "#{id}/"

    		{
    			"id" => id,
    			"permalink" => permalink
    		}
  		end
  end
end