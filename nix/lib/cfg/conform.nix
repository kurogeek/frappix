{nixpkgs}: let
  l = nixpkgs.lib // builtins;
in {
  data = {};
  format = "yaml";
  output = ".conform.yaml";
  packages = [nixpkgs.conform];
  apply = d: {
    policies =
      []
      ++ (l.optional (d ? commit) {
        type = "commit";
        spec = d.commit;
      })
      ++ (l.optional (d ? license) {
        type = "license";
        spec = d.license;
      });
  };
}
