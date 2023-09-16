require "./lib/lib_wayland_client"
require "./lib/lib_xdg_shell"
require "./surface"
require "./registry"
require "./decor"

module WaylandClient
  class Display
    def self.connect
      display = new(LibWaylandClient.wl_display_connect(nil))
      raise "Unable to connect" unless display

      yield display
    ensure
      display.disconnect if display
    end

    getter registry

    getter decorator : Decor { Decor.new(self) }

    def initialize(@display : Pointer(LibWaylandClient::WlDisplay))
      @registry = Registry.new(@display)
      roundtrip
    end

    def to_unsafe
      @display
    end

    def disconnect
      LibWaylandClient.wl_display_disconnect(@display)
    end

    def roundtrip
      LibWaylandClient.wl_display_roundtrip(@display)
    end

    def dispatch
      LibWaylandClient.wl_display_dispatch(@display)
    end

    def flush
      LibWaylandClient.wl_display_flush(@display)
    end

    def wait_loop
      if decorator.has_frame?
        decorator.wait_loop
      else
        # TODO: Get better support for raw xdg_toplevels. Autobreak
        # from loop is needed there too.
        fd = LibWaylandClient.wl_display_get_fd(@display)
        file = IO::FileDescriptor.new(fd)
        loop do
          flush
          file.wait_readable
          dispatch
        end
      end
    end

    def seat
      @registry.seat
    end

    def create_frame(surface,
                     title = nil,
                     app_id = nil,
                     &configure_callback : LibC::Int, LibC::Int, LibDecor::WindowState -> Void)
      decorator.frame(surface, title, app_id, configure_callback)
    end

    def create_surface(kind, format, opaque, accepts_input = true)
      buffer_pool = format.pool(kind)
      format.surface(self, buffer_pool, opaque, accepts_input)
    end

    def finalize
      LibWaylandClient.wl_display_disconnect(@display)
    end
  end
end
