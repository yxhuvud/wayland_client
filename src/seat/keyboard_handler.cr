require "./xkb"

module WaylandClient
  class Seat
    module KeyboardHandler
      PAGE_SIZE = 4096

      getter xkb

      def initialize
        @xkb = Xkb.new
        @modifiers = Xkb::Modifiers.new(0, 0, 0, 0)

        @callback = LibWaylandClient::WlKeyboardListener.new(
          keymap: LibWaylandClient::WlKeyboardListenerKeymap.new do |data, keyboard, format, fd, size|
            handler = data.as(self)
            handler.xkb.setup(format, IO::FileDescriptor.new(fd), size)
          end,

          enter: LibWaylandClient::WlKeyboardListenerEnter.new do |data, keyboard, serial, surface, keys|
            handler = data.as(self)
            keys = handler.xkb.extract_multiple(keys.value)

            handler.enter(pressed_keys: keys, surface: surface, serial: serial)
          end,

          leave: LibWaylandClient::WlKeyboardListenerLeave.new do |data, keyboard, serial, surface|
            data.as(self).leave(surface, serial: serial)
          end,

          key: LibWaylandClient::WlKeyboardListenerKey.new do |data, keyboard, serial, time, key, state|
            handler = data.as(self)
            handler.key(
              time: time,
              key: handler.xkb.extract(key),
              state: state,
              serial: serial
            )
          end,

          modifiers: LibWaylandClient::WlKeyboardListenerModifiers.new do |data, keyboard, serial, mods_depressed, latched, locked, group|
            handler = data.as(self)
            handler.modifiers = Xkb::Modifiers.new(mods_depressed, latched, locked, group)
          end,

          repeat_info: LibWaylandClient::WlKeyboardListenerRepeatInfo.new do |data, keyboard, rate, delay|
            handler = data.as(self)
            handler.repeat_info(rate, delay)
          end
        )
      end

      def enter(pressed_keys, surface, serial)
      end

      def leave(surface, serial)
      end

      def key(time, key, state, serial)
      end

      def repeat_info(rate, delay)
      end

      class Base
        include KeyboardHandler
      end

      protected def listener
        pointerof(@callback)
      end

      protected def modifiers
        @modifiers
      end

      protected def modifiers=(modifiers)
        @modifiers = modifiers
      end
    end
  end
end
