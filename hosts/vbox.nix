{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9ad8bea4-dcbd-4e12-b51e-62365088ab9b";
      fsType = "ext4";
    };
  swapDevices =
    [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  # hardware.video.hidpi.enable = lib.mkDefault true;

  # Try to fix default shitty sound experience on Carbon
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };

  # FIXME: https://github.com/NixOS/nixpkgs/pull/97972#issuecomment-834774554
  services.tlp.enable = false;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.device = "/dev/sda";

  virtualisation.virtualbox.guest.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "sureyeaah" ];
  };

  networking.hostName = "vbox";
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;

  programs.mosh.enable = true;

  # services.xserver.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  users.users.sureyeaah= {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    pulsemixer
    fzf
    htop
    ripgrep
    mpv
    kitty
  ];

  services = {
    openssh.enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
