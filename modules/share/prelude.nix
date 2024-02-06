{ pkgs, lib, ... }:
{
  environment.systemPackages = map lib.lowPrio (with pkgs; [
    vim
    curl
    git
  ]);
}
