{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "xurl";
  version = "1.1.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "xdevplatform";
    repo = "xurl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sL1CIXM3tD9pL8hig+UhBAK7G+4JVOFevHdIyS3DhCU=";
  };
  vendorHash = "sha256-sYGm/Yrcu+i+EsjcJfZcCrp3tvWLxo8cte5YnC0fEbI=";

  postPatch = ''
    substituteInPlace api/client_test.go \
      --replace-fail 'xurl/dev' 'xurl/${finalAttrs.version}'
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/xdevplatform/xurl/version.Version=${finalAttrs.version}"
    "-X=github.com/xdevplatform/xurl/version.Commit=${finalAttrs.src.rev}"
    "-X=github.com/xdevplatform/xurl/version.BuildDate=1970-01-01T00:00:00Z"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The official CLI for the X API";
    homepage = "https://github.com/xdevplatform/xurl";
    changelog = "https://github.com/xdevplatform/xurl/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jinser ];
    mainProgram = "xurl";
  };
})
