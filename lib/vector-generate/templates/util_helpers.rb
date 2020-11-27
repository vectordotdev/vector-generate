module VectorGenerate
	class Templates
		module UtilHelpers
			def pluralize(count, word)
		    count != 1 ? "#{count} #{word.pluralize}" : "#{count} #{word}"
		  end

		  def strip(content)
	      content.strip
	    end
		end
	end
end
