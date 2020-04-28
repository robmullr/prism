require "../shader"

module Prism
  # A pseudo light object that provides some of the basic light properties.
  # This light source is at a location within the scene.
  struct BaseLight
    include Prism::Shader::Serializable

    @[Prism::Shader::Field(name: "color")]
    @color : Vector3f

    @[Prism::Shader::Field(name: "intensity")]
    @intensity : Float32

    getter color, intensity

    def initialize(@color : Vector3f, @intensity : Float32)
    end
  end
end