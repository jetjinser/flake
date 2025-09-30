{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent (finalAttrs: {
  pname = "openai-compatible-conversation";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "michelle-avery";
    repo = "openai-compatible-conversation";
    rev = finalAttrs.version;
    hash = "sha256-AY84iBM0ZtM28yJGLI/9xlor/8Aa3LiHI9179bLoWbY=";
  };

  meta = {
    description = "A copy of Home Assistant's built-in OpenAI Conversation Agent, with support for changing the base url";
    homepage = "https://github.com/michelle-avery/openai-compatible-conversation";
    mainProgram = "openai-compatible-conversation";
    platforms = lib.platforms.all;
  };
})
