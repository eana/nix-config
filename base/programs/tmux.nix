{ pkgs }:
let wl-paste = "${pkgs.wl-clipboard-rs}/bin/wl-paste";
in {
  # General Settings
  enable = true;
  shortcut = "a";
  baseIndex = 1;
  clock24 = true;
  escapeTime = 0;
  secureSocket = false;

  # History and Terminal Settings**
  historyLimit = 999999999;

  # Key Mode and Plugin Configuration**
  keyMode = "vi";

  plugins = with pkgs; [ tmuxPlugins.resurrect ];

  extraConfig = ''
    # Mouse
    bind-key m set-option -g mouse on \; display 'Mouse: ON'
    bind-key M set-option -g mouse off \; display 'Mouse: OFF'

    bind-key -T copy-mode-vi 'v' send -X begin-selection     # Begin selection in copy mode.
    bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle  # Begin selection in copy mode.
    # Yank selection in copy mode.
    bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel '{{#if (eq os "windows-wsl")}}clip.exe{{else}}${wl-paste}{{/if}}'

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
}

