{
  flake,
  config,
  pkgs,
  ...
}:

let
  inherit (flake.config.lib) mkHM;
  inherit (config.sops) secrets;
in
mkHM (_: {
  programs.fish = {
    functions = {
      battery = {
        description = "Show battery info";
        body = # fish
          ''
            upower -i (upower -e | grep battery) | awk '
              /state:/       {printf "%-15s \033[1;32m%s\033[0m\n",             "State",       $2    };
              /energy-rate:/ {printf "%-15s \033[1;34m%s\033[1;33m%s\033[0m\n", "Energy Rate", $2, $3};
              /voltage:/     {printf "%-15s \033[1;34m%s\033[1;33m%s\033[0m\n", "Voltage",     $2, $3};
              /percentage:/  {printf "%-15s \033[1;34m%s\033[0m\n",             "Percentage",  $2    };
              /capacity:/    {printf "%-15s \033[1;34m%s\033[0m\n",             "Capacity",    $2    };
            '
          '';
      };
    };
    shellAbbrs = {
      t = "task";
    };
  };
})
// ({
  security.pki.certificateFiles = [
    ../../assets/2jk.crt
  ];

  sops.secrets.nix-secret-key = { };
  nix.settings.secret-key-files = secrets.nix-secret-key.path;

  services.scx-loader = {
    enable = false;
    config.default_sched = "scx_pandemonium";
  };

  powerManagement.powertop.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    pd.enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };
})
