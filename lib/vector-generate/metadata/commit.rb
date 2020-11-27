require "json"

require "active_support/core_ext/string/filters"

require_relative "commit_scope"

module VectorGenerate
  class Metadata
    class Commit
      TYPES = ["chore", "docs", "enhancement", "feat", "fix", "perf"].freeze
      TYPES_THAT_REQUIRE_SCOPES = ["enhancement", "feat", "fix"].freeze

      attr_reader :author,
        :breaking_change,
        :date,
        :deletions_count,
        :description,
        :files_count,
        :insertions_count,
        :message,
        :pr_number,
        :scopes,
        :sha,
        :type

      attr_accessor :highlight_permalink

      def initialize(attributes)
        @author = attributes.fetch("author")
        @breaking_change = attributes.fetch("breaking_change")
        @deletions_count = attributes["deletions_count"] || 0
        @description = attributes.fetch("description")
        @files_count = attributes.fetch("files_count")
        @date = attributes.fetch("date")
        @insertions_count = attributes["insertions_count"] || 0
        @pr_number = attributes["pr_number"]
        @scopes = (attributes["scopes"] || []).collect { |s| CommitScope.new(s) }
        @sha = attributes.fetch("sha")
        @type = attributes.fetch("type")

        @message = "#{type}(#{scopes.collect(&:name).join(", ")}: #{description} (##{pr_number})"
      end

      def breaking_change?
        @breaking_change == true
      end

      def bug_fix?
        type == "fix"
      end

      def chore?
        type == "chore"
      end

      def components
        return @components if defined?(@components)

        @components =
          if new_feature?
            match =  description.match(/`?(?<name>[a-zA-Z_]*)`? (?<type>source|transform|sink)/i)

            if !match.nil?
              [
                {name: match.fetch(:name).downcase, type: match.fetch(:type).downcase}.to_struct
              ]
            else
              []
            end
          else
            scopes.collect(&:component)
          end
      end

      def doc_update?
        type == "docs"
      end

      def enhancement?
        type == "enhancement"
      end

      def new_feature?
        type == "feat"
      end

      def performance_improvement?
        type == "perf"
      end

      def sha_short
        @sha_short ||= sha.truncate(7, omission: "")
      end

      def sink?
        component_type == "sink"
      end

      def source?
        component_type == "source"
      end

      def to_h
        {
          author: author,
          breaking_change: breaking_change,
          date: date,
          deletions_count: deletions_count,
          description: description,
          files_count: files_count,
          highlight_permalink: highlight_permalink,
          insertions_count: insertions_count,
          message: message,
          pr_number: pr_number,
          scopes: scopes.deep_to_h,
          sha: sha,
          type: type,
        }
      end

      def transform?
        component_type == "transform"
      end
    end
  end
end