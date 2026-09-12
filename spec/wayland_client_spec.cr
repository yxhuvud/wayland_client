require "./spec_helper"

def client(&)
  result = nil
  WaylandClient.connect do |current|
    result = current
    yield current
  end
  result.not_nil!
end

describe WaylandClient do
  describe ".connect" do
    it "connects a display" do
      client do |client|
        client.display.connected?.should be_true
      end
    end

    it "disconnects the display once the block ends" do
      client { }.display.connected?.should be_false
    end

    it "closes safely when called more than once" do
      client do |client|
        client.close
        client.close

        client.closed?.should be_true
        client.display.connected?.should be_false
      end
    end

    it "populates the registry while the connection is live" do
      client do |client|
        names = client.registry.names.values
        [
          "wl_compositor",
          "wl_shm",
          "wl_subcompositor",
          "xdg_wm_base",
          "wl_seat",
        ].all? { |name| name.in?(names) }.should be_true
      end
    end

    it "allows a surface to be closed more than once" do
      client do |client|
        surface = client.create_surface(
          kind: :memory,
          format: WaylandClient::Format::XRGB8888,
          opaque: true,
        )

        surface.format.should eq WaylandClient::Format::XRGB8888
        surface.buffer_pool.size.should eq({0, 0})
        surface.close
        surface.close
      end
    end
  end
end
