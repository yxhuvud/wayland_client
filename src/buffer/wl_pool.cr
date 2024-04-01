require "../format"
require "./memory"
require "../lib/lib_wayland_client"

module WaylandClient
  module Buffer
    class WlPool(T)
      getter fd, shm, wl_buffer, buffer, shm_pool

      def initialize(@shm : Pointer(LibWaylandClient::WlShm), release)
        @fd = IO::FileDescriptor.new(LibC.memfd_create("buffer".to_unsafe, 0))
        @buffer = Pointer(Void).null
        @wl_buffer = Pointer(LibWaylandClient::WlBuffer).null
        @size = 0
        @capacity = 0
        @buffer_listener = LibWaylandClient::WlBufferListener.new(release: release)
        @closed = false
        @shm_pool = Pointer(LibWaylandClient::WlShmPool).null
      end

      def allocate_buffer(x, y, pixel_size, memory)
        destroy_buffer if @size > 0

        @wl_buffer, @size = create_buffer(x, y, pixel_size)

        WaylandClient::LibWaylandClient.wl_buffer_add_listener(wl_buffer, pointerof(@buffer_listener), memory.as(Void*))
        wl_buffer
      end

      private def create_buffer(x, y, pixel_size)
        stride = x * pixel_size
        new_size = stride * y

        {
          WaylandClient::LibWaylandClient.wl_shm_pool_create_buffer(
            pool(new_size), 0, x, y, stride, format
          ),
          new_size,
        }
      end
      private def format
        T.shm_format
      end

      private def within_bounds?(requested_size)
        (@capacity >> 1) <= requested_size <= @capacity
      end

      def close
        return if @closed

        unmap
        @closed = true
      end

      def unmap
        destroy_buffer
        unmap_pool
      end

      private def destroy_buffer
        WaylandClient::LibWaylandClient.wl_buffer_destroy(@wl_buffer)
      end

      private def pool(requested_size)
        return @shm_pool if within_bounds?(requested_size)

        unmap_pool if @capacity > 0
        @capacity = (requested_size * 1.4).to_i

        LibC.ftruncate(fd.fd, @capacity)
        @buffer = LibC.mmap(nil, @capacity, LibC::PROT_READ | LibC::PROT_WRITE, LibC::MAP_SHARED, fd.fd, 0)
        @shm_pool = WaylandClient::LibWaylandClient.wl_shm_create_pool(shm, fd.fd, @capacity)
      end

      private def unmap_pool
        LibC.munmap(@buffer, @capacity)
        WaylandClient::LibWaylandClient.wl_shm_pool_destroy(@shm_pool)
      end

      def finalize
        close
      end
    end
  end
end
