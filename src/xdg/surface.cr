require "../xdg"

class WaylandClient::Xdg
  class Surface
    getter surface
    getter xdg_surface : LibXdgShell::XdgSurface*

    def initialize(@xdg : Xdg, @surface : WaylandClient::Surface, @configure_callback : Surface -> Void)
      @xdg_surface = WaylandClient::LibXdgShell.get_xdg_surface(xdg.xdg_base, surface)
      @listener = LibXdgShell::SurfaceListener.new(
        configure: Proc(Void*, LibXdgShell::XdgSurface*, UInt32, Void).new do |instance, surface, serial|
          instance.as(Surface).configure(surface, serial)
        end
      )
      LibXdgShell.xdg_surface_add_listener(self, pointerof(@listener), self.as(Void*))
    end

    def to_unsafe
      xdg_surface
    end

    def configure(xdg_surface : LibXdgShell::XdgSurface*, serial) : Void
      p :surface_configure
      @configure_callback.call(self)
      LibXdgShell.xdg_surface_ack_configure(self, serial)
      commit
    end

    def attach_buffer(buffer, x = 0, y = 0)
      surface.attach_buffer(buffer, x, y)
    end

    def commit
      surface.commit
    end
  end
end
