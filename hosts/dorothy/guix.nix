{
  services.guix = {
    # TODO: come back
    enable = false;
    extraArgs = [
      "--substitute-urls=https://mirror.sjtu.edu.cn/guix/"
    ];
  };
}
