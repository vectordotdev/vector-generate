require_relative "log"
require_relative "metric"

class Metadata
	class DataModel
	  TYPES = ["log", "metric"].freeze

	  attr_reader :log, :metric

	  def initialize(hash)
	    @log = Log.new(hash.fetch("log"))
	    @metric = Metric.new(hash.fetch("metric"))
	  end

	  def to_h
	  	{
	  		log: log.deep_to_h,
	  		metric: metric.deep_to_h
	  	}
	  end

	  def types
	    TYPES
	  end
	end
end