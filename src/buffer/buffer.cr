module WaylandClient
  module Buffer
    module Buffer
      getter width : Int32
      getter height : Int32

      abstract def buffer

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
    end
  end
end
