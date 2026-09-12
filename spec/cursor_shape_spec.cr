require "./spec_helper"
require "../src/lib/lib_cursor_shape"

describe WaylandClient::CursorShape do
  it "uses the protocol's v2 shape values" do
    WaylandClient::CursorShape::Default.value.should eq 1u32
    WaylandClient::CursorShape::Pointer.value.should eq 4u32
    WaylandClient::CursorShape::ZoomOut.value.should eq 34u32
    WaylandClient::CursorShape::DndAsk.value.should eq 35u32
    WaylandClient::CursorShape::AllResize.value.should eq 36u32
  end
end
