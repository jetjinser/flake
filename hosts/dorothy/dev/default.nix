{ flake
, config
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  imports = [
    # ./container.nix
    # ./virt.nix
    ./tool.nix
  ];

  sops = {
    secrets.waka_api_key = { };
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

  systemd.tmpfiles.settings.generated = {
    "/home/${myself}/.wakatime.cfg".C = {
      user = myself;
      group = "users";
      mode = "0400";
      argument = config.sops.templates."wakatime.cfg".path;
    };
  };
}
