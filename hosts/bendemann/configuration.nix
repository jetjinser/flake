{
  lib,
  pkgs,
  ...
}:

let
  unfree-stuffs = [
    "nvidia-x11"
    "nvidia-persistenced"
    "nvidia-settings"

    "cuda_cudart"
    "cuda_nvcc"
    "cuda_cccl"
    "libcublas"
    "libcurand"
    "libcusparse"
    "libnvjitlink"
    "libcufft"
    "cudnn"
    "cuda_nvrtc"
  ];
in
{
  networking.hostName = "bendemann";

  # TODO: abstract
  users.users.jinser =
    let
      ssh-keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILkVlWmF+kMCPIdWkvDsXFHDtq84njf8NVN7GxUCAHs julien@darwin"
      ];
    in
    {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = ssh-keys;
    };

  services.smartd.enable = true;

  # i18n.defaultLocale = "en_US.UTF-8";
  i18n.defaultLocale = "zh_CN.UTF-8";

  networking.proxy.default = "http://127.0.0.1:7890/";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfree-stuffs;
  };

  zramSwap.enable = true;

  services.journald.extraConfig = "MaxRetentionSec=7d";

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
