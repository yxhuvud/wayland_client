require "./lib/lib_wayland_client"
require "./subsurface"
require "./region"
require "./buffer/pool"
require "./surface/frame_callback"

module WaylandClient
  class Surface
    getter surface : LibWaylandClient::WlSurface*
    getter registry : Registry
    getter(frame_handler) { FrameCallback.new(self) }
    getter display : Display
    getter pool : WaylandClient::Buffer::BufferPool

    def initialize(@registry, opaque : Bool, @display, @pool) # todo: listener
      @surface = WaylandClient::LibWaylandClient.wl_compositor_create_surface(registry.compositor)

      region(add_all: true).opaque! if opaque
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

    def with_eventual_buffer(cb)
      if buf = checkout?(display)
        cb.call(buf)
      else
        pool.callback = cb
      end
    end

    def repaint!(flush = true)
      buffer = pool.checkout(display)
      yield buffer
      attach_buffer(buffer)
      damage_all
      commit
      display.flush if flush
    end

    def resize(x, y)
      pool.resize(x, y)
    end

    def size
      pool.size
    end

    def damage_all
      damage_buffer(0, 0, Int32::MAX, Int32::MAX)
    end

    def create_subsurface(opaque, sync = true, pool = nil)
      Subsurface.new(self, sync, opaque, pool)
    end

    def commit
      LibWaylandClient.wl_surface_commit(surface)
    end

    def finalize
      LibWaylandClient.wl_surface_destroy(self)
    end
  end
end
