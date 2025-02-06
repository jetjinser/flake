{
  pkgs,
  ...
}:

{
  programs.fish.enable = true;

  users.users =
    let
      hashedPassword = "$6$gVQz/r75hkES.aRj$tjswSTTNHcdvoKFY1i40xfspAg3/vTZLAweg81OrQveQRs9cBb/qIGv1F8jd.c5//cTmHxwnBidqbAjbCuU/u/";
    in
    {
      jinser = {
        isNormalUser = true;
        home = "/home/jinser";
        description = "Jinser Kafka";
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "audio"
          "networkmanager"
        ];
        inherit hashedPassword;
      };
      root = {
        inherit hashedPassword;
      };
    };
}
