{
  imports = [
    # ./container.nix
    # ./virt.nix
  ];

  # TODO: get help with preservation?
  #
  # sops = {
  #   secrets.waka_api_key = { };
  #   templates."wakatime.cfg".content = ''
  #     [settings]
  #     debug = false
  #     hidefilenames = false
  #     ignore =
  #         COMMIT_EDITMSG$
  #         PULLREQ_EDITMSG$
  #         MERGE_MSG$
  #         TAG_EDITMSG$
  #     api_url = https://waka.yeufossa.org/api
  #     api_key = "${config.sops.placeholder.waka_api_key}"
  #   '';
  # };
  #
  # systemd.tmpfiles.settings.generated = {
  #   "/home/${myself}/.wakatime.cfg".f = { user = myself; group = "users"; mode = "0400"; };
  # };
}
