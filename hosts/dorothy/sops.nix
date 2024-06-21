{ flake
, config
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  imports = [
    flake.inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/persist/home/${myself}/.config/sops/age/keys.txt";
    secrets = {
      server = { };
      password = { };
      method = { };

      waka_api_key = { };
    };
    templates."wakatime.cfg".content = ''
      [settings]
      debug = false
      hidefilenames = false
      ignore =
          COMMIT_EDITMSG$
          PULLREQ_EDITMSG$
          MERGE_MSG$
          TAG_EDITMSG$
      api_url = https://waka.yeufossa.org/api
      api_key = "${config.sops.placeholder.waka_api_key}"
    '';
  };
}
