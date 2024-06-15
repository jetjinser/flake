{ inputs
, ...
}:

{
  imports = [
    inputs.devshell.flakeModule
    ./share.nix
    ./remote.nix
    ./darwin.nix
  ];

  perSystem = _: {
    devshells.default = {
      name = "NixConsole";
      motd = ''
        {italic}{99}🦾 Life in Nix 👾{reset}
        $(type -p menu &>/dev/null && menu)
      '';
    };
  };
}
