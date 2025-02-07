# frozen_string_literal: true

module GraphQL
  module Tracing
    # This implementation forwards events to a notification handler (i.e.
    # ActiveSupport::Notifications or Dry::Monitor::Notifications)
    # with a `graphql` suffix.
    module NotificationsTrace
      include PlatformTrace
      # Initialize a new NotificationsTracing instance
      #
      # @param engine [#instrument(key, metadata, block)] The notifications engine to use
      def initialize(engine:, **rest)
        @notifications_engine = engine
        super
      end

      {
        "lex" => "lex.graphql",
        "parse" => "parse.graphql",
        "validate" => "validate.graphql",
        "analyze_multiplex" => "analyze_multiplex.graphql",
        "analyze_query" => "analyze_query.graphql",
        "execute_query" => "execute_query.graphql",
        "execute_query_lazy" => "execute_query_lazy.graphql",
        "execute_field" => "execute_field.graphql",
        "execute_field_lazy" => "execute_field_lazy.graphql",
        "authorized" => "authorized.graphql",
        "authorized_lazy" => "authorized_lazy.graphql",
        "resolve_type" => "resolve_type.graphql",
        "resolve_type_lazy" => "resolve_type.graphql",
      }.each do |trace_method, platform_key|
        module_eval <<-RUBY, __FILE__, __LINE__
          def #{trace_method}(**metadata, &blk)
            @notifications_engine.instrument("#{platform_key}", metadata, &blk)
          end
        RUBY
      end
    end
  end
end
