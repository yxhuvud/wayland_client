require "./lib/lib_wayland_client"

module WaylandClient
  class Surface
    getter surface : LibWaylandClient::WlSurface*

    def initialize(compositor) # todo: listener
      @surface = WaylandClient::LibWaylandClient.wl_compositor_create_surface(compositor)
    end

    def to_unsafe
      surface
    end

    def attach_buffer(buffer, x = 0, y = 0)
      LibWaylandClient.wl_surface_attach(surface, buffer, x, y)
    end

    def damage_buffer(x, y, width, height)
      LibWaylandClient.wl_surface_damage_buffer(self, x, y, width, height)
    end

    def repaint!(pool, flush = true)
      buffer = pool.checkout
      yield buffer
      attach_buffer(buffer)
      damage_all
      commit
      pool.display.flush if flush
    end

    def damage_all
      damage_buffer(0, 0, Int32::MAX, Int32::MAX)
    end

    def commit
      LibWaylandClient.wl_surface_commit(surface)
    end

    def finalize
      LibWaylandClient.wl_surface_destroy(self)
    end
  end
end
