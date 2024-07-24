{ pkgs
, ...
}:

# let
#   nurApps = with config.nur.repos; [
#     linyinfeng.wemeet
#   ];
# in
{
  # imports = [
  #   flake.inputs.nur.nixosModules.nur
  # ];

  environment.systemPackages = with pkgs; [
    prismlauncher
    atlauncher
  ];
  # ] ++ nurApps;
}
