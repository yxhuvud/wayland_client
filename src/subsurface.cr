module WaylandClient
  class Subsurface(Format)
    getter surface : Surface(Format)
    getter parent : GenericSurface

    def initialize(@parent : GenericSurface, kind, opaque, sync, position)
      buffer_pool = Format.pool(kind)
      @surface = Format.surface(parent.registry, buffer_pool, opaque)
      @subsurface = WaylandClient::LibWaylandClient.wl_subcompositor_get_subsurface(
        parent.registry.subcompositor,
        surface,
        parent
      )
      self.sync = sync
      self.position = position
    end

    def position=(position)
      WaylandClient::LibWaylandClient.wl_subsurface_set_position(self, *position)
    end

    def sync=(value : Bool)
      if value
        WaylandClient::LibWaylandClient.wl_subsurface_set_sync(self)
      else
        WaylandClient::LibWaylandClient.wl_subsurface_set_desync(self)
      end
    end

    def to_unsafe
      @subsurface
    end

    def close
      WaylandClient::LibWaylandClient.wl_subsurface_destroy(@subsurface)
      @surface.close
    end
  end
end
