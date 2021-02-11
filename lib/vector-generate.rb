require "erb"

require "active_support/core_ext/array/conversions"
require "active_support/core_ext/hash/deep_merge"
require "active_support/core_ext/string/conversions"
require "active_support/core_ext/string/filters"
require "active_support/core_ext/string/indent"

require_relative "vector-generate/config_writers"
require_relative "vector-generate/core_ext"
require_relative "vector-generate/data_loaders"
require_relative "vector-generate/json_schema"
require_relative "vector-generate/metadata"
require_relative "vector-generate/post_processors"
require_relative "vector-generate/printer"
require_relative "vector-generate/templates"

module VectorGenerate
  DOCS_PATH = "/docs"
  GUIDES_PATH = "/guides"
  HIGHLIGHTS_PATH = "/highlights"
  HOST = "https://vector.dev"
  OPERATING_SYSTEMS = ["Linux", "macOS", "Windows"].freeze
  POSTS_PATH = "/blog"

  def self.render_templates(root_dir, templates, relative_link_paths)
    Printer.title("Generating templates in #{root_dir}")

    template_paths =
      Dir.
        glob("#{root_dir}/**/[^_]*.erb", File::FNM_DOTMATCH).
        to_a.
        filter { |path| !path.include?("/.meta/") }.
        filter { |path| !path.include?("/_partials/") }.
        filter { |path| !path.include?("/scripts/generate/") }.
        filter { |path| !path.include?("/vector/") }

    Printer.say("Found #{template_paths.size} templates to render")

    template_paths.each do |template_path|
      render_template(root_dir, templates, template_path, relative_link_paths)
    end
  end

  def self.render_template(root_dir, templates, template_path, relative_link_paths)
    begin
      content = templates.render(template_path)

      if template_path.end_with?(".md.erb")
        content = content.clone
        content = PostProcessors::ComponentImporter.import!(content)
        content = PostProcessors::SectionSorter.sort!(content)
        content = PostProcessors::SectionReferencer.reference!(content)
        content = PostProcessors::OptionLinker.link!(content)
        content = PostProcessors::LinkDefiner.define!(content, templates.metadata.links, relative_link_paths)
        content = PostProcessors::VRLSyntaxConverter.convert!(content)
        content = PostProcessors::VectorHostRemover.convert!(content)

        # must be last
        #content = PostProcessors::LastModifiedSetter.set!(content, template_path)

        # PostProcessors::FrontMatterValidator.validate!(content, template_path)
      end

      content = PostProcessors::AutogenerateLabeler.label!(content, template_path)

      File.write(template_path.gsub(/\.erb$/, ""), content)

      Printer.say("Rendered #{template_path.gsub(root_dir, "")}")
    rescue StandardError
      Printer.say("Error while rendering file #{template_path.gsub(root_dir, "")}")
      raise
    end
  end
end