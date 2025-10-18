{
  config,
  pkgs,
  lib,
  ...
}:

let
  enable = true;
  user = "liteLLM";

  cfg = config.services;

  fineTuningUser = {
    config = lib.mkIf enable {
      systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;
      systemd.services.litellm.serviceConfig.DynamicUser = lib.mkForce false;
    };
  };
in
{
  imports = [ fineTuningUser ];

  sops =
    let
      inherit (config.sops) placeholder;
    in
    {
      secrets = {
        dpskToken4liteLLM = { };
      };
      templates."liteLLM.env".content = ''
        DEEPSEEK_API_KEY = "${placeholder.dpskToken4liteLLM}";
      '';
    };
  services = {
    ollama = {
      inherit enable;
      user = "ollama";
      loadModels = [
        "llama3.2:latest"
        "devstral:24b"
        "deepseek-r1:7b"
        "mistral-small:24b"
        "deepseek-r1:1.5b"
        "gemma3:4b"
        "embeddinggemma:300m"
      ];
    };
    litellm = {
      enable = false;
      settings = {
        general_settings =
          let
            pgSettings = cfg.postgresql.settings;
            inherit (pgSettings) listen_addresses port;
          in
          {
            master_key = "sk-testing";
            database_url = "postgresql://${user}@${listen_addresses}:${toString port}/${user}";
          };
        model_list =
          let
            mkOllamaModel = model: {
              model_name = model;
              litellm_params = {
                model = "ollama/${model}";
                api_key = "os.environ/OLLAMA_BASE_URL";
              };
            };
          in
          [
            (mkOllamaModel "gemma3:4b")
            (mkOllamaModel "embeddinggemma:300m")
            (mkOllamaModel "llama3.2:latest")

            # "deepseek/deepseek-chat"
            # "deepseek/deepseek-reasoner"
          ];
        environment_variables = {
          OLLAMA_BASE_URL = "http://${cfg.ollama.host}:${toString cfg.ollama.port}";
        };
      };
      environmentFile = config.sops.templates."liteLLM.env".path;
    };
    postgresql = {
      enable = false;
      ensureDatabases = [ user ];
      ensureUsers = [
        {
          name = user;
          ensureDBOwnership = true;
        }
      ];
      authentication = ''
        local ${user} ${user} trust
      '';
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/432925
  systemd.services.litellm.serviceConfig = {
    ExecStartPre =
      let
        schema = "${pkgs.litellm}/${pkgs.python3.sitePackages}/litellm/proxy/schema.prisma";
        inherit (pkgs) prisma-engines;
        prismaGen = pkgs.writeShellApplication {
          name = "prisma-gen";
          runtimeInputs = [ pkgs.python3Packages.prisma ];
          text = ''
            prisma generate --schema=${schema}
          '';
          runtimeEnv = {
            PRISMA_SCHEMA_ENGINE_BINARY = lib.getExe' prisma-engines "schema-engine";
            PRISMA_QUERY_ENGINE_BINARY = lib.getExe' prisma-engines "query-engine";
            PRISMA_INTROSPECTION_ENGINE_BINARY = lib.getExe' prisma-engines "introspection-engine";
            PRISMA_FMT_BINARY = lib.getExe' prisma-engines "prisma-fmt";
            PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines}/lib/libquery_engine.node";
          };
        };
      in
      [ (lib.getExe prismaGen) ];
    # Environment =
    #   let
    #     inherit (pkgs) prisma-engines;
    #   in
    #   lib.mapAttrsToList (k: v: "${k}=${v}") {
    #     PRISMA_SCHEMA_ENGINE_BINARY = lib.getExe' prisma-engines "schema-engine";
    #     PRISMA_QUERY_ENGINE_BINARY = lib.getExe' prisma-engines "query-engine";
    #     PRISMA_INTROSPECTION_ENGINE_BINARY = lib.getExe' prisma-engines "introspection-engine";
    #     PRISMA_FMT_BINARY = lib.getExe' prisma-engines "prisma-fmt";
    #
    #     PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines}/lib/libquery_engine.node";
    #   };
  };

  preservation.preserveAt."/persist" = {
    directories = [
      cfg.ollama.home
      cfg.litellm.stateDir
    ];
  };
}
