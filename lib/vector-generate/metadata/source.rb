#encoding: utf-8

require "ostruct"

require_relative "component"
require_relative "field"
require_relative "fields"

module VectorGenerate
  class Metadata
    class Source < Component
      attr_reader :delivery_guarantee,
        :fields,
        :installation,
        :noun,
        :output_types,
        :link_name,
        :strategies,
        :through_description

      def initialize(hash)
        super(hash)

        # Init

        @delivery_guarantee = hash.fetch("delivery_guarantee")
        @fields = OpenStruct.new
        @installation = hash.fetch("installation").to_struct
        @noun = hash.fetch("noun")
        @output_types = hash.fetch("output_types")
        @strategies = hash["strategies"] || []
        @through_description = hash["through_description"] || ""

        # fields

        fields = hash["fields"] || {}

        if fields["log"]
          @fields.log = Fields.new(fields["log"])
        end

        if fields["metric"]
          @fields.metric = fields.fetch("metric").to_struct
        end
      end

      def can_receive_from?(component)
        false
      end

      def can_send_to?(component)
        component.respond_to?(:input_types) &&
          component.input_types.intersection(output_types).any?
      end

      def collects?
        function_category == "collects"
      end

      def log_fields_list
        @log_fields_list ||= fields.log ? fields.log.fields_list : []
      end

      def to_h
        super.merge(
          noun: noun,
          output_types: output_types,
          through_description: through_description.remove_markdown_links
        )
      end
    end
  end
end