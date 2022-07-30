require "./display"

module WaylandClient
  class BufferPool(T)
    getter display

    def initialize(@display : WaylandClient::Display)
      @free_buffers = Deque(T).new
    end

    def checkout
      return buffer if buffer = @free_buffers.pop?

      T.new(display)
    end

    def checkin(buffer)
      @free_buffers << buffer
    end
  end

  class MemoryBuffer(F)
    getter fd, display
    @max_x : Int32
    @max_y : Int32

    def initialize(@display : WaylandClient::Display)
      @fd = IO::FileDescriptor.new(LibC.memfd_create("buffer".to_unsafe, 0))
      @closed = false
      @buffer = Pointer(F).null
      @wl_buffer = Pointer(LibWaylandClient::WlBuffer).null
      @max_x = @max_y = @size = 0
      # TODO: Set up release-handling
      # TODO: Double buffering?
    end

    def resize(x, y)
      stride = x * pixel_size
      new_size = stride * y
      @size = new_size
      LibC.ftruncate(fd.fd, @size)

      # TODO: Have an internal wrapping for buffer which keep track of size and pointers.
      @buffer = LibC.mmap(nil, @size, LibC::PROT_READ | LibC::PROT_WRITE, LibC::MAP_SHARED, fd.fd, 0).as(Pointer(F))
      pool = WaylandClient::LibWaylandClient.wl_shm_create_pool(shm, fd.fd, @size)
      @wl_buffer = WaylandClient::LibWaylandClient.wl_shm_pool_create_buffer(
        pool, 0, x, y, stride, F.shm_format
      )
      WaylandClient::LibWaylandClient.wl_shm_pool_destroy(pool)
      @max_x = x - 1
      @max_y = y - 1
      # TODO: cleanup old buf
    end

    def set_all
      buf = @buffer
      0.to(@max_y) do |y|
        0.to(@max_x) do |x|
          buf.value = yield(x, y)
          buf += 1
        end
      end
    end

    def to_unsafe
      @wl_buffer
    end

    def unmap
      #   WaylandClient::LibWaylandClient.wl_buffer_destroy(@buffer)
      LibC.munmap(@buffer, @size)
    end

    def close
      return if @closed
      WaylandClient::LibWaylandClient.wl_buffer_destroy(@buffer)
      LibC.munmap(@buffer, @size)

      fd.close
      @closed = true
    end

    private def shm
      display.registry.shm
    end

    private def pixel_size
      sizeof(F)
    end

    def finalize
      close
    end
  end
end
