{
  nixpkgs,
  system,
  overlays,
}:
import nixpkgs {
  # wkhtmltopdf
  config.permittedInsecurePackages = ["openssl-1.1.1w"];
  config.allowUnfree = true;

  inherit system;

  overlays = [
    overlays.libs
    overlays.tools
    overlays.python
    overlays.frappe
  ];
}
