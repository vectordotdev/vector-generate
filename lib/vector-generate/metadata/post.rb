module VectorGenerate
  class Metadata
    class Post
      include Comparable

      attr_reader :authors_githubs,
        :date,
        :description,
        :id,
        :path,
        :permalink,
        :tags,
        :title

      def initialize(hash)
        @authors_githubs = hash.fetch("authors_githubs")
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
          authors_githubs: authors_githubs,
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
