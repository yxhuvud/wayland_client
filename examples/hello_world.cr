require "../src/wayland_client"

WaylandClient.connect do |client|
  surface = client.create_surface(
    kind: :memory,
    format: WaylandClient::Format::XRGB8888,
    opaque: true,
  )

  # The block is called on initialization and on resize, and
  # potentially in more cases.
  frame = client.create_frame(surface, title: "hello", app_id: "hello app") do |max_x, max_y, window_state|
    surface.repaint! do |buf|
      buf.map! do |x, y|
        # This will create a diagonal line on a green background
        if (max_x + max_y)/2 - 25 <= x + y <= (max_x + max_y)/2 + 25
          WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF)
        else
          WaylandClient::Format::XRGB8888.new(0x77, 0xCC, 0x00)
        end
      end
    end
    surface.commit
  end

  client.wait_loop
  surface.close
end
