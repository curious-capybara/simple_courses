# frozen_string_literal: true

require 'dry/matcher/result_matcher'
require 'primitive_serializer'

class ResponseCreator
  Data = Struct.new(:message, :status_code, keyword_init: true)

  def initialize(serializer: PrimitiveSerializer.new)
    @serializer = serializer
  end

  def call(result, success_code: 200)
    Dry::Matcher::ResultMatcher.(result) do |m|
      m.success do |entity|
        Data.new(
          message: serializer.call(entity),
          status_code: success_code
        )
      end

      m.failure(:failed) do |_reason, message|
        Data.new(
          message: message,
          status_code: 422
        )
      end

      m.failure(:error) do |_reason, exception|
        # TODO log exception
        Data.new(
          message: 'Internal server error', # we don't want to leak details
          status_code: 500
        )
      end

      m.failure do |payload|
        raise RuntimeError.new("Unknown result: #{payload}")
      end
    end
  end

  private

  attr_reader :serializer
end
