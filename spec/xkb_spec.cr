require "./spec_helper"
require "../src/seat/xkb"

describe WaylandClient::Seat::Xkb do
  it "converts modifier masks to modifier flags" do
    modifiers = WaylandClient::Seat::Xkb::Modifiers.new(
      WaylandClient::Seat::Xkb::Modifiers::Modifier::SHIFT.value |
        WaylandClient::Seat::Xkb::Modifiers::Modifier::CTRL.value,
      0u32,
      WaylandClient::Seat::Xkb::Modifiers::Modifier::CAPSLOCK.value,
      0u32,
    )

    modifiers.depressed.should eq(
      WaylandClient::Seat::Xkb::Modifiers::Modifier::SHIFT |
        WaylandClient::Seat::Xkb::Modifiers::Modifier::CTRL
    )
    modifiers.locked.should eq WaylandClient::Seat::Xkb::Modifiers::Modifier::CAPSLOCK
  end

  it "identifies modifier keysyms" do
    modifier = WaylandClient::Seat::Xkb::Key.new(65505u32, 42u32)
    regular = WaylandClient::Seat::Xkb::Key.new(65u32, 30u32)

    modifier.modifier?.should be_true
    regular.modifier?.should be_false
    regular.chr.should eq 'A'
  end
end
