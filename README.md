# wayland_client

A Wayland client for Crystal, intended to handle the nitty gritty
details of interacting with Wayland, while interacting well with the
Crystal event loop. It does this by providing reasonably ideomatic
interfaces that make it easy to accomplish what often takes a bunch of
instructions and/or callback setup and nonobvious setup to do
directly.

This is however not a graphics toolkit - this provides the buffers to
write to, nothing more. It does not provide any functionality of
rendering text, for example. You get a buffer, and it is up to you to
fill it with something reasonable.

## Installation

0. Install needed libraries.

This means that the following libraries need to be present

```
libdecor
libwayland-client
libxkbcommon
```

Also for obvious reasons, please remember that for things to work
Wayland needs to be used on the system.

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     wayland_client:
       github: yxhuvud/wayland_client
   ```

2. Run `shards install`

Warning: So far it has only been tested with Gnome. Please report (or
send fixes) for Plasma or other wayland compositors. Supporting
decorations using the extension instead of through libdecor is a major
task, but would be accepted as long as the libdecor stuff also works.
The latter is necessary on Gnome because they don't want to support
the extension.

## Usage
See the examples folder for more details and how things tie together.

### Client
The client is the main way to create and setup things. It also handle
the event loop interaction. To actually do something, you need a main
surface that you are using. After creating that, then you need to
create a frame for it do actually display it. That frame taka a block
that will be invoked when the frame is ready to display, or when the
window is resized or generally when the compositor feels like it.

When the block is invoked the surface needs to be filled with content
and committed. We also need to mark that the whole buffer is damaged
and needs to be repainted. To do that we need to check out a buffer
and then fill that buffer with data.

Resizing the buffers are handled by the framework, so don't keep
references around to buffers or whatnot.

Anyhow, once all the things are set up, `client.wait_loop` needs to be
called to actually display things and to handle incoming events. This
call will block until the frame is closed, so if you want things to
happen in the background you should create new fibers for that.

Example:
```
WaylandClient.connect do |client|
  surface = client.create_surface(
    kind: :memory,
    format: WaylandClient::Format::XRGB8888,
    opaque: true,
  )
  frame = client.create_frame(surface, title: "hello", app_id: "hello app") do |max_x, max_y, window_state|
    # `repaint!` is a shortcut to do all of this except
    # filling the buffer (which it yields to a block)
    buf = surface.attached_buffer
    buf.map! { WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF) }
    buf.damage_all
    buf.commit
    surface.commit
  end

  client.wait_loop
  surface.close
end
```

Relevant methods:

`.connect`: Create a client. Takes a block and yields the client. Disconnects when done.

`wait_loop`: Wait for events to come in, and then handles them. Blocking.

`pointer`: listener handler for handling mouse pointer input. Has one
relevant method, the `handler=` method. See <examples/complex.cr>
for how to do that.

`keyboard`: listener handler for handling keyboard input. Has one
relevant method, the `handler=` method. See <examples/complex.cr> for
how to do that.

`touch` as above, except it is actually a big TODO so far. PRs welcome.

`create_surface(kind : Buffer::Kind, format, opaque, accepts_input = true)`

Creates a new surface. Needed to create a new frame. 

- `kind` specifies what kind of buffer that the surface will use.
  Currently only `:memory` is implemented, but it would be nice to get a
  DMA backed one as well.

- `format` denotes how the pixels are stored. Implemented ones can be
   found in `src/format.cr`. It is easy to create implement new formats,
   see the `WlShmFormat` enum to see which ones are available to make.
   PRs welcome.

-  `opaque` Tells the compositor if the surface is opaque or not. It
   should be true for performance, but if you want translucence you
   need to have it be false.

- `accepts_input`: Should the surface accept input, or should the
  input pass through down to the layer beneath it?

`create_frame(surface, title = nil, app_id = nil, &block)`. Takes a
  surface, a title (that is shown in the title bar), and an app_id
  (which is shown in the task bar), and a block. The block needs to be
  there and will need to check out a buffer for the surface, and then
  commit the surface. If no surface is painted and committed then no
  window will appear, so don't forget this part.

### Surface

Surfaces are used to be the thing holding buffers and represent a part
of your screen. In addition to buffers, they can accept input, and are
a big part of interacting with the wayland event loop. Every time you
draw a new frame you need to tell the compositor what parts of a
surface it needs to paint, using something that is called "damage".
Surfaces have a two dimensional size, which in the case of the
toplevel surface that is connected to the frame, will be defined by
the frame when the user resizes the window.

Relevant methods:
- `create_subsurface(kind : Buffer::Kind, format, opaque, sync = true)`
  Creates a subdivision of the surface that can have its own rules. It
  holds another surface which can then either cover the whole parent
  or just a part of it. `kind`, `format` and `opaque` is just passed
  on to the subsurface that is created. `sync` is a flag to denote if
  the subsurface will only be updated when the parent is updated, or
  if it should update independently of the parent. Often sync is just
  fine for static content, but if you want dynamic updates then you
  probably want to not have it be synced.

- `request_frame(frame_callback : Proc(UInt32, Nil))`

  Tell the compositor that you want to render a new frame at whatever
  refresh rate your monitor is running at. Requires that the surface is
  not synced. Observe that the toplevel surface must be sync due to a
  limitation in libdecor, so to use this a subsurface needs to be used.

  The argument to the Proc is a timestamp. The callback should check
  out a buffer for the surface and then repaint the parts it cares
  about and then commit it again. Much the same as the callback for
  `create_frame`, except it actually won't break anything if you
  choose not to update anything. You just won't get an update then.

  See `examples/complex` to see how this can be used.

- `damage_buffer(x, y, width, height)` Tell the compositor that the
  marked area should be repainted.

- `repaint!` Shortcut method to get a buffer, and tell the compositor to use it. Yields the buffer.

- `attached_buffer` return a buffer that is attached to the surface

- `resize(x, y)` Resize the surface to the given size. This will interact weirdly with user resize of windows, but
  works fine for subsurfaces, or if the window is fixed in size.

- `damage_all` Mark the whole surface as damaged

- `commit` Tell the compositor that the updates to the surface is done and that it should be repainted.

- `close` Close the surface. Currently it needs to be done manually.

### Buffer

Buffers, that contain the actual graphics data. Under the hood, this
will use a pool of buffers, and keep track of what the compositor is
done with, and the pool will also delay updates when things get to
busy on the compositor side to keep up with the monitor frame rate. Do
not keep references to buffers around, always check out a new one from
the surface you want to modify.

Has a bunch of methods, but the ones that should be used from the
outside is.

- `to_slice` Get the buffer in a Slice representation.
- `map!` Takes a block, yields the x and y coordinates for the pixel
  in question. Block needs to return a pixel in the matching `Format`.
- `map!(xrange, yrange)` Same as the argumentless version except it
  will only yield the pixels in the given ranges.

PRs welcome for better API, this is decidedly very limited :)

### Format
Binary representation formats for how pixels are stored in memory.
Common ones are `WaylandClient::Format::ARGB8888` and
`WaylandClient::Format::XRGB8888`.

Each format has its own accessor methods, the ones for the ones listed
above are `red`, `green`, `blue`, as well as `alpha`for the `ARGB8888`
format.

In addition to that there is one, `cursor` that is located there due
to type declaration limitations/bugs in Crystal.

- `cursor(client, kind : Buffer::Kind,
          size : NamedTuple(x: Int32, y: Int32),
          hotspot : NamedTuple(x: Int32, y: Int32),
          &callback : Buffer::Memory(self) -> Void)`
  See `examples/complex.cr` for how to use it.

### Input
Input is handled by assigning a handler to the corresponding input
method. Each kind have their own base handler type that should be
used. They each have a module, but be aware they declare an
initialize, so be sure to call `super()` to make certain things are
initialized properly.

All of these keep track of what surface they happen on. Currently
there is no good way of mapping that backwards to the surface object
they correspond to.

See `examples/complex.cr` for a simple example of how these can be
used.

#### Mouse
Include `include WaylandClient::PointerHandler` into a class and have
it define `enter`, `leave`, or `frame`. The handler include a
`pointer_event` method that contain all information you should need to
handle the user action. `enter` and `leave` are obvious what they do,
but not `frame`. There is a bunch of other events that are emitted,
but most are really multi-shot things that will be aggregated into the
`frame` callback.

It may be that more callback methods are necessary. They will be added
if necessary. I have not found any documentation for what events are
aggregated into frame events and what that are not.

#### Keyboard
Very similar to the `PointerHandler`. `enter` and `leave` here is a
bit less obvious but they are basically focus events. In addition to that there is to methods that can be defined, they are `key` and `repeat_info`. They have signatures:

- `enter(pressed_keys, surface, serial)` `pressed_keys`: What keys are currently being pressed. `serial` Used in certain contexts, like cursors.
- `leave(surface, serial)`
- `key(time, key, state, serial)`: `time`: when it happened. `key`: What key changed state. `state`: Was it pressed down or released? `serial`: used in certain timing related contexts, like pointers.
- `repeat_info(rate, delay)` Information about what settings the user
  have for when a held down key will repeat the key.
#### Touch
Mostly todo as I havn't bothered setting up the laptop to test with. PRs welcome.
### Counter
Premade functionality to do things like frame rate counting. Set up like
```
frame_counter = WaylandClient::Counter.new("Frames: %s")
spawn do
  loop { frame_counter.measure { |value| puts "frame: %s" % value } }
end
```
and then make sure it is called like
```
frame_counter.register time
```
whereever you want to measure.

Will likely grow more features like percentile handling at some point.

### GPU usage

It should be possible to use existing Crystal libraries for OpenGL for
interacting with the raw buffers. That will involve an extra copy
though, so it will not be optimally efficient.

What is wanted there is
 - Support for DMA buffers. There is some preparation work done to support
   having multiple buffer types but the actual DMA buffer type is not done yet.
 - Wayland EGL bindings needs to be implemented.
 - Crystal EGL bindings. Should probably be a separate library.

PRs/examples are very welcome.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/yxhuvud/wayland_client/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Linus Sellberg](https://github.com/yxhuvud) - creator and maintainer
