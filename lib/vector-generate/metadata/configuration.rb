require_relative "field"

module VectorGenerate
  class Metadata
    class Configuration
      attr_reader :options, :how_it_works

      def initialize(hash)
        @options = hash.fetch("configuration").to_struct_with_name(constructor: Field)
        @how_it_works = hash.fetch("how_it_works")
      end
    end
  end
end