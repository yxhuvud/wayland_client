require "./lib/lib_wayland_client"
require "./subsurface"
require "./region"
require "./buffer/pool"
require "./surface/frame_callback"

module WaylandClient
  module GenericSurface
  end

  class Surface(Format)
    include GenericSurface

    getter surface : LibWaylandClient::WlSurface*
    getter(frame_handler) { FrameCallback.new(self) }
    getter registry : Registry
    getter buffer_pool : WaylandClient::Buffer::Pool(WaylandClient::Buffer::Memory(Format))

    def initialize(@registry, @buffer_pool, opaque, accepts_input = true) # todo: listener
      @surface = WaylandClient::LibWaylandClient.wl_compositor_create_surface(registry.compositor)
      region.accepts_input if !accepts_input
      region(add_all: true).opaque! if opaque
    end

    def format
      Format
    end

    def region(add_all = false)
      Region.new(registry.compositor, self, add_all: add_all)
    end

    def request_frame(*args)
      frame_handler.request(*args)
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

    def repaint(&)
      if buffer_pool.available?
        yield attached_buffer
        damage_all
        commit
        true
      else
        false
      end
    end

    # Return a buffer attached to the surface. Be sure to damage and
    # commit the surface once any work is done, otherwise any changes
    # to the buffer won't be applied.

    # Warning: Will give a different buffer each time. Call this only
    # once each time an update is to happen.
    def attached_buffer
      buffer = buffer_pool.checkout(registry)
      attach_buffer(buffer)
      buffer
    end

    def resize(x, y)
      buffer_pool.resize(x, y)
    end

    def size
      sz = buffer_pool.size
      {x: sz[0], y: sz[1]}
    end

    def damage_all
      damage_buffer(0, 0, Int32::MAX, Int32::MAX)
    end

    def create_subsurface(kind : Buffer::Kind, format, opaque, sync = true, position = {0, 0})
      format.subsurface(self, kind, opaque, sync: sync, position: position)
    end

    def commit
      LibWaylandClient.wl_surface_commit(surface)
    end

    def close
      LibWaylandClient.wl_surface_destroy(self)
    end
  end
end
