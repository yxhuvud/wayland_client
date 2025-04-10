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
      client.registry.names.superset_of?(
        {
           1u32 => "wl_compositor",
           3u32 => "wl_shm",
           9u32 => "wl_subcompositor",
          10u32 => "xdg_wm_base",
          16u32 => "wl_seat",
        }
      ).should be_true
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
