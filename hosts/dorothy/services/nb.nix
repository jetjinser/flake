{
  flake,
  ...
}:

{
  imports = [ flake.inputs.nonebot2.nixosModules.default ];
  nixpkgs.overlays = [ flake.inputs.nonebot2.overlays.default ];

  services.nonebot2 = {
    enable = false;
    uvlock = ./uv.lock;
    settings = {
      project.dependencies = [
        "nonebot-adapter-onebot>=2.4.6"
        "nonebot2[fastapi,websockets]>=2.4.1"
      ];
      tool.nonebot = {
        builtin_plugins = [ "echo" ];
      };
    };
  };
}
