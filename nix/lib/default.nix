/*
The frappix helper library, assembled per-system.

  - dev     : devshell/nixago/arion wrappers (`mkShell`, `mkNixago`, `mkArion`)
  - ops     : OCI image tooling (`mkOperable`, `mkOperableOCI`, `mkSetup`, ...)
  - cfg     : nixago pebbles for repository dotfiles
  - configs : the data those pebbles render

`nixpkgs` is an already instantiated (plain) nixpkgs package set for `system`.
Exposed as `inputs.lib` inside the cells and as `lib.<system>` on the flake.
*/
{
  inputs,
  system,
  nixpkgs,
}: let
  nixago = inputs.nixago.lib.${system};
  dmerge = inputs.dmerge;
  nix2container = inputs.n2c.packages.${system}.nix2container;
in {
  ops = import ./ops {inherit nixpkgs dmerge nix2container;};
  dev = import ./dev {
    inherit nixpkgs dmerge nixago;
    inherit (inputs) devshell arion;
  };
  cfg = import ./cfg {inherit nixpkgs;};
  configs = import ./configs {inherit nixpkgs;};
}
