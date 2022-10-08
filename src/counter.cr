module WaylandClient
  class Counter
    getter time

    def initialize(@template : String)
      @counter = 0
      @time = 0u64
    end

    def register
      register Time.utc.to_unix_ms.to_u64
    end

    def register(at)
      if time.zero?
        @time = at.to_u64
      elsif at &- time > 1000
        while @time <= at &- 1000
          @time = @time &+ 1000
        end
        puts @template % @counter
        @counter = 1
      else
        @counter &+= 1
      end
    end
  end
end
