module Seeds
	module ReleaseSeeds
		def seed_releases!(metadata, releases_dir)
			metadata.releases_list.each do |release|
			  template_path = "#{releases_dir}/#{release.version}.md.erb"

			  Seeds.write_new_file(
			    template_path,
			    <<~EOF
			    <%- release = metadata.releases.send("#{release.version}") -%>
			    <%= release_header(release) %>

			    <%- if release.highlights.any? -%>
			    ## Highlights

			    <div className="sub-title">Noteworthy changes in this release</div>

			    <%= release_highlights(release, heading_depth: 3) %>

			    <%- end -%>
			    ## Changelog

			    <div className="sub-title">A complete list of changes</div>

			    <Changelog version={<%= release.version.to_json %>} />

			    ## What's Next

			    <%= release_whats_next(release) %>
			    EOF
			  )
			end
		end
	end
end