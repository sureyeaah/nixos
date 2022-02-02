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

  hardware.enableRedistributableFirmware = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/aea47ad7-882a-42b5-8a87-dd764e1a63b9";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DC91-DC02";
      fsType = "vfat";
    };

  fileSystems."/mnt/DATA" =
    { device = "/dev/disk/by-uuid/E2F633A8F6337C3B";
      fsType = "ntfs";
      options = [ "rw" "gid=100" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/72dc1d28-31f2-460e-845f-ab179ace908f"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "sureyeaah" ];
    autoOptimiseStore = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  networking.hostName = "dell";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlp5s0.useDHCP = true;
  networking.extraHosts = 
    ''
      172.31.107.209 ci-ingress.relicx.ai
    '';

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";
  
  # TODO: move this
  programs.mosh.enable = true;

  users.users.sureyeaah= {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
    shell = pkgs.fish;
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
    calibre
    mesa-demos
    anydesk
    solaar
    remmina
  ]);


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
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
