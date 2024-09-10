{ config
, ...
}:

let
  inherit (config.users) users;
in
{
  services.radicle = {
    enable = true;
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAaMWa9Od5wh1+ozsjKg4KJvh1jR/UBXgHY1DQLGTfqA radicle";
  };

  sops = {
    secrets.radPriKey = {
      owner = users.radicle.name;
    };
  };
}
