{
  nixpkgs,
  frappix,
  system,
}: let
  _pins = import ./_pins.nix {inherit (nixpkgs) lib;};

  inject = final: prev: {
    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (pyFinal: pyPrev: {
          # extend the python package set with yet-unpackaged or
          # more up-to-date python dependencies
        })
      ];
    # extend the frappix package set
    frappix = prev.frappix.overrideScope (finalFrappix: prevFrappix: {
      # inject your pinned sources (if any) into the frappix build pipeline
      appSources = prevFrappix.appSources.overrideScope (_: _: _pins);
      # add custom apps that are not yet packaged by frappix
      # my-app = finalFrappix.callPackage ./my-app.nix {};
    });
  };
in
  import nixpkgs {
    # wkhtmltopdf
    config.permittedInsecurePackages = ["openssl-1.1.1w"];
    config.allowUnfree = true;

    inherit system;

    overlays = [
      frappix.libsOverlay.${system}
      frappix.toolsOverlay.${system}
      frappix.pythonOverlay.${system}
      frappix.frappeOverlay.${system}
      inject
    ];
  }
