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

  # Fix for zsh-syntax-highlighting paste slowness
  pasteFixScript = ''
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
  '';

in
{
  options.module.zsh = {
    enable = mkEnableOption "Z shell opinionated profile";

    p10kConfigFile = mkOption {
      type = types.path;
      default = ../../../assets/.p10k.zsh;
      description = "Path to the Powerlevel10k configuration file (.p10k.zsh)";
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
      };

      oh-my-zsh = {
        enable = true;
        extraConfig = pasteFixScript + awsHelperScript;
      };

      initContent = ''
        # zmodload zsh/zprof
        skip_global_compinit=1

        # Fix ctrl + left/right arrow keys
        bindkey "\e[1;5C" forward-word
        bindkey "\e[1;5D" backward-word
        # Bind esc + backspace to delete the word before the cursor
        bindkey '\e^?' backward-kill-word

        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # zprof
      '';

      completionInit = ''
        autoload -Uz compinit
        for dump in ~/.zcompdump(N.mh+24); do
          compinit
        done
        compinit -C
      '';

      shellAliases = {
        gapp = "gcloud auth application-default login";
        gauth = "gcloud auth login";
        ide = "idea-community . > /dev/null 2>&1";
        k = "kubectl";
      };

      plugins = [
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
    };
  };
}
