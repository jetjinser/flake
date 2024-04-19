{ lib
, fetchFromSourcehut
, buildGoModule
}: buildGoModule {
  pname = "betula";
  version = "master";

  src = fetchFromSourcehut {
    owner = "~bouncepaw";
    repo = "betula";
    rev = "e83a303da043e33fd1c98290957ed1f403fe92c6";
    hash = "sha256-FBA55t8UeMNzsxA/HtBmnLyXSzxcJp/uk4MTTKsExIc=";
  };
  vendorHash = "sha256-SWcQYF8LP6lw5kWlAVFt3qiwDnvpSOXenmdm6TSfJSc=";

  CGO_ENABLED = 1;
  # These tests use internet, so are failing in Nix build.
  # See also: https://todo.sr.ht/~bouncepaw/betula/91
  checkFlags = "-skip=TestTitles|TestHEntries";

  meta = with lib; {
    description = "Single-user self-hosted bookmarking software";
    homepage = "https://betula.mycorrhiza.wiki/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ GoldsteinE ];
  };
}
