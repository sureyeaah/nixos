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
  oledBrightness = pkgs.writeScriptBin "oled_brightness" (builtins.readFile ./oled_brightness.sh);
  lockScreen = pkgs.writeScriptBin "lock_screen" ''
    #!${pkgs.stdenv.shell}
    xsecurelock;
  '';
  lockAndSuspend = pkgs.writeScriptBin "lock_and_suspend" ''
    #!${pkgs.stdenv.shell}
    xsecurelock &
    sleep 2
    systemctl suspend
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
    oledBrightness
    playerctl
    gnome.gnome-screenshot
    xsecurelock
    lockAndSuspend
    lockScreen
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
