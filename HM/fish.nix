{ pkgs, config, ... }:

{
  programs.fish.enable = true;
  programs.fish.plugins = [];

  programs.fish.shellAbbrs = {
    ls = "ls --color";
    rm = "rm -v";
    cp = "cp -v";
    mv = "mv -v";
    clip = "xclip -selection c";
    store-alive = "nix-store -q --roots";
    permission = "stat -c%a";
  };

}
