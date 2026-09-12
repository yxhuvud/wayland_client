# TODO: Write documentation for `WaylandClient`

require "./format"
require "./display"
require "./counter"
require "./buffer/memory"

module WaylandClient
  VERSION = "0.1.0"

  def self.connect(&)
    Client.new.client { |client| yield client }
  end

  class Client
    getter :display, :registry

    def initialize
      @display = Display.new
      @registry = Registry.new(@display)
      @surfaces = [] of GenericSurface
      @frames = [] of Decor::Frame
      @closed = false
      @display.roundtrip
      @registry.seat
      @display.roundtrip
    end

    def client(&)
      yield self
    ensure
      close
    end

    def close
      return if @closed
      @closed = true
      @frames.reverse_each(&.close)
      @display.close_decorator
      @surfaces.reverse_each(&.close)
      @registry.close
      @display.close
    end

    def closed?
      @closed
    end

    def wait_loop
      display.wait_loop
    end

    def seat
      @registry.seat
    end

    def pointer
      seat.pointer
    end

    def keyboard
      seat.keyboard
    end

    def touch
      seat.touch
    end

    def create_frame(surface,
                     title = nil,
                     app_id = nil,
                     initial_size = {400, 300},
                     &configure_callback : LibC::Int, LibC::Int, LibDecor::WindowState -> Void)
      frame = display.decorator.frame(surface, title, app_id, initial_size, configure_callback)
      @frames << frame
      frame
    end

    def create_surface(kind : Buffer::Kind, format, opaque, accepts_input = true)
      surface = format.surface(registry, kind, opaque, accepts_input)
      @surfaces << surface
      surface
    end
  end
end
