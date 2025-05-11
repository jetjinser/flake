{
  flake,
  ...
}:

let
  inherit (flake.config.lib) mkHM;
in
mkHM (
  {
    pkgs,
    ...
  }:

  {
    programs.fish.functions = {
      battery = {
        description = "Show battery info";
        body = # fish
          ''
            upower -i (upower -e | grep battery) | awk '
              /state/       {printf "%-15s \033[1;32m%s\033[0m\n",             "State",       $2    };
              /energy-rate/ {printf "%-15s \033[1;34m%s\033[1;33m%s\033[0m\n", "Energy Rate", $2, $3};
              /voltage/     {printf "%-15s \033[1;34m%s\033[1;33m%s\033[0m\n", "Voltage",     $2, $3};
              /percentage/  {printf "%-15s \033[1;34m%s\033[0m\n",             "Percentage",  $2    };
              /capacity/    {printf "%-15s \033[1;34m%s\033[0m\n",             "Capacity",    $2    };
            '
          '';
      };
    };
  }
)
// {
}
