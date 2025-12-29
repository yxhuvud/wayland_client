require "./pool"
require "./wl_pool"
require "./buffer"
require "../registry"
require "../lib/lib_c"

module WaylandClient
  module Buffer
    class Memory(T)
      include ::WaylandClient::Buffer::Buffer

      getter registry, pool
      getter wl_pool : WlPool(T)

      def initialize(@registry : WaylandClient::Registry, @pool : Pool(Memory(T)))
        @wl_buffer = Pointer(LibWaylandClient::WlBuffer).null
        @width = @height = 0

        @wl_pool = WlPool(T).new(@registry.shm, release)
      end

      private def release
        Proc(Void*, Pointer(LibWaylandClient::WlBuffer), Void).new do |data, _wl_buffer|
          data.as(Memory(T)).checkin
        end
      end

      protected def checkin
        pool.checkin(self)
      end

      def resize(width, height)
        wl_pool.allocate_buffer(width, height, pixel_size, self)
        @width = width
        @height = height
      end

      private def buffer
        wl_pool.buffer.as(Pointer(T))
      end

      def to_slice
        Slice(T).new(buffer, width * height)
      end

      def to_unsafe
        wl_pool.wl_buffer
      end

      def close
        @wl_pool.close
      end

      private def pixel_size
        sizeof(T)
      end
    end
  end
end
