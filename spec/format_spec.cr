require "./spec_helper"

describe WaylandClient::Format do
  it "stores ARGB channels in the declared pixel layout" do
    pixel = WaylandClient::Format::ARGB8888.new(1u8, 2u8, 3u8, 4u8)

    pixel.red.should eq 3u8
    pixel.green.should eq 2u8
    pixel.blue.should eq 1u8
    pixel.alpha.should eq 4u8
    WaylandClient::Format::ARGB8888.shm_format
      .should eq WaylandClient::LibWaylandClient::WlShmFormat::ARGB8888
  end

  it "reports the XRGB shared-memory format" do
    WaylandClient::Format::XRGB8888.shm_format
      .should eq WaylandClient::LibWaylandClient::WlShmFormat::XRGB8888
  end

  it "converts ARGB pixels using semantic RGBA channels" do
    pixel = WaylandClient::Format::ARGB8888.from_rgba(
      red: 1u8,
      green: 2u8,
      blue: 3u8,
      alpha: 4u8,
    )

    pixel.to_rgba.should eq({red: 1u8, green: 2u8, blue: 3u8, alpha: 4u8})
  end

  it "converts XRGB pixels with opaque alpha" do
    pixel = WaylandClient::Format::XRGB8888.from_rgba(
      red: 1u8,
      green: 2u8,
      blue: 3u8,
      alpha: 4u8,
    )

    pixel.to_rgba.should eq({red: 1u8, green: 2u8, blue: 3u8, alpha: 255u8})
  end
end
