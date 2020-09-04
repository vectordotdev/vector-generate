#encoding: utf-8

require "uri"

module VectorGenerate
  module PostProcessors
    # Responsible for resolving link definitions.
    #
    # This classes parses all links out of our markdown files and adds definitions
    # at the bottom of the file.
    #
    # See the `Links` class for more info on how links are resoolved.
    class LinkDefiner
      DEFINITION_REGEX = "\\[((?:#{Metadata::Links::CATEGORIES.join("|")})(?:[a-zA-Z0-9_\\-\\.\\/#\\?= ]*))\\]"

      class << self
        def define!(*args)
          new(*args).define!
        end

        def remove_link_footers(content)
          new_content = content.gsub(/#{DEFINITION_REGEX}: ([^\s]*)\n/, '').strip

          parts = new_content.partition(/\n\n\[(?:[a-zA-Z0-9_\-\.\/#\?= ]*)\]:/)
          top = parts.first.strip
          middle = parts.fetch(1)
          bottom = parts.last.strip

          "#{top}\n\n#{middle}#{bottom}".strip
        end
      end

      attr_reader :content, :links, :file_path

      def initialize(content, links, relative_paths = true)
        @content = self.class.remove_link_footers(content)
        @links = links
        @relative_paths = relative_paths == true
      end

      def define!
        #verify_no_direct_links!

        link_ids = content.scan(/\[\[#{DEFINITION_REGEX}\]\]/).collect(&:first).uniq

        link_ids.each do |link_id|
          definition = get_path_or_url(link_id)
          content.gsub!("[[[#{link_id}]]]", definition)
        end

        link_ids = content.scan(/\]#{DEFINITION_REGEX}/).collect(&:first).uniq

        footer_links = []

        link_ids.each do |link_id|
          definition = get_path_or_url(link_id)
          footer_links << "[#{link_id}]: #{definition}"
        end

        <<~EOF
        #{content}

        #{footer_links.sort.join("\n")}
        EOF
      end

      private
        def get_path_or_url(link_id)
          definition = links.fetch(link_id)

          if definition.start_with?("/") && !relative_paths?
            url = HOST + definition.gsub(/\.md$/, "")
            uri = URI.parse(url)

            if !uri.path.end_with?("/")
              uri.path = uri.path + "/"
            end

            definition = uri.to_s
          end

          definition
        end

        def relative_paths?
          @relative_paths == true
        end

        def verify_no_direct_links!
          direct_links = content.scan(/\]\([^#]([a-zA-Z0-9_\-\.\/?= ]*)\)/).flatten.uniq

          if direct_links.any?
            raise <<~EOF
            You used a direct link in the #{file_path.inspect} file:

            #{direct_links.first.inspect.indent(2)}

            This is not allowed in the Vector documentation for validation purposes.
            Please:

            1. Update your links to use a short link.
            2. Add the short link to the /.meta/links.toml file.
            EOF
          end

          true
        end
    end
  end
end
