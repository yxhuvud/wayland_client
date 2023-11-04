require "./keyboard_handler"

module WaylandClient
  class Seat
    class Keyboard
      getter handler

      def initialize(seat)
        @keyboard = LibWaylandClient.wl_seat_get_keyboard(seat)
        @handler = KeyboardHandler::Base.new
      end

      def handler=(handler : KeyboardHandler)
        LibWaylandClient.wl_keyboard_add_listener(self, handler.listener, handler.as(Void*))
        @handler = handler
      end

      def to_unsafe
        @keyboard
      end
    end
  end
end
