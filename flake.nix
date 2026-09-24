{
  description = "Frappe Development & Deployment Environment";

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    perSystem = lib.genAttrs systems (system: import ./nix {inherit inputs system;});
    forAllSystems = f: lib.mapAttrs (_: f) perSystem;
  in {
    # The full nixpkgs instance with all frappix overlays applied,
    # e.g. `nix build .#frappix.erpnext` or `nix run .#nvchecker-nix`.
    legacyPackages = forAllSystems (frappix: frappix.pkgs);
    packages = forAllSystems (frappix: {
      deployment-for-manual-testing = frappix.deploymentForManualTesting.script;
    });
    devShells = forAllSystems (frappix: frappix.devShells);
    checks = forAllSystems (frappix: frappix.checks);
    templates = import ./examples/templates.nix;

    # For downstream projects (see examples/templates).
    lib = forAllSystems (frappix: frappix.lib);
    shellModule = forAllSystems (frappix: frappix.shell.bench);
    jobs = forAllSystems (frappix: frappix.jobs);
    toolsOverlay = forAllSystems (frappix: frappix.overlays.tools);
    pythonOverlay = forAllSystems (frappix: frappix.overlays.python);
    frappeOverlay = forAllSystems (frappix: frappix.overlays.frappe);
    libsOverlay = forAllSystems (frappix: frappix.overlays.libs);
    nixosModules = forAllSystems (frappix: frappix.nixos);
    ociModules = forAllSystems (frappix: frappix.oci);

    # Deployment artifacts and test beds.
    ociImages = forAllSystems (frappix: frappix.ociImages);
    microvms = forAllSystems (frappix: frappix.microvms);
    nixosTests = forAllSystems (frappix: frappix.nixosTests);
    arionProjects = forAllSystems (frappix: frappix.arionProjects);
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
