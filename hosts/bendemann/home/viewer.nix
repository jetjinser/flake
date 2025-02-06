{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    zotero_7
  ];
}
