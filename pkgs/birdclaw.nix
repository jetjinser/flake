{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  makeWrapper,
  pnpmConfigHook,
  nodejs-slim_26,
  pnpm_10,
  xurl,
}:

let
  nodejs-slim = nodejs-slim_26;
  pnpm = pnpm_10.override { inherit nodejs-slim; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "birdclaw";
  version = "0.8.3";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "birdclaw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kJnafd8IIcDe4+VEXLu+Mq7jpzoX372Z8K+jF3w5Leg=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs-slim
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-0djdzQOAdNDtOguolT5F9w5Odv19ssBaHf6jM9FD3iE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/birdclaw
    mkdir $out/bin
    cp -r src node_modules bin package.json $out/lib/node_modules/birdclaw/

    ln -s $out/lib/node_modules/birdclaw/bin/birdclaw.mjs $out/bin/birdclaw
    chmod +x $out/bin/birdclaw
    patchShebangs $out/bin/birdclaw
    wrapProgram $out/bin/birdclaw \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs-slim
          xurl
        ]
      }

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Stores all your tweets nicely claw-able for agents";
    homepage = "https://github.com/steipete/birdclaw";
    changelog = "https://github.com/steipete/birdclaw/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jinser ];
    mainProgram = "birdclaw";
    platforms = lib.platforms.all;
  };
})
