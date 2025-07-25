{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.zsh;

  p10kConfig = ../../../assets/.p10k.zsh;

  defaultOhMyZshExtraConfig = ''
    # ZSH_TMUX_AUTOSTART=true

    ### Fix slowness of pastes with zsh-syntax-highlighting.zsh
    pasteinit() {
      OLD_SELF_INSERT=''${''${(s.:.)widgets[self-insert]}[2,3]}
      zle -N self-insert url-quote-magic
    }

    pastefinish() {
      zle -N self-insert $OLD_SELF_INSERT
    }
    zstyle :bracketed-paste-magic paste-init pasteinit
    zstyle :bracketed-paste-magic paste-finish pastefinish
    ### Fix slowness of pastes

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

  defaultInitContent = ''
    # zmodload zsh/zprof
    skip_global_compinit=1

    # rofi-rbw
    bindkey "^[b" run_rofi
    function run_rofi(){
      rofi-rbw --selector rofi --selector-args=-normal-window --clipboarder wl-copy --typer ydotool
    }
    zle -N run_rofi
    # Fix ctrl + left/right arrow keys
    bindkey "\e[1;5C" forward-word
    bindkey "\e[1;5D" backward-word
    # Bind esc + backspace to delete the word before the cursor
    bindkey '\e^?' backward-kill-word

    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    # zprof
  '';

  defaultCompletionInit = ''
    autoload -Uz compinit
    for dump in ~/.zcompdump(N.mh+24); do
      compinit
    done
    compinit -C
  '';

  defaultPlugins = [
    {
      name = "zsh-fzf-history-search";
      src = pkgs.fetchFromGitHub {
        owner = "joshskidmore";
        repo = "zsh-fzf-history-search";
        rev = "d5a9730b5b4cb0b39959f7f1044f9c52743832ba";
        sha256 = "1dm1asa4ff5r42nadmj0s6hgyk1ljrckw7val8fz2n0892b8h2mm";
      };
    }
  ];

  defaultShellAliases = {
    gapp = "gcloud auth application-default login";
    gauth = "gcloud auth login";
    ide = "idea-community . > /dev/null 2>&1";
    k = "kubectl";
  };

in
{
  options.module.zsh = {
    enable = mkEnableOption "Z shell";

    package = mkOption {
      type = types.package;
      default = pkgs.zsh;
      description = "Z shell";
    };

    enableCompletion = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Zsh completion";
    };

    ohMyZsh = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Oh My Zsh";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = defaultOhMyZshExtraConfig;
        description = "Extra configuration for Oh My Zsh";
      };
    };

    history = {
      size = mkOption {
        type = types.int;
        default = 10000;
        description = "Maximum number of history entries to keep in memory";
      };

      save = mkOption {
        type = types.int;
        default = 10000;
        description = "Maximum number of history entries to save to file";
      };

      share = mkOption {
        type = types.bool;
        default = true;
        description = "Share history between all sessions";
      };

      extended = mkOption {
        type = types.bool;
        default = true;
        description = "Save extended history (timestamp and duration)";
      };
    };

    initContent = mkOption {
      type = types.lines;
      default = defaultInitContent;
      description = "Extra initialization commands for Zsh";
    };

    completionInit = mkOption {
      type = types.lines;
      default = defaultCompletionInit;
      description = "Initialization commands to run when completion is enabled";
    };

    plugins = mkOption {
      type = types.listOf (types.attrsOf types.anything);
      default = defaultPlugins;
      description = "List of Zsh plugins to install";
    };

    shellAliases = mkOption {
      type = types.attrsOf types.str;
      default = defaultShellAliases;
      description = "Shell aliases for Zsh";
    };

    autosuggestion = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable zsh-autosuggestions";
      };
    };

    syntaxHighlighting = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable zsh-syntax-highlighting";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Install .p10k.zsh configuration
    home.file.".p10k.zsh".source = p10kConfig;

    programs.zsh = {
      enable = true;
      inherit (cfg) package;
      inherit (cfg)
        enableCompletion
        initContent
        completionInit
        plugins
        shellAliases
        ;

      oh-my-zsh = lib.mkIf cfg.ohMyZsh.enable {
        enable = true;
        inherit (cfg.ohMyZsh) extraConfig;
      };

      history = {
        inherit (cfg.history) size;
        inherit (cfg.history) save;
        inherit (cfg.history) share;
        inherit (cfg.history) extended;
      };

      autosuggestion = {
        inherit (cfg.autosuggestion) enable;
      };

      syntaxHighlighting = {
        inherit (cfg.syntaxHighlighting) enable;
      };
    };
  };
}
