{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.module.zsh;

  awsHelperScript = ''
    ax() {
      local profile
      profile="$( (echo "UNSET ALL"; sed -n -e 's/^\[profile \(.*\)\]/\1/p' ~/.aws/config) | fzf --tac --no-sort)"
      if [ "$profile" = "UNSET ALL" ]; then
        for var in $(env | grep '^AWS_' | cut -d= -f1); do
          unset "$var"
        done
        echo "Unset all AWS environment variables."
        return
      fi
      eval $(~/bin/aws-export-profile "$profile")
      if [ -n "$profile" ]; then
        export AWS_PROFILE="$profile"
        export AWS_DEFAULT_PROFILE="$profile"
        export AWS_PAGER=""
      fi
    }
  '';

  pasteFixScript = ''
    # ZSH_TMUX_AUTOSTART=true

    # Load necessary Zsh widgets for the fix
    autoload -Uz bracketed-paste-magic
    autoload -Uz url-quote-magic
    zle -N bracketed-paste bracketed-paste-magic
    zle -N self-insert url-quote-magic

    pasteinit() {
      OLD_SELF_INSERT=''${''${(s.:.)widgets[self-insert]}[2,3]}
      zle -N self-insert url-quote-magic
    }
    pastefinish() {
      zle -N self-insert $OLD_SELF_INSERT
    }
    zstyle :bracketed-paste-magic paste-init pasteinit
    zstyle :bracketed-paste-magic paste-finish pastefinish
  '';

in
{
  options.module.zsh = {
    enable = mkEnableOption "Pure Z shell profile";

    p10kConfigFile = mkOption {
      type = types.nullOr types.path;
      default = ../../../assets/.p10k.zsh;
      description = "Path to the Powerlevel10k configuration file (.p10k.zsh)";
      example = "./assets/.p10k.zsh";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.zsh;
      description = "Z shell package to use";
    };
  };

  config = mkIf cfg.enable {
    home.file = mkIf (cfg.p10kConfigFile != null) {
      ".p10k.zsh".source = cfg.p10kConfigFile;
    };

    programs.zsh = {
      enable = true;
      inherit (cfg) package;

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 10000;
        save = 10000;
        share = true;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
      };

      completionInit = ''
        autoload -Uz compinit
        # Only run compinit if the dump file is older than 24h
        for dump in ~/.zcompdump(N.mh+24); do
          compinit
        done
        compinit -C
      '';

      initContent = ''
        # -- Fix Keybindings --
        bindkey -e                           # Use Emacs mode

        # 1. Fix Home and End keys
        # We use the terminfo database to detect the correct escape sequences
        [[ -n "''${terminfo[khome]}" ]] && bindkey "''${terminfo[khome]}" beginning-of-line
        [[ -n "''${terminfo[kend]}"  ]] && bindkey "''${terminfo[kend]}"  end-of-line

        # 2. Manual fallbacks (some terminals don't report terminfo correctly)
        bindkey "^[[H" beginning-of-line
        bindkey "^[[F" end-of-line
        bindkey "^[OH" beginning-of-line
        bindkey "^[OF" end-of-line

        # macOS VT-style Home/End
        bindkey "^[[1~" beginning-of-line
        bindkey "^[[4~" end-of-line

        # 3. Word deletion style (from previous step)
        autoload -U select-word-style
        select-word-style bash

        # ... Ctrl-A, E, K, etc. ...
        bindkey '^K' kill-line
        bindkey '^A' beginning-of-line
        bindkey '^E' end-of-line
        bindkey '^W' backward-kill-word

        # -- Custom Scripts --
        ${pasteFixScript}
        ${awsHelperScript}

        # Fix arrow keys and esc+backspace
        bindkey "\e[1;5C" forward-word
        bindkey "\e[1;5D" backward-word

        # Bind esc + backspace to delete the word before the cursor
        bindkey '\e^?' backward-kill-word

        # -- FZF History Search --
        source ${
          pkgs.fetchFromGitHub {
            owner = "joshskidmore";
            repo = "zsh-fzf-history-search";
            rev = "d5a9730b5b4cb0b39959f7f1044f9c52743832ba";
            sha256 = "1dm1asa4ff5r42nadmj0s6hgyk1ljrckw7val8fz2n0892b8h2mm";
          }
        }/zsh-fzf-history-search.zsh

        # -- Theme --
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

        # Load user configuration if it exists
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';

      shellAliases = {
        gapp = "gcloud auth application-default login";
        gauth = "gcloud auth login";
        ide = "idea-community . > /dev/null 2>&1";
        k = "kubectl";
      };
    };
  };
}
