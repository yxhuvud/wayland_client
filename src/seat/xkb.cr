require "../lib/lib_wayland_client"
require "../lib/lib_xkbcommon"
require "c/fcntl"

module WaylandClient
  class Seat
    class Xkb
      record(Modifiers, depressed : UInt32, latched : UInt32, locked : UInt32, group : UInt32) do
        @[Flags]
        enum Modifier : UInt32
          SHIFT    =    1
          CAPSLOCK =    2
          CTRL     =    4
          ALT      = 4104
          ALTGR    =  128
          NUMLOCK  =   16
        end

        def depressed
          Modifier.new(@depressed)
        end

        def latched
          Modifier.new(@latched)
        end

        def locked
          Modifier.new(@locked)
        end

        def group
          Modifier.new(@group)
        end
      end

      record(Key, value : LibXkbcommon::XkbKeysym, key : UInt32) do
        MODIFIERS = {
          65505, 65505, # SHIFT
          65509,        # CAPS
          65507, 65508, # CTRL
          65513,        # ALT
          65027,        # ALTGR
          65407,        # NUMLOCK. Scroll lock and pause are not modifiers.
        }

        def chr
          value.unsafe_chr
        rescue OverflowError
          raise "chr value out of range: #{value}"
        end

        def name(state)
          buf = StaticArray(LibC::Char, 128).new(0)
          buf_size = sizeof(LibC::Char) * buf.size
          name_size = LibXkbcommon.xkb_keysym_get_name(value, buf.to_unsafe, buf_size)
          LibXkbcommon.xkb_state_key_get_utf32(state, key + 8, buf, buf_size)

          String.new(buf.to_unsafe)
        end

        def modifier?
          value.in?(MODIFIERS)
        end

        def inspect(io : IO) : Nil
          if value < 65535
            io << "Key('" << chr << "', modifier:" << modifier? << ", raw: " << value << " )"
          else
            io << "Key(<UNPRINTABLE>, raw: " << value << " )"
          end
        end
      end

      getter context, state, keymap

      def initialize
        @context = LibXkbcommon.xkb_context_new(LibXkbcommon::XkbContextFlags::NoFlags)
        @state = ::Pointer(LibXkbcommon::XkbState).null
        @keymap = ::Pointer(LibXkbcommon::XkbKeymap).null
      end

      def setup(format, fd, size)
        raise "Unknown keyboard format #{format}" unless format == LibWaylandClient::WlKeyboardKeymapFormat::XkbV1.value

        xkb_keymap = read_keymap(fd, size)
        xkb_state = LibXkbcommon.xkb_state_new(xkb_keymap)

        LibXkbcommon.xkb_state_unref(state) if state
        LibXkbcommon.xkb_keymap_unref(keymap) if keymap

        @keymap = xkb_keymap
        @state = xkb_state
      end

      private def read_keymap(fd, size)
        # Those nice examples that can be googled up for getting
        # this in a nicer way with mmap? Well they don't work
        # because the file descriptor is sealed. See man fcntl for
        # more information on wtf a sealed fd is.
        data = fd.rewind
        buffer = Bytes.new(size)
        data.read buffer
        LibXkbcommon.xkb_keymap_new_from_string(
          context,
          buffer,
          LibXkbcommon::XkbKeymapFormat::TextV1,
          LibXkbcommon::XkbKeymapCompileFlags::NoFlags
        )
      end

      def extract_multiple(wl_array)
        Slice(UInt32).new(pointer: wl_array.data.as(UInt32*), size: wl_array.size // 4)
          .map { |key| extract(key) }.reject &.modifier?
      end

      def extract(key)
        Key.new(LibXkbcommon.xkb_state_key_get_one_sym(state, key + 8), key)
      end
    end
  end
end
