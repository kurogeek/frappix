let
version = "v16.36.0";
in
{
  pname = "erpnext-v16";
  inherit version;
  meta = {
    url = "https://github.com/frappe/erpnext/releases/tag/${version}";
    description = "Sources for erpnext-v16 (${version})";
  };
  src = builtins.fetchTree {
    type = "github";
    owner = "frappe"; repo = "erpnext";
    narHash = "sha256-pwFEY3bFE1/yDeSQvW2/jGBZ2EOuEuQg6Mb8OGBM87E=";
    rev = "b30aa5334bcea94dba74f5b866af13c43a861948";
  };
  passthru = builtins.fromJSON ''{"since": "version-15", "upstream": "URL: https://github.com/frappe/erpnext\nPull: +refs/heads/develop:refs/remotes/upstream/develop\nPull: +refs/heads/version-16:refs/remotes/upstream/version-16\nPull: +refs/heads/version-16-hotfix:refs/remotes/upstream/version-16-hotfix\nPull: +refs/tags/v16.*:refs/remotes/upstream/tags/v16.*\n"}'';
}
