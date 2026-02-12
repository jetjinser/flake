let
  enable = true;
in
{
  services = {
    ollama = {
      inherit enable;
      loadModels = [
        # embedding models
        "embeddinggemma:300m"
        "dengcao/Qwen3-Embedding-4B:Q4_K_M"
      ];
    };
  };

  # broken: https://github.com/NixOS/nixpkgs/pull/367695
  # nixpkgs.config = {
  #   cudaSupport = false;
  #   rocmSupport = true;
  # };
}
