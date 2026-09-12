require "./spec_helper"
require "../src/seat/pointer_event"

describe WaylandClient::Seat::PointerEvent do
  it "resets transient event state" do
    event = WaylandClient::Seat::PointerEvent.new
    surface = Pointer(WaylandClient::LibWaylandClient::WlSurface).new(1_u64)
    event.surface = surface
    event.x = 10
    event.y = 20
    event.serial = 30
    event.button_state = true
    event.button = 40
    event.axis = 50
    event.time = 60
    event.value_vertical = 70
    event.value_horizontal = 80
    event.discrete_vertical = 90
    event.discrete_horizontal = 100

    event.reset

    event.x.should eq 10
    event.y.should eq 20
    event.serial.should eq 30
    event.surface.should eq surface
    event.button_state.should be_false
    event.button.should eq 0
    event.axis.should eq 0
    event.time.should eq 0
    event.value_vertical.should eq 0
    event.value_horizontal.should eq 0
    event.discrete_vertical.should eq 0
    event.discrete_horizontal.should eq 0
  end
end
