require "../src/wayland_client"
require "./cairo"

struct Figure
  FORMS = {
    [[false, true, false, false]]*4,              # I
    [[true, true], [true, true]],                 # O
    [[false, true], [false, true], [true, true]], # J
    [[true, false], [true, false], [true, true]], # L
    [[false, true], [true, true], [true, false]], # Z
    [[true, false], [true, true], [false, true]], # S
    [[false, true], [true, true], [false, true]], # T
  }

  getter depth : Int32
  getter offset : Int32
  getter form : Array(Array(Bool))

  def initialize(@form = FORMS[rand(FORMS.size)], depth = nil, offset = nil)
    @depth = depth || 0
    @offset = offset || (::Tetris::SIZE[1] - @form[0].size) // 2
  end

  def each_used_position(&)
    form.size.times do |height|
      form[1].size.times do |width|
        yield(height + depth, width + offset) if form[height][width]
      end
    end
  end

  def drop_one
    Figure.new(form, depth + 1, offset)
  end

  def move_left
    Figure.new(form, depth, offset - 1)
  end

  def move_right
    Figure.new(form, depth, offset + 1)
  end

  def rotate_clock
    Figure.new(form.reverse.transpose, depth, offset)
  end

  def rotate_counter_clock
    Figure.new(form.transpose.reverse!, depth, offset)
  end

  def collides?(blocks)
    each_used_position do |depth, offset|
      return true unless 0 <= offset < blocks.first.size
      return true if depth >= blocks.size
      return true if blocks[depth][offset]
    end
    false
  end

  def imprint(blocks)
    each_used_position do |depth, offset|
      blocks[depth][offset] = true
    end
  end
end

class Tetris
  SIZE = {30, 10}

  getter score
  getter level
  getter blocks : Array(Array(Bool))
  getter figure : Figure
  getter drop_interval
  getter score_callback

  def initialize(&score_callback)
    @score = 0
    @level = 0
    @blocks = Array.new(SIZE[0]) { Array(Bool).new(SIZE[1]) { false } }
    @figure = Figure.new
    @score_callback = score_callback
  end

  def drop_interval
    ((0.8 - (level - 1) * 0.007) ** (level - 1)).seconds
  end

  def reset
    initialize
  end

  def tick(dropped = 0)
    return true if figure? &.drop_one

    figure.imprint(blocks)
    deleted = clear_full_rows
    adjust_score(deleted, dropped) if deleted > 0
    !!assign_valid(Figure.new)
  end

  private def adjust_score(deleted, dropped)
    multiplier = {40, 100, 300, 1200}[deleted - 1]
    @score += multiplier * (level + 1) + dropped * (level // 2).clamp(0, 5)
    @level += deleted
    score_callback.call
  end

  private def clear_full_rows
    indices = blocks.each_index.select { |index| blocks[index].all? }.to_a
    indices.each do |index|
      block = blocks.delete_at(index)
      blocks.unshift block.fill(false)
    end
    indices.size
  end

  def drop_all
    while figure? &.drop_one; end
    tick
  end

  def figure?(&)
    assign_valid(yield @figure)
  end

  private def assign_valid(next_figure_state)
    @figure = next_figure_state unless next_figure_state.collides?(blocks)
  end
end

class KeyboardHandler
  include WaylandClient::KeyboardHandler

  XKB_KEY_Left      = 0xff51
  XKB_KEY_Up        = 0xff52
  XKB_KEY_Right     = 0xff53
  XKB_KEY_Down      = 0xff54
  XKB_KEY_Space     = 0x0020
  XKB_KEY_x         = 0x0078
  XKB_KEY_z         = 0x007a
  XKB_KEY_CONTROL_L = 0xffe3
  XKB_KEY_CONTROL_R = 0xffe4

  getter game

  def initialize(game : Tetris)
    @game = game
    super()
  end

  def key(time, key, state, serial)
    return unless state.pressed?

    case key.value
    when XKB_KEY_Up, XKB_KEY_x                           then game.figure? &.rotate_clock
    when XKB_KEY_z, XKB_KEY_CONTROL_L, XKB_KEY_CONTROL_R then game.figure? &.rotate_counter_clock
    when XKB_KEY_Left                                    then game.figure? &.move_left
    when XKB_KEY_Right                                   then game.figure? &.move_right
    when XKB_KEY_Down                                    then game.figure? &.drop_one
    when XKB_KEY_Space                                   then game.drop_all
    end
  end
end

class TetrisGUI
  LIGHTGRAY = WaylandClient::Format::XRGB8888.new(0xEE, 0xEE, 0xEE)
  BLUE      = WaylandClient::Format::XRGB8888.new(0x88, 0x88, 0xFF)
  GRAY      = WaylandClient::Format::XRGB8888.new(0xCC, 0xCC, 0xCC)
  WHITE     = WaylandClient::Format::XRGB8888.new(0xFF, 0xFF, 0xFF)
  LIGHTBLUE = WaylandClient::Format::XRGB8888.new(0xBB, 0xBB, 0xFF)

  BLOCK_WIDTH         = 20
  PLAYING_AREA_OFFSET = BLOCK_WIDTH
  BORDER              = BLOCK_WIDTH

  PLAYING_HEIGHT = BLOCK_WIDTH * Tetris::SIZE[0]
  PLAYING_WIDTH  = BLOCK_WIDTH * Tetris::SIZE[1]
  WINDOW_HEIGHT  = PLAYING_HEIGHT + 4 * BLOCK_WIDTH
  WINDOW_WIDTH   = 2 * PLAYING_WIDTH + 4 * BLOCK_WIDTH

  getter main : WaylandClient::Surface(WaylandClient::Format::XRGB8888)
  getter playing_area : WaylandClient::Subsurface(WaylandClient::Format::XRGB8888)
  getter score_area : WaylandClient::Subsurface(WaylandClient::Format::XRGB8888)
  getter repaint_callback
  getter game
  # FIXME: Improve type - users should not need to know about Decor
  getter frame : WaylandClient::Decor::Frame

  def initialize(client : WaylandClient::Client)
    @main = client.create_surface(
      kind: :memory,
      format: WaylandClient::Format::XRGB8888,
      opaque: true,
    )
    @playing_area = main.create_subsurface(
      kind: :memory,
      format: WaylandClient::Format::XRGB8888,
      opaque: true,
      sync: false,
      position: {PLAYING_AREA_OFFSET + BORDER, PLAYING_AREA_OFFSET + BORDER}
    )
    @score_area = main.create_subsurface(
      kind: :memory,
      format: WaylandClient::Format::XRGB8888,
      opaque: true,
      sync: false,
      position: {WINDOW_WIDTH // 2 + BORDER * 2, PLAYING_AREA_OFFSET + BORDER}
    )
    @repaint_callback = Proc(UInt32, Nil).new { paint_playing_area }
    @frame = client.create_frame(
      main,
      title: "Tetris",
      app_id: "tetris",
      initial_size: {WINDOW_WIDTH, WINDOW_HEIGHT}
    ) { setup }
    @frame.resizable = false

    @game = Tetris.new { paint_score_area }
    client.keyboard.handler = KeyboardHandler.new(@game)
  end

  def setup
    main.repaint do |buf|
      buf.fill(GRAY)
      buf.fill(
        BORDER...BORDER + PLAYING_WIDTH + 2 * BORDER,
        BORDER...BORDER + PLAYING_HEIGHT + 2 * BORDER,
        WHITE
      )
    end

    playing_area.surface.resize(width: PLAYING_WIDTH, height: PLAYING_HEIGHT)
    paint_playing_area
    playing_area.surface.request_frame(repaint_callback)

    score_area.surface.resize(width: PLAYING_WIDTH - BORDER, height: PLAYING_HEIGHT // 2)
    paint_score_area
  end

  def run
    loop do
      sleep game.drop_interval
      break unless game.tick
    end
  end

  def close
    playing_area.close
    main.close
  end

  private def paint_playing_area
    playing_area.surface.repaint do |buffer|
      paint_settled_blocks(buffer)
      paint_current_figure(buffer)
    end
  end

  private def paint_settled_blocks(buffer)
    height_offset = 0
    game.blocks.each do |row|
      width_offset = 0
      row.each do |block|
        buffer.fill(block_range(width_offset), block_range(height_offset), block ? BLUE : LIGHTGRAY)
        width_offset += BLOCK_WIDTH
      end
      height_offset += BLOCK_WIDTH
    end
  end

  private def paint_current_figure(buffer)
    game.figure.each_used_position do |height, width|
      buffer.fill(block_range(width * BLOCK_WIDTH), block_range(height * BLOCK_WIDTH), LIGHTBLUE)
    end
  end

  private def block_range(offset)
    offset...offset + BLOCK_WIDTH
  end

  private def paint_score_area
    score_area.surface.repaint do |buf|
      buf.map! { WHITE }

      score_text(buf, "SCORE:", BORDER)
      score_text(buf, game.score.to_s, BORDER*2)
      score_text(buf, "LEVEL:", BORDER*3)
      score_text(buf, game.level.to_s, BORDER*4)
    end
  end

  private def score_text(buf, text, offset)
    Cairo.write_to_buf(buf.to_slice, buf.width, buf.height, text,
      pos: {BORDER, offset}.map(&.to_f),
      rgba: {0.0, 0.0, 0.0, 1.0}
    )
  end
end

WaylandClient.connect do |client|
  gui = TetrisGUI.new(client)
  spawn { gui.run }
  client.wait_loop
  gui.close
end
