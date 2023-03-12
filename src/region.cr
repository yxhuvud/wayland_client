module WaylandClient
  class Region
    def initialize(compositor, @surface : Surface, add_all = false)
      @region =
        if add_all
          # Region commands with null region affect the whole thing
          Pointer(LibWaylandClient::WlRegion).null
        else
          LibWaylandClient.wl_compositor_create_region(compositor)
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

    def accepts_input
      LibWaylandClient.wl_surface_set_input_region(@surface, self)
    end

    def finalize
      LibWaylandClient.wl_region_destroy(@region) if @region
    end
  end
end
