# https://github.com/Stzx/flake/blob/0a84d6492ec63c969a08c947418381da9f0e2517/pkgs/peer-ban-helper/package.nix
# under MIT License

{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
  pnpm,
  gradle_9,
  makeWrapper,
  temurin-bin-25,
  pbhJre ? temurin-bin-25, # temurin-jre-bin-25 = size++
  vmOpts ? "-XX:+UseZGC -XX:+ZGenerational -Dpbh.usePlatformConfigLocation=true -Dpbh.nogui=true",
}:

assert lib.versionAtLeast (lib.getVersion pbhJre) "25";

let
  jdk' = temurin-bin-25;
  gradle' = gradle_9;

  # 有些“可疑”的 repository URLs (应该没问题)
  # 我虽然打包了，但并没有使用该软件
  pname = "peer-ban-helper";

  version = "9.1.0-alpha5";

  src = fetchFromGitHub {
    owner = "PBH-BTN";
    repo = "PeerBanHelper";
    tag = "v${version}";
    hash = "sha256-FX4+8PZWyO5IvpbufCHOCf5HSGmhYIvJU40aaqI+NOM=";
    leaveDotGit = true; # gen UI version
  };

  webui = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit version src;

    pname = "${pname}-webui";

    sourceRoot = "${finalAttrs.src.name}/webui";

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
    ];

    # pnpmRoot = "webui";

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;

      fetcherVersion = 2;
      hash = "sha256-CEqnFRjckEDguX16yJbYfdc47eW4q52I4g6MZ5SGprA=";
    };

    buildPhase = ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r ./dist/ $out/

      runHook postInstall
    '';
  });
in
stdenvNoCC.mkDerivation (finalAttrs: rec {
  inherit pname version src;

  nativeBuildInputs = [
    gradle'
    makeWrapper
  ];

  mitmCache = gradle'.fetchDeps {
    # inherit (finalAttrs) pname;

    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  __darwinAllowLocalNetworking = true;

  gradleFlags = [
    "-x"
    "distTar"
    "-x"
    "distZip"
    "-Dorg.gradle.java.home=${jdk'}"
  ];

  preBuild = ''
    cp -rv ${webui}/ src/main/resources/static/ \
      && chmod -R u+w src/main/resources/static/
  '';

  # PACKAGING.md
  #
  # pbh.datadir, pbh.configdir, pbh.logsdir
  #
  # swing, swt, nogui, silent
  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/${pname}/ ./build/libs/*.jar
    install -Dm644 -t $out/share/${pname}/libraries/ ./build/libraries/*

    makeWrapper ${lib.getExe pbhJre} $out/bin/${meta.mainProgram} \
        --add-flags "${vmOpts} -Dpbh.release=nixos -jar $out/share/${pname}/PeerBanHelper.jar"

    runHook postInstall
  '';

  passthru = {
    inherit webui;
  };

  meta = {
    description = "自动封禁不受欢迎、吸血和异常的 BT 客户端";
    homepage = "https://github.com/PBH-BTN/PeerBanHelper";
    license = lib.licenses.gpl3Only;
    mainProgram = "peer-ban-helper";
    platforms = lib.platforms.all;
  };
})
