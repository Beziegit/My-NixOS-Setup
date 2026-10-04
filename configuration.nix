# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Jovian-NixOS (Steam Deck-style "Gaming Mode" session), pinned to a commit
      (
        let revision = "49c2c729cc6d78bf64ae252d3a31e6311d896ab9"; in
        builtins.fetchTarball {
          url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/${revision}.tar.gz";
          sha256 = "sha256-mpFFy+vabu4WOma4Tx7myAPUaj+Ob58qK8ZXL/xANmo=";
        } + "/modules"
      )
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "lv";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

    environment.systemPackages = with pkgs; [
    lsb-release  # Provides 'lsb_release' used by Haxe/Lime engine systems
    mesa-demos   # Provides 'glxinfo' parsed during graphics detection
  ];

  # ENVIRONMENT PATH ENHANCEMENT FOR UNPATCHED BINARIES
  environment.sessionVariables = {
    NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
    PATH = [ "/run/current-system/sw/bin" ];
  };
  # WRAP ARK GRAPHICAL APPLICATION WITH UNRAR SUPPORT PATHS
  nixpkgs.config.packageOverrides = pkgs: {
    kdePackages = pkgs.kdePackages // {
      ark = pkgs.kdePackages.ark.overrideAttrs (oldAttrs: {
        postFixup = (oldAttrs.postFixup or "") + ''
          wrapProgram $out/bin/ark \
            --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.unrar pkgs.rar ]}"
        '';
      });
    };
  };
  # NIX-LD DYNAMIC ENVIRONMENT LIBRARIES
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Core system & compiler runtime
    stdenv.cc.cc
    zlib
    glib

    # X11 / Windowing (Updated to new naming formats to avoid deprecation warnings)
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

    # Graphics / OpenGL
    libGL
    libGLU
    vulkan-loader

    # Audio (Crucial for rhythm games like FNF)
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
  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.bezie = {
     isNormalUser = true;
     extraGroups = ["networkmanager" "wheel" "video" "audio" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
     ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.flatpak.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true;
  services.envfs.enable = true;

  jovian.steam = {
    enable = true;
    user = "bezie";
    autoStart = false; # false = pick "Gaming Mode" at the login screen; true = boot straight into it
    # desktopSession = "plasma"; # what "Switch to Desktop" goes to (needed if autoStart = true)
  };
  system.stateVersion = "26.05"; # Did you read the comment?

}

