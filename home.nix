{ pkgs, inputs, system, ...}:

rec {
  imports = [
    ./HM/zsh.nix
    ./HM/kitty.nix
    ./HM/nvim
    ./HM/rofi
    ./HM/polybar
    ./HM/dunst.nix
  ];

  programs.home-manager.enable = true;

  # home.username = "sureyeaah";

  home.packages = with pkgs; [
    libnotify
    iw
    git
    cachix
    gh
    tig
    zellij
    fzf
    wget
    htop
    ripgrep
    util-linux
    usbutils
    pciutils
    psmisc
    p7zip
    logseq
    nix-prefetch-git
    dnsutils
    lazygit
  ];

  home.file.".config/starship.toml".source = ./starship.toml;
  
  programs = {

    git = {
      enable = true;
      userName = "Shaurya Gupta";
      userEmail = "shauryab98@gmail.com";
      ignores = ["*~" "*.swp"];
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

    tmux = {
      enable = true;
    };

    starship = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    jq.enable = true;

    ssh = {
      enable = true;
      extraConfig = ''
host *
  ControlMaster auto
  ControlPath ~/.ssh/ssh_mux_%h_%p_%r
Host relicx-dev
  HostName 172.31.19.28
  User ubuntu
  IdentityFile ~/sureyeaah-dell.pem
'';
    };
  };

  # TODO enable again.
  manual.manpages.enable = false;

  home.stateVersion = "21.03";

}
