#!/usr/bin/env ruby

#
# Requires
#

require "rubygems"
require "bundler"
require "erb"

Bundler.require(:default)

require "active_support/core_ext/array/conversions"
require "active_support/core_ext/hash/deep_merge"
require "active_support/core_ext/string/conversions"
require "active_support/core_ext/string/filters"
require "active_support/core_ext/string/indent"

require_relative "lib/core_ext"
require_relative "lib/data_loaders"
require_relative "lib/json_schema"
require_relative "lib/metadata"
require_relative "lib/post_processors"
require_relative "lib/templates"

#
# Functions
#

def render_templates(metadata, target_dir, relative_link_paths)
	templates =
		Dir.
	  	glob("#{target_dir}/**/[^_]*.erb", File::FNM_DOTMATCH).
	  	to_a.
	  	filter { |path| !path.start_with?("#{target_dir}/.meta/") }

	template_context = Templates.new(metadata)

	templates.each do |template|
		content = template_context.render(template)

		if template.end_with?(".md.erb")
		  content = content.clone
		  content = PostProcessors::ComponentImporter.import!(content)
		  content = PostProcessors::SectionSorter.sort!(content)
		  content = PostProcessors::SectionReferencer.reference!(content)
		  content = PostProcessors::OptionLinker.link!(content)
		  content = PostProcessors::LinkDefiner.define!(content, metadata.links, relative_link_paths)
		  content = PostProcessors::AutogenerateLabeler.label!(content, template)
		  # must be last
		  content = PostProcessors::LastModifiedSetter.set!(content, template)

		  # PostProcessors::FrontMatterValidator.validate!(content, template)
		end

		File.write(template.gsub(/\.erb$/, ""), content)
	end
end

#
# Constants
#

DOCS_PATH = "/docs"
GUIDES_PATH = "/guides"
HIGHLIGHTS_PATH = "/highlights"
HOST = "https://vector.dev"
OPERATING_SYSTEMS = ["Linux", "MacOS", "Windows"].freeze
POSTS_PATH = "/blog"

ROOT_DIR = Dir.pwd
VECTOR_TARGET_DIR = File.join(ROOT_DIR, "targets", "vector")
VECTOR_WEBSITE_TARGET_DIR = File.join(ROOT_DIR, "targets", "vector-website")
VECTOR_WEBSITE_STATIC_DIR = File.join(VECTOR_WEBSITE_TARGET_DIR, "static")


#
# Globals
#

global_meta = DataLoaders::MetaLoader.load!(File.join(ROOT_DIR, ".meta", "global"))
docs = DataLoaders::DocsLoader.load!(File.join(VECTOR_WEBSITE_TARGET_DIR, "docs"))
guides = DataLoaders::GuidesLoader.load!(File.join(VECTOR_WEBSITE_TARGET_DIR, "guides"))
highlights = DataLoaders::HighlightsLoader.load!(File.join(VECTOR_WEBSITE_TARGET_DIR, "highlights"))
pages = DataLoaders::PagesLoader.load!(File.join(VECTOR_WEBSITE_TARGET_DIR, "src", "pages"))
posts = DataLoaders::PostsLoader.load!(File.join(VECTOR_WEBSITE_TARGET_DIR, "blog"))
permalinks =
	{
		"docs" => docs.collect { |d| d.fetch("permalink") },
		"guides" => guides.values.collect { |category| category.fetch("guides").flatten.collect { |g| g.fetch("permalink") } }.flatten,
		"highlights" => highlights.collect { |h| h.fetch("permalink") },
		"pages" => pages.collect { |p| p.fetch("permalink") },
		"posts" => posts.collect { |p| p.fetch("permalink") }
	}

#
# vector repo
#

# use v0.10 so we aren't changes changes that have not been released
vector_meta = DataLoaders::MetaLoader.load!(File.join(ROOT_DIR, ".meta", "vector", "v0.10", ".meta"))
metadata = Metadata.new(global_meta, vector_meta, guides, highlights, posts, permalinks)
render_templates(metadata, VECTOR_TARGET_DIR, false)

#
# vector-website repo
#

# use v0.10 so we aren't exposing changes that have not been released
vector_meta = DataLoaders::MetaLoader.load!(File.join(ROOT_DIR, ".meta", "vector", "v0.10", ".meta"))
metadata = Metadata.new(global_meta, vector_meta, guides, highlights, posts, permalinks)
render_templates(metadata, VECTOR_WEBSITE_TARGET_DIR, true)