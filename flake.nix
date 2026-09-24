{
  description = "Frappe Development & Deployment Environment";

  outputs = inputs: let
    loader = import ./nix/loader.nix {inherit inputs;};
    inherit (loader) systems cells;
    lib = inputs.nixpkgs.lib;
    forAllSystems = lib.genAttrs systems;
  in
    # The per-system cell tree, exposed at the top level exactly like the
    # former `std` schema (e.g. `.#x86_64-linux.src.pkgs.frx`,
    # `.#x86_64-linux.local.shells.book`).
    (forAllSystems (system: cells.${system}))
    // {
      # nix-cli compatible outputs (formerly assembled via `std.growOn` soil).
      packages = forAllSystems (system: {inherit (cells.${system}.src.pkgs) frx;});
      shellModule = forAllSystems (system: cells.${system}.src.shell.bench);
      toolsOverlay = forAllSystems (system: cells.${system}.src.overlays.tools);
      devShells = forAllSystems (system: cells.${system}.local.shells);
      checks = forAllSystems (system: cells.${system}.tests.checks);
      pythonOverlay = forAllSystems (system: cells.${system}.src.overlays.python);
      frappeOverlay = forAllSystems (system: cells.${system}.src.overlays.frappe);
      libsOverlay = forAllSystems (system: cells.${system}.src.overlays.libs);
      nixosModules = forAllSystems (system: cells.${system}.src.nixos);
      templates = cells.${lib.head systems}.examples.templates;
    };

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs = {
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    nixago.inputs.nixago-exts.follows = "";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixpkgs";
    n2c.url = "github:nlewo/nix2container";
    # deep-merge helper, formerly pulled in transitively via divnix/std
    dmerge.url = "github:divnix/dmerge/0.2.1";
    # frx is the (frappix-branded) paisano TUI; build it from source directly
    # (formerly reached via std.inputs.paisano-tui).
    paisano-tui.url = "github:paisano-nix/tui/v0.5.0";
    paisano-tui.flake = false;
  };
}
