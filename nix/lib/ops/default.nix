{
  nixpkgs,
  dmerge,
  nix2container,
}: let
  ops = {
    lazyDerivation = import ./lazyDerivation.nix {inherit nixpkgs;};
    mkSetup = import ./mkSetup.nix {inherit nixpkgs;};
    writeScript = import ./writeScript.nix {inherit nixpkgs ops;};
    mkUser = import ./mkUser.nix {inherit nixpkgs ops;};
    mkOperable = import ./mkOperable.nix {inherit nixpkgs ops;};
    mkOCI = import ./mkOCI.nix {inherit nixpkgs ops nix2container;};
    mkStandardOCI = import ./mkStandardOCI.nix {inherit nixpkgs ops dmerge nix2container;};
  };
in
  ops
