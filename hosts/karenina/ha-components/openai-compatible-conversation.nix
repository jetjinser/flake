{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  openai,
}:

let
  owner = "michelle-avery";
  domain = "openai_compatible_conversation";
  version = "0.0.7";

in
buildHomeAssistantComponent {
  inherit owner domain version;

  src = fetchFromGitHub {
    inherit owner;
    repo = "openai-compatible-conversation";
    tag = version;
    hash = "sha256-AY84iBM0ZtM28yJGLI/9xlor/8Aa3LiHI9179bLoWbY=";
  };

  dependencies = [ openai ];

  meta = {
    description = "A copy of Home Assistant's built-in OpenAI Conversation Agent, with support for changing the base url";
    homepage = "https://github.com/michelle-avery/openai-compatible-conversation";
    mainProgram = "openai-compatible-conversation";
    platforms = lib.platforms.all;
  };
}
