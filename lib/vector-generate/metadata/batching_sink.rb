#encoding: utf-8

require_relative "sink"

module VectorGenerate
  class Metadata
  	class BatchingSink < Sink
  	  def initialize(hash)
  	    super(hash)
  	  end
  	end
  end
end