{ config, lib, pkgs, modulesPath, latest, ... }:

let
  # TODO: move this.
  stremio = pkgs.callPackage ../HM/stremio.nix {};
in {
  imports = [ ];
  # Trackpad support
  services.xserver.libinput = {
    enable = true;
    touchpad.naturalScrolling = false;
    touchpad.tapping = true;
  };

  # Logitech support
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # High DPI
  services.xserver.monitorSection = ''
   DisplaySize 406 228
  '';
  console.font = "latarcyrheb-sun32";
  services.xserver.dpi = 180;

  hardware.enableRedistributableFirmware = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fe1f9642-3691-4c99-806d-4c358caeba49";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/303E-75B2";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/711251ca-1367-41e2-b4db-a10032ae8256"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # graphics
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl.enable = true;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nix.settings = {
    trusted-users = [ "root" "sureyeaah" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  networking.hostName = "relicx-xps13";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  networking.extraHosts = 
    ''
      172.31.78.58 ci-ingress.relicx.ai
    '';

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";
  
  # TODO: move this
  programs.mosh.enable = true;

  users.users.sureyeaah= {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "docker" ];
    shell = pkgs.zsh;
  };
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    vscode
    pulsemixer
    mpv
    brave 
    chromium
    git
    pavucontrol
    xclip
    xfce.xfce4-clipman-plugin
    spotify
    stremio
    xfce.thunar
    mcomix3
    steam-run
    obsidian
    slack
    winetricks
    # calibre
    mesa-demos
    anydesk
    solaar
    remmina
    python
    zoom-us
  ]);

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "sureyeaah" ];

  services = {
    openssh.enable = true;
  };

  # VPN
  services.openvpn.servers = {
    relicx = { config = '' config /home/sureyeaah/relicx/relicx.ovpn''; };
  };
  security.pki.certificateFiles = [ ../secrets/relicx/root.crt ];

  # Audio and bluetooth
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  systemd.services.systemd-user-sessions.enable = false;

  services.gnome.gnome-keyring.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
