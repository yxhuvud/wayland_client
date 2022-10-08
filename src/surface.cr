require "./lib/lib_wayland_client"
require "./subsurface"

module WaylandClient
  class Surface
    alias FrameCallback = Proc(UInt32, Nil)
    getter surface : LibWaylandClient::WlSurface*
    getter registry : Registry
    getter frame_handler : FrameCallback?
    property callback_count

    def initialize(@registry : Registry) # todo: listener
      @callback_count = 0
      @surface = WaylandClient::LibWaylandClient.wl_compositor_create_surface(registry.compositor)
      @frame_callback = LibWaylandClient::WlCallbackListener.new(
        done: Proc(Pointer(Void), Pointer(LibWaylandClient::WlCallback), UInt32, Void).new do |data, cb, time|
          LibWaylandClient.wl_callback_destroy(cb)
          data.as(Surface).frame(time)
        end,
      )
      @frame_handler = nil
      @chained_frames = false
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

    def request_frame(frame_handler : FrameCallback, chain = true, clear_callback = true)
      @chained_frames = chain
      @frame_handler = frame_handler
      @callback_count += 1
      server_callback = LibWaylandClient.wl_surface_frame(surface)
      LibWaylandClient.wl_callback_add_listener(server_callback, pointerof(@frame_callback), self.as(Void*))
    end

    protected def frame(time)
      @callback_count -= 1

      # For some reason I don't understand there will always be 2
      # frame callbacks going. If there is more it means window was
      # resized and then we should skip requesting more as that will
      # compound the amount      # of callbacks.
      skip_next = callback_count > 1

      if handler = @frame_handler
        handler.call(time)
        request_frame(handler, true, false) if @chained_frames && !skip_next
      else
        raise "Invalid frame setup, no handler detected"
      end
    end

    def damage_all
      damage_buffer(0, 0, Int32::MAX, Int32::MAX)
    end

    def create_subsurface(sync = true)
      Subsurface.new(self, sync)
    end

    def commit
      LibWaylandClient.wl_surface_commit(surface)
    end

    def finalize
      LibWaylandClient.wl_surface_destroy(self)
    end
  end
end
