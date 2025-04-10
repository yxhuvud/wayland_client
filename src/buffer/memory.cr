require "./pool"
require "./wl_pool"
require "../registry"
require "../lib/lib_c"

module WaylandClient
  module Buffer
    module Buffer
    end

    class Memory(T)
      include ::WaylandClient::Buffer::Buffer

      getter registry, pool, x_size, y_size
      getter wl_pool : WlPool(T)

      def initialize(@registry : WaylandClient::Registry, @pool : Pool(Memory(T)))
        @wl_buffer = Pointer(LibWaylandClient::WlBuffer).null
        @x_size = @y_size = 0

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

      def resize(x, y)
        wl_pool.allocate_buffer(x, y, pixel_size, self)
        @x_size = x - 1
        @y_size = y - 1
      end

      private def buffer
        wl_pool.buffer.as(Pointer(T))
      end

      def to_slice
        Slice(T).new(buffer, (x_size + 1) * (y_size + 1))
      end

      def map!(&)
        buf = buffer
        0.to(@y_size) do |y|
          0.to(@x_size) do |x|
            buf.value = yield(x, y)
            buf += 1
          end
        end
      end

      def map!(xrange, yrange, &)
        buf_with_xoffset = buffer + xrange.begin
        yoffset = @y_size + 1
        yrange.each do |y|
          buf = buf_with_xoffset + yoffset &* (y)
          xrange.each do |x|
            buf.value = yield(x, y)
            buf += 1
          end
        end
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
