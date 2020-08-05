module PostProcessors
  # Add an autogenerated notice to generated files.
  class AutogenerateLabeler
  	ANCHOR = "\n## ".freeze

  	class << self
  		def label!(content, template)
	      notice =
	        <<~EOF

	        <!--
	             THIS FILE IS AUTOGENERATED!

	             To make changes please edit the template located at:

	             #{template.gsub(ROOT_DIR, "").split("/")[3..-1].join("/")}.erb
	        -->
	        EOF

	      if content.include?(ANCHOR)
	      	content.sub!(/#{ANCHOR}/, "#{notice}\n## ")
	      else
	      	notice + content
	      end
	    end
	  end
	end
end