module WaylandClient
  @[Link("wayland-client", ldflags: "#{__DIR__}/../../build/shim.o")]
  lib LibWaylandClient
    alias WlArray = Void
    alias WlBuffer = Void
    alias WlCallback = Void
    alias WlCompositor = Void
    alias WlConnection = Void
    alias WlDisplay = Void
    alias WlKeyboard = Void
    alias WlMessage = Void
    alias WlPointer = Void
    alias WlRegion = Void
    alias WlRegistry = Void
    alias WlSeat = Void
    alias WlShm = Void
    alias WlShmPool = Void
    alias WlSubcompositor = Void
    alias WlSubsurface = Void
    alias WlSurface = Void
    alias WlTouch = Void
    alias XdgWmBase = Void

    struct WlRegistryListener
      global : Pointer(Void), Pointer(WlRegistry), LibC::UInt, Pointer(LibC::Char), LibC::UInt -> Void
      global_remove : Pointer(Void), Pointer(WlRegistry), LibC::UInt -> Void
    end

    struct WlBufferListener
      release : Pointer(Void), Pointer(WlBuffer) -> Void
    end

    struct WlCallbackListener
      done : Pointer(Void), Pointer(WlCallback), UInt32 -> Void
    end

    struct WlPointerListener
      enter : Pointer(Void), Pointer(WlPointer), UInt32, Pointer(WlSurface), LibC::Int, LibC::Int -> Void
      leave : Pointer(Void), Pointer(WlPointer), UInt32, Pointer(WlSurface) -> Void
      motion : Pointer(Void), Pointer(WlPointer), UInt32, LibC::Int, LibC::Int -> Void
      button : Pointer(Void), Pointer(WlPointer), UInt32, UInt32, UInt32, UInt32 -> Void
      axis : Pointer(Void), Pointer(WlPointer), UInt32, UInt32, LibC::Int -> Void
      frame : Pointer(Void), Pointer(WlPointer) -> Void
      axis_source : Pointer(Void), Pointer(WlPointer), WlPointerAxisSource -> Void
      axis_stop : Pointer(Void), Pointer(WlPointer), UInt32, UInt32 -> Void
      axis_discrete : Pointer(Void), Pointer(WlPointer), UInt32, Int32 -> Void
      axis_value120 : Pointer(Void), Pointer(WlPointer), UInt32, Int32 -> Void
    end

    struct WlSeatListener
      capabilities : Pointer(Void), Pointer(WlSeat), WlSeatCapability -> Void
      name : Pointer(Void), Pointer(WlSeat), Pointer(LibC::Char) -> Void
    end

    struct WlInterface
      name : LibC::Char*
      version : LibC::Int
      method_count : LibC::Int
      methods : WlMessage*
      event_count : LibC::Int
      events : WlMessage*
    end

    $wl_compositor_interface : WlInterface
    $wl_seat_interface : WlInterface
    $wl_shm_interface : WlInterface
    $wl_subcompositor_interface : WlInterface

    alias WlDisplayUpdateFunc = UInt32, Pointer(Void) -> LibC::Int
    alias WlDisplayGlobalFunc = Pointer(WlDisplay), UInt32, Pointer(LibC::Char), UInt32, Pointer(Void) -> LibC::Int
    alias WlConnectionUpdateFunc = Pointer(WlConnection), UInt32, Pointer(Void) -> LibC::Int

    fun wl_display_connect(name : Pointer(Char)) : Pointer(WlDisplay)
    fun wl_display_disconnect(Pointer(WlDisplay))
    fun wl_display_dispatch(Pointer(WlDisplay)) : LibC::Int
    fun wl_display_dispatch_pending(Pointer(WlDisplay)) : LibC::Int
    fun wl_display_flush(Pointer(WlDisplay)) : LibC::Int
    fun wl_display_read_events(Pointer(WlDisplay)) : LibC::Int
    fun wl_display_roundtrip(Pointer(WlDisplay)) : LibC::Int
    fun wl_display_get_fd(Pointer(WlDisplay)) : LibC::Int

    fun wl_buffer_destroy(Pointer(WlBuffer)) : Void
    fun wl_callback_destroy(Pointer(WlCallback)) : Void

    fun wl_region_destroy = wl_surface_destroy_shim(Pointer(WlRegion)) : Void
    fun wl_surface_destroy = wl_surface_destroy_shim(Pointer(WlSurface)) : Void

    fun wl_display_get_registry = wl_display_get_registry_shim(WlDisplay*) : Pointer(WlRegistry)
    fun wl_registry_add_listener = wl_registry_add_listener_shim(WlRegistry*, WlRegistryListener*, Void*)
    fun wl_registry_bind = wl_registry_bind_shim(WlRegistry*, UInt32, WlInterface*, UInt32) : Void*
    fun wl_compositor_create_surface = wl_compositor_create_surface_shim(WlCompositor*) : WlSurface*
    fun wl_shm_create_pool = wl_shm_create_pool_shim(WlShm*, LibC::Int, LibC::Int) : WlShmPool*
    fun wl_shm_pool_destroy = wl_shm_pool_destroy_shim(Pointer(WlShmPool)) : Void
    fun wl_shm_pool_create_buffer = wl_shm_pool_create_buffer_shim(
      WlShmPool*, LibC::Int, LibC::Int, LibC::Int, LibC::Int, WlShmFormat
    ) : WlBuffer*
    fun wl_buffer_destroy = wl_buffer_destroy_shim(Pointer(WlBuffer))
    fun wl_buffer_add_listener = wl_buffer_add_listener_shim(WlBuffer*, WlBufferListener*, Void*)
    fun wl_surface_attach = wl_surface_attach_shim(WlSurface*, WlBuffer*, LibC::Int, LibC::Int)
    fun wl_surface_commit = wl_surface_commit_shim(WlSurface*)
    fun wl_surface_damage_buffer = wl_surface_damage_buffer_shim(Pointer(WlSurface), LibC::Int, LibC::Int, LibC::Int, LibC::Int) : Void

    fun wl_surface_frame = wl_surface_frame_shim(Pointer(WlSurface)) : Pointer(WlCallback)
    fun wl_callback_add_listener = wl_callback_add_listener_shim(Pointer(WlCallback), Pointer(WlCallbackListener), Pointer(Void)) : LibC::Int
    fun wl_callback_destroy = wl_callback_destroy_shim(Pointer(WlCallback))

    fun wl_subcompositor_get_subsurface = wl_subcompositor_get_subsurface_shim(Pointer(WlSubcompositor), Pointer(WlSurface), Pointer(WlSurface)) : Pointer(WlSubsurface)
    fun wl_subsurface_set_sync = wl_subsurface_set_sync_shim(Pointer(WlSubsurface)) : Void
    fun wl_subsurface_set_desync = wl_subsurface_set_desync_shim(Pointer(WlSubsurface)) : Void
    fun wl_subsurface_destroy = wl_subsurface_destroy_shim(Pointer(WlSubsurface)) : Void

    fun wl_region_add = wl_region_add_shim(Pointer(WlRegion), LibC::Int, LibC::Int, LibC::Int, LibC::Int) : Void
    fun wl_region_subtract = wl_region_subtract_shim(Pointer(WlRegion), LibC::Int, LibC::Int, LibC::Int, LibC::Int) : Void

    fun wl_compositor_create_region =
      wl_compositor_create_region_shim(Pointer(WlCompositor)) : Pointer(WlRegion)
    fun wl_surface_set_opaque_region =
      wl_surface_set_opaque_region_shim(Pointer(WlSurface), Pointer(WlRegion)) : Void
    fun wl_surface_set_input_region =
      wl_surface_set_input_region_shim(Pointer(WlSurface), Pointer(WlRegion)) : Void

    fun wl_seat_get_pointer = wl_seat_get_pointer_shim(Pointer(WlSeat)) : Pointer(WlPointer)
    fun wl_pointer_add_listener = wl_pointer_add_listener_shim(Pointer(WlPointer), Pointer(WlPointerListener), Pointer(Void)) : Void
    fun wl_seat_add_listener = wl_seat_add_listener_shim(Pointer(WlSeat), Pointer(WlSeatListener), Pointer(Void)) : Void

    # Enums:
    enum WlShmFormat : LibC::UInt
      ARGB8888    =          0 # 32-bit ARGB format, [31:0] A:R:G:B 8:8:8:8 little endian
      XRGB8888    =          1 # 32-bit RGB format [31:0] x:R:G:B 8:8:8:8 little endian
      C8          = 0x20203843 # 8-bit color index format [7:0] C
      RGB332      = 0x38424752 # 8-bit RGB format [7:0] R:G:B 3:3:2
      BGR233      = 0x38524742 # 8-bit BGR format [7:0] B:G:R 2:3:3
      XRGB4444    = 0x32315258 # 16-bit xRGB format [15:0] x:R:G:B 4:4:4:4 little endian
      XBGR4444    = 0x32314258 # 16-bit xBGR format [15:0] x:B:G:R 4:4:4:4 little endian
      RGBX4444    = 0x32315852 # 16-bit RGBx format [15:0] R:G:B:x 4:4:4:4 little endian
      BGRX4444    = 0x32315842 # 16-bit BGRx format [15:0] B:G:R:x 4:4:4:4 little endian
      ARGB4444    = 0x32315241 # 16-bit ARGB format [15:0] A:R:G:B 4:4:4:4 little endian
      ABGR4444    = 0x32314241 # 16-bit ABGR format [15:0] A:B:G:R 4:4:4:4 little endian
      RGBA4444    = 0x32314152 # 16-bit RBGA format [15:0] R:G:B:A 4:4:4:4 little endian
      BGRA4444    = 0x32314142 # 16-bit BGRA format [15:0] B:G:R:A 4:4:4:4 little endian
      XRGB1555    = 0x35315258 # 16-bit xRGB format [15:0] x:R:G:B 1:5:5:5 little endian
      XBGR1555    = 0x35314258 # 16-bit xBGR 1555 format [15:0] x:B:G:R 1:5:5:5 little endian
      RGBX5551    = 0x35315852 # 16-bit RGBx 5551 format [15:0] R:G:B:x 5:5:5:1 little endian
      BGRX5551    = 0x35315842 # 16-bit BGRx 5551 format [15:0] B:G:R:x 5:5:5:1 little endian
      ARGB1555    = 0x35315241 # 16-bit ARGB 1555 format [15:0] A:R:G:B 1:5:5:5 little endian
      ABGR1555    = 0x35314241 # 16-bit ABGR 1555 format [15:0] A:B:G:R 1:5:5:5 little endian
      RGBA5551    = 0x35314152 # 16-bit RGBA 5551 format [15:0] R:G:B:A 5:5:5:1 little endian
      BGRA5551    = 0x35314142 # 16-bit BGRA 5551 format [15:0] B:G:R:A 5:5:5:1 little endian
      RGB565      = 0x36314752 # 16-bit RGB 565 format [15:0] R:G:B 5:6:5 little endian
      BGR565      = 0x36314742 # 16-bit BGR 565 format [15:0] B:G:R 5:6:5 little endian
      RGB888      = 0x34324752 # 24-bit RGB format [23:0] R:G:B little endian
      BGR888      = 0x34324742 # 24-bit BGR format [23:0] B:G:R little endian
      XBGR8888    = 0x34324258 # 32-bit xBGR format [31:0] x:B:G:R 8:8:8:8 little endian
      RGBX8888    = 0x34325852 # 32-bit RGBx format [31:0] R:G:B:x 8:8:8:8 little endian
      BGRX8888    = 0x34325842 # 32-bit BGRx format [31:0] B:G:R:x 8:8:8:8 little endian
      ABGR8888    = 0x34324241 # 32-bit ABGR format [31:0] A:B:G:R 8:8:8:8 little endian
      RGBA8888    = 0x34324152 # 32-bit RGBA format [31:0] R:G:B:A 8:8:8:8 little endian
      BGRA8888    = 0x34324142 # 32-bit BGRA format [31:0] B:G:R:A 8:8:8:8 little endian
      XRGB2101010 = 0x30335258 # 32-bit xRGB format [31:0] x:R:G:B 2:10:10:10 little endian
      XBGR2101010 = 0x30334258 # 32-bit xBGR format [31:0] x:B:G:R 2:10:10:10 little endian
      RGBX1010102 = 0x30335852 # 32-bit RGBx format [31:0] R:G:B:x 10:10:10:2 little endian
      BGRX1010102 = 0x30335842 # 32-bit BGRx format [31:0] B:G:R:x 10:10:10:2 little endian
      ARGB2101010 = 0x30335241 # 32-bit ARGB format [31:0] A:R:G:B 2:10:10:10 little endian
      ABGR2101010 = 0x30334241 # 32-bit ABGR format [31:0] A:B:G:R 2:10:10:10 little endian
      RGBA1010102 = 0x30334152 # 32-bit RGBA format [31:0] R:G:B:A 10:10:10:2 little endian
      BGRA1010102 = 0x30334142 # 32-bit BGRA format [31:0] B:G:R:A 10:10:10:2 little endian
      YUYV        = 0x56595559 # packed YCbCr format [31:0] Cr0:Y1:Cb0:Y0 8:8:8:8 little endian
      YVYU        = 0x55595659 # packed YCbCr format [31:0] Cb0:Y1:Cr0:Y0 8:8:8:8 little endian
      UYVY        = 0x59565955 # packed YCbCr format [31:0] Y1:Cr0:Y0:Cb0 8:8:8:8 little endian
      VYUY        = 0x59555956 # packed YCbCr format [31:0] Y1:Cb0:Y0:Cr0 8:8:8:8 little endian
      AYUV        = 0x56555941 # packed AYCbCr format [31:0] A:Y:Cb:Cr 8:8:8:8 little endian
      NV12        = 0x3231564e # 2 plane YCbCr Cr:Cb format 2x2 subsampled Cr:Cb plane
      NV21        = 0x3132564e # 2 plane YCbCr Cb:Cr format 2x2 subsampled Cb:Cr plane
      NV16        = 0x3631564e # 2 plane YCbCr Cr:Cb format 2x1 subsampled Cr:Cb plane
      NV61        = 0x3136564e # 2 plane YCbCr Cb:Cr format 2x1 subsampled Cb:Cr plane
      YUV410      = 0x39565559 # 3 plane YCbCr format 4x4 subsampled Cb (1) and Cr (2) planes
      YVU410      = 0x39555659 # 3 plane YCbCr format 4x4 subsampled Cr (1) and Cb (2) planes
      YUV411      = 0x31315559 # 3 plane YCbCr format 4x1 subsampled Cb (1) and Cr (2) planes
      YVU411      = 0x31315659 # 3 plane YCbCr format 4x1 subsampled Cr (1) and Cb (2) planes
      YUV420      = 0x32315559 # 3 plane YCbCr format 2x2 subsampled Cb (1) and Cr (2) planes
      YVU420      = 0x32315659 # 3 plane YCbCr format, 2x2 subsampled Cr (1) and Cb (2) planes
      YUV422      = 0x36315559 # 3 plane YCbCr format, 2x1 subsampled Cb (1) and Cr (2) planes
      YVU422      = 0x36315659 # 3 plane YCbCr format, 2x1 subsampled Cr (1) and Cb (2) planes
      YUV444      = 0x34325559 # 3 plane YCbCr format, non-subsampled Cb (1) and Cr (2) planes
      YVU444      = 0x34325659 # 3 plane YCbCr format, non-subsampled Cr (1) and Cb (2) planes
    end

    @[Flags]
    enum WlSeatCapability : LibC::UInt
      None     = 0
      Pointer  = 1
      Keyboard = 2
      Touch    = 4
    end

    enum WlPointerAxisSource : UInt32
      Wheel      = 0
      Finger     = 1
      Continuous = 2
      Tilt       = 3
    end
  end
end
