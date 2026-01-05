require "cairo"

module Cairo
  # Note: This is probably not a good way to use Cairo. If I properly understand what is going on then it may be
  # wasteful to set up surface and contexts for each frame text is wanted.
  def self.write_to_buf(buf, width, height, text,
                        rgba = {0.0, 1.0, 1.0, 1.0},
                        font_size = 10.0,
                        pos = {15.0, 15.0},
                        font_face = {"Sans", Cairo::FontSlant::Normal, Cairo::FontWeight::Normal})
    bytes = buf.to_unsafe_bytes
    format = Cairo::Format::ARGB32
    stride = format.stride_for_width(width)
    surface = Cairo::Surface.new(bytes, format, width, height, stride)
    context = Cairo::Context.new(surface)
    context.set_source_rgba(*rgba)
    context.font_size = font_size
    context.move_to(*pos)
    context.select_font_face(*font_face)
    context.show_text(text)
  end
end
