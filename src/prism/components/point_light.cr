require "./base_light"

module Prism
  # Represents a point light.
  # That is, light that radiates out from a point.
  class PointLight < BaseLight
    include Uniform::Serializable
    COLOR_DEPTH = 256.0f32

    @[Uniform::Field(struct: "PointLight", key: "range")]
    @range : Float32
    @[Uniform::Field(struct: "PointLight", key: "atten")]
    @attenuation : Attenuation

    property range
    getter attenuation

    def initialize
      initialize(Vector3f.new(1, 0, 0), 0.5, Attenuation.new(0.0f32, 0.0f32, 1.0f32))
    end

    def initialize(color : Vector3f)
      initialize(color, 0.5, Attenuation.new(0.0f32, 0.0f32, 1.0f32))
    end

    def initialize(color : Vector3f, intensity : Float32, @attenuation : Attenuation)
      super(color, intensity)

      a = @attenuation.exponent
      b = @attenuation.linear
      c = @attenuation.constant - COLOR_DEPTH * intensity * color.max

      @range = (-b + Math.sqrt(b * b - 4.0f32 * a * c)) / (2.0f32 * a)

      self.shader = Shader.new("forward-point")
    end
  end
end
