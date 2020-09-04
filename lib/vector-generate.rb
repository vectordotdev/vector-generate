require "erb"

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

module VectorGenerate
  DOCS_PATH = "/docs"
  GUIDES_PATH = "/guides"
  HIGHLIGHTS_PATH = "/highlights"
  HOST = "https://vector.dev"
  OPERATING_SYSTEMS = ["Linux", "MacOS", "Windows"].freeze
  POSTS_PATH = "/blog"

  def self.render_templates(metadata, target_dir, relative_link_paths)
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
end