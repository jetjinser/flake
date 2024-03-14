{ qkgs
, ...
}:

{
  perSystem = { pkgs, ... }: {
    typhonJobs = {
      inherit (qkgs) alist;
    };
  };
}
