require_relative "field"

module VectorGenerate
	class Metadata
		class DataModel
		  TYPES = ["log", "metric"].freeze

		  attr_reader :schema

		  def initialize(hash)
        @schema = hash.fetch("schema").to_struct_with_name(constructor: Field)
		  end

		  def types
		  	TYPES
		  end
		end
	end
end