{ pkgs, lib, ... }:
{
  environment.systemPackages = map lib.lowPrio (with pkgs; [
    # keep-sorted start
    curl
    git
    screen
    zuo
    jq
    file
    # keep-sorted end
  ]);
}
