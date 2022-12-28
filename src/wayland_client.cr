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

WHITE = WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF)
BLACK = WaylandClient::Format::XRGB8888.new(0, 0, 0)

WaylandClient.display do |display|
  surface = display.create_surface(
    buffer_pool: WaylandClient::Buffer.new(:memory, WaylandClient::Format::XRGB8888),
    opaque: true
  )
  # fixme
  subsurface = surface.create_subsurface sync: false, opaque: true

  frame_counter = WaylandClient::Counter.new("Frames: %s")
  setup_counter = WaylandClient::Counter.new("setup: %s")

  frame_callback = Proc(UInt32, Nil).new do |time|
    frame_counter.register time

    subsurface.surface.repaint!(&.map! { WHITE })
  end

  display.create_frame(surface, title: "hello", app_id: "hello app") do |x, y, window_state|
    setup_counter.register

    surface.repaint!(flush: false, &.set_all { |x1, y1| BLACK })
    subsurface.surface.resize(*surface.size)
    subsurface.surface.repaint! &.map! { WHITE }

    subsurface.surface.request_frame(frame_callback)
  end

  display.wait_loop
end
