{ pkgs, system, ...}:

let
  vim-spaceduck = pkgs.vimUtils.buildVimPlugin {
    name = "vim-spaceduck";
    src = pkgs.fetchFromGitHub {
      owner = "pineapplegiant";
      repo = "spaceduck";
      rev = "49427ce5bdbf97fb775465bee32af41049cdfd21";
      sha256 = "sha256-i49heAGcF1A9AeomJHNgSXy12bVb81pR2Lnk9PcsHOk=";
    };
  };

in {
  programs.neovim = {
    enable = true;
    # package = pkgs.neovimnightly;
    viAlias = true;
    vimAlias = true;
    extraConfig = builtins.readFile ./init.vim;
    plugins = with pkgs.vimPlugins; [
      nerdcommenter 
      vim-surround
      nerdtree
      vim-devicons
      vim-nerdtree-syntax-highlight
      vim-bufkill
      vim-easymotion
      indentLine
      fzf-vim
      fzfWrapper
      vim-airline
      vim-airline-themes
      tabular
      ctrlp
      vim-fugitive
      colorizer
      haskell-vim
      vim-nix
      gruvbox-community
      vim-spaceduck
    ];

  };
}

