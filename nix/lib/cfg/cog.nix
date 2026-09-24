{ nixpkgs }: {
  data = {};
  output = "cog.toml";
  commands = [
    {
      package = nixpkgs.cocogitto;
      name = "cog";
    }
  ];
}
