#encoding: utf-8

require 'net/http'

require_relative "links/resolver"

module VectorGenerate
  # Links
  #
  # This class implements reader methods for statically and dynamically defined
  # links.
  #
  # == Statically defined linked
  #
  # Links can be statically defined in the ./meta/links.toml file.
  #
  # == Dynamically defined linked
  #
  # To reduce the burden of having to manually define every link this class
  # implement dynamic readers that can be found in the `#fetch_dynamic_url`
  # method.
  class Metadata
    class Links
      CATEGORIES = ["docs", "guides", "pages", "urls"].freeze

      attr_reader :values

      def initialize(links, permalinks)
        @links = links
        @resolver = Resolver.new(permalinks)
        @values = {}
      end

      def exists?(id)
        fetch(id)
        true
      rescue KeyError
        false
      end

      def fetch(id)
        parsed_id = parse_id!(id)

        if @links[parsed_id.category] && @links[parsed_id.category][parsed_id.name]
          value = @links[parsed_id.category][parsed_id.name]
          value = [value, parsed_id.query].compact.join("?")
          value = [value, parsed_id.anchor].compact.join("#")
          value
        else
          @resolver.resolve!(parsed_id)
        end
      end

      def fetch_id(id)
        # Docusaurus does not allow a leading or trailing `/`
        fetch(id).split("/")[2..-1].join("/").gsub(/\/$/, "")
      end

      private
        def normalize_name(name)
          name.downcase.gsub(".", "/").gsub("-", "_").split("#", 2).first
        end

        def parse_id!(id)
          id_parts = id.split(".", 2)

          if id_parts.length != 2
            raise ArgumentError.new("Link id is invalid! #{id}")
          end

          category = id_parts[0]
          suffix = id_parts[1]
          hash_parts = suffix.split("#", 2)
          name = hash_parts[0]
          anchor = hash_parts[1]
          query_parts = name.split("?", 2)
          name = query_parts[0]
          normalized_name = normalize_name(name)
          query = query_parts[1]

          OpenStruct.new({
            :anchor => anchor,
            :category => category,
            :id => id,
            :name => name,
            :normalized_name => normalized_name,
            :query => query
          })
        end
    end
  end
end
