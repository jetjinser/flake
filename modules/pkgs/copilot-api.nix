{
  lib,
  stdenv,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  bun,
  makeWrapper,
}:

let
  pname = "copilot-api";
  version = "0.5.14";

  src = fetchFromGitHub {
    owner = "ericc-ch";
    repo = "copilot-api";
    rev = "v${version}";
    hash = "sha256-rRtByk5Fx3sn7vALjR4Pj42keB4hZyd/gFe6I0NivCI=";
  };

  node_modules = stdenv.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version src;

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

      bun install \
        --force \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --production

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/node_modules
      cp -R ./node_modules $out

      runHook postInstall
    '';

    dontFixup = true;

    outputHash = "sha256-Vqul+qFQKAjwwteIp5/tCbDtGUuaqoaVKDOobZ84ZA4=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  configurePhase = ''
    runHook preConfigure
    cp -R ${node_modules}/node_modules .
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # Build the project using bun
    bun build src/main.ts --outfile=dist/main.js --target=bun

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 dist/main.js $out/dist/main.js
    makeWrapper ${lib.getExe' bun "bun"} $out/bin/copilot-api \
      --add-flags "run $out/dist/main.js"

    runHook postInstall
  '';

  meta = {
    description = "Turn GitHub Copilot into OpenAI/Anthropic API compatible server";
    homepage = "https://github.com/ericc-ch/copilot-api";
    license = lib.licenses.mit;
    mainProgram = "copilot-api";
    platforms = lib.platforms.all;
  };
}
