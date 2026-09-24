/*
Repo-local replacement for the subset of the `divnix/std` framework library
that frappix uses (`std.lib.dev`, `std.lib.ops`, `std.lib.cfg` and
`std.data.configs`).

The former `std` flake input is gone; these helpers are vendored under
`nix/lib` and assembled here per-system. `nixpkgs` is an already instantiated
(plain) nixpkgs package set for `system` — the same thing std used to expose as
`inputs.nixpkgs`.
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
  ops = import ./lib/ops {inherit nixpkgs dmerge nix2container;};
  dev = import ./lib/dev {
    inherit nixpkgs dmerge nixago;
    inherit (inputs) devshell arion;
  };
  cfg = import ./lib/cfg {inherit nixpkgs;};
  configs = import ./lib/configs {inherit nixpkgs;};
}
