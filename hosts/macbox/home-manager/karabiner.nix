_:

let
  # PC-style text editing bindings, applied globally by Karabiner-Elements (brew cask).
  # Rule order matters: Karabiner applies rules top-down, first match wins.
  # 1. AltGr (right_option) chords run first so AltGr+letter becomes Ctrl/Command+letter.
  # 2. Home/End -> Command+arrows, Ctrl+Home/End -> Command+Up/Down (macOS apps understand Cmd).
  #    Right Option (AltGr) + Home/End and Left Option + Home/End both map to Cmd+Up/Down
  #    (beginning/end of document). The right_option variant must be listed explicitly
  #    because the swap rule below turns right_option into right_control, and by the time
  #    Home is processed, the modifier no longer matches a "left_option" constraint.
  # 3. Swap Right Control and Right Option (AltGr) last: a bare RCtrl becomes Option, so
  #    RCtrl+arrow/Backspace map to native Option+arrow/Backspace word operations in
  #    TextEdit/Firefox. Kitty maps option/cmd+arrow to shell sequences in
  #    home/users/jonas/common.nix.

  # Single key mapping. An empty mandatory list means "no modifier constraints",
  # matching Karabiner's default of all optional modifiers.
  mkBinding = fromKey: mandatory: toKey: toModifiers: {
    type = "basic";
    from = {
      key_code = fromKey;
    }
    // (
      if mandatory == [ ] then
        { }
      else
        {
          modifiers = { inherit mandatory; };
        }
    );
    to = [
      (
        {
          key_code = toKey;
        }
        // (
          if toModifiers == [ ] then
            { }
          else
            {
              modifiers = toModifiers;
            }
        )
      )
    ];
  };

  mkRule = description: bindings: {
    inherit description;
    manipulators = bindings;
  };

  rules = [
    (mkRule
      "AltGr (Right Ctrl) chords: C -> Ctrl+C, A -> Cmd+A, V -> Ctrl+V, R -> Ctrl+R, T -> Ctrl+T, D -> Ctrl+D, PgUp -> Ctrl+PgUp, PgDn -> Ctrl+PgDn"
      [
        (mkBinding "c" [ "right_option" ] "c" [ "control" ])
        (mkBinding "a" [ "right_option" ] "a" [ "command" ])
        (mkBinding "v" [ "right_option" ] "v" [ "control" ])
        (mkBinding "r" [ "right_option" ] "r" [ "control" ])
        (mkBinding "t" [ "right_option" ] "t" [ "control" ])
        (mkBinding "d" [ "right_option" ] "d" [ "control" ])
        (mkBinding "page_up" [ "right_option" ] "page_up" [ "control" ])
        (mkBinding "page_down" [ "right_option" ] "page_down" [ "control" ])
      ]
    )
    (mkRule "Windows-style Home and End" [
      # Right Option (AltGr) + Home/End -> Cmd+Up/Down.
      # Listed before the swap rule so the raw right_option modifier is still
      # present when this rule is evaluated.
      (mkBinding "home" [ "right_option" ] "up_arrow" [ "command" ])
      (mkBinding "end" [ "right_option" ] "down_arrow" [ "command" ])
      # Left Option + Home/End -> Cmd+Up/Down (beginning/end of document)
      (mkBinding "home" [ "left_option" ] "up_arrow" [ "command" ])
      (mkBinding "end" [ "left_option" ] "down_arrow" [ "command" ])
      # Bare Home/End -> Cmd+Left/Right (beginning/end of line)
      (mkBinding "home" [ ] "left_arrow" [ "command" ])
      (mkBinding "end" [ ] "right_arrow" [ "command" ])
      # Ctrl+Home/End -> Cmd+Up/Down (beginning/end of document)
      (mkBinding "home" [ "control" ] "up_arrow" [ "command" ])
      (mkBinding "end" [ "control" ] "down_arrow" [ "command" ])
    ])
    (mkRule "Swap Right Option (AltGr) and Right Control" [
      (mkBinding "right_option" [ ] "right_control" [ ])
      (mkBinding "right_control" [ ] "right_option" [ ])
    ])
  ];
in
{
  home.file.".config/karabiner/karabiner.json".text = builtins.toJSON {
    profiles = [
      {
        complex_modifications = {
          inherit rules;
        };
        selected = true;
        virtual_hid_keyboard = {
          keyboard_type_v2 = "ansi";
        };
      }
    ];
  };
}
