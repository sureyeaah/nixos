{ pkgs, config, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    dotDir = ".config/zsh";

    history = {
      save = 100000;
      share = true;
    };

    envExtra = lib.strings.concatStrings ["PATH=$PATH:/home/sureyeaah/.cargo/bin"];

    shellAliases = {
      ls = "ls --color";
      rm = "rm -v";
      cp = "cp -v";
      mv = "mv -v";
      lg = "lazygit";
      clip = "xclip -selection c";
      store-alive = "nix-store -q --roots";
      permission = "stat -c%a";
    };

    prezto = {
      enable = true;

      # Case insensitive completion
      caseSensitive = false;

      # Autoconvert .... to ../..
      editor.dotExpansion = true;

      # Prezto modules to load

      pmodules = [
        "utility"
        "completion"
        "environment"
        "terminal"
        "editor"
        "history"
        "directory"
        "syntax-highlighting"
        "history-substring-search"
      ];

    };

    plugins = [
      {
        name = "zsh-abbrev-alias";
        file = "abbrev-alias.plugin.zsh";
        src = builtins.fetchGit {
          # Updated 2020-12-31
          url = "https://github.com/momo-lab/zsh-abbrev-alias";
          rev = "2f3d218f426aff21ac888217b0284a3a1470e274";
        };
      }
      {
        name = "zsh-async";
        file = "async.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/mafredri/zsh-async";
          rev = "bbbc92bd01592513a6b7739a45b7911af18acaef";
        };
      }
      {
        name = "zsh-colored-man-pages";
        file = "colored-man-pages.plugin.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/ael-code/zsh-colored-man-pages";
          rev = "57bdda68e52a09075352b18fa3ca21abd31df4cb";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        file = "zsh-syntax-highlighting.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/zsh-users/zsh-syntax-highlighting/";
          rev = "932e29a0c75411cb618f02995b66c0a4a25699bc";
        };
      }
    ];
  };
}
