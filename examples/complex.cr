require "../src/wayland_client"

SURFACE_WHITE         = WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF)
SUBSURFACE_RED        = WaylandClient::Format::XRGB8888.new(0xFF, 0, 0)
SUBSURFACE2_BLACK     = WaylandClient::Format::ARGB8888.new(0x0, 0x0, 0x0, 0xAA)
CURSOR_ALPHA          = WaylandClient::Format::ARGB8888.new(0x0, 0x0, 0x0, 0x00)
CURSOR_POINTER        = WaylandClient::Format::ARGB8888.new(0xAA, 0xAA, 0xAA, 0xFF)
CURSOR_POINTER_BORDER = WaylandClient::Format::ARGB8888.new(0xFF, 0xFF, 0xFF, 0xFF)

frame_counter = WaylandClient::Counter.new("Frames: %s")
sleep 0.01 # To make the counters print in consistent order
setup_counter = WaylandClient::Counter.new("setup: %s")

spawn do
  loop { frame_counter.measure { |value| puts "frame: %s" % value } }
end

spawn do
  loop { setup_counter.measure { |value| puts "config: %s" % value } }
end

class PointerHandler
  include WaylandClient::PointerHandler

  property fullscreen
  property cursor : WaylandClient::Cursor(WaylandClient::Format::ARGB8888)

  def initialize(@frame : WaylandClient::Decor::Frame, @cursor)
    super()
    @fullscreen = false
  end

  def enter
    @cursor.use(pointer_event.serial)
  end

  def frame
    if pointer_event.button_state
      pp pointer_event
      # Commented due to what I think is a libdecor bug. But I could
      # be using it wrong too..

      # if fullscreen
      #   @frame.unfullscreen
      #   @fullscreen = false
      # else
      #   @frame.fullscreen
      #   @fullscreen = true
      # end
    end
  end
end

class KeyboardHandler
  include WaylandClient::KeyboardHandler

  def key(time, key, state, serial)
    p "keyboard key: %s, modifiers: %s" % {key, modifiers.depressed.to_s}
  end
end

WaylandClient.connect do |client|
  surface = client.create_surface(
    kind: :memory,
    format: WaylandClient::Format::XRGB8888,
    opaque: true,
  )

  # Creates an async subsurface, as there is (currently) no way to use
  # libdecor with async top surfaces. An async surface is necessary or
  # else there will be update events only when the outer frame wake up
  # and wants to update. Which won't be very often.
  subsurface = surface.create_subsurface(
    kind: :memory,
    format: WaylandClient::Format::XRGB8888,
    sync: false,
    opaque: true,
  )

  # Create a different subsurface, that is updated whenever someone chooses to
  subsurface2 = subsurface.surface.create_subsurface(
    kind: :memory,
    format: WaylandClient::Format::ARGB8888,
    opaque: true,
  )

  frame_callback = Proc(UInt32, Nil).new do |time|
    frame_counter.register time

    subsurface.surface.repaint!(&.map! { SUBSURFACE_RED })
  end

  # The block is called on initialization and on resize, and
  # potentially in more cases.
  frame = client.create_frame(surface, title: "hello", app_id: "hello app") do |x, y, window_state|
    setup_counter.register

    surface.repaint! &.map! { SUBSURFACE_RED }
    surface.commit

    # Make sure to paint the subsurface here as it will look wrong on
    # resize otherwise.
    subsurface.surface.resize(**surface.size)
    subsurface.surface.repaint! &.map! { SUBSURFACE_RED }

    # paint second subsurface, once
    subsurface2.surface.resize(x: 50, y: 100)
    subsurface2.surface.repaint! &.map! { SUBSURFACE2_BLACK }

    # Automatically generate new frames at monitor FPS. Cannot be set
    # up before configuration (ie this block) has been run, but also
    # has to be regenerated on each configuration due to what I
    # believe is a compositor bug. If it is only set up once it will
    # stop running if there is a configuration event, but if a new
    # frame is requested it will run both!
    subsurface.surface.request_frame(frame_callback)
  end

  cursor = WaylandClient::Format::ARGB8888.cursor(
    client: client,
    kind: :memory,
    size: {x: 32, y: 32},
    hotspot: {x: 0, y: 0},
  ) do |buf|
    buf.map! do |x, y|
      if x == 0 || y == 0
        CURSOR_POINTER_BORDER
      elsif x < 15 || y < 15
        CURSOR_POINTER
      else
        CURSOR_ALPHA
      end
    end
  end
  client.pointer.handler = PointerHandler.new(frame, cursor)
  client.keyboard.handler = KeyboardHandler.new

  client.wait_loop

  subsurface2.close
  subsurface.close
  surface.close
end
