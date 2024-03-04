{ pkgs, lib, ... }:
{
  environment.systemPackages = map lib.lowPrio (with pkgs; [
    curl
    git
    screen
  ]);
}
