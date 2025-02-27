{ pkgs }:

{
  enable = true;
  enableCompletion = true;

  oh-my-zsh = {
    enable = true;
    extraConfig = ''
      # ZSH_TMUX_AUTOSTART=true

      ### Fix slowness of pastes with zsh-syntax-highlighting.zsh
      pasteinit() {
        OLD_SELF_INSERT=''${''${(s.:.)widgets[self-insert]}[2,3]}
        zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
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

        # https://github.com/cytopia/aws-export-profile
        eval $(~/bin/aws-export-profile "$profile")
        if [ -n "$profile" ]; then
          export AWS_PROFILE="$profile"
          export AWS_DEFAULT_PROFILE="$profile"
          export AWS_PAGER=""
        fi
      }
    '';
  };

  history = {
    size = 10000;
    save = 10000;
    share = true;
    extended = true;
  };

  # Enable autosuggestions
  autosuggestion.enable = true;

  # Enable syntax highlighting
  syntaxHighlighting.enable = true;

  initExtraFirst = ''
    # zmodload zsh/zprof
    skip_global_compinit=1
  '';

  completionInit = ''
    autoload -Uz compinit
    for dump in ~/.zcompdump(N.mh+24); do
      compinit
    done
    compinit -C
  '';

  initExtra = ''
    # Fix ctrl + left/right arrow keys
    bindkey "\e[1;5C" forward-word
    bindkey "\e[1;5D" backward-word
    # Bind esc + backspace to delete the word before the cursor
    bindkey '\e^?' backward-kill-word

    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    # zprof
  '';

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

  shellAliases = {
    gapp = "gcloud auth application-default login";
    gauth = "gcloud auth login";
    ide = "idea-community . > /dev/null 2>&1";
    k = "kubectl";
    sudo = "/run/wrappers/bin/sudo";
  };
}
