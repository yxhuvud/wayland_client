require "./display"
require "./lib/lib_decor"
require "./decor/frame"

module WaylandClient
  class Decor
    getter context, display
    @error_callback : Pointer(LibDecor::Context), WaylandClient::LibDecor::Error, Pointer(Char) -> Void

    def initialize(@display : Display)
      @error_callback = Proc(LibDecor::Context*, LibDecor::Error, Char*, Void).new do |_context, error, char|
        error_message = String.new(char.as(Pointer(UInt8)))

        puts "#{error.to_s} : #{error_message}"
      end
      @interface = LibDecor::Interface.new(error: @error_callback)
      @context = LibDecor.libdecor_new(display, pointerof(@interface))
      @frames = Set(Frame).new
    end

    def frame(surface,
              title = nil,
              app_id = nil,
              &configure_callback : LibC::Int, LibC::Int, LibDecor::WindowState -> Void)
      frame(surface, title, app_id, configure_callback)
    end

    def frame(surface, title, app_id, configure_callback)
      Decor::Frame.new(self, surface, configure_callback).tap do |frame|
        frame.title = title if title
        frame.app_id = app_id if app_id
        # Trigger configure event:
        frame.map
        @frames << frame
      end
    end

    def frame_removed(frame)
      @frames.delete(frame)
    end

    def to_unsafe
      @context
    end

    def wait_loop
      fd = LibDecor.get_fd(@context)
      file = IO::FileDescriptor.new(fd)
      event_loop = Crystal::EventLoop.current
      loop do
        display.flush
        event_loop.wait_readable(file)
        dispatch

        break unless has_frame?
      end
    end

    def has_frame?
      @frames.size > 0
    end

    def dispatch
      LibDecor.dispatch(context, 0)
    end

    def finalize
      LibDecor.unref @context
    end
  end
end
