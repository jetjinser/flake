let
  enable = true;
in
{
  services.beszel.hub = {
    inherit enable;
    port = 19003;
    host = "hub.2jk.pw";
  };
}
