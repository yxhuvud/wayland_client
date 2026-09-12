require "./lib_wayland_client"

module WaylandClient
  @[Link("wayland-client", ldflags: "#{__DIR__}/../../build/cursor-shape-v1.o")]
  lib LibCursorShape
    type Manager = Void
    type Device = Void

    enum Shape : UInt32
      Default       = 1
      ContextMenu   = 2
      Help          = 3
      Pointer       = 4
      Progress      = 5
      Wait          = 6
      Cell          = 7
      Crosshair     = 8
      Text          = 9
      VerticalText  = 10
      Alias         = 11
      Copy          = 12
      Move          = 13
      NoDrop        = 14
      NotAllowed    = 15
      Grab          = 16
      Grabbing      = 17
      EResize       = 18
      NResize       = 19
      NEResize      = 20
      NWResize      = 21
      SResize       = 22
      SEResize      = 23
      SWResize      = 24
      WResize       = 25
      EWResize      = 26
      NSResize      = 27
      NESWResize    = 28
      NWSEResize    = 29
      ColResize     = 30
      RowResize     = 31
      AllScroll     = 32
      ZoomIn        = 33
      ZoomOut       = 34
      DndAsk        = 35
      AllResize     = 36
    end

    fun cursor_shape_manager_interface = cursor_shape_manager_interface_shim : Pointer(LibWaylandClient::WlInterface)
    fun cursor_shape_manager_destroy = cursor_shape_manager_destroy_shim(Pointer(Manager)) : Void
    fun cursor_shape_manager_get_pointer = cursor_shape_manager_get_pointer_shim(Pointer(Manager), Pointer(LibWaylandClient::WlPointer)) : Pointer(Device)
    fun cursor_shape_device_destroy = cursor_shape_device_destroy_shim(Pointer(Device)) : Void
    fun cursor_shape_device_set_shape = cursor_shape_device_set_shape_shim(Pointer(Device), UInt32, UInt32) : Void
  end

  alias CursorShape = LibCursorShape::Shape
end
