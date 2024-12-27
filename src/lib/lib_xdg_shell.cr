require "./lib_wayland_client"

module WaylandClient
  @[Link(ldflags: "#{__DIR__}/../../build/xdg-shell.o")]
  lib LibXdgShell
    type XdgSurface = Void
    type XdgToplevel = Void

    struct BaseListener
      ping : Void*, LibWaylandClient::XdgWmBase*, UInt32 -> Void
    end

    struct SurfaceListener
      configure : Void*, XdgSurface*, UInt32 -> Void
    end

    struct ToplevelListener
      configure : Void*, LibXdgShell::XdgToplevel*, Int32, Int32, LibWaylandClient::WlArray* -> Void
      close : Void*, LibXdgShell::XdgToplevel* -> Void
      configure_bounds : Void*, LibXdgShell::XdgToplevel*, Int32, Int32 -> Void
    end

    $xdg_wm_base_interface : LibWaylandClient::WlInterface

    fun get_xdg_surface = xdg_wm_base_get_xdg_surface_shim(LibWaylandClient::XdgWmBase*, LibWaylandClient::WlSurface*) : XdgSurface*
    fun xdg_surface_get_toplevel = xdg_surface_get_toplevel_shim(XdgSurface*) : XdgToplevel*
    fun xdg_toplevel_set_title = xdg_toplevel_set_title_shim(XdgToplevel*, LibC::Char*)
    fun xdg_toplevel_add_listener = xdg_toplevel_add_listener_shim(XdgToplevel*, ToplevelListener*, Void*)
    fun xdg_wm_base_add_listener = xdg_wm_base_add_listener_shim(LibWaylandClient::XdgWmBase*, BaseListener*, Void*)
    fun xdg_wm_base_pong = xdg_wm_base_pong_shim(LibWaylandClient::XdgWmBase*, UInt32) : Void
    fun xdg_surface_add_listener = xdg_surface_add_listener_shim(XdgSurface*, SurfaceListener*, Void*)
    fun xdg_surface_ack_configure = xdg_surface_ack_configure_shim(XdgSurface*, UInt32) : Void
  end
end
