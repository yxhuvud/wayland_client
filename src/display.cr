require "./lib/lib_wayland_client"
require "./lib/lib_xdg_shell"
require "./surface"
require "./registry"
require "./decor"
require "./cursor"

module WaylandClient
  class Display
    getter decorator : Decor { Decor.new(self) }

    def initialize
      @display = LibWaylandClient.wl_display_connect(nil)
      raise "Unable to connect" if @display.null?
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

    def finalize
      LibWaylandClient.wl_display_disconnect(@display)
    end
  end
end
