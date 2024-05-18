{ pkgs
, lib
, ...
}:

{
  programs = {
    foot = {
      enable = true;
      server.enable = true;
      settings = import ./components/foot.nix { inherit pkgs lib; };
    };
    eza.enable = true;
    lazygit.enable = true;
  };

  home.packages = with pkgs; [
    dua
    comma
  ];
}
