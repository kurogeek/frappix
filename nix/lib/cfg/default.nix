{nixpkgs}: {
  conform = import ./conform.nix {inherit nixpkgs;};
  editorconfig = import ./editorconfig.nix {inherit nixpkgs;};
  mdbook = import ./mdbook.nix {inherit nixpkgs;};
  treefmt = import ./treefmt.nix {inherit nixpkgs;};
  lefthook = import ./lefthook.nix {inherit nixpkgs;};
  cog = import ./cog.nix {inherit nixpkgs;};
}
