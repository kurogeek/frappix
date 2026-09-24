{ nixpkgs, arion }: let inherit (nixpkgs) lib; in
  let
    disabledNotice = ''
      arion's nixos instrumentation is disabled here.

      If you want to create a container that uses NixOS + systemd as its init-system,
      please find out how it's done here:
        ${arion}/src/nix/service/nixos-init.nix

      Build the image with the oci tooling of this repository and pass it to your
      arion configuration.
    '';

    disableNixosModule = {
      disabledModules = [
        (arion + /src/nix/nixos/container-systemd.nix)
        (arion + /src/nix/nixos/default-shell.nix)
        (arion + /src/nix/service/nixos.nix)
        (arion + /src/nix/service/nixos-init.nix)
      ];
      imports = [
        (lib.mkRemovedOptionModule ["nixos" "configuration"] disabledNotice)
        (lib.mkRemovedOptionModule ["nixos" "build"] disabledNotice)
        (lib.mkRemovedOptionModule ["nixos" "evaluatedConfig"] disabledNotice)
      ];
    };
  in
    module:
      arion.lib.eval {
        modules = [disableNixosModule module];
        pkgs = nixpkgs;
      }
