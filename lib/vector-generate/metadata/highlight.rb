module VectorGenerate
  class Metadata
    class Highlight
      include Comparable

      attr_reader :author_github,
        :date,
        :description,
        :hide_on_release_notes,
        :id,
        :permalink,
        :pr_numbers,
        :release,
        :tags,
        :title

      def initialize(hash)
        @author_github = hash.fetch("author_github")
        @date = Date.parse(hash.fetch("date"))
        @description = hash.fetch("description")
        @hide_on_release_notes = hash.fetch("hide_on_release_notes")
        @id = hash.fetch("id")
        @permalink = hash.fetch("permalink")
        @pr_numbers = hash.fetch("pr_numbers")
        @release = hash.fetch("release")
        @tags = hash.fetch("tags")
        @title = hash.fetch("title")

        # Requirements

        if breaking_change? && !hash.fetch("content").include?("## Upgrade Guide")
          raise Exception.new(
            <<~EOF
            The following "breaking change" highlight does not have an "Upgrade
            Guide" section:

                #{id}

            This is required for all "breaking change" highlights to ensure
            we provide a good, consistent UX for upgrading users. To fix this,
            please add a "Upgrade Guide" section:

                ## Upgrade Guide

                Make the following changes in your `vector.toml` file:

                ```diff title="vector.toml"
                 [sinks.example]
                   type = "example"
                -  remove = "me"
                +  add = "me"
                ```

                That's it!

            EOF
          )
        end
      end

      def <=>(other)
        date <=> other.date
      end

      def breaking_change?
        type?("breaking change")
      end

      def eql?(other)
        self.<=>(other) == 0
      end

      def hide_on_release_notes?
        @hide_on_release_notes == true
      end

      def sink?(name)
        tag?("sink: #{name}")
      end

      def source?(name)
        tag?("source: #{name}")
      end

      def tag?(name)
        tags.any? { |tag| tag == name }
      end

      def transform?(name)
        tag?("transform: #{name}")
      end

      def type
        @type ||=
          begin
            type_tag = tags.find { |tag| tag.start_with?("type: ") }
            type_tag.gsub(/^type: /, '')
          end
      end

      def type?(name)
        tag?("type: #{name}")
      end

      def to_h
        {
          author_github: author_github,
          date: date,
          description: description,
          hide_on_release_notes: hide_on_release_notes,
          id: id,
          permalink: permalink,
          tags: tags,
          title: title
        }
      end
    end
  end
end
