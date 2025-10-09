let
  enable = true;
in
{
  services = {
    ollama = {
      inherit enable;
      loadModels = [
        "gemma3:4b"
        # embedding models
        "embeddinggemma:300m"
      ];
    };
  };

  # broken: https://github.com/NixOS/nixpkgs/pull/367695
  # nixpkgs.config = {
  #   cudaSupport = false;
  #   rocmSupport = true;
  # };
}
