require_relative "post_processors/autogenerate_labeler"
require_relative "post_processors/component_importer"
require_relative "post_processors/front_matter_validator"
require_relative "post_processors/last_modified_setter"
require_relative "post_processors/link_definer"
require_relative "post_processors/option_linker"
require_relative "post_processors/section_referencer"
require_relative "post_processors/section_sorter"
require_relative "post_processors/vector_host_remover"
require_relative "post_processors/vrl_syntax_converter"

module VectorGenerate
  module PostProcessor
  end
end
