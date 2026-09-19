{
  lib,
  buildPythonPackage,
  fetchPypi,
  maturin,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "pdf-inspector";
  # NOTE: pinned by zotero-mcp (pdf-inspector==0.2.6)
  version = "0.2.6";
  pyproject = true;

  src = fetchPypi {
    pname = "pdf_inspector";
    inherit version;
    hash = "sha256-W7OH85v3qTsCtJGItnC5eY+MzH5Y9o7uWIOlEqoFzrI=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-/PTqpmL2JdnK/Ejo3IAK/DqTSVrA9zTmFnmRPoc4tLc=";
  };

  build-system = [ maturin ];

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  pythonImportsCheck = [ "pdf_inspector" ];

  meta = {
    description = "Fast PDF inspection, classification and text extraction with smart scanned vs text-based detection";
    homepage = "https://github.com/firecrawl/pdf-inspector";
    changelog = "https://github.com/firecrawl/pdf-inspector/releases";
    license = lib.licenses.mit;
  };
}
