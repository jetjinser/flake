{ pkgs, lib, ... }:
{
  environment.systemPackages = map lib.lowPrio (with pkgs; [
    # keep-sorted start
    curl
    git
    screen
    (zuo.overrideAttrs (old: {
      version = "1.10";
    }))
    jq
    file
    # keep-sorted end
  ]);
}
