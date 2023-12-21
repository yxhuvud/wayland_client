require "./surface"

module WaylandClient
  class Cursor(Format)
    getter surface : Surface(Format)
    getter hotspot
    getter callback : Proc(WaylandClient::Buffer::Memory(Format), Void)

    def initialize(@client : WaylandClient::Client, @surface, size, @hotspot : NamedTuple(x: Int32, y: Int32), @callback)
      surface.resize(size[:x], size[:y])
    end

    def use(serial)
      paint
      LibWaylandClient.wl_pointer_set_cursor(pointer, serial, surface, hotspot[:x], hotspot[:y])
    end

    private def paint
      surface.repaint! { |buf| @callback.call(buf) }
    end

    private def pointer
      @client.pointer
    end
  end
end
