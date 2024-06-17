{
  services.guix = {
    enable = true;
    extraArgs = [
      "--substitute-urls=https://mirror.sjtu.edu.cn/guix/"
    ];
  };
}
