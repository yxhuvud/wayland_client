require "./lib/lib_wayland_client"

module WaylandClient
  class Surface
    getter surface : LibWaylandClient::WlSurface*

    def initialize(compositor) # todo: listener
      @surface = WaylandClient::LibWaylandClient.wl_compositor_create_surface(compositor)
      # @listener = LibXdgShell::SurfaceListener.new(
      #   configure: Proc(Void*, LibXdgShell::WlSurface*, UInt32, Void).new do |instance, surface, serial|
      #     instance.as(Surface).configure(surface, serial)
      #   end
      # )
      # LibXdgShell.xdg_surface_add_listener(xdg_surface, pointerof(@listener), self.as(Void*))
    end

    def to_unsafe
      surface
    end

    # def configure(xdg_surface : LibXdgShell::XdgSurface*, serial) : Void
    #   p :surface_configure
    #   @configure_callback.call(self)
    #   LibXdgShell.xdg_surface_ack_configure(xdg_surface, serial)
    #   commit
    # end

    def attach_buffer(buffer, x = 0, y = 0)
      WaylandClient::LibWaylandClient.wl_surface_attach(surface, buffer, x, y)
    end

    def damage_buffer(x1, x2, x3, x4)
      LibWaylandClient.wl_surface_damage_buffer(self, x1, x2, x3, x4)
    end

    def commit
      WaylandClient::LibWaylandClient.wl_surface_commit(surface)
    end

    def finalize
      # TODO: destroy surface
    end
  end
end
