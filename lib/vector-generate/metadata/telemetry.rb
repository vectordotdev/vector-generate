require_relative "field"

module VectorGenerate
  class Metadata
    class Telemetry

      attr_reader :metrics

      def initialize(hash)
        @metrics = hash.fetch("metrics").to_struct_with_name(constructor: Field)
      end

      def metrics_list
        @metrics_list ||= metrics.to_h.values.sort_by { |m| m.name }
      end
    end
  end
end