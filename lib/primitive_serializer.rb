# enough for our use case
class PrimitiveSerializer
  def call(entity)
    case entity
    when Course
      { name: entity.name, id: entity.id }.tap do |serialized|
        serialized[:enrollments] = entity.enrollments_count if entity.respond_to?(:enrollments_count)
      end
    when User
      { email: entity.email, id: entity.id }
    when Array
      entity.map(&method(:call))
    when Enrollment
      { user_id: entity.user_id, course_id: entity.course_id }
    else
      raise RuntimeError.new("Unknown entity to serialize: #{entity.inspect}")
    end
  end
end
