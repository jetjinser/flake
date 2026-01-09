{
  inputs,
  ...
}:

{
  imports = [
    inputs.pre-commit-hooks.flakeModule
  ];

  perSystem =
    { config, ... }:
    {
      pre-commit.settings.hooks = {
        nixfmt.enable = true;
        typos = {
          # exclude not working: `**/secrets*`
          enable = false;
          settings.configPath = ".typos.toml";
        };
      };
      devshells.default.devshell.startup.pre-commit-hook.text = config.pre-commit.installationScript;
    };
}
