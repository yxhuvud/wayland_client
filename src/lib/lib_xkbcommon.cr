module WaylandClient
  @[Link("xkbcommon")]
  lib LibXkbcommon
    alias XkbContext = Void
    alias XkbKeymap = Void
    alias XkbState = Void
    alias XkbKeycode = UInt32
    alias XkbKeysym = UInt32

    @[Flags]
    enum XkbContextFlags
      NoFlags            = 0
      NoDefaultIncludes  = 1 << 0
      NoEnvironmentNames = 1 << 1
    end

    enum XkbKeymapFormat
      TextV1 = 1
    end

    enum XkbKeymapCompileFlags
      NoFlags = 0
    end

    fun xkb_context_new(XkbContextFlags) : Pointer(XkbContext)
    fun xkb_context_unref(Pointer(XkbContext)) : Void
    fun xkb_keymap_new_from_string(Pointer(XkbContext), Pointer(LibC::Char), XkbKeymapFormat, XkbKeymapCompileFlags) : Pointer(XkbKeymap)
    fun xkb_keymap_unref(Pointer(XkbKeymap)) : Void
    fun xkb_state_new(Pointer(XkbKeymap)) : Pointer(XkbState)
    fun xkb_state_unref(Pointer(XkbState)) : Void
    fun xkb_state_key_get_one_sym(Pointer(XkbState), XkbKeycode) : XkbKeysym
    fun xkb_state_key_get_syms(Pointer(XkbState), XkbKeycode, Pointer(XkbKeysym))
    fun xkb_keysym_get_name(XkbKeysym, Pointer(LibC::Char), LibC::SizeT) : LibC::Int
    fun xkb_state_key_get_utf32(Pointer(XkbState), XkbKeycode, Pointer(UInt8), LibC::SizeT) : LibC::Int
    # xkb_state_key_get_utf8
    # xkb_state_update_mask
  end
end
