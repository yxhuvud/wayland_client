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

      getter registry, pool, width, height
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

      def map!(&)
        buf = buffer
        height.times do |h|
          width.times do |w|
            buf.value = yield(w, h)
            buf += 1
          end
        end
      end

      def map!(width_range, height_range, &)
        width_end = width_range.excludes_end? ? width_range.end - 1 : width_range.end
        height_end = height_range.excludes_end? ? height_range.end - 1 : height_range.end

        raise "invalid range: width #{width_range} - max: #{width}" if width_end >= width
        raise "invalid range: height #{height_range} - may: #{height}" if height_end >= height

        # upper left corner of what to paint
        buf = buffer + height_range.begin * width + width_range.begin
        width_offset = width - (width_end - width_range.begin + 1)

        height_range.each do |h|
          width_range.each do |w|
            buf.value = yield(w, h)
            buf += 1
          end
          buf += width_offset
        end
      end

      def fill(value)
        map! { value }
      end

      def fill(width_range, height_range, value)
        map!(width_range, height_range) { value }
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
