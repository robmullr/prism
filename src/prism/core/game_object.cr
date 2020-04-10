# require "./game_component"
# require "./transform"
require "./rendering_engine"
require "./moveable"

module Prism::Core
  # Represents an object within the scene graph.
  # The screen graph is composed of a tree of `GameObject`s.
  class GameObject
    include Core::Moveable

    @children : Array(Core::GameObject)
    @components : Array(Core::GameComponent)
    @transform : Core::Transform
    @engine : Core::RenderingEngine?

    getter transform

    def initialize
      @children = [] of Core::GameObject
      @components = [] of Core::GameComponent
      @transform = Core::Transform.new
    end

    # Adds a child `GameObject` to this object
    # The child will inherit certain attributes of the parent
    # such as transformation.
    def add_object(child : Core::GameObject)
      @children.push(child)
      if engine = @engine
        child.engine = engine
      end
      child.transform.parent = @transform
    end

    # Removes a `GameObject` from this object
    def remove_object(child : Core::GameObject)
      @children.delete(child)
      child.transform.parent = nil
    end

    # Alias for add_object
    def add_child(child : Core::GameObject)
      add_object(child)
    end

    # Alias for remove_object
    def remove_child(child : Core::GameObject)
      remove_object(child)
    end

    # Removes a `GameComponent` from this object
    def remove_component(component : Core::GameComponent)
      component.parent = Core::GameObject.new
      @components.delete(component)
      return self
    end

    # Adds a `GameComponent` to this object
    def add_component(component : Core::GameComponent)
      component.parent = self
      @components.push(component)
      return self
    end

    # Performs input update logic on this object's children
    def input_all(tick : RenderLoop::Tick, input : RenderLoop::Input)
      input(tick, input)

      0.upto(@children.size - 1) do |i|
        @children[i].input_all(tick, input)
      end
    end

    # Performs game update logic on this object's children
    def update_all(tick : RenderLoop::Tick)
      update(tick)

      0.upto(@children.size - 1) do |i|
        @children[i].update_all(tick)
      end
    end

    # Performs rendering operations on this object's children
    #
    # > Warning: the *rendering_engine* property will be deprecated in the future
    def render_all(shader : Core::Light, rendering_engine : Core::RenderingEngine)
      render(shader, rendering_engine)

      0.upto(@children.size - 1) do |i|
        @children[i].render_all(shader, rendering_engine)
      end
    end

    # Performs input update logic on this object
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @transform.update

      0.upto(@components.size - 1) do |i|
        @components[i].input(tick, input)
      end
    end

    # Performs game update logic on this object
    def update(tick : RenderLoop::Tick)
      0.upto(@components.size - 1) do |i|
        @components[i].update(tick)
      end
    end

    # Performs rendering operations on this object
    #
    # > Warning: the *rendering_engine* property will be deprecated in the future
    def render(shader : Core::Light, rendering_engine : Core::RenderingEngine)
      0.upto(@components.size - 1) do |i|
        @components[i].render(shader, rendering_engine)
      end
    end

    # Returns an array of all attached objects including it's self
    def get_all_attached : Array(Core::GameObject)
      result = [] of Core::GameObject
      @children.each do |c|
        result.concat(c.get_all_attached)
      end
      result.push(self)
      return result
    end

    # Sets the `CoreEngine` on this object
    # This allows the object and it's children to interact with the engine
    def engine=(engine : Core::RenderingEngine)
      if @engine != engine
        @engine = engine

        0.upto(@components.size - 1) do |i|
          @components[i].add_to_engine(engine)
        end

        0.upto(@children.size - 1) do |i|
          @children[i].engine = engine
        end
      end
    end
  end

  # TODO: this will become the new name. Maybe we should call this an Element instead?
  alias Object = Core::GameObject
end
