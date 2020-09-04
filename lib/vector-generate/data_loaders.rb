require_relative "data_loaders/docs_loader"
require_relative "data_loaders/guides_loader"
require_relative "data_loaders/highlights_loader"
require_relative "data_loaders/meta_loader"
require_relative "data_loaders/pages_loader"
require_relative "data_loaders/posts_loader"

module VectorGenerate
  module DataLoaders
    def self.load!(meta_dir, docs_dir, guides_dir, highlights_dir, pages_dir, posts_dir)
      meta = MetaLoader.load!(File.join(meta_dir))
      Printer.say("Loaded #{meta_dir}")

      docs = DocsLoader.load!(docs_dir)
      Printer.say("Loaded #{docs_dir}")

      guides = GuidesLoader.load!(guides_dir)
      Printer.say("Loaded #{guides_dir}")

      highlights = HighlightsLoader.load!(highlights_dir)
      Printer.say("Loaded #{highlights_dir}")

      pages = PagesLoader.load!(pages_dir)
      Printer.say("Loaded #{pages_dir}")

      posts = PostsLoader.load!(posts_dir)
      Printer.say("Loaded #{posts_dir}")

      permalinks =
        {
          "docs" => docs.collect { |d| d.fetch("permalink") },
          "guides" => guides.values.collect { |category| category.fetch("guides").flatten.collect { |g| g.fetch("permalink") } }.flatten,
          "highlights" => highlights.collect { |h| h.fetch("permalink") },
          "pages" => pages.collect { |p| p.fetch("permalink") },
          "posts" => posts.collect { |p| p.fetch("permalink") }
        }

      OpenStruct.new({
        "meta" => meta,
        "docs" => docs,
        "guides" => guides,
        "highlights" => highlights,
        "pages" => pages,
        "posts" => posts,
        "permalinks" => permalinks
      })
    end
  end
end