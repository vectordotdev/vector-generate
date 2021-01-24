#encoding: utf-8

module VectorGenerate
  module PostProcessors
    # Converts `vrl` syntax highlighting to `ruby`
    class VRLSyntaxConverter
      class << self
        def convert!(content)
          content.gsub(/```vrl/, "```coffee")
        end
      end
    end
  end
end
