require_relative "seeds/guide_seeds"
require_relative "seeds/release_seeds"

module Seeds
	extend self

	def write_new_file(path, contents)
	  if !File.exists?(path)
	    dirname = File.dirname(path)

	    unless File.directory?(dirname)
	      FileUtils.mkdir_p(dirname)
	    end

	    File.open(path, 'w+') { |file| file.write(contents) }

	    Printer.say("Created #{path}")
	  end
	end
end