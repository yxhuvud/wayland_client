require "./lib_wayland_client"

module WaylandClient
  @[Link("decor-0")]
  lib LibDecor
    enum Error
      CompositorIncompatible
      InvalidFrameComposition
    end

    @[Flags]
    enum WindowState
      None
      Active
      Maximized
      Fullscreen
      TiledLeft
      TiledRight
      TiledTop
      TiledBottom
    end

    enum ResizeEdge
      None
      Top
      Bottom
      Left
      TopLeft
      BottomLeft
      Right
      TopRight
      BottomRight
    end

    @[Flags]
    enum Capabilities
      Move
      Resize
      Minimimze
      Fullscreen
      Close
    end

    # Need to be able to do a copy of this one, sadly.
    struct Configuration
      serial : UInt32
      has_window_state : Bool
      window_state : WindowState
      has_size : Bool
      window_width : LibC::Int
      window_height : LibC::Int
    end

    alias Frame = Void
    alias Context = Void
    alias State = Void

    struct Interface
      error : Context*, Error, Char* -> Void
    end

    struct FrameInterface
      configure : Pointer(Frame), Pointer(Configuration), Pointer(Void) -> Void
      close : Pointer(Frame), Pointer(Void) -> Void
      commit : Pointer(Frame), Pointer(Void) -> Void
      dismiss_popup : Pointer(Frame), Pointer(Char), Pointer(Void) -> Void
    end

    fun unref = libdecor_unref(Pointer(Context)) : Void
    fun libdecor_new(LibWaylandClient::WlDisplay*, Interface*) : Context*
    fun get_fd = libdecor_get_fd(Pointer(Context)) : LibC::Int
    fun dispatch = libdecor_dispatch(Pointer(Context), LibC::Int) : LibC::Int
    fun decorate = libdecor_decorate(Pointer(Context), Pointer(LibWaylandClient::WlSurface), Pointer(FrameInterface), Pointer(Void)) : Pointer(Frame)

    fun libdecor_frame_set_translate_coordinate(Pointer(Frame), LibC::Int, LibC::Int, Pointer(LibC::Int), Pointer(LibC::Int)) : Void
    fun frame_set_visibility = libdecor_frame_set_visibility(Pointer(Frame), LibC::Int) : Void
    fun frame_is_visible = libdecor_frame_is_visible(Pointer(Frame)) : LibC::Int
    fun frame_set_title = libdecor_frame_set_title(Pointer(Frame), Pointer(Char)) : Void
    fun frame_get_title = libdecor_frame_get_title(Pointer(Frame)) : Pointer(Char)
    fun frame_set_app_id = libdecor_frame_set_app_id(Pointer(Frame), Pointer(Char)) : Void
    fun frame_set_capabilities = libdecor_frame_set_capabilities(Pointer(Frame), Capabilities) : Void
    fun frame_unset_capabilities = libdecor_frame_unset_capabilities(Pointer(Frame), Capabilities) : Void

    fun frame_commit = libdecor_frame_commit(Pointer(Frame), Pointer(State), Pointer(Configuration)) : Void
    fun frame_close = libdecor_frame_close(Pointer(Frame)) : Void
    fun frame_unref = libdecor_frame_unref(Pointer(Frame)) : Void
    fun frame_map = libdecor_frame_map(Pointer(Frame)) : Void

    fun configuration_get_content_size = libdecor_configuration_get_content_size(Pointer(Configuration), Pointer(Frame), Pointer(LibC::Int), Pointer(LibC::Int)) : LibC::Int
    fun configuration_get_window_state = libdecor_configuration_get_window_state(Pointer(Configuration), Pointer(WindowState)) : LibC::Int

    fun state_new = libdecor_state_new(LibC::Int, LibC::Int) : Pointer(State)
    fun state_free = libdecor_state_free(Pointer(State))

    fun set_fullscreen = libdecor_frame_set_fullscreen(Pointer(Frame), Pointer(LibWaylandClient::WlOutput)) : Void
    fun unset_fullscreen = libdecor_frame_unset_fullscreen(Pointer(Frame)) : Void
  end
end
