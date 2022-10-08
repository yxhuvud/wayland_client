module WaylandClient
  module Buffer
    macro new(kind, format)
      case :{{kind.id}}
      when :memory # TODO: enum.. # FIXME when multiple kinds are supported: don't need them to be required!
        WaylandClient::Buffer::Pool(WaylandClient::Buffer::Memory({{format.id}})).new
      else
        raise "Unreachable"
      end
    end

    module BufferPool
    end

    class Pool(T)
      include BufferPool

      POOL_SIZE = 2

      getter size : Tuple(Int32, Int32)
      property callback : Proc(Nil)?

      def initialize(x = 0, y = 0)
        @free_buffers = Deque(T).new
        @size = {x, y}
        @checked_out = 0
        @callback = nil
      end

      def resize(x, y)
        raise "Invalid size" unless x > 0 && y > 0

        @size = {x, y}
      end

      def resize!(x, y, surface)
        resize(x, y)
        surface.repaint!(self, flush: false) { |buffer| yield buffer }
      end

      def checkout(display : WaylandClient::Display)
        if buffer = @free_buffers.pop?
          buffer.resize(*size) if wrong_size?(buffer)
          @checked_out &+= 1
          return buffer
        end

        @checked_out &+= 1
        T.new(display, self)
          .tap &.resize(*size)
      end

      def available?
        @checked_out < POOL_SIZE
      end

      def checkin(buffer)
        @checked_out &-= 1
        if @checked_out >= POOL_SIZE
          buffer.close
          raise "FAIL" if callback
        else
          @free_buffers << buffer
          if cb = @callback
            @callback = nil
            cb.call
          end
        end
      end

      private def wrong_size?(buffer)
        (buffer.x_size &+ 1 != @size[0]) || (buffer.y_size &+ 1 != @size[1])
      end
    end
  end
end
