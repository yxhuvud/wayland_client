require "../lib/lib_wayland_client"

module WaylandClient
  class Seat
    class PointerEvent
      property surface : LibWaylandClient::WlSurface* # FIXME: Associate a handler to a surface using these?
      property x : LibC::Int
      property y : LibC::Int
      property serial : UInt32
      property button_state : Bool
      property button : UInt32
      property axis : UInt32
      property time : UInt32
      property axis_source : LibWaylandClient::WlPointerAxisSource
      property value_vertical : Int32
      property value_horizontal : Int32
      property discrete_horizontal : Int32
      property discrete_vertical : Int32

      def initialize
        @surface = ::Pointer(LibWaylandClient::WlSurface).null
        @x = 0
        @y = 0
        @serial = 0
        @button_state = false
        @button = 0
        @axis = 0
        @axis_source = LibWaylandClient::WlPointerAxisSource::Wheel
        @time = 0 # Unit?!?
        @value_horizontal = 0
        @discrete_horizontal = 0
        @value_vertical = 0
        @discrete_vertical = 0
      end

      def reset
        @button_state = false
        @button = 0
        @axis = 0
        @axis_source = LibWaylandClient::WlPointerAxisSource::Wheel
        @time = 0 # Unit?!?
        @value_horizontal = 0
        @discrete_horizontal = 0
        @value_vertical = 0
        @discrete_vertical = 0
      end
    end
  end
end
