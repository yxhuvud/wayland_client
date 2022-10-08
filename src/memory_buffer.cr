require "./display"

module WaylandClient
  module Buffer
    macro new(kind, format, display)
      case :{{kind.id}}
      when :memory # TODO: enum..
        WaylandClient::Buffer::Pool(WaylandClient::Buffer::Memory({{format.id}})).new({{display.id}})
      else
        raise "Unreachable"
      end
    end

    class Pool(T)
      getter display
      getter size : Tuple(Int32, Int32)

      def initialize(@display : WaylandClient::Display, x = 0, y = 0)
        @free_buffers = Deque(T).new
        @size = {x, y}
        @checked_out = 0
      end

      def resize(x, y)
        raise "Invalid size" unless x > 0 && y > 0

        @size = {x, y}
      end

      def resize!(x, y, surface)
        resize(x, y)
        surface.repaint!(self, flush: false) { |buffer| yield buffer }
      end

      def checkout
        if buffer = @free_buffers.pop?
          buffer.resize(*size) if wrong_size?(buffer)
          @checked_out &+= 1
          return buffer
        end

        @checked_out &+= 1
        T.new(display, self)
          .tap &.resize(*size)
      end

      def checkin(buffer)
        @checked_out &-= 1
        if @free_buffers.size > 3
          buffer.close
        else
          @free_buffers << buffer
        end
      end

      private def wrong_size?(buffer)
        (buffer.x_size &+ 1 != @size[0]) || (buffer.y_size &+ 1 != @size[1])
      end
    end

    class Memory(T)
      getter fd, display, pool, x_size, y_size

      def initialize(@display : WaylandClient::Display, @pool : Pool(Memory(T)))
        @fd = IO::FileDescriptor.new(LibC.memfd_create("buffer".to_unsafe, 0))
        @closed = false
        @buffer = Pointer(T).null
        @wl_buffer = Pointer(LibWaylandClient::WlBuffer).null
        @x_size = @y_size = @size = 0
        @buffer_listener = LibWaylandClient::WlBufferListener.new(
          release: Proc(Void*, Pointer(LibWaylandClient::WlBuffer), Void).new do |data, buffer|
            buffer = data.as(Memory(T))
            buffer.pool.checkin(buffer)
          end
        )
      end

      def resize(x, y)
        stride = x * pixel_size
        new_size = stride * y
        unmap if @wl_buffer
        LibC.ftruncate(fd.fd, new_size)
        @buffer = LibC.mmap(nil, new_size, LibC::PROT_READ | LibC::PROT_WRITE, LibC::MAP_SHARED, fd.fd, 0).as(Pointer(T))
        pool = WaylandClient::LibWaylandClient.wl_shm_create_pool(shm, fd.fd, new_size)
        @wl_buffer = WaylandClient::LibWaylandClient.wl_shm_pool_create_buffer(
          pool, 0, x, y, stride, T.shm_format
        )
        WaylandClient::LibWaylandClient.wl_buffer_add_listener(@wl_buffer, pointerof(@buffer_listener), self.as(Void*))
        WaylandClient::LibWaylandClient.wl_shm_pool_destroy(pool)
        @size = new_size
        @x_size = x - 1
        @y_size = y - 1
      end

      def set_all
        buf = @buffer
        0.to(@y_size) do |y|
          0.to(@x_size) do |x|
            buf.value = yield(x, y)
            buf += 1
          end
        end
      end

      def set(xrange, yrange)
        buf_with_xoffset = @buffer + xrange.begin
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
        @wl_buffer
      end

      def unmap
        WaylandClient::LibWaylandClient.wl_buffer_destroy(@wl_buffer)
        LibC.munmap(@buffer, @size)
      end

      def close
        return if @closed

        unmap
        fd.close
        @closed = true
      end

      private def shm
        display.registry.shm
      end

      private def pixel_size
        sizeof(T)
      end

      def finalize
        close
      end
    end
  end
end
