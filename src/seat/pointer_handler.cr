require "../lib/lib_wayland_client"
require "./pointer_event"

module WaylandClient
  class Seat
    module PointerHandler
      getter :pointer_event

      def initialize
        @pointer_event = PointerEvent.new
        @callback = LibWaylandClient::WlPointerListener.new(
          enter: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), UInt32, Pointer(LibWaylandClient::WlSurface), LibC::Int, LibC::Int, Void).new do |data, pointer, serial, surface, x, y|
            data.as(self).enter(serial, surface, x, y)
          end,
          leave: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), UInt32, Pointer(LibWaylandClient::WlSurface), Void).new do |data, pointer, serial, surface|
            data.as(self).leave(serial, surface)
          end,
          motion: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), UInt32, LibC::Int, LibC::Int, Void).new do |data, pointer, time, x, y|
            data.as(self).motion(time, x, y)
          end,
          button: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), UInt32, UInt32, UInt32, UInt32, Void).new do |data, pointer, serial, time, button, state|
            data.as(self).button(time, serial, button, state)
          end,
          axis: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), UInt32, UInt32, LibC::Int, Void).new do |data, pointer, time, axis, value|
            data.as(self).axis(time, axis, value)
          end,
          frame: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), Void).new { |data, pointer| data.as(self).frame },
          axis_source: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), LibWaylandClient::WlPointerAxisSource, Void).new { |data, pointer, axis_source| data.as(self).axis_source(axis_source) },
          axis_stop: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), UInt32, UInt32, Void).new { |data, pointer, time, axis| data.as(self).axis_stop(time, axis) },
          axis_discrete: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), UInt32, Int32, Void).new { |data, pointer, axis, discrete| data.as(self).axis_discrete(axis, discrete * 120) },
          axis_value120: Proc(Pointer(Void), Pointer(LibWaylandClient::WlPointer), UInt32, Int32, Void).new { |data, pointer, axis, discrete| data.as(self).axis_discrete(axis, discrete) },
        )
      end

      def process
      end

      class Base
        include PointerHandler
      end

      protected def enter(serial, surface, x, y)
        pointer_event.serial = serial
        pointer_event.surface = surface
        pointer_event.x = x
        pointer_event.y = y
      end

      protected def leave(serial, surface)
        pointer_event.serial = serial
        pointer_event.surface = surface
      end

      protected def motion(time, x, y)
        pointer_event.time = time
        pointer_event.x = x
        pointer_event.y = y
      end

      protected def button(time, serial, button, state)
        pointer_event.time = time
        pointer_event.serial = serial
        pointer_event.button = button
        pointer_event.button_state = state == 1
      end

      protected def axis(time, axis, value)
        pointer_event.time = time
        pointer_event.axis = axis
        if axis == 0
          pointer_event.value_vertical = value
        else
          pointer_event.value_horizontal = value
        end
      end

      protected def frame
        process
        pointer_event.reset
      end

      protected def axis_source(axis_source)
        pointer_event.axis_source = axis_source
      end

      protected def axis_stop(time, axis)
        raise "Axis stop: Not implemented yet, sorry. Please tell me how to trigger it"
      end

      protected def axis_discrete(axis, value)
        if axis == 0
          pointer_event.discrete_vertical = value
        else
          pointer_event.discrete_horizontal = value
        end
      end

      protected def listener
        pointerof(@callback)
      end
    end
  end
end
