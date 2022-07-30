require "./lib/lib_wayland_client"
require "./lib/lib_xdg_shell"
require "./xdg/toplevel"

module WaylandClient
  class Xdg
    getter xdg_base

    def initialize(@xdg_base : LibWaylandClient::XdgWmBase*)
      @base_listener = LibXdgShell::BaseListener.new(
        ping: Proc(Void*, LibWaylandClient::XdgWmBase*, UInt32, Void).new do |_, base, serial|
          LibXdgShell.xdg_wm_base_pong(base, serial)
        end
      )

      LibXdgShell.xdg_wm_base_add_listener(@xdg_base, pointerof(@base_listener), self.as(Void*))
    end

    # Creates a raw new toplevel surface. This does not include any window decorations.
    def create_toplevel(surface : WaylandClient::Surface, &configure_callback : Toplevel, Surface -> Void)
      Toplevel.new(self, surface, configure_callback)
    end
  end
end
