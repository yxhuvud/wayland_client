require "./lib/lib_wayland_client"
require "./seat/keyboard"
require "./seat/pointer"
require "./seat/touch"

module WaylandClient
  alias PointerHandler = Seat::PointerHandler
  alias KeyboardHandler = Seat::KeyboardHandler

  module TouchHandler
    class Base
      include TouchHandler
    end
  end

  class Seat
    getter seat_base
    getter name
    @pointer : Pointer?
    @keyboard : Keyboard?
    @touch : Touch?

    def initialize(@seat_base : LibWaylandClient::WlSeat*)
      @capabilities = LibWaylandClient::WlSeatCapability.new(0)
      @listener = LibWaylandClient::WlSeatListener.new(
        capabilities: Proc(Void*, LibWaylandClient::WlSeat*, LibWaylandClient::WlSeatCapability, Void).new do |seat, base, capabilities|
          seat.as(Seat).setup_capabilities(capabilities)
        end,
        name: Proc(Void*, LibWaylandClient::WlSeat*, LibC::Char*, Void).new do |_, _, name|
        end
      )

      @pointer = nil
      @keyboard = nil
      @touch = nil

      @pointer_enabled = false
      @keyboard_enabled = false
      @touch_enabled = false

      LibWaylandClient.wl_seat_add_listener(@seat_base, pointerof(@listener), self.as(Void*))
    end

    def pointer
      raise "pointer not enabled" unless pointer?

      @pointer ||= Pointer.new(self)
    end

    def pointer?
      @pointer_enabled
    end

    def keyboard?
      @keyboard_enabled
    end

    def keyboard
      raise "keyboard not enabled" unless keyboard?

      @keyboard ||= Keyboard.new(self)
    end

    def touch?
      @touch_enabled
    end

    def touch
      raise "touch not enabled" unless touch?

      @touch ||= Touch.new(self)
    end

    def setup_capabilities(capabilities)
      # TODO: Does this need to handle things being disconnected and
      # reconnected?
      @pointer_enabled = capabilities.pointer?
      @keyboard_enabled = capabilities.keyboard?
      @touch_enabled = capabilities.touch?
    end
  end
end
