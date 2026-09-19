{
  lib,
  fuse,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
}:

buildGoModule rec {
  pname = "alist";
  version = "3.31.0";

  src = fetchFromGitHub {
    owner = "alist-org";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Xg1pxMLY4M/5wA44UIms1PW1TYaO0+WB8YBc65MFSYA=";
  };

  proxyVendor = true;
  vendorHash = "sha256-Zi6ROgGFT+x7xR5GsDnryCwCUm6bHBbtuh778MSmuV4=";

  dist = fetchzip {
    url = "https://github.com/alist-org/alist-web/releases/download/${version}/dist.tar.gz";
    sha256 = "sha256-bxgamMy9PP8UmNOqDZagR3ojNKaW5u2ksOjwsDR+ue8=";
  };

  postUnpack = ''
    mkdir -p $sourceRoot/public
    cp -Tr ${dist} $sourceRoot/public/dist
    chmod 755 -R $sourceRoot/public
  '';

  doCheck = false;

  buildInputs = [
    fuse
  ];

  ldflags =
    let
      mkFlag = k: v: "-X 'github.com/alist-org/alist/v3/internal/conf.${k}=${v}'";
    in
    [
      "-w"
      "-s"
    ]
    ++ lib.mapAttrsToList mkFlag {
      # BuiltAt = 1;
      # GoVersion = 2;
      # GitAuthor = 3;
      GitCommit = src.rev;
      Version = "v${version}";
      WebVersion = version;
    };

  meta = with lib; {
    homepage = "https://github.com/alist-org/alist";
    changelog = "https://github.com/alist-org/alist/releases/tag/v${version}";
    description = "A file list/WebDAV program that supports multiple storages, powered by Gin and Solidjs";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ t4ccer ];
    mainProgram = "alist";
  };
}
