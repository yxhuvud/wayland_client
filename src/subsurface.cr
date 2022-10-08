module WaylandClient
  class Subsurface
    getter surface
    getter parent

    def initialize(@parent : Surface, sync)
      @surface = Surface.new(parent.registry)
      @subsurface = WaylandClient::LibWaylandClient.wl_subcompositor_get_subsurface(
        parent.registry.subcompositor, surface, parent
      )
      self.sync = sync
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
  end
end
