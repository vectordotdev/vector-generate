class Templates
	module ReleaseHelpers
		def release_breaking_changes(release, heading_depth: 3)
	    render("#{partials_path}/_release_breaking_changes.md", binding).strip
	  end

	  def release_header(release)
	    render("#{partials_path}/_release_header.md", binding).strip
	  end

	  def release_highlights(release, heading_depth: 3, tags: true)
	    render("#{partials_path}/_release_highlights.md", binding).strip
	  end

	  def release_summary(release)
	    parts = []

	    if release.new_features.any?
	      parts << pluralize(release.new_features.size, "new feature")
	    end

	    if release.enhancements.any?
	      parts << pluralize(release.enhancements.size, "enhancement")
	    end

	    if release.bug_fixes.any?
	      parts << pluralize(release.bug_fixes.size, "bug fix")
	    end

	    parts.join(", ")
	  end

	  def release_whats_next(release, heading_depth: 3)
	    render("#{partials_path}/_release_whats_next.md", binding).strip
	  end
	end
end