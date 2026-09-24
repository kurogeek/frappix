{
  nixpkgs,
  system,
  devshell,
  nixago,
  dmerge,
  arion,
}: {
  mkShell = import ./mkShell.nix {inherit nixpkgs system devshell nixago;};
  mkNixago = import ./mkNixago.nix {inherit nixpkgs nixago dmerge;};
  mkArion = import ./mkArion.nix {inherit nixpkgs arion;};
}
