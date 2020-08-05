require 'front_matter_parser'

module DataLoaders
	module GuidesLoader
		extend self

		def load!(dir)
			{
				"advanced" => {
					"title" => "Advanced",
					"description" => "Go beyond the basics, become a Vector pro, and extract the full potential of Vector.",
					"guides" => load_sub_dir!(dir, "advanced"),
					"series" => false
				},
				"getting-started" => {
					"title" => "Getting Started",
					"description" => "Take Vector from zero to production in under 10 minutes.",
					"guides" => load_sub_dir!(dir, "getting-started"),
					"series" => true
				},
				"integrate" => {
					"title" => "Integrate",
					"description" => "Targeted guides for integrating platforms, data sources, and data destinations.",
					"guides" => load_sub_dir!(dir, "integrate"),
					"series" => false
				}
			}
		end

		private
			def load_sub_dir!(dir, sub_dir)
				Dir.
		      glob("#{dir}/#{sub_dir}/**/*.md").
		      filter { |path| File.read(path).start_with?("---\n") }.
		      collect { |path| parse_file!(dir, path) }.
		      sort_by { |hash| [ hash["series_position"], hash.fetch("title") ] }
			end

			def parse_file!(dir, path)
				parsed = FrontMatterParser::Parser.parse_file(path)
	  		front_matter = parsed.front_matter
	  		id = path.sub(dir, '').sub(/\.md$/, "")
	  		permalink = "#{GUIDES_PATH}#{id}/"

	  		front_matter.clone.merge({
	  			"id" => id,
	  			"permalink" => permalink
	  		})#.validate_schema!(sub_dir)
			end
	end
end