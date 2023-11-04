require "./pointer_handler"

module WaylandClient
  class Seat
    class Pointer
      getter handler

      def initialize(seat)
        @pointer = LibWaylandClient.wl_seat_get_pointer(seat)
        @handler = PointerHandler::Base.new
      end

      def handler=(handler : PointerHandler)
        LibWaylandClient.wl_pointer_add_listener(self, handler.listener, handler.as(Void*))
        @handler = handler
      end

      def to_unsafe
        @pointer
      end
    end
  end
end
