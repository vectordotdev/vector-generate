#encoding: utf-8

module VectorGenerate
  module PostProcessors
    # Remove the `https://vector.dev` host
    #
    # This ensures that the site works on other domains, like master.vector.dev
    class VectorHostRemover
      class << self
        def convert!(content)
          content.gsub("https://vector.dev", "").gsub("https://www.vector.dev", "")
        end
      end
    end
  end
end
