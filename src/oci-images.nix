{
  nixpkgs,
  pkgs,
  oci,
}: let
  inherit (nixpkgs) lib;

  evaled = lib.evalModules {
    modules = [
      {_module.args = {inherit pkgs;};}
      oci.frappix
      oci.testrig
    ];
  };
in {
  frappix-base = evaled.config.oci.frappix.image;
}
