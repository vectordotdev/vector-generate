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

require_relative "lib/config_writers"
require_relative "lib/core_ext"
require_relative "lib/data_loaders"
require_relative "lib/json_schema"
require_relative "lib/metadata"
require_relative "lib/post_processors"
require_relative "lib/printer"
require_relative "lib/seeds"
require_relative "lib/templates"

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
VECTOR_MANAGEMENT_TARGET_DIR = File.join(ROOT_DIR, "targets", "vector-management")
VECTOR_TARGET_DIR = File.join(ROOT_DIR, "targets", "vector")
VECTOR_WEBSITE_TARGET_DIR = File.join(ROOT_DIR, "targets", "vector-website")
VECTOR_WEBSITE_GUIDES_DIR = File.join(VECTOR_WEBSITE_TARGET_DIR, "guides")
VECTOR_WEBSITE_RELEASES_DIR = File.join(VECTOR_WEBSITE_TARGET_DIR, "releases")
VECTOR_WEBSITE_STATIC_DIR = File.join(VECTOR_WEBSITE_TARGET_DIR, "static")

#
# Flags
#

target = ARGV.include?("--target")


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
		  # must be last
		  content = PostProcessors::LastModifiedSetter.set!(content, template)

		  # PostProcessors::FrontMatterValidator.validate!(content, template)
		end

		 content = PostProcessors::AutogenerateLabeler.label!(content, template)

		File.write(template.gsub(/\.erb$/, ""), content)

		Printer.say("Rendered #{template.gsub(ROOT_DIR, "")}")
	rescue StandardError
		Printer.say("Error while rendering file #{template.gsub(ROOT_DIR, "")}")
		raise
	end
end

#
# Globals
#

Printer.title("Loading data...")

global_meta = DataLoaders::MetaLoader.load!(File.join(ROOT_DIR, ".meta", "global"))
Printer.say("Loaded #{File.join(ROOT_DIR, ".meta", "global")}")

docs = DataLoaders::DocsLoader.load!(File.join(VECTOR_WEBSITE_TARGET_DIR, "docs"))
Printer.say("Loaded #{File.join(VECTOR_WEBSITE_TARGET_DIR, "docs")}")

guides = DataLoaders::GuidesLoader.load!(VECTOR_WEBSITE_GUIDES_DIR)
Printer.say("Loaded #{VECTOR_WEBSITE_GUIDES_DIR}")

highlights = DataLoaders::HighlightsLoader.load!(File.join(VECTOR_WEBSITE_TARGET_DIR, "highlights"))
Printer.say("Loaded #{File.join(VECTOR_WEBSITE_TARGET_DIR, "highlights")}")

pages = DataLoaders::PagesLoader.load!(File.join(VECTOR_WEBSITE_TARGET_DIR, "src", "pages"))
Printer.say("Loaded #{File.join(VECTOR_WEBSITE_TARGET_DIR, "src", "pages")}")

posts = DataLoaders::PostsLoader.load!(File.join(VECTOR_WEBSITE_TARGET_DIR, "blog"))
Printer.say("Loaded #{File.join(VECTOR_WEBSITE_TARGET_DIR, "blog")}")

permalinks =
	{
		"docs" => docs.collect { |d| d.fetch("permalink") },
		"guides" => guides.values.collect { |category| category.fetch("guides").flatten.collect { |g| g.fetch("permalink") } }.flatten,
		"highlights" => highlights.collect { |h| h.fetch("permalink") },
		"pages" => pages.collect { |p| p.fetch("permalink") },
		"posts" => posts.collect { |p| p.fetch("permalink") }
	}

#
# targets/vector
#

Printer.title("Generating targets/vector")

# use v0.10 so we aren't changes changes that have not been released
vector_meta = DataLoaders::MetaLoader.load!(File.join(ROOT_DIR, ".meta", "vector", "v0.10", ".meta"))
metadata = Metadata.new(global_meta, vector_meta, guides, highlights, posts, permalinks)
render_templates(metadata, VECTOR_TARGET_DIR, false)

#
# targets/vector-website
#

Printer.title("Generating targets/vector-website")

# use v0.10 so we aren't exposing changes that have not been released
vector_meta = DataLoaders::MetaLoader.load!(File.join(ROOT_DIR, ".meta", "vector", "v0.10", ".meta"))
metadata = Metadata.new(global_meta, vector_meta, guides, highlights, posts, permalinks)

Seeds::GuideSeeds.seed_platforms!(metadata, VECTOR_WEBSITE_GUIDES_DIR)
Seeds::GuideSeeds.seed_sinks!(metadata, VECTOR_WEBSITE_GUIDES_DIR)
Seeds::GuideSeeds.seed_sources!(metadata, VECTOR_WEBSITE_GUIDES_DIR)
Seeds::ReleaseSeeds.seed_releases!(metadata, VECTOR_WEBSITE_RELEASES_DIR)

render_templates(metadata, VECTOR_WEBSITE_TARGET_DIR, true)

#
# targets/vector-management
#

Printer.title("Generating targets/vector-management")

vector_meta = DataLoaders::MetaLoader.load!(File.join(ROOT_DIR, ".meta", "vector", "master", ".meta"))
metadata = Metadata.new(global_meta, vector_meta, guides, highlights, posts, permalinks)
render_templates(metadata, VECTOR_MANAGEMENT_TARGET_DIR, true)
