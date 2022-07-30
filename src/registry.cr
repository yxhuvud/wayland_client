require "./lib/lib_wayland_client"
require "./xdg"

module WaylandClient
  # A class to keep track of global Wayland objects and their interfaces.
  class Registry
    alias WlRegistry = LibWaylandClient::WlRegistry

    getter xdg : Xdg?

    def initialize(display)
      @names = Hash(LibC::UInt, String).new

      @listener = LibWaylandClient::WlRegistryListener.new(
        global: setup_fun,
        global_remove: teardown_fun
      )

      @compositor = Pointer(LibWaylandClient::WlCompositor).null
      @shm = Pointer(LibWaylandClient::WlShm).null

      @xdg = nil

      wl_registry = LibWaylandClient.wl_display_get_registry(display)
      LibWaylandClient.wl_registry_add_listener(wl_registry, listener, self.as(Pointer(Void)))
    end

    def register(wl_registry, interface_name, name, version)
      raise "Already exist" if @names[name]?

      @names[name] = interface_name

      case interface_name
      when "wl_compositor"
        @compositor = bind_interface(LibWaylandClient.wl_compositor_interface, LibWaylandClient::WlCompositor)
      when "wl_shm"
        @shm = bind_interface(LibWaylandClient.wl_shm_interface, LibWaylandClient::WlShm)
      when "xdg_wm_base"
        base = bind_interface(LibXdgShell.xdg_wm_base_interface, LibWaylandClient::XdgWmBase)
        @xdg = Xdg.new(base)
      # when "zxdg_decoration_man"
      #   base = bind_interface(LibXdgShell.xdg_wm_base_interface, LibWaylandClient::XdgWmBase)
      #   @xdg = Xdg.new(base)

       else
         #    p interface_name
      end
    end

    def compositor
      @compositor.not_nil!
    end

    def shm
      @shm.not_nil!
    end

    def xdg
      @xdg.not_nil!
    end

    def unregister(int)
      interface_name = @names.delete(name)
      case interface_name
      when "wl_compositor"
        @compositor = nil
      when "wl_shm"
        @shm = nil
      when "xdg_wm_base"
        @xdg = nil
      end
      # todo clear interface
    end

    private def listener
      pointerof(@listener)
    end

    private def setup_fun
      Proc(Pointer(Void), Pointer(WlRegistry), LibC::UInt, Pointer(LibC::Char), LibC::UInt, Void).new do |reg, wl_registry, name, interface, version|
        registry = reg.as(Registry)

        interface_name = String.new(interface)
        registry.register(wl_registry, interface_name, name, version)
      end
    end

    private def teardown_fun
      Proc(Pointer(Void), Pointer(WlRegistry), LibC::UInt, Void).new do |reg, wl_registry, interface|
        registry = reg.as(Registry)
      end
    end

    private macro bind_interface(interface, klass)
      LibWaylandClient.wl_registry_bind(
        wl_registry,
        name,
        pointerof({{interface}}),
        version
      ).as({{klass}}*)
    end
  end
end
