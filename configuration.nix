# The https://search.nixos.org/options page and in the NixOS manual (`nixos-help`).
# to edit this configuration file to define what my system should install
# Merged with SteamNix (https://github.com/SteamNix/SteamNix)
# Note: hardware-configuration.nix, Jovian and the CachyOS kernel are all provided by flake.nix
{ config, lib, pkgs, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Boot
  boot.tmp.cleanOnBoot = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 6;
  hardware.amdgpu.initrd.enable = false;

  boot.kernelParams = [ "quiet" ];
  boot.kernel.sysctl = {
    "kernel.split_lock_mitigate" = 0;
    "kernel.nmi_watchdog"        = 0;
    "kernel.sched_bore"          = "1"; # works with the CachyOS kernel
  };
  boot.initrd = {
    systemd.enable = true;
    verbose        = false;
  };
  boot.consoleLogLevel = 0;
  boot.plymouth.enable = true;
  # Packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    lsb-release  # Provides 'lsb_release' used by Haxe/Lime engine systems
    mesa-demos   # Provides 'glxinfo' parsed during graphics detection
    git
    xwayland-satellite
    modrinth-app
    spotify
  ];
  # Environment
  #
  environment.sessionVariables = {
    NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
    PATH = [ "/run/current-system/sw/bin" ];

    NIXOS_OZONE_WL = "1";
    PROTON_USE_NTSYNC        = "1";
    PROTON_ENABLE_AMD_AGS    = "1";
    ENABLE_GAMESCOPE_WSI     = "1";
    STEAM_MULTIPLE_XWAYLANDS = "1";
  };
  xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  config = {
    common = {
      default = [ "gtk" ];
    };
  };
};
  # Graphical application with unrar support paths
  nixpkgs.config.packageOverrides = pkgs: {
    kdePackages = pkgs.kdePackages // {
      ark = pkgs.kdePackages.ark.overrideAttrs (oldAttrs: {
        postFixup = (oldAttrs.postFixup or "") + ''
          wrapProgram $out/bin/ark \
            --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.unrar pkgs.rar ]}"
        '';
      });
    };
  spotify = pkgs.spotify.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        wrapProgram $out/bin/spotify \
          --add-flags "--no-sandbox --disable-gpu"
      '';
    });
  };
  # Nix-ld libraries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Core system & compiler runtime
    stdenv.cc.cc
    zlib
    glib

    # X11 / Windowing
    libx11
    libxext
    libxcursor
    libxinerama
    libxrandr
    libxi
    libxrender
    libxcomposite
    libxdamage
    libxtst
    libxscrnsaver
    libxkbcommon

    # Graphics / OpenGL
    libGL
    libGLU
    vulkan-loader
    libx11

    # Audio
    alsa-lib
    libpulseaudio
    openal
    libsndfile

    # Common extra deps
    unrar
    rar
    vlc
    dbus
    fontconfig
    freetype
    udev
  ];
  # Programs
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
  # Users
  users.users.bezie = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "seat" "docker" "libvirtd" ];
    packages = with pkgs; [
      tree
    ];
  };
  jovian = {
    steam = {
      enable = true;
      user = "bezie";
      autoStart = true;          # Boots straight into Gaming Mode
      desktopSession = "plasma"; # Where "Switch to Desktop" goes to
    };
    decky-loader.enable = true;
    steamos.useSteamOSConfig = true;
    hardware.has.amd.gpu = true;
  };
  # Main services
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.flatpak.enable = true;
  services.envfs.enable = true;
  security.polkit.enable = true;
  # Other services
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;
  virtualisation.libvirtd.enable = true;
  # networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  hardware.graphics.enable = true;
  # System version
  system.stateVersion = "26.05";
}
