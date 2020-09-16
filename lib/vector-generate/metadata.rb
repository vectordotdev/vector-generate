require "erb"
require "ostruct"
require "toml-rb"

require_relative "metadata/batching_sink"
require_relative "metadata/data_model"
require_relative "metadata/exposing_sink"
require_relative "metadata/field"
require_relative "metadata/guides"
require_relative "metadata/highlight"
require_relative "metadata/installation"
require_relative "metadata/links"
require_relative "metadata/post"
require_relative "metadata/release"
require_relative "metadata/source"
require_relative "metadata/streaming_sink"
require_relative "metadata/template_context"
require_relative "metadata/transform"
require_relative "version"

module VectorGenerate
  # Object representation of the /.meta directory
  #
  # This represents the /.meta directory in object form. Sub-classes represent
  # each sub-component.
  class Metadata
    attr_reader :blog_posts,
      :data_model,
      :domains,
      :env_vars,
      :guides,
      :highlights,
      :installation,
      :links,
      :options,
      :tests,
      :posts,
      :releases,
      :sinks,
      :sources,
      :team,
      :transforms

    def initialize(meta_data, docs_data: {}, guides_data: {}, highlights_data: {}, pages_data: {}, posts_data: {})
      @data_model = DataModel.new(meta_data.fetch("data_model"))
      @domains = meta_data.fetch("domains").collect { |h| OpenStruct.new(h) }
      @guides = guides_data.to_struct_with_name(constructor: Guides)
      @highlights = highlights_data.collect { |hash| Highlight.new(hash) }
      @installation = Installation.new(meta_data.fetch("installation"))
      @options = meta_data.fetch("options").to_struct_with_name(constructor: Field)
      @posts = posts_data.collect { |hash| Post.new(hash) }
      @releases = OpenStruct.new()
      @sinks = OpenStruct.new()
      @sources = OpenStruct.new()
      @transforms = OpenStruct.new()
      @tests = Field.new(meta_data.fetch("tests").merge({"name" => "tests"}))

      # releases

      release_versions =
        meta_data.fetch("releases").collect do |version_string, _release_hash|
          Version.new(version_string)
        end

      meta_data.fetch("releases").collect do |version_string, release_hash|
        version = Version.new(version_string)

        last_version =
          release_versions.
            select { |other_version| other_version < version }.
            sort.
            last

        release_hash["version"] = version_string
        release = Release.new(release_hash, last_version, @highlights)
        @releases.send("#{version_string}=", release)
      end

      # sources

      meta_data.fetch("sources").collect do |source_name, source_hash|
        source_hash["name"] = source_name
        source_hash["posts"] = posts.select { |post| post.source?(source_name) }
        source = Source.new(source_hash)
        @sources.send("#{source_name}=", source)
      end

      # transforms

      meta_data.fetch("transforms").collect do |transform_name, transform_hash|
        transform_hash["name"] = transform_name
        transform_hash["posts"] = posts.select { |post| post.transform?(transform_name) }
        transform = Transform.new(transform_hash)
        @transforms.send("#{transform_name}=", transform)
      end

      # sinks

      meta_data.fetch("sinks").collect do |sink_name, sink_hash|
        sink_hash["name"] = sink_name
        sink_hash["posts"] = posts.select { |post| post.sink?(sink_name) }

        (sink_hash["service_providers"] || []).each do |service_provider|
          provider_hash = (meta_data["service_providers"] || {})[service_provider.downcase] || {}
          sink_hash["env_vars"] = (sink_hash["env_vars"] || {}).merge((provider_hash["env_vars"] || {}).clone)
          sink_hash["options"] = sink_hash["options"].merge((provider_hash["options"] || {}).clone)
        end

        sink =
          case sink_hash.fetch("egress_method")
          when "batching"
            BatchingSink.new(sink_hash)
          when "exposing"
            ExposingSink.new(sink_hash)
          when "streaming"
            StreamingSink.new(sink_hash)
          end

        @sinks.send("#{sink_name}=", sink)
      end

      # links

      links_meta = meta_data.fetch("links").deep_merge(meta_data["links"] || {})

      docs_data.collect { |d| d.fetch("permalink") }

      permalinks =
        {
          "docs" => docs_data.collect { |d| d.fetch("permalink") },
          "guides" => guides_data.values.collect { |category| category.fetch("guides").flatten.collect { |g| g.fetch("permalink") } }.flatten,
          "highlights" => highlights_data.collect { |h| h.fetch("permalink") },
          "pages" => pages_data.collect { |p| p.fetch("permalink") },
          "posts" => posts_data.collect { |p| p.fetch("permalink") }
        }

      @links = Links.new(links_meta, permalinks)

      # env vars

      @env_vars = (meta_data.fetch("env_vars") || {}).to_struct_with_name(constructor: Field)

      components.each do |component|
        component.env_vars.to_h.each do |key, val|
          @env_vars["#{key}"] = val
        end
      end

      # team

      @team =
        meta_data.fetch("team").collect do |member|
          OpenStruct.new(member)
        end
    end

    def components
      @components ||= sources_list + transforms_list + sinks_list
    end

    def env_vars_list
      @env_vars_list ||= env_vars.to_h.values.sort
    end

    def event_types
      @event_types ||= data_model.types
    end

    def latest_patch_releases
      version = Version.new("#{latest_version.major}.#{latest_version.minor}.0")

      releases_list.select do |release|
        release.version >= version
      end
    end

    def latest_release
      @latest_release ||= releases_list.last
    end

    def latest_version
      @latest_version ||= latest_release.version
    end

    def newer_releases(release)
      releases_list.select do |other_release|
        other_release > release
      end
    end

    def new_post
      return @new_post if defined?(@new_post)

      @new_post ||=
        begin
          last_post = posts.last

          if (Date.today - last_post.date) <= 30
            last_post
          else
            nil
          end
        end
    end

    def new_release
      return @new_release if defined?(@new_release)

      @new_release ||=
        begin
          last_release = releases.releases_list.last

          if (Date.today - last_release.date) <= 30
            last_release
          else
            nil
          end
        end
    end

    def post_tags
      @post_tags ||= posts.collect(&:tags).flatten.uniq
    end

    def platform_names
      @platforms ||=
        begin
          (
            installation.operating_systems_list.collect(&:name) +
            installation.package_managers_list.collect(&:name) +
            installation.package_managers_list.collect(&:archs).flatten.uniq +
            installation.platforms_list.collect(&:name)
          ).sort
        end
    end

    def previous_minor_releases(release)
      releases_list.select do |other_release|
        other_release.version < release.version &&
          other_release.version.major != release.version.major &&
          other_release.version.minor != release.version.minor
      end
    end

    def releases_list
      @releases_list ||= @releases.to_h.values.sort
    end

    def relesed_versions
      releases
    end

    def service_providers
      @service_providers ||= components.collect(&:service_providers).flatten.uniq
    end

    def sinks_list
      @sinks_list ||= sinks.to_h.values.sort
    end

    def sources_list
      @sources_list ||= sources.to_h.values.sort
    end

    def to_h
      {
        event_types: event_types,
        guides: guides.deep_to_h,
        installation: installation.deep_to_h,
        latest_highlight: highlights.last.deep_to_h,
        latest_post: posts.last.deep_to_h,
        latest_release: latest_release.deep_to_h,
        highlights: highlights.deep_to_h,
        posts: posts.deep_to_h,
        post_tags: post_tags,
        releases: releases.deep_to_h,
        sources: sources.deep_to_h,
        team: team.deep_to_h,
        transforms: transforms.deep_to_h,
        sinks: sinks.deep_to_h
      }
    end

    def transforms_list
      @transforms_list ||= transforms.to_h.values.sort
    end
  end
end

