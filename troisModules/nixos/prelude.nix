{ pkgs, lib, ... }:
{
  environment.systemPackages = map lib.lowPrio (with pkgs; [
    # keep-sorted start
    curl
    git
    screen
    # keep-sorted end
  ]);
}
