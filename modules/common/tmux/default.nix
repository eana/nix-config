{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.tmux;

  clipboardPackage = if pkgs.stdenv.isLinux then pkgs.wl-clipboard else null;

  defaultClipboardCmdStr =
    if pkgs.stdenv.isDarwin then
      "pbcopy"
    else if pkgs.stdenv.isLinux then
      "${clipboardPackage}/bin/wl-paste"
    else
      "";
  commonExtraConfig = ''
    # Mouse
    bind-key m set-option -g mouse on \; display 'Mouse: ON'
    bind-key M set-option -g mouse off \; display 'Mouse: OFF'

    bind-key -T copy-mode-vi 'v' send -X begin-selection      # Begin selection in copy mode.
    bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle   # Begin selection in copy mode.

    # Restoring pane contents
    set -g @resurrect-capture-pane-contents 'on'

    # Send the same command to all panes/windows/sessions
    bind E command-prompt -p "Command:" \
                "run \"tmux list-panes -a -F '##{session_name}:##{window_index}.##{pane_index}' \
                      | xargs -I PANE tmux send-keys -t PANE '%1' Enter\""

    # Equally size pane of tmux
    # Horizontally
    unbind S
    bind S split-window \; select-layout even-vertical

    # Vertically
    unbind |
    bind | split-window -h \; select-layout even-horizontal

    # Reload configuration
    bind r source-file ~/.config/tmux/tmux.conf \; display '~/.config/tmux/tmux.conf sourced'

    set -g status-right " \"#{=20:pane_title}\" %Y-%m-%d %H:%M"

    # Get 256 colors to work in tmux
    # This is the value of the TERM environment variable inside tmux
    set -g default-terminal "screen-256color"

    # Handle tmux nested session
    # https://medium.freecodecamp.org/tmux-in-practice-local-and-nested-remote-tmux-sessions-4f7ba5db8795
    set -g status-bg colour40
    # for tmux < 2.9
    #setw -g window-status-current-bg colour40
    # for tmux > 2.9
    setw -g window-status-current-style bg=colour40

    bind -n C-t new-window -a
    bind -n S-left  prev
    bind -n S-right next
    bind -n S-C-left  swap-window -t -1
    bind -n S-C-right swap-window -t +1

    bind -n M-F11 set -qg status-bg colour25
    bind -n M-F12 set -qg status-bg colour40
    bind -n S-up \
        send-keys M-F12 \; \
        set -qg status-bg colour25 \; \
        unbind -n S-left \; \
        unbind -n S-right \; \
        unbind -n S-C-left \; \
        unbind -n S-C-right \; \
        unbind -n C-t \; \
        set -qg prefix C-b
    bind -n S-down \
        send-keys M-F11 \; \
        set -qg status-bg colour40 \; \
        bind -n S-left  prev \; \
        bind -n S-right next \; \
        bind -n S-C-left swap-window -t -1 \; \
        bind -n S-C-right swap-window -t +1 \; \
        bind -n C-t new-window -a -c "#{pane_current_path}" \; \
        set -qg prefix C-a

    # Renumber windows in tmux
    set-option -g renumber-windows on

    # Resize panes
    # Use Alt-arrow keys without prefix key to switch panes
    bind -n M-Left resize-pane -L 1
    bind -n M-Right resize-pane -R 1
    bind -n M-Up resize-pane -U 1
    bind -n M-Down resize-pane -D 1

    # Bind to Shift+{Left,Right} to next/previous window
    bind -n S-Right next-window
    bind -n S-Left previous-window

    # Toggle synchronize-panes
    bind C-x setw synchronize-panes

    # Change window status if the panes are synchronized
    # https://superuser.com/a/908443
    set-option -gw window-status-current-format '#{?pane_synchronized,#[bg=red],}#I:#W#F#{?pane_synchronized,#[bg=red]#[default],}'
    set-option -gw window-status-format '#{?pane_synchronized,#[bg=red],}#I:#W#F#{?pane_synchronized,#[bg=red]#[default],}'

    # neovim
    set-option -g focus-events on
    # This is the value of the TERM environment variable outside tmux
    set-option -sa terminal-features ',xterm-256color:RGB'

    # Make home/end keys to work
    # ❯ tput khome | cat -v; echo
    # ^[[1~
    # ❯ tput kend | cat -v; echo
    # ^[[4~
    bind-key -n Home send Escape "[1~"
    bind-key -n End send Escape "[4~"
  '';

in
{
  options.module.tmux = {
    enable = mkEnableOption "tmux terminal multiplexer";

    package = mkOption {
      type = types.package;
      default = pkgs.tmux;
      description = "Terminal multiplexer";
    };

    shortcut = mkOption {
      type = types.str;
      default = "a";
      description = "Base shortcut key for tmux commands";
    };

    baseIndex = mkOption {
      type = types.int;
      default = 1;
      description = "Base index for windows and panes";
    };

    clock24 = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to use 24-hour clock";
    };

    escapeTime = mkOption {
      type = types.int;
      default = 0;
      description = "Time in milliseconds for which tmux waits after an escape is input";
    };

    secureSocket = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use secure socket";
    };

    historyLimit = mkOption {
      type = types.int;
      default = 999999999;
      description = "Maximum number of lines kept in history";
    };

    keyMode = mkOption {
      type = types.str;
      default = "vi";
      description = "Key binding mode (vi or emacs)";
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.tmuxPlugins.resurrect ];
      description = "List of tmux plugins to install";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = ""; # Empty default, as it's constructed below
      description = "Additional tmux configuration";
    };

    # New option for the clipboard command. User can override this.
    clipboardCmd = mkOption {
      type = types.str;
      default = defaultClipboardCmdStr;
      description = ''
        Command for clipboard integration (e.g., "wl-paste", "pbcopy").
        For WSL, "clip.exe" is handled internally by default.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      inherit (cfg)
        package
        shortcut
        baseIndex
        clock24
        escapeTime
        secureSocket
        historyLimit
        keyMode
        plugins
        ;

      extraConfig =
        let
          clipboardCopyCommand =
            if cfg.clipboardCmd != "" then
              ''
                bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel '{{#if (eq os "windows-wsl")}}clip.exe{{else }}${cfg.clipboardCmd}{{/if}}'
              ''
            else
              "";
        in
        ''
          ${commonExtraConfig}
          ${clipboardCopyCommand}
          ${cfg.extraConfig} # User's additional extraConfig lines
        '';
    };

    home.packages = lib.mkIf pkgs.stdenv.isLinux (
      lib.optional (clipboardPackage != null) clipboardPackage
    );
  };
}
