/*
This file holds reproducible shells with commands in them.

They conveniently also generate config files in their startup hook.
*/
{
  nixpkgs,
  system,
  overlays,
  dev,
  cfg,
  # configuration data for the dotfiles rendered by the shells, see ./config.nix
  configData,
}: let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [overlays.tools];
  };
in {
  # Tool Homepage: https://numtide.github.io/devshell/
  default =
    (dev.mkShell {
      name = "Frappix Shell";

      # Tool Homepage: https://nix-community.github.io/nixago/
      # Generates the repository dotfiles from the startup hook when entering the shell.
      nixago = [
        (dev.mkNixago cfg.conform)
        (dev.mkNixago cfg.treefmt configData.treefmt)
        (dev.mkNixago cfg.editorconfig configData.editorconfig)
        (dev.mkNixago cfg.lefthook configData.lefthook)
        (dev.mkNixago cfg.mdbook configData.mdbook)
      ];

      commands = [
        {package = pkgs.nvfetcher;}
        {package = pkgs.nvchecker-nix;}
      ];
    })
    // {meta.description = "Development environment for this repository";};
  book =
    (dev.mkShell {
      name = "Frappix Book Shell";
      nixago = [(dev.mkNixago cfg.mdbook configData.mdbook)];
    })
    // {meta.description = "Book development & rendering environment for this repository";};
}
