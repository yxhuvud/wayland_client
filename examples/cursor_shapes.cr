require "../src/wayland_client"

class CursorShapePointerHandler
  include WaylandClient::PointerHandler

  getter pointer

  def initialize(@pointer : WaylandClient::Seat::Pointer)
    super()
  end

  def enter
    set_shape(WaylandClient::CursorShape::Default)
  end

  def set_shape(shape : WaylandClient::CursorShape)
    unless pointer.cursor_shapes?
      puts "cursor-shape-v1 is not available; use a custom surface cursor instead"
      return
    end

    # The protocol requires the latest pointer-enter serial. The pointer
    # wrapper uses this handler's most recent enter serial by default.
    pointer.set_shape(shape)
    puts "cursor shape: #{shape}"
  end
end

class CursorShapeKeyboardHandler
  include WaylandClient::KeyboardHandler

  SHAPES = [
    WaylandClient::CursorShape::Pointer,
    WaylandClient::CursorShape::Grab,
    WaylandClient::CursorShape::Text,
    WaylandClient::CursorShape::Wait,
    WaylandClient::CursorShape::Crosshair,
  ]

  def initialize(@pointer_handler : CursorShapePointerHandler)
    super()
  end

  def key(time, key, state, serial)
    return unless state.pressed?

    index =
      case key.chr
      when '1' then 0
      when '2' then 1
      when '3' then 2
      when '4' then 3
      when '5' then 4
      else return
      end

    @pointer_handler.set_shape(SHAPES[index])
  end
end

WaylandClient.connect do |client|
  surface = client.create_surface(
    kind: :memory,
    format: WaylandClient::Format::XRGB8888,
    opaque: true,
  )

  client.create_frame(surface, title: "Cursor shapes", app_id: "cursor-shapes") do
    surface.repaint do |buffer|
      buffer.fill(WaylandClient::Format::XRGB8888.from_rgba(
        red: 0x30u8,
        green: 0x35u8,
        blue: 0x40u8,
        alpha: 0xFFu8,
      ))
    end
  end

  pointer_handler = CursorShapePointerHandler.new(client.pointer)
  client.pointer.handler = pointer_handler
  client.keyboard.handler = CursorShapeKeyboardHandler.new(pointer_handler)

  puts "Move the pointer into the window, then press 1-5 to change shape."
  puts "Available: #{client.pointer.cursor_shapes?}"
  client.wait_loop
end
