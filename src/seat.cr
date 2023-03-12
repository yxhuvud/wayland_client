require "./lib/lib_wayland_client"
require "./seat/pointer_handler"

module WaylandClient
  alias PointerHandler = Seat::PointerHandler

  module KeyboardHandler
    class Base
      include KeyboardHandler
    end
  end

  module TouchHandler
    class Base
      include TouchHandler
    end
  end

  class Seat
    getter seat_base
    getter name
    getter pointer_handler

    def initialize(@seat_base : Pointer(LibWaylandClient::WlSeat))
      @capabilities = LibWaylandClient::WlSeatCapability.new(0)
      @listener = LibWaylandClient::WlSeatListener.new(
        capabilities: Proc(Pointer(Void), Pointer(LibWaylandClient::WlSeat), LibWaylandClient::WlSeatCapability, Void).new do |seat, base, capabilities|
          seat.as(Seat).setup_capabilities(capabilities)
        end,
        name: Proc(Pointer(Void), Pointer(LibWaylandClient::WlSeat), Pointer(LibC::Char), Void).new do |_, _, name|
        end
      )
      @pointer_handler = PointerHandler::Base.new
      @keyboard_handler = KeyboardHandler::Base.new
      @touch_handler = TouchHandler::Base.new

      @pointer_enabled = false
      @keyboard_enabled = false
      @touch_enabled = false

      LibWaylandClient.wl_seat_add_listener(@seat_base, pointerof(@listener), self.as(Void*))
    end

    def pointer?
      @pointer_enabled
    end

    def keyboard?
      @keyboard_enabled1
    end

    def touch?
      @touch_enabled
    end

    def setup_capabilities(capabilities)
      @pointer_enabled = capabilities.pointer?
      @keyboard_enabled = capabilities.keyboard?
      @touch_enabled = capabilities.touch?
    end

    def pointer_handler=(handler : PointerHandler)
      pointer = LibWaylandClient.wl_seat_get_pointer(@seat_base)
      LibWaylandClient.wl_pointer_add_listener(pointer, handler.listener, handler.as(Void*))
      @pointer_handler = handler
    end

    def keyboard_handler=(handler : KeyboardHandler)
      # TODO listener
      @keyboard_handler = handler
    end

    def touch_handler=(handler : TouchHandler)
      # TODO listener
      @touch_handler = handler
    end
  end
end
