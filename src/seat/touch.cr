#require "./touch_handler"

module WaylandClient
  class Seat
    class Touch
      getter handler

      def initialize(seat)
        @touch = LibWaylandClient.wl_seat_get_touch(seat)
        @handler = TouchHandler::Base.new
      end

      def handler=(handler : TouchHandler)
        LibWaylandClient.wl_touch_add_listener(self, handler.listener, handler.as(Void*))
        @handler = handler
      end

      def to_unsafe
        @touch
      end
    end
  end
end
