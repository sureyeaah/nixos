{ pkgs, config, ... }:

{
  programs.zsh.enable = true;

  programs.zsh.shellAliases = {
    ls = "ls --color";
    rm = "rm -v";
    cp = "cp -v";
    mv = "mv -v";
    clip = "xclip -selection c";
    store-alive = "nix-store -q --roots";
    permission = "stat -c%a";
  };

  ohMyZsh = {
    enable = true;
    plugins = [ "git" "bundler" "dotenv" ];
    theme = "robbyrussell";
  };
}
