require "cairo"

module Cairo
  def self.write_to_buf(buf, width, height, text)
    casted = buf.to_unsafe_bytes
    format = Cairo::Format::ARGB32
    stride = format.stride_for_width(width + 1)
    surface = Cairo::Surface.new(casted, format, width + 1, height + 1, stride)
    context = Cairo::Context.new(surface)
    context.set_source_rgba(0, 1, 1, 1)
    context.font_size = 10.0
    context.move_to(15, 15)
    context.select_font_face("Sans", Cairo::FontSlant::Normal, Cairo::FontWeight::Normal)
    context.show_text(text)
  end
end
