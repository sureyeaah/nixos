{ pkgs, ... }:

let 
  icomoon-feather = pkgs.callPackage ./icomoon-feather.nix {};
in {
  # Set system-wide fonts.
  fonts.fonts = with pkgs; [
    noto-fonts
    fira-code
    fira-mono
    icomoon-feather
    font-awesome
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Set default fonts.
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    monospace = [ "Noto Sans Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };
}
