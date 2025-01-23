{ config
, pkgs
, lib
, ...
}:

let
  cfg = config.services;

  # waitng for: https://nixpkgs-tracker.ocfox.me/?pr=375918
  gcp-storage-emulator = pkgs.python312.pkgs.buildPythonPackage rec {
    pname = "gcp-storage-emulator";
    version = "2024.08.03";
    pyproject = true;
    src = pkgs.fetchFromGitHub {
      owner = "oittaa";
      repo = "gcp-storage-emulator";
      rev = "v${version}";
      hash = "sha256-Lp9Wvod0wSE2+cnvLXguhagT30ax9TivyR8gC/kB7w0=";
    };
    build-system = with pkgs.python312.pkgs; [
      setuptools
      wheel
    ];
    nativeCheckInputs = with pkgs.python312.pkgs; [
      flake8
      fs
      google-cloud-storage
      google-crc32c
      pytest
      pytestCheckHook
      pytest-cov
      requests
    ];
    pythonImportsCheck = [
      "gcp_storage_emulator"
    ];
  };

  pname = "open-webui";
  version = "0.5.6";
  src = pkgs.fetchFromGitHub {
    owner = "open-webui";
    repo = "open-webui";
    tag = "v${version}";
    hash = "sha256-9HRUFG8knKJx5Fr0uxLPMwhhbNnQ7CSywla8LGZu8l4=";
  };

  frontend = pkgs.buildNpmPackage {
    inherit pname version src;
    npmDepsHash = "sha256-copQjrFgVJ6gZ8BwPiIsHEKSZDEiuVU3qygmPFv5Y1A=";
    postPatch = ''
      substituteInPlace package.json \
        --replace-fail "npm run pyodide:fetch && vite build" "vite build"
    '';
    env.CYPRESS_INSTALL_BINARY = "0";
    env.ONNXRUNTIME_NODE_INSTALL_CUDA = "skip";
    env.NODE_OPTIONS = "--max-old-space-size=8192";
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share
      cp -a build $out/share/open-webui
      runHook postInstall
    '';
  };

  open-webui = pkgs.open-webui.overridePythonAttrs (old: {
    inherit version src;
    dependencies = old.dependencies ++ (with pkgs.python312.pkgs; [
      google-cloud-storage
      moto
    ] ++ [
      gcp-storage-emulator
    ]);
    makeWrapperArgs = [ "--set FRONTEND_BUILD_DIR ${frontend}/share/open-webui" ];
  });
in
{
  services = {
    ollama = {
      enable = true;
      user = "ollama";
      loadModels = [
        "deepseek-r1:1.5b"
        "deepseek-r1:7b"
      ];
    };
    open-webui = {
      enable = true;
      package = open-webui;
      port = 9000;
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        WEBUI_AUTH = "False";

        http_proxy = "http://127.0.0.1:7890/";
        https_proxy = "http://127.0.0.1:7890/";

        ENABLE_OPENAI_API = "False";
        OLLAMA_API_BASE_URL = "http://${cfg.ollama.host}:${toString cfg.ollama.port}";
      };
    };
  };

  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  systemd.services.open-webui.serviceConfig.DynamicUser = lib.mkForce false;
  systemd.services.open-webui.serviceConfig.User = "open-webui";
  systemd.services.open-webui.serviceConfig.Group = "open-webui";
  users = {
    users.open-webui = {
      home = cfg.open-webui.stateDir;
      isSystemUser = true;
      group = "open-webui";
    };
    groups.open-webui = { };
  };

  preservation.preserveAt."/persist" = {
    directories = [
      cfg.ollama.home
      cfg.open-webui.stateDir
    ];
  };
  # broken: https://github.com/NixOS/nixpkgs/pull/367695
  # nixpkgs.config = {
  #   cudaSupport = false;
  #   rocmSupport = true;
  # };
}
