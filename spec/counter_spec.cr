require "./spec_helper"

describe WaylandClient::Counter do
  it "counts registrations" do
    counter = WaylandClient::Counter.new("test")

    counter.counter.should eq 0
    counter.register(123)
    counter.register(456)
    counter.counter.should eq 2
  end
end
