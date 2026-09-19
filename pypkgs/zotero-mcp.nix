{
  buildPythonPackage,
  fetchPypi,
  lib,
  hatchling,
  installShellFiles,
  pyzotero,
  mcp,
  python-dotenv,
  pydantic,
  requests,
  fastmcp,
  unidecode,
  markitdown,
  pdf-inspector,
  # semantic extras
  withSemantic ? false,
  chromadb,
  sentence-transformers,
  openai,
  google-genai,
  tiktoken,
  # pdf extras
  withPdf ? false,
  pymupdf,
  ebooklib,
  # scite extras
  withScite ? false,
}:
buildPythonPackage rec {
  pname = "zotero-mcp-server";
  version = "0.9.1";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "zotero_mcp_server";
    hash = "sha256-tMstrPEZntmm/sK4xBWAuF8419rv6cOocEUxkcwKGNU=";
  };

  build-system = [ hatchling ];

  nativeBuildInputs = [ installShellFiles ];

  dependencies = [
    pyzotero
    mcp
    python-dotenv
    pydantic
    requests
    fastmcp
    unidecode
    markitdown
    pdf-inspector
  ]
  ++ lib.optionals withSemantic [
    chromadb
    sentence-transformers
    openai
    google-genai
    tiktoken
  ]
  ++ lib.optionals withPdf [
    pymupdf
    ebooklib
  ]
  ++ lib.optionals withScite [
    requests
  ];

  pythonImportsCheck = [ "zotero_mcp" ];

  meta = {
    description = "A Model Context Protocol server for Zotero";
    homepage = "https://github.com/54yyyu/zotero-mcp";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "zotero-mcp";
  };
}
