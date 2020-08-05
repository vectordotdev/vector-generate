require_relative "guide"

class Metadata
  class Guides
    attr_reader :children, :description, :guides, :name, :series, :title

    def initialize(hash)
      @description = hash.fetch("description")
      @guides = hash.fetch("guides").collect { |g| Guide.new(g) }
      @name = hash.fetch("name")
      @series = hash.fetch("series")
      @title = hash.fetch("title")
    end

    def to_h
      {
        children: children.deep_to_h,
        description: description,
        guides: guides.deep_to_h,
        name: name,
        series: series,
        title: title
      }
    end
  end
end