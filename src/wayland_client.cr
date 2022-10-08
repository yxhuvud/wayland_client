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

  setup_counter = WaylandClient::Counter.new("setup: %s")

  display.create_frame(surface, title: "hello", app_id: "hello app") do |x, y, window_state|
    setup_counter.register
    pool.resize!(x, y, surface) do |buffer|
      buffer.set_all do |x1, y1|
        (x1 &* y1 < x &* x / 2) ? WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF) : WaylandClient::Format::XRGB8888.new(0, 0, 0)
      end
    end
  end

  spawn do
    loop do
      sleep 5
      surface.repaint!(pool, &.set_all { WaylandClient::Format::XRGB8888.new(0, 0xFF, 0) })
    end
  end

  display.wait_loop
end
