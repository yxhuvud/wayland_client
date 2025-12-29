require "cairo"

module Cairo
  # Note: This is probably not a good way to use Cairo. If I properly understand what is going on then it may be
  # wasteful to set up surface and contexts for each frame text is wanted.
  def self.write_to_buf(buf, width, height, text)
    bytes = buf.to_unsafe_bytes
    format = Cairo::Format::ARGB32
    stride = format.stride_for_width(width)
    surface = Cairo::Surface.new(bytes, format, width, height, stride)
    context = Cairo::Context.new(surface)
    context.set_source_rgba(0, 1, 1, 1)
    context.font_size = 10.0
    context.move_to(15, 15)
    context.select_font_face("Sans", Cairo::FontSlant::Normal, Cairo::FontWeight::Normal)
    context.show_text(text)
  end
end
