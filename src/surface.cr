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

    def attach_buffer(buffer, width = 0, height = 0)
      LibWaylandClient.wl_surface_attach(surface, buffer, width, height)
    end

    def damage_buffer(w, h, width, height)
      LibWaylandClient.wl_surface_damage_buffer(self, w, h, width, height)
    end

    def repaint(&)
      if buffer_pool.available?
        begin
          yield attached_buffer
        ensure
          damage_all
          commit
        end
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

    def resize(width, height)
      buffer_pool.resize(width, height)
    end

    def size
      sz = buffer_pool.size
      {width: sz[0], height: sz[1]}
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
