module WaylandClient
  module Buffer
    enum Kind
      Memory
    end

    module BufferPool
    end

    class Pool(T)
      include BufferPool

      POOL_SIZE = 2

      getter size : Tuple(Int32, Int32)

      def initialize(width = 0, height = 0)
        @free_buffers = Deque(T).new
        @size = {width, height}
        @checked_out = 0
      end

      def resize(width, height)
        raise "Invalid size" unless width > 0 && height > 0

        @size = {width, height}
      end

      def resize!(width, height, surface, &)
        resize(width, height)
        surface.repaint(self, flush: false) { |buffer| yield buffer }
      end

      def checkout(registry : WaylandClient::Registry)
        if buffer = @free_buffers.pop?
          buffer.resize(*size) if wrong_size?(buffer)
          @checked_out &+= 1
          return buffer
        end

        @checked_out &+= 1
        T.new(registry, self)
          .tap &.resize(*size)
      end

      def available?
        @checked_out < POOL_SIZE
      end

      def checkin(buffer)
        @checked_out &-= 1
        if @checked_out >= POOL_SIZE
          # Practical problem: On window resize mutter won't release
          # buffers back fast enough, meaning despite doing our best
          # to avoid allocating new it doesn't help as mutter
          # prioritizes other things. Sigh.
          buffer.close
        else
          @free_buffers << buffer
        end
      end

      private def wrong_size?(buffer)
        (buffer.width != @size[0]) || (buffer.height != @size[1])
      end
    end
  end
end
