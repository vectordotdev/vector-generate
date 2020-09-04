module VectorGenerate
  class Metadata
    class Post
      include Comparable

      attr_reader :author_github,
        :date,
        :description,
        :id,
        :path,
        :permalink,
        :tags,
        :title

      def initialize(hash)
        @author_github = hash.fetch("author_github")
        @date = Date.parse(hash.fetch("date"))
        @description = hash.fetch("description")
        @id = hash.fetch("id")
        @permalink = hash.fetch("permalink")
        @tags = hash.fetch("tags")
        @title = hash.fetch("title")
      end

      def <=>(other)
        date <=> other.date
      end

      def eql?(other)
        self.<=>(other) == 0
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

      def type?(name)
        tag?("type: announcement")
      end

      def to_h
        {
          author_github: author_github,
          date: date,
          description: description,
          id: id,
          path: path,
          permalink: permalink,
          tags: tags,
          title: title
        }
      end
    end
  end
end
