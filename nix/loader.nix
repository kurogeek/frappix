/*
A tiny, plain-Nix cell loader that replaces `divnix/std` (paisano) `growOn`.

It reproduces exactly the three magic bindings that the cell files rely on:

  - `inputs`  : the flake inputs, but with `inputs.nixpkgs` swapped for an
                instantiated (plain) nixpkgs package set for the current system,
                `inputs.self` reduced to sourceInfo, `inputs.cells` set to all
                loaded cells, and `inputs.stdlib` set to the vendored library
                (see ./stdlib.nix, the former `inputs.std.lib`/`inputs.std.data`).
  - `cell`    : the current cell's own blocks (siblings).
  - `inputs.cells.<cell>.<block>` : every cell's blocks, plus `.system`.

Like paisano, each block file is loaded with `builtins.scopedImport` so that
`inputs` and `cell` resolve as free variables; if the file evaluates to a
function it is additionally applied to `{inputs, cell;}`.

The `system` attribute injected onto each cell mirrors paisano's de-systemized
`inputs.cells.<cell>.system` (used by deployment-for-manual-testing/runnables).
*/
{inputs}: let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib;

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  # An instantiated, importable, plain nixpkgs for `system`.
  npkgsFor = system: nixpkgs.legacyPackages.${system} // {inherit (nixpkgs) outPath sourceInfo;};

  # The cell block layout: <cell>.<block> = path to the block's .nix file/dir.
  blocks = {
    src = {
      overlays = ../src/overlays;
      pkgs = ../src/pkgs.nix;
      nixos = ../src/nixos.nix;
      shell = ../src/shell.nix;
      vms = ../src/vms.nix;
      jobs = ../src/jobs.nix;
      oci = ../src/oci.nix;
      oci-images = ../src/oci-images.nix;
      config = ../src/config.nix;
    };
    local = {
      config = ../local/config.nix;
      shells = ../local/shells.nix;
    };
    apps = {
      sources = ../apps/sources.nix;
    };
    examples = {
      templates = ../examples/templates.nix;
    };
    tests = {
      nixos-tests = ../tests/nixos-tests.nix;
      checks = ../tests/checks.nix;
      arion-compose = ../tests/arion-compose.nix;
    };
    deployment-for-manual-testing = {
      runnables = ../deployment-for-manual-testing/runnables.nix;
    };
  };

  loadFor = system: let
    baseInputs =
      inputs
      // {
        nixpkgs = npkgsFor system;
        self = inputs.self.sourceInfo // {rev = inputs.self.sourceInfo.rev or "not-a-commit";};
        stdlib = import ./stdlib.nix {
          inherit inputs system;
          nixpkgs = npkgsFor system;
        };
        cells = injectedCells;
      };

    # `inputs.cells` carries the de-systemized `.system` marker per cell.
    injectedCells = lib.mapAttrs (_: cellBlocks: cellBlocks // {inherit system;}) loaded;

    loadBlock = cellName: path: let
      cell = loaded.${cellName};
      signature = {
        inputs = baseInputs;
        inherit cell;
      };
      imported = builtins.scopedImport {inherit (signature) inputs cell;} path;
    in
      if builtins.isFunction imported
      then imported signature
      else imported;

    loaded = lib.mapAttrs (cellName: lib.mapAttrs (_: loadBlock cellName)) blocks;
  in
    loaded;
in {
  inherit systems;
  cells = lib.genAttrs systems loadFor;
}
