# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };
  # Load amd driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  
  # Setup Nvidia
  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # I AM USING AN RTX2070
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Setup Nvidia Prime for better power management
    prime = {
      # Setup Experimental Reverse Sync
      # reverseSync.enable = true;
      # allowExternalGpu = true;

      # Make sure to use the correct Bus ID values for your system!
      # intelBusId = "PCI:0:2:0"; # For Intel GPUs
      nvidiaBusId = "PCI:100:0:0";
      amdgpuBusId = "PCI:193:0:0"; # For AMD GPU
    };

  };

  specialisation = {
    on-the-go.configuration = {
      system.nixos.tags = [ "laptop-offload" ];
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce true;
        prime.offload.enableOffloadCmd = lib.mkForce true;
        prime.sync.enable = lib.mkForce false;
      };
    };
    battlestation.configuration = {
      system.nixos.tags = [ "battlestation-sync" ];
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce false;
	prime.offload.enableOffloadCmd = lib.mkForce false;
	prime.sync.enable = lib.mkForce true;
      };
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable NTFS filesystems
  boot.supportedFilesystems = [ "ntfs" ];

  # Setup Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "jay-topN"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the Plasma6 Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Setup home manager
  # home-manager = {
    # specialArgs = { inherit inputs; };
    # users = {
      # "jaycbreak" = import ./home.nix;
    # };
  # };
  home-manager.users."jaycbreak" = import ./home.nix;


  # Setup User
  users.users.jaycbreak = {
    isNormalUser = true;
    description = "Jacob";
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "Welcome123";
    shell = pkgs.zsh;
  };

  # Install zsh
  programs.zsh.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Steam
  programs.steam.enable = true;

  # Xbox Wireless Module "for Windows" enabled for Xbox One Controller Support
  hardware.xone.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wl-clipboard
    wayland-utils
    git
    wget
    btop
    # KDE
    kdePackages.plasma-thunderbolt
    kdePackages.discover
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.ksystemlog
    kdePackages.sddm-kcm
    kdePackages.partitionmanager
    # Needed for Prism Launcher to run
    mesa
    libGL
    libglvnd
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable fwudp for Firmware updates
  services.fwupd.enable = true;

  # Enable Thunderbolt
  services.hardware.bolt.enable = true;


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  system.stateVersion = "25.05"; # Did you read the comment?

}
