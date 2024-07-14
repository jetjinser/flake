{
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };
}
