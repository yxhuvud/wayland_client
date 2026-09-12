require "./lib/lib_wayland_client"
require "./lib/lib_xdg_shell"
require "./surface"
require "./registry"
require "./decor"
require "./cursor"

module WaylandClient
  class Display
    @decorator : Decor?
    @closed = false

    getter decorator : Decor { @decorator ||= Decor.new(self) }

    def initialize
      @display = LibWaylandClient.wl_display_connect(nil)
      @connected = true

      raise "Unable to connect" if @display.null?
    end

    def connected?
      @connected
    end

    def to_unsafe
      @display
    end

    def disconnect
      return if @closed
      @closed = true
      LibWaylandClient.wl_display_disconnect(@display)
      @connected = false
    end

    def close
      close_decorator
      disconnect
    end

    # Releases the decorator and its frames before surfaces are destroyed.
    def close_decorator
      @decorator.try &.close
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
        event_loop = Crystal::EventLoop.current
        loop do
          flush
          event_loop.wait_readable(file)
          dispatch
        end
      end
    end

    def finalize
      close
    end
  end
end
