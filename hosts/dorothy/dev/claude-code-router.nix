{
  lib,
  fetchFromGitHub,
  stdenv,
  makeWrapper,

  nodejs_22,
  pnpm_10,

  claude-code,
}:

let
  pnpm = pnpm_10;
  nodejs = nodejs_22;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "claude-code-router";
  version = "1.0.39";

  src = fetchFromGitHub {
    owner = "musistudio";
    repo = "claude-code-router";
    rev = "19d0f3b8f53315a981a835e8700813ffa0fe67a4";
    hash = "sha256-RhGu9WIAdvTOpHzOcN61PKVI3gl0Ivoi3r60jbSTPLM=";
  };

  nativeBuildInputs = [
    makeWrapper
    pnpm.configHook
    nodejs
  ];

  pnpmWorkspaces = [
    "@musistudio/claude-code-router"
    "temp-project"
  ];
  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    fetcherVersion = 2;
    hash = "sha256-SVW9x/5Ma2mcpNjKWEzMX8vFYYLCSwYWVazdJOqH/mw=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r {dist,node_modules} $out/lib

    makeWrapper ${nodejs}/bin/node $out/bin/ccr \
      --add-flags $out/lib/dist/cli.js \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs
          claude-code
        ]
      } \
      --set NODE_ENV production \
      --set NODE_PATH "$out/lib/node_modules"

    runHook postInstall
  '';

  meta = {
    description = "Use Claude Code as the foundation for coding infrastructure, allowing you to decide how to interact with the model while enjoying updates from Anthropic";
    homepage = "https://github.com/musistudio/claude-code-router";
    license = lib.licenses.mit;
    mainProgram = "ccr";
    platforms = lib.platforms.all;
  };
})
