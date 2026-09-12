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

    it "closes keyboard XKB resources with the client" do
      keyboard = nil
      client do |current|
        keyboard = current.keyboard
        keyboard.handler.xkb.context.null?.should be_false
      end

      keyboard.not_nil!.handler.xkb.context.null?.should be_true
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

    it "removes globals from the registry" do
      client do |client|
        global_name = nil
        client.registry.names.each do |name, interface_name|
          global_name = name if interface_name == "wl_shm"
        end

        global_name.should_not be_nil
        client.registry.unregister(global_name.not_nil!)
        client.registry.names.values.should_not contain("wl_shm")
      end
    end

    it "detects and uses native cursor shapes when available" do
      client do |client|
        manager_name = nil
        client.registry.names.each do |name, interface_name|
          manager_name = name if interface_name == "wp_cursor_shape_manager_v1"
        end

        pointer = client.pointer
        if manager_name
          client.registry.versions[manager_name.not_nil!].should be >= 1
          pointer.cursor_shapes?.should be_true
          pointer.set_shape(WaylandClient::CursorShape::Default, 0u32)
        else
          pointer.cursor_shapes?.should be_false
        end
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
