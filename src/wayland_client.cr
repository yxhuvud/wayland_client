# TODO: Write documentation for `WaylandClient`

require "./display"
require "./lib/lib_c"

module WaylandClient
  VERSION = "0.1.0"

  def self.display
    Display.connect { |display| yield display }
  end
end

WaylandClient.display do |display|
  surface = display.create_surface
  pool = WaylandClient::Buffer.build(:memory, WaylandClient::Format::XRGB8888, display)

  display.create_frame(surface, title: "hello", app_id: "hello app") do |x, y, window_state|
    buffer = pool.checkout_of_size(x, y)

    white = WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF)
    black = WaylandClient::Format::XRGB8888.new(0, 0, 0)
    buffer.set_all do |x1, y1|
      (x1 * y1 < x * x / 2) ? white : black
    end
    surface.attach_buffer(buffer)
    surface.commit
  end

  display.wait_loop
end
