require "./spec_helper"
require "../src/seat/pointer_handler"

class SpecPointerHandler
  include WaylandClient::Seat::PointerHandler

  @received : NamedTuple(time: UInt32, x: Int32, y: Int32, button: UInt32, button_state: Bool)?
  getter received

  def initialize
    @received = nil
    super
  end

  def frame
    @received = {
      time: pointer_event.time,
      x: pointer_event.x,
      y: pointer_event.y,
      button: pointer_event.button,
      button_state: pointer_event.button_state,
    }
  end

  def simulate_frame
    motion(12u32, 30, 40)
    button(13u32, 14u32, 272u32, 1u32)
    handle_frame
  end
end

describe WaylandClient::Seat::PointerHandler do
  it "delivers accumulated pointer state and resets it after a frame" do
    handler = SpecPointerHandler.new

    handler.simulate_frame

    handler.received.should eq({
      time: 13u32,
      x: 30,
      y: 40,
      button: 272u32,
      button_state: true,
    })
    handler.pointer_event.time.should eq 0
    handler.pointer_event.button.should eq 0
    handler.pointer_event.button_state.should be_false
  end
end
