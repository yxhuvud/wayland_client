# TODO: Write documentation for `WaylandClient`

require "./format"
require "./display"
require "./counter"
require "./buffer/memory"

module WaylandClient
  VERSION = "0.1.0"

  def self.display
    Display.connect { |display| yield display }
  end
end

SURFACE_WHITE     = WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF)
SUBSURFACE_RED    = WaylandClient::Format::XRGB8888.new(0xFF, 0, 0)
SUBSURFACE2_BLACK = WaylandClient::Format::ARGB8888.new(0x0, 0x0, 0x0, 0xAA)

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

  def initialize(@frame : WaylandClient::Decor::Frame)
    super()
    @fullscreen = false
  end

  def process
    if pointer_event.button_state
      p "button pressed: %s " % pointer_event.button
      # Commented due to libdecor bug
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

WaylandClient.display do |display|
  surface = display.create_surface(
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
  frame = display.create_frame(surface, title: "hello", app_id: "hello app") do |x, y, window_state|
    setup_counter.register

    surface.repaint! &.map! { SUBSURFACE_RED }
    # The base surface needs an attached buffer, or there will be no
    # window generated, but it actually don't need to be painted as
    # the subsurface will cover the whole of it.
    surface.attach_buffer
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

  display.seat.pointer_handler = PointerHandler.new(frame)
  display.seat.keyboard_handler = KeyboardHandler.new

  display.wait_loop

  subsurface.close
  surface.close
end
