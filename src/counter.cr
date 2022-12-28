module WaylandClient
  class Counter
    getter time
    getter counter

    def initialize(@template : String)
      @counter = 0
      @time = Time.utc
    end

    def register
      register Time.utc.to_unix_ms.to_u64
    end

    # TODO: Keep history and stats
    def register(at)
      @counter &+= 1
    end

    def measure(frequency = 1)
      yield @counter
      @counter = 0
      @time += frequency.seconds
      timeout = @time - Time.utc
      sleep timeout
    end
  end
end
