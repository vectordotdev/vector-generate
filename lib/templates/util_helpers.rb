class Templates
	module UtilHelpers
		def pluralize(count, word)
	    count != 1 ? "#{count} #{word.pluralize}" : "#{count} #{word}"
	  end

	  def strip(content)
      content.strip
    end

		def subpages(link_name = nil)
	    dir =
	      if link_name
	        docs_dir = metadata.links.fetch(link_name).gsub(/\/$/, "")
	        "#{WEBSITE_ROOT}#{docs_dir}"
	      else
	        dirname = File.basename(@_template_path).split(".").first
	        @_template_path.split("/")[0..-2].join("/") + "/#{dirname}"
	      end

	    Dir.glob("#{dir}/*.md").
	      to_a.
	      sort.
	      collect do |f|
	        path = DOCS_BASE_PATH + f.gsub(DOCS_ROOT, '').split(".").first
	        name = File.basename(f).split(".").first.gsub("-", " ").humanize

	        loader = FrontMatterParser::Loader::Yaml.new(whitelist_classes: [Date])
	        front_matter = FrontMatterParser::Parser.parse_file(f, loader: loader).front_matter
	        sidebar_label = front_matter.fetch("sidebar_label", "hidden")
	        if sidebar_label != "hidden"
	          name = sidebar_label
	        end

	        "<Jump to=\"#{path}/\">#{name}</Jump>"
	      end.
	      join("\n").
	      strip
	  end

	  def tags(tags)
	    tags.collect { |tag| "`#{tag}`" }.join(" ")
	  end

	  def vector_summary
	    render("#{partials_path}/_vector_summary.md", binding).strip
	  end

	  def warnings(warnings)
	    render("#{partials_path}/_warnings.md", binding).strip
	  end
	end
end