{
  description = "MY FRAPPIX";

  outputs = {
    nixpkgs,
    frappix,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    pkgsFor = system: import ./apps/pkgs.nix {inherit nixpkgs frappix system;};
  in {
    # the package set of this project, e.g. `nix build .#frappix.erpnext`
    legacyPackages = forAllSystems pkgsFor;

    # repository tasks, e.g. `nix run .#new-site` or `nix run .#run-env`
    packages = forAllSystems (system: frappix.jobs.${system});

    # the development environment, entered via direnv (see .envrc)
    devShells = forAllSystems (system:
      import ./tools/shells.nix {
        inherit frappix system;
        pkgs = pkgsFor system;
      });
  };

  # try to stick with a relesed version for a while
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-24.11";

  inputs.frappix.url = "github:blaggacao/frappix";
}
