require "./spec_helper"

def client(&)
  c = nil
  WaylandClient.connect do |client|
    c = client
    yield client
  end
  c.not_nil!
end

describe WaylandClient do
  describe ".connect" do
    it "connects a display" do
      client = client do |c|
        c.display.connected?.should be_true
      end
    end

    it "disconnect the display once done" do
      client { }.display.connected?.should be_false
    end

    it "populates the registry information" do
      client = client { }
      names = client.registry.names.values
      [
        "wl_compositor",
        "wl_shm",
        "wl_subcompositor",
        "xdg_wm_base",
        "wl_seat",
      ].all? { |name| name.in?(names) }.should be_true
    end

    it "allows the creation of a surface" do
      client do |c|
        surface = c.create_surface(
          kind: :memory,
          format: WaylandClient::Format::XRGB8888,
          opaque: true,
        )

        surface.format.should eq WaylandClient::Format::XRGB8888
        surface.buffer_pool.size.should eq({0, 0})
      end
    end
  end
end
