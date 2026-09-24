{ nixpkgs }: {
  data = {};
  output = "treefmt.toml";
  format = "toml";
  commands = [{package = nixpkgs.treefmt1 or nixpkgs.treefmt;}];
}
