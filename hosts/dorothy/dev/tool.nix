{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;
in
mkHM (
  {
    pkgs,
    lib,
    config,
    ...
  }:

  let
    cfg = config.programs.btop;
    rose-pine-btop = pkgs.fetchFromGitHub {
      owner = "rose-pine";
      repo = "btop";
      rev = "6d6abdc";
      hash = "sha256-sShQYfsyR5mq/e+pjeIsFzVZv3tCpQEdGC9bnTKlQ5c=";
    };
    rose-pine-btop-plain = pkgs.runCommandLocal "plain-rose-pine" { } ''
      cat ${rose-pine-btop}/rose-pine.theme > $out
    '';
    btop-desktop-with-app-id = pkgs.runCommandLocal "btop-desktop-with-app-id" { } ''
      mkdir -p $out/share/applications
      cat ${cfg.package}/share/applications/btop.desktop > $out/share/applications/btop.desktop

      sed -i 's/Terminal=true/Terminal=false/'                 $out/share/applications/btop.desktop
      sed -i 's/Exec=btop/Exec=footclient --app-id btop btop/' $out/share/applications/btop.desktop
    '';
    kilocode-cli = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.kilocode-cli;
    kilocode-with-sandboxed =
      pkgs.runCommand "kilocode"
        {
          nativeBuildInputs = [ pkgs.makeWrapper ];
        }
        ''
          mkdir -p $out/bin
          makeWrapper ${kilocode-cli}/bin/kilocode $out/bin/kilocode \
            --set KILO_BWRAP_PATH "${lib.getExe' pkgs.bubblewrap "bwrap"}"
        '';
  in
  {
    home.packages = [
      (lib.hiPrio btop-desktop-with-app-id)
      kilocode-with-sandboxed
      pkgs.bubblewrap
    ];

    programs.btop = {
      enable = true;
      package = pkgs.btop-rocm;
      themes.rose-pine = rose-pine-btop-plain;
      settings = {
        color_theme = "rose-pine";
        vim_keys = true;
        rounded_corners = false;
      };
    };

    programs.git = {
      settings.sendemail = {
        smtpServer = "smtp.gmail.com";
        smtpServerPort = 587;
        smtpEncryption = "tls";
        smtpUser = "cmdr.jv@gmail.com";
      };
    };
  }
)
// {
  imports = [ flake.config.modules.nixos.misc ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${myself}/vie/projet/flake";
  };
  nix.gc.automatic = false;
}
