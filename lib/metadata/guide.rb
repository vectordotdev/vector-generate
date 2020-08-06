class Metadata
  class Guide
    include Comparable

    attr_reader :author_github,
      :description,
      :id,
      :last_modified_on,
      :permalink,
      :series_position,
      :title

    def initialize(hash)
      @author_github = hash.fetch("author_github")
      @description = hash.fetch("description")
      @id = hash.fetch("id")
      @last_modified_on = hash["last_modified_on"]
      @permalink = hash.fetch("permalink")
      @series_position = hash["series_position"]
      @title = hash.fetch("title")
    end

    def <=>(other)
      id <=> other.id
    end

    def eql?(other)
      self.<=>(other) == 0
    end

    def to_h
      {
        author_github: author_github,
        description: description,
        id: id,
        last_modified_on: last_modified_on,
        series_position: series_position,
        title: title
      }
    end
  end
end