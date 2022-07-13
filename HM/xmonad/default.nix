{ config, pkgs, ... }:

let
  switchLaptopMonitor = pkgs.writeScriptBin "switch_laptop_monitor" ''
    #!${pkgs.stdenv.shell}
    xrandr --output DP-1 --off --output eDP-1 --auto --output DP-3 --off
    systemctl restart --user polybar
  '';
  switchExternalMonitor = pkgs.writeScriptBin "switch_external_monitor" ''
    #!${pkgs.stdenv.shell}
    xrandr --output DP-1 --auto --output eDP-1 --off --output DP-3 --off
    systemctl restart --user polybar
  '';
  switchTv = pkgs.writeScriptBin "switch_tv" ''
    #!${pkgs.stdenv.shell}
    xrandr --output DP-1 --off --output eDP-1 --off --output DP-3 --auto --transform 1.05,0,0,0,1.05,0,0,0,1
    systemctl restart --user polybar
  '';
  switchExternalMonitor2 = pkgs.writeScriptBin "switch_external_monitor_2" ''
    #!${pkgs.stdenv.shell}
    xrandr --output DP-1 --off --output eDP-1 --off --output DP-4 --auto --transform 1.05,0,0,0,1.05,0,0,0,1
    systemctl restart --user polybar
  '';
in {
  environment.systemPackages = with pkgs; [
    xorg.xwininfo
    xorg.xdpyinfo
    xorg.xrandr
    arandr
    autorandr
    feh
    switchLaptopMonitor
    switchExternalMonitor
    switchExternalMonitor2
    switchTv
    playerctl
    gnome.gnome-screenshot
  ];

  services.xserver = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
      ];
      enableContribAndExtras = true;
      config = pkgs.lib.readFile ./xmonad-sureyeaah/Main.hs;
    };
  };
  services.xserver.displayManager.defaultSession = "none+xmonad";
} 
