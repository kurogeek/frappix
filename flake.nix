{
  description = "Frappe Development & Deployment Environment";

  outputs = inputs: let
    loader = import ./nix/loader.nix {inherit inputs;};
    inherit (loader) systems cells;
    lib = inputs.nixpkgs.lib;
    forAllSystems = lib.genAttrs systems;
  in {
    # The full nixpkgs instance with all frappix overlays applied,
    # e.g. `nix build .#frappix.erpnext` or `nix run .#nvchecker-nix`.
    legacyPackages = forAllSystems (system: cells.${system}.src.pkgs);
    packages = forAllSystems (system: {
      deployment-for-manual-testing = cells.${system}.deployment-for-manual-testing.runnables.script;
    });
    devShells = forAllSystems (system: cells.${system}.local.shells);
    checks = forAllSystems (system: cells.${system}.tests.checks);
    templates = cells.${lib.head systems}.examples.templates;

    # For downstream projects (see examples/templates).
    inherit (loader) lib;
    shellModule = forAllSystems (system: cells.${system}.src.shell.bench);
    jobs = forAllSystems (system: cells.${system}.src.jobs);
    toolsOverlay = forAllSystems (system: cells.${system}.src.overlays.tools);
    pythonOverlay = forAllSystems (system: cells.${system}.src.overlays.python);
    frappeOverlay = forAllSystems (system: cells.${system}.src.overlays.frappe);
    libsOverlay = forAllSystems (system: cells.${system}.src.overlays.libs);
    nixosModules = forAllSystems (system: cells.${system}.src.nixos);
    ociModules = forAllSystems (system: cells.${system}.src.oci);

    # Deployment artifacts and test beds.
    ociImages = forAllSystems (system: cells.${system}.src.oci-images);
    microvms = forAllSystems (system: cells.${system}.src.vms);
    nixosTests = forAllSystems (system: cells.${system}.tests.nixos-tests);
    arionProjects = forAllSystems (system: cells.${system}.tests.arion-compose);
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
    # deep-merge helper used by the oci tooling
    dmerge.url = "github:divnix/dmerge/0.2.1";
  };
}
