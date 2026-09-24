/*
Wires the repository's Nix files together for one `system`.

Every file is a plain function that receives exactly what it needs; this is
the only place that knows how they fit together.
*/
{
  inputs,
  system,
}: let
  # An instantiated, importable, plain nixpkgs for `system`.
  nixpkgs = inputs.nixpkgs.legacyPackages.${system} // {inherit (inputs.nixpkgs) outPath sourceInfo;};
  lib = import ./lib {inherit inputs system nixpkgs;};

  # App sources (frappe, erpnext, ...) and the package set built from them.
  sources = import ../apps/sources.nix {inherit nixpkgs;};
  overlays = import ../src/overlays {inherit sources;};
  pkgs = import ../src/pkgs.nix {inherit nixpkgs system overlays;};

  # Modules and the artifacts derived from them.
  configData = import ../src/config.nix {inherit nixpkgs;};
  nixos = import ../src/nixos.nix;
  oci = import ../src/oci.nix {
    inherit sources;
    inherit (lib) ops;
  };
  ociImages = import ../src/oci-images.nix {inherit nixpkgs pkgs oci;};
  shell = import ../src/shell.nix {
    inherit nixpkgs configData;
    inherit (lib) dev cfg configs;
  };
  jobs = import ../src/jobs.nix {inherit nixpkgs;};
  microvms = import ../src/vms.nix {
    inherit nixpkgs system pkgs nixos;
    inherit (inputs) microvm;
  };

  # The repository's own development environment and test beds.
  devShells = import ../local/shells.nix {
    inherit nixpkgs system overlays;
    inherit (lib) dev cfg;
    configData = import ../local/config.nix {inherit nixpkgs;};
  };
  checks = import ../tests/checks.nix {inherit nixpkgs system pkgs nixos;};
  nixosTests = import ../tests/nixos-tests.nix {inherit nixpkgs system pkgs nixos;};
  arionProjects = import ../tests/arion-compose.nix {
    inherit ociImages;
    inherit (lib) dev;
  };
  deploymentForManualTesting = import ../deployment-for-manual-testing/runnables.nix {inherit nixpkgs system pkgs nixos;};
in {
  inherit lib sources overlays pkgs nixos oci ociImages shell jobs microvms devShells checks nixosTests arionProjects deploymentForManualTesting;
}
