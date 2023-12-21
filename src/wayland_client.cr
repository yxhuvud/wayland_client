# TODO: Write documentation for `WaylandClient`

require "./format"
require "./display"
require "./counter"
require "./buffer/memory"

module WaylandClient
  VERSION = "0.1.0"

  def self.connect
    Client.new.client { |client| yield client }
  end

  class Client
    getter :display, :registry

    def initialize
      @display = Display.new
      @registry = Registry.new(@display)
      @display.roundtrip
      @registry.seat
      @display.roundtrip
    end

    def client
      yield self
    ensure
      display.disconnect
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
                     &configure_callback : LibC::Int, LibC::Int, LibDecor::WindowState -> Void)
      display.decorator.frame(surface, title, app_id, configure_callback)
    end

    def create_surface(kind : Buffer::Kind, format, opaque, accepts_input = true)
      format.surface(registry, kind, opaque, accepts_input)
    end

    def create_cursor(kind : Buffer::Kind, format, size, hotspot)
      format.cursor(self, kind, size, hotspot) { |buf| yield buf }
    end
  end
end
