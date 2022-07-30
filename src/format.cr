require "./lib/lib_wayland_client"

module WaylandClient
  module Format
    alias Formats = WaylandClient::LibWaylandClient::WlShmFormat

    record(ARGB8888, alpha : UInt8, red : UInt8, green : UInt8, blue : UInt8) do
      def self.shm_format
        Formats::ARGB8888
      end
    end

    record(XRGB8888, _unused : UInt8, red : UInt8, green : UInt8, blue : UInt8) do
      def self.new(red : UInt8, green : UInt8, blue : UInt8)
        new(red, green, blue, 0i8)
      end

      def self.shm_format
        Formats::XRGB8888
      end
    end

    # BYTE_SIZE = {
    #   Formats::ARGB8888    => 4,
    #   Formats::XRGB8888    => 4,
    #   Formats::C8          => 1,
    #   Formats::RGB332      => 1,
    #   Formats::BGR233      => 1,
    #   Formats::XRGB4444    => 1,
    #   Formats::XBGR4444    => 2,
    #   Formats::RGBX4444    => 2,
    #   Formats::BGRX4444    => 2,
    #   Formats::ARGB4444    => 2,
    #   Formats::ABGR4444    => 2,
    #   Formats::RGBA4444    => 2,
    #   Formats::BGRA4444    => 2,
    #   Formats::XRGB1555    => 2,
    #   Formats::XBGR1555    => 2,
    #   Formats::RGBX5551    => 2,
    #   Formats::BGRX5551    => 2,
    #   Formats::ARGB1555    => 2,
    #   Formats::ABGR1555    => 2,
    #   Formats::RGBA5551    => 2,
    #   Formats::BGRA5551    => 2,
    #   Formats::RGB565      => 2,
    #   Formats::BGR565      => 2,
    #   Formats::RGB888      => 3,
    #   Formats::BGR888      => 3,
    #   Formats::XBGR8888    => 4,
    #   Formats::RGBX8888    => 4,
    #   Formats::BGRX8888    => 4,
    #   Formats::ABGR8888    => 4,
    #   Formats::RGBA8888    => 4,
    #   Formats::BGRA8888    => 4,
    #   Formats::XRGB2101010 => 4,
    #   Formats::XBGR2101010 => 4,
    #   Formats::RGBX1010102 => 4,
    #   Formats::BGRX1010102 => 4,
    #   Formats::ARGB2101010 => 4,
    #   Formats::ABGR2101010 => 4,
    #   Formats::RGBA1010102 => 4,
    #   Formats::BGRA1010102 => 4,
    #   Formats::YUYV        => 4,
    #   Formats::YVYU        => 4,
    #   Formats::UYVY        => 4,
    #   Formats::VYUY        => 4,
    #   Formats::AYUV        => 4,
    # }
    # NV12        => ??? # 2 plane YCbCr Cr:Cb format 2x2 subsampled Cr:Cb plane
    # NV21        => ??? # 2 plane YCbCr Cb:Cr format 2x2 subsampled Cb:Cr plane
    # NV16        => ??? # 2 plane YCbCr Cr:Cb format 2x1 subsampled Cr:Cb plane
    # NV61        => ??? # 2 plane YCbCr Cb:Cr format 2x1 subsampled Cb:Cr plane
    # YUV410      => ??? # 3 plane YCbCr format 4x4 subsampled Cb (1) and Cr (2) planes
    # YVU410      => ??? # 3 plane YCbCr format 4x4 subsampled Cr (1) and Cb (2) planes
    # YUV411      => ??? # 3 plane YCbCr format 4x1 subsampled Cb (1) and Cr (2) planes
    # YVU411      => ??? # 3 plane YCbCr format 4x1 subsampled Cr (1) and Cb (2) planes
    # YUV420      => ??? # 3 plane YCbCr format 2x2 subsampled Cb (1) and Cr (2) planes
    # YVU420      => ??? # 3 plane YCbCr format, 2x2 subsampled Cr (1) and Cb (2) planes
    # YUV422      => ??? # 3 plane YCbCr format, 2x1 subsampled Cb (1) and Cr (2) planes
    # YVU422      => ??? # 3 plane YCbCr format, 2x1 subsampled Cr (1) and Cb (2) planes
    # YUV444      => ??? # 3 plane YCbCr format, non-subsampled Cb (1) and Cr (2) planes
    # YVU444      => ??? # 3 plane YCbCr format, non-subsampled Cr (1) and Cb (2) planes
  end
end
