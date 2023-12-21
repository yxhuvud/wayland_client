require "../lib/lib_wayland_client"
require "./pointer_event"

module WaylandClient
  class Seat
    module PointerHandler
      getter :pointer_event

      def initialize
        @pointer_event = PointerEvent.new
        @callback = LibWaylandClient::WlPointerListener.new(
          enter: LibWaylandClient::WlPointerListenerEnter.new do |data, pointer, serial, surface, x, y|
            data.as(self).handle_enter(serial, surface, x, y)
          end,

          leave: LibWaylandClient::WlPointerListenerLeave.new do |data, pointer, serial, surface|
            data.as(self).handle_leave(serial, surface)
          end,

          motion: LibWaylandClient::WlPointerListenerMotion.new do |data, pointer, time, x, y|
            data.as(self).motion(time, x, y)
          end,

          button: LibWaylandClient::WlPointerListenerButton.new do |data, pointer, serial, time, button, state|
            data.as(self).button(time, serial, button, state)
          end,

          axis: LibWaylandClient::WlPointerListenerAxis.new do |data, pointer, time, axis, value|
            data.as(self).axis(time, axis, value)
          end,

          frame: LibWaylandClient::WlPointerListenerFrame.new do |data, pointer|
            data.as(self).frame
          end,

          axis_source: LibWaylandClient::WlPointerListenerAxisSource.new do |data, pointer, axis_source|
            data.as(self).axis_source(axis_source)
          end,

          axis_stop: LibWaylandClient::WlPointerListenerAxisStop.new do |data, pointer, time, axis|
            data.as(self).axis_stop(time, axis)
          end,

          axis_discrete: LibWaylandClient::WlPointerListenerAxisDiscrete.new do |data, pointer, axis, discrete|
            data.as(self).axis_discrete(axis, discrete * 120)
          end,

          axis_value120: LibWaylandClient::WlPointerListenerAxisValue120.new do |data, pointer, axis, discrete|
            data.as(self).axis_discrete(axis, discrete)
          end,
        )
      end

      def frame
      end

      def enter
      end

      def leave
      end

      class Base
        include PointerHandler
      end

      protected def handle_enter(serial, surface, x, y)
        pointer_event.serial = serial
        pointer_event.surface = surface
        pointer_event.x = x
        pointer_event.y = y
        enter
        pointer_event.reset
      end

      protected def handle_leave(serial, surface)
        pointer_event.serial = serial
        pointer_event.surface = surface
        leave
        pointer_event.reset
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

      protected def handle_frame
        frame
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
