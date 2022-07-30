module WaylandClient
  class Decor
    class Frame
      getter :decor, :surface

      def initialize(@decor : Decor, @surface : Surface, @configure_callback : Proc(LibC::Int, LibC::Int, LibDecor::WindowState, Void))
        @interface = LibDecor::FrameInterface.new(
          configure: Proc(Pointer(LibDecor::Frame), Pointer(LibDecor::Configuration), Pointer(Void), Void).new { |frame, config, data|
            data.as(Frame).configure(config)
          },
          close: Proc(Pointer(LibDecor::Frame), Pointer(Void), Void).new { |frame, data|
            frame = data.as(Frame)
            # TODO: support close callback.
            frame.unref
          },
          commit: Proc(Pointer(LibDecor::Frame), Pointer(Void), Void).new { |frame, data|
            data.as(Frame).surface.commit
          },
          dismiss_popup: Proc(Pointer(LibDecor::Frame), Pointer(Char), Pointer(Void), Void).new { |frame, charp, data|
            p :dismiss
          }
        )
        @frame = LibDecor.decorate(decor, surface, pointerof(@interface), self.as(Void*))
      end

      def configure(config)
        dimensions = get_content_size(config)
        initial = false
        x, y =
          if dimensions
            dimensions
          else
            initial = true

            {400, 300}
          end
        window_state = get_window_state(config)
        # Initial call to configure sets the initial window size,
        # doing the callback at this point will result in misalignment in output.
        commit(config, x, y) if initial
        @configure_callback.call(x, y, window_state)
        commit(config, x, y)
      end

      def get_content_size(config : Pointer(LibDecor::Configuration))
        return nil if LibDecor.configuration_get_content_size(config, self, out x, out y).zero?

        {x, y}
      end

      def translate(x, y)
        LibDecor.libdecor_frame_translate_coordinate(self, x, y, out x2, out y2)
        {x2, y2}
      end

      def get_window_state(config : Pointer(LibDecor::Configuration))
        LibDecor.configuration_get_window_state(config, out window_state)
        window_state
      end

      def to_unsafe
        @frame.not_nil!
      end

      def visibility=(visibility : Bool)
        LibDecor.frame_set_visibility(self, visiblity ? 1 : 0)
      end

      def visible?
        LibDecor.frame_is_visible(self)
      end

      def title=(string)
        LibDecor.frame_set_title(self, string.to_unsafe.as(Pointer(Char)))
      end

      def title
        chars = LibDecor.frame_get_title(self)
        String.new(chars)
      end

      def app_id=(app_id)
        LibDecor.frame_set_app_id(self, app_id.to_unsafe.as(Pointer(Char)))
      end

      # TODO: capabilities

      def unref
        decor.frame_removed(self)
        LibDecor.frame_unref(self)
      end

      def close
        LibDecor.frame_close(self)
      end

      def map
        LibDecor.frame_map(self)
      end

      def commit(config, x, y)
        state = LibDecor.state_new(x, y)
        LibDecor.frame_commit(self, state, config)
        LibDecor.state_free(state)
      end
    end
  end
end
