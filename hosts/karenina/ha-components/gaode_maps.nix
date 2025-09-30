{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent rec {
  owner = "dscao";
  domain = "gaode_maps";
  version = "2025.8.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    tag = version;
    hash = "sha256-WEOES6SIc8h7GejDhRi/HS1VGy6AQgalbI1vkKLdh/E=";
  };

  dependencies = [
  ];

  meta = {
    changelog = "https://github.com/frenck/spook/releases/tag/${version}";
    description = "Toolbox for Home Assistant";
    homepage = "https://github.com/dscao/gaode_maps";
    license = lib.licenses.gpl3Only;
  };
}
