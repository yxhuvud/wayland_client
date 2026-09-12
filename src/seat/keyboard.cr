require "./keyboard_handler"

module WaylandClient
  class Seat
    class Keyboard
      getter handler

      def initialize(seat)
        @keyboard = LibWaylandClient.wl_seat_get_keyboard(seat)
        @handler = KeyboardHandler::Base.new
        @closed = false
      end

      def handler=(handler : KeyboardHandler)
        raise "keyboard is closed" if @closed
        LibWaylandClient.wl_keyboard_add_listener(self, handler.listener, handler.as(Void*))
        @handler = handler
      end

      def close
        return if @closed
        @closed = true
        @handler.close
      end

      def to_unsafe
        @keyboard
      end
    end
  end
end
