require "./spec_helper"

class SpecPixelBuffer
  include WaylandClient::Buffer::Buffer

  getter width : Int32
  getter height : Int32

  def initialize(@width : Int32, @height : Int32)
    @pixels = StaticArray(UInt32, 12).new(0u32)
  end

  def buffer
    @pixels.to_unsafe
  end

  def pixels
    @pixels.to_a
  end
end

class SpecPooledBuffer
  getter width : Int32
  getter height : Int32
  getter closed : Bool

  def initialize
    @width = 0
    @height = 0
    @closed = false
  end

  def resize(@width : Int32, @height : Int32)
  end

  def close
    @closed = true
  end
end

describe WaylandClient::Buffer do
  describe WaylandClient::Buffer::Buffer do
    it "maps every pixel" do
      buffer = SpecPixelBuffer.new(4, 3)

      buffer.map! { |x, y| (y * 4 + x).to_u32 }

      buffer.pixels.should eq((0u32...12u32).to_a)
    end

    it "maps only the requested ranges" do
      buffer = SpecPixelBuffer.new(4, 3)

      buffer.fill(0u32)
      buffer.map!(1...3, 1...3) { |x, y| (y * 4 + x).to_u32 }

      buffer.pixels.should eq([
        0u32, 0u32, 0u32, 0u32,
        0u32, 5u32, 6u32, 0u32,
        0u32, 9u32, 10u32, 0u32,
      ])
    end

    it "rejects ranges outside the buffer" do
      buffer = SpecPixelBuffer.new(4, 3)

      expect_raises(Exception, /invalid range/) do
        buffer.map!(4...5, 0...1) { 1u32 }
      end
    end
  end

  describe WaylandClient::Buffer::Pool do
    it "reuses released buffers and enforces the pool size" do
      pool = WaylandClient::Buffer::Pool(SpecPooledBuffer).new(20, 10)

      first = pool.checkout { SpecPooledBuffer.new }
      second = pool.checkout { SpecPooledBuffer.new }

      first.width.should eq 20
      first.height.should eq 10
      pool.available?.should be_false

      pool.checkin(first)
      pool.available?.should be_true

      reused = pool.checkout { SpecPooledBuffer.new }
      reused.should eq first
      pool.checkin(second)
      pool.checkin(reused)
    end

    it "rejects invalid sizes" do
      pool = WaylandClient::Buffer::Pool(SpecPooledBuffer).new

      expect_raises(Exception, /Invalid size/) do
        pool.resize(0, 10)
      end
    end
  end
end
