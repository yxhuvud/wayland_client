require "./pointer_handler"
require "../lib/lib_cursor_shape"

module WaylandClient
  class Seat
    class Pointer
      getter handler
      @cursor_shape_device : ::Pointer(LibCursorShape::Device)?

      def initialize(seat, @cursor_shape_manager : ::Pointer(LibCursorShape::Manager)?)
        @pointer = LibWaylandClient.wl_seat_get_pointer(seat)
        @handler = PointerHandler::Base.new
        @cursor_shape_device = nil
      end

      def handler=(handler : PointerHandler)
        LibWaylandClient.wl_pointer_add_listener(self, handler.listener, handler.as(Void*))
        @handler = handler
      end

      def to_unsafe
        @pointer
      end

      def set_shape(shape : CursorShape, serial = handler.pointer_event.serial)
        manager = @cursor_shape_manager
        raise "cursor shapes are not supported" unless manager

        device = @cursor_shape_device ||= LibCursorShape.cursor_shape_manager_get_pointer(manager, self)
        LibCursorShape.cursor_shape_device_set_shape(device, serial, shape.value)
      end

      def cursor_shapes?
        !@cursor_shape_manager.nil?
      end

      def close
        if device = @cursor_shape_device
          LibCursorShape.cursor_shape_device_destroy(device)
          @cursor_shape_device = nil
        end
      end
    end
  end
end
