require 'front_matter_parser'

module VectorGenerate
	module DataLoaders
		module GuidesLoader
			extend self

			def load!(dir)
				{
					"basic" => {
						"title" => "Basic",
						"description" => "Get started and learn the Vector basics.",
						"guides" => load_root_dir!(dir),
						"series" => false
					},
					"advanced" => {
						"title" => "Advanced",
						"description" => "Advanced guides that go deep on specific features and niches.",
						"guides" => load_sub_dir!(dir, "advanced"),
						"series" => false
					},
					"integrate" => {
						"title" => "Integrate",
						"description" => "Simple step-by-step integration guides.",
						"guides" => load_sub_dir!(dir, "integrate"),
						"series" => false
					},
					"level-up" => {
						"title" => "Level up",
						"description" => "Go from Vector beginner to pro! Everything you need to use Vector confidently.",
						"guides" => load_sub_dir!(dir, "level-up"),
						"series" => true
					},
				}
			end

			private
				def load_root_dir!(dir)
					Dir.
			      glob("#{dir}/*.md").
			      filter { |path| File.read(path).start_with?("---\n") }.
			      collect { |path| parse_file!(dir, path) }.
			      sort_by { |hash| [ hash["series_position"], hash.fetch("title") ] }
				end

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
		  		id = path.sub(dir + "/", "").sub(/\.md$/, "")
		  		permalink = "#{GUIDES_PATH}/#{id}/"

		  		front_matter.clone.merge({
		  			"id" => id,
		  			"permalink" => permalink
		  		})#.validate_schema!(sub_dir)
				end
		end
	end
end