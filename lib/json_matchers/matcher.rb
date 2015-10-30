require "json_schema"

module JsonMatchers
  class Matcher
    def initialize(schema_path, **options)
      @schema_path = schema_path
      @options = options
    end

    def matches?(response)
      @response = response

      begin
        schema_data = JSON.parse(File.read(@schema_path.to_s))
        response_body = JSON.parse(@response.body)
        json_schema = JsonSchema.parse!(schema_data)
        json_schema.expand_references
        json_schema.validate!(response_body)
      rescue RuntimeError => ex
        @validation_failure_message = ex.message
        return false
      rescue JsonSchema::SchemaError, JSON::ParserError => ex
        raise InvalidSchemaError
      end

      true
    end

    def validation_failure_message
      @validation_failure_message.to_s
    end

    private

    attr_reader :schema_path, :options
  end
end
