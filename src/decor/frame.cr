module WaylandClient
  class Decor
    class Frame
      getter :decor, :surface

      def initialize(@decor : Decor, @surface : GenericSurface, @configure_callback : Proc(LibC::Int, LibC::Int, LibDecor::WindowState, Void), @initial_size = {400, 300})
        @interface = LibDecor::FrameInterface.new(
          configure: Proc(Pointer(LibDecor::Frame), Pointer(LibDecor::Configuration), Pointer(Void), Void).new { |frame, config, data|
            data.as(Frame).configure(config)
          },
          close: Proc(Pointer(LibDecor::Frame), Pointer(Void), Void).new { |frame, data|
            frame = data.as(Frame)
            frame.unref
          },
          commit: Proc(Pointer(LibDecor::Frame), Pointer(Void), Void).new { |frame, data|
            data.as(Frame).surface.commit
          },
          dismiss_popup: Proc(Pointer(LibDecor::Frame), Pointer(Char), Pointer(Void), Void).new { |frame, charp, data|
            p :dismiss # TODO
          }
        )
        @frame = LibDecor.decorate(decor, surface, pointerof(@interface), self.as(Void*))
      end

      protected def configure(config)
        return perform_configure(config) if surface.buffer_pool.available?

        # If there is no available buffer, copy config and perform
        # the configuration later once there is a buffer available.
        # Do note that we need to copy the config as libdecor will
        # free it immediately after the call to configure.
        config_copy = Pointer(LibDecor::Configuration).malloc
        config_copy.copy_from(config, 1)
        surface.buffer_pool.callback = Proc(Nil).new { perform_configure(config_copy) }
      end

      private def perform_configure(config)
        dimensions = get_content_size(config)
        initial = false
        x, y =
          if dimensions
            dimensions
          else
            initial = true
            @initial_size
          end
        window_state = get_window_state(config)
        with_state(x, y) do |state|
          # Initial call to configure sets the initial window size,
          # doing the callback at this point will result in misalignment in output.
          commit(config, state) if initial
          surface.resize(x, y)
          @configure_callback.call(x, y, window_state)
          commit(config, state)
        end
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

      def with_state(x, y, &)
        state = LibDecor.state_new(x, y)
        yield state
        LibDecor.state_free(state)
      end

      def commit(config, state)
        LibDecor.frame_commit(self, state, config)
      end

      # TODO: Support selecting output.
      def fullscreen
        LibDecor.set_fullscreen(self, Pointer(LibWaylandClient::WlOutput).null)
      end

      def unfullscreen
        LibDecor.unset_fullscreen(self)
      end

      def maximize
        LibDecor.set_maximized(self, Pointer(LibWaylandClient::WlOutput).null)
      end

      def unmaximize
        LibDecor.unset_maximized(self)
      end

      def movable?
        capability?(:move)
      end

      def movable=(b)
        set_capability_if(b, :move)
      end

      def minimizable?
        capability?(:minimize)
      end

      def minimizable=(b)
        set_capability_if(b, :minimize)
      end

      def closable?
        capability?(:close)
      end

      def closable=(b)
        set_capability_if(b, :close)
      end

      def fullscreenable?
        capability?(:fullscreen)
      end

      def fullscreenable=(b)
        set_capability_if(b, :fullscreen)
      end

      def resizable?
        capability?(:resize)
      end

      def resizable=(b)
        set_capability_if(b, :resize)
      end

      private def capability?(capability : LibDecor::Capabilities)
        LibDecor.frame_has_capability(self, capability) > 0
      end

      private def set_capability_if(b, capability : LibDecor::Capabilities)
        if b
          LibDecor.frame_set_capabilities(self, capability)
        else
          LibDecor.frame_unset_capabilities(self, capability)
        end
      end
    end
  end
end
