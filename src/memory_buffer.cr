require "./display"

module WaylandClient
  module Buffer
    macro build(kind, format, display)
      case :{{kind.id}}
      when :memory # TODO: enum..
        WaylandClient::Buffer::Pool(WaylandClient::Buffer::Memory({{format.id}})).new({{display.id}})
      else
        raise "Unreachable"
      end
    end

    class Pool(T)
      getter display

      def initialize(@display : WaylandClient::Display)
        @free_buffers = Deque(T).new
      end

      def checkout_of_size(x, y)
        buf = checkout
        if (buf.current_x != x) || (buf.current_y != y)
          buf.resize(x, y)
        end
        buf
      end

      def checkout
        if buffer = @free_buffers.pop?
          return buffer
        end

        T.new(display, self)
      end

      def checkin(buffer)
        if @free_buffers.size > 4
          buffer.close
        else
          @free_buffers << buffer
        end
      end
    end

    class Memory(T)
      getter fd, display, pool, current_x, current_y

      def initialize(@display : WaylandClient::Display, @pool : Pool(Memory(T)))
        @fd = IO::FileDescriptor.new(LibC.memfd_create("buffer".to_unsafe, 0))
        @closed = false
        @buffer = Pointer(T).null
        @wl_buffer = Pointer(LibWaylandClient::WlBuffer).null
        @current_x = @current_y = @size = 0
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
        @current_x = x - 1
        @current_y = y - 1
      end

      def set_all
        buf = @buffer
        0.to(@current_y) do |y|
          0.to(@current_x) do |x|
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
