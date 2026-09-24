{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  cfg = import ../cfg {inherit nixpkgs;};
  overrides = {
    cog = import ./cog.nix {inherit nixpkgs;};
    lefthook = import ./lefthook.nix {inherit nixpkgs;};
    treefmt = import ./treefmt.nix {inherit nixpkgs;};
    editorconfig = import ./editorconfig.nix {inherit nixpkgs;};
  };
in
  l.mapAttrs (name: config: l.recursiveUpdate config (overrides.${name} or {})) cfg
