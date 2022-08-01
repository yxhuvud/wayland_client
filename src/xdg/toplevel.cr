require "./surface"

class WaylandClient::Xdg
  class Toplevel
    getter toplevel, surface, xdg
    getter bounds

    def initialize(@xdg : Xdg, wl_surface : WaylandClient::Surface, @configure_callback : Toplevel, Surface -> Void)
      @surface = Surface.new(xdg, wl_surface, Proc(Surface, Void).new { })
      @toplevel = WaylandClient::LibXdgShell.xdg_surface_get_toplevel(xdg_surface)

      @xdg_toplevel_listener = LibXdgShell::ToplevelListener.new(
        configure: Proc(Void*, LibXdgShell::XdgToplevel*, Int32, Int32, LibWaylandClient::WlArray*, Void).new do |instance, _toplevel, width, height, states|
          p :toplevel_configure
          instance.as(Toplevel).configure(width, height, states)
        end,
        close: Proc(Void*, LibXdgShell::XdgToplevel*, Void).new do |instance, _toplevel|
          p :toplevel_close
          instance.as(Toplevel).close
        end,
        configure_bounds: Proc(Void*, LibXdgShell::XdgToplevel*, Int32, Int32, Void).new do |instance, _toplevel, width, height|
          p :toplevel_configure_bounds
          instance.as(Toplevel).configure_bounds(width, height)
        end,
      )
      LibXdgShell.xdg_toplevel_add_listener(self, pointerof(@xdg_toplevel_listener), self.as(Void*))
      @bounds = {-1, -1}
      surface.commit
    end

    def to_unsafe
      toplevel
    end

    def xdg_surface
      surface.xdg_surface
    end

    def configure(width, height, states)
      @configure_callback.call(self, surface)
    end

    def close
    end

    def configure_bounds(width, height)
      @bounds = {width, height}
    end

    def title=(title)
      WaylandClient::LibXdgShell.xdg_toplevel_set_title(self, title)
    end
  end
end
