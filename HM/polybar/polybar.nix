{ pkgs, system, config, ... }:

let
  colors = builtins.readFile ./colors.ini;
in {
  services.polybar = {
    enable = true;
    package = pkgs.polybarFull;
    config = ./config.ini;
    extraConfig = colors;
    script = ''
PATH="$PATH:${pkgs.coreutils}/bin/:${pkgs.gnugrep}/bin/:${pkgs.xorg.xrandr}/bin/"
xrandr --listmonitors | grep "^ .:" | cut -d" " -f6 | while read m ;  do
  MONITOR=$m polybar main &
done
'';
  };
}

