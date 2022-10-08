# TODO: Write documentation for `WaylandClient`

require "./display"
require "./lib/lib_c"

module WaylandClient
  VERSION = "0.1.0"

  def self.display
    Display.connect { |display| yield display }
  end
end

WHITE = WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF)
BLACK = WaylandClient::Format::XRGB8888.new(0, 0, 0)

WaylandClient.display do |display|
  surface = display.create_surface
  pool = WaylandClient::Buffer.new(:memory, WaylandClient::Format::XRGB8888, display)
  subsurface = surface.create_subsurface sync: false

  frame_counter = WaylandClient::Counter.new("Frames: %s")
  setup_counter = WaylandClient::Counter.new("setup: %s")

  frame_callback = Proc(UInt32, Nil).new do |time|
    frame_counter.register time
    subsurface.surface.repaint!(pool, &.set_all { WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xCF) })
  end

  display.create_frame(surface, title: "hello", app_id: "hello app") do |x, y, window_state|
    setup_counter.register
    pool.resize!(x, y, surface) do |buffer|
      buffer.set_all do |x1, y1|
        (x1 &* y1 < x &* x / 2) ? WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF) : WaylandClient::Format::XRGB8888.new(0, 0, 0)
      end
    end

    subsurface.surface.repaint!(pool) do |buf|
      buf.set_all { WaylandClient::Format::XRGB8888.new(0xFF, 0xAF, 0xFF) }
    end

    subsurface.surface.request_frame(frame_callback)
  end

  display.wait_loop
end
