require_relative "field"

module VectorGenerate
  class Metadata
  	class Metric
  	  attr_reader :schema

  	  def initialize(hash)
  	    @schema = hash.fetch("schema").to_struct_with_name(constructor: Field)
  	  end

  	  def schema_list
  	    @schema_list ||= schema.to_h.values.sort
  	  end

      def to_h
        {
          schema: schema.deep_to_h
        }
      end
  	end
  end
end