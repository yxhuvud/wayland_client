require "./pool"
require "../registry"
require "../lib/lib_c"

module WaylandClient
  module Buffer
    module Buffer
    end

    class Memory(T)
      include ::WaylandClient::Buffer::Buffer

      getter fd, registry, pool, x_size, y_size

      def initialize(@registry : WaylandClient::Registry, @pool : Pool(Memory(T)))
        @closed = false
        @wl_buffer = Pointer(LibWaylandClient::WlBuffer).null
        @x_size = @y_size = 0
        @buffer_listener = LibWaylandClient::WlBufferListener.new(release: release)

        @size = 0
        @fd = IO::FileDescriptor.new(LibC.memfd_create("buffer".to_unsafe, 0))
        @buffer = Pointer(T).null
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
        destroy_buffer if @wl_buffer
        @wl_buffer = allocate_buffer(x, y)
        @x_size = x - 1
        @y_size = y - 1
      end

      def allocate_buffer(x, y)
        stride = x * pixel_size
        new_size = stride * y
        with_pool(new_size) do |pool|
          wl_buffer = WaylandClient::LibWaylandClient.wl_shm_pool_create_buffer(
            pool, 0, x, y, stride, T.shm_format
          )
          WaylandClient::LibWaylandClient.wl_buffer_add_listener(wl_buffer, pointerof(@buffer_listener), self.as(Void*))
          wl_buffer
        end
      end

      private def with_pool(requested_size)
        unmap_pool if @wl_buffer
        LibC.ftruncate(fd.fd, requested_size)
        @buffer = LibC.mmap(nil, requested_size, LibC::PROT_READ | LibC::PROT_WRITE, LibC::MAP_SHARED, fd.fd, 0).as(Pointer(T))
        shm_pool = WaylandClient::LibWaylandClient.wl_shm_create_pool(shm, fd.fd, requested_size)
        @size = requested_size
        wl_buffer = yield shm_pool
        WaylandClient::LibWaylandClient.wl_shm_pool_destroy(shm_pool)
        wl_buffer
      end

      def to_slice
        Slice(T).new(@buffer, (x_size + 1) * (y_size + 1))
      end

      def map!
        buf = @buffer
        0.to(@y_size) do |y|
          0.to(@x_size) do |x|
            buf.value = yield(x, y)
            buf += 1
          end
        end
      end

      def map!(xrange, yrange)
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
        destroy_buffer
        unmap_pool
      end

      private def destroy_buffer
        WaylandClient::LibWaylandClient.wl_buffer_destroy(@wl_buffer)
      end

      private def unmap_pool
        LibC.munmap(@buffer, @size)
      end

      def close
        return if @closed

        unmap
        fd.close
        @closed = true
      end

      private def shm
        registry.shm
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
