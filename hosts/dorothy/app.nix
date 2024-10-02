{ pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    prismlauncher
    atlauncher
  ];
}
