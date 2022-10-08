module WaylandClient
  class Region
    def initialize(compositor, @surface : Surface, add_all = false)
      @region = LibWaylandClient.wl_compositor_create_region(compositor)
      if add_all
        add(0, 0, Int32::MAX, Int32::MAX)
      end
    end

    def to_unsafe
      @region
    end

    def add(x, y, width, height)
      LibWaylandClient.wl_region_add(self, x, y, width, height)
      self
    end

    def subtract(x, y, width, height)
      LibWaylandClient.wl_region_subtract(self, x, y, width, height)

      self
    end

    def opaque!
      LibWaylandClient.wl_surface_set_opaque_region(@surface, self)
    end

    def accepts_input=(value : Bool)
      #       wl_surface_set_input_region
      #      raise "TOODODO"
    end

    def finalize
      LibWaylandClient.wl_region_destroy(self)
    end
  end
end
