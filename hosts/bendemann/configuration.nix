{ lib, pkgs, ... }:
let
  unfree-stuffs = [
    "nvidia-x11"
    "nvidia-persistenced"
    "nvidia-settings"

    "steam"
    "steam-original"
    "steam-run"

    "qq"
    "zoom"
  ];
in
{
  networking.hostName = "bendemann";

  # TODO: abstract
  users.users.jinser = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.proxy.default = "http://127.0.0.1:7890/";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) unfree-stuffs;
  };

  zramSwap.enable = true;

  services.journald.extraConfig = "MaxRetentionSec=7d";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v24n.psf.gz";
    keyMap = "us";
  };

  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";

    LIBVA_DRIVER_NAME = "nvidia";
    CLUTTER_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_BACKEND = "vulkan";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  system.stateVersion = "22.05";
}
