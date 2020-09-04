module VectorGenerate
	class Templates
		module HighlightHelpers
			def highlights(highlights, author: true, colorize: false, group_by: "type", heading_depth: 3, size: nil, tags: true, timeline: true)
		    case group_by
		    when "type"
		      highlights.sort_by!(&:type)
		    when "version"
		      highlights.sort_by!(&:date)
		    else
		      raise ArgumentError.new("Invalid group_by value: #{group_by.inspect}")
		    end

		    highlight_maps =
		      highlights.collect do |highlight|
		        {
		          authorGithub: highlight.author_github,
		          dateString: "#{highlight.date}T00:00:00",
		          description: highlight.description,
		          permalink: highlight.permalink,
		          prNumbers: highlight.pr_numbers,
		          release: highlight.release,
		          tags: highlight.tags,
		          title: highlight.title,
		          type: highlight.type
		        }
		      end

		    render("#{partials_path}/_highlights.md", binding).strip
		  end
		end
	end
end
