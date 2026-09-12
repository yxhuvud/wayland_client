module WaylandClient
  class FrameCallback
    alias Callback = Proc(UInt32, Nil)

    getter surface
    getter frame_handler : Callback?
    getter callback_count
    getter callbacks

    def initialize(@surface : GenericSurface)
      @callback_count = 0
      @callback = LibWaylandClient::WlCallbackListener.new(
        done: Proc(Pointer(Void), Pointer(LibWaylandClient::WlCallback), UInt32, Void).new do |data, cb, time|
          callback = data.as(FrameCallback)
          callback.callbacks.delete(cb)
          callback.frame(time)
          LibWaylandClient.wl_callback_destroy(cb)
        end,
      )
      @frame_handler = nil
      @chained_frames = false
      @callbacks = Set(Pointer(LibWaylandClient::WlCallback)).new
      @closed = false
    end

    def request(frame_handler : Callback, chain = true)
      raise "frame callback is closed" if @closed
      @chained_frames = chain
      @frame_handler = frame_handler
      @callback_count += 1
      server_callback = LibWaylandClient.wl_surface_frame(surface)
      @callbacks << server_callback
      LibWaylandClient.wl_callback_add_listener(server_callback, pointerof(@callback), self.as(Void*))
    end

    def close
      return if @closed
      @closed = true
      @callbacks.each { |callback| LibWaylandClient.wl_callback_destroy(callback) }
      @callbacks.clear
      @callback_count = 0
    end

    protected def frame(time)
      @callback_count -= 1

      # For some reason I don't understand there will always be 2
      # frame callbacks going. If there is more it means window was
      # resized and then we should skip requesting more as that will
      # compound the amount of callbacks.
      skip_next = callback_count > 1

      if handler = @frame_handler
        !skip_next && handler.call(time)

        request(handler, true) if @chained_frames && !skip_next
      else
        raise "Invalid frame setup, no handler detected"
      end
    end
  end
end
