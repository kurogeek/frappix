let
version = "v15.115.0";
in
{
  pname = "erpnext";
  inherit version;
  meta = {
    url = "https://github.com/frappe/erpnext/releases/tag/${version}";
    description = "Sources for erpnext (${version})";
  };
  src = builtins.fetchTree {
    type = "github";
    owner = "frappe"; repo = "erpnext";
    narHash = "sha256-f8aYUsG+XNvRmqT9QnjKeG1yF9ntgkAf/VaD+xHooro=";
    rev = "b5f784612d5b7969b72848dda5b22f10d3a8f764";
  };
  passthru = builtins.fromJSON ''{"since": "version-14", "upstream": "URL: https://github.com/frappe/erpnext\nPull: +refs/heads/develop:refs/remotes/upstream/develop\nPull: +refs/heads/version-15:refs/remotes/upstream/version-15\nPull: +refs/heads/version-15-hotfix:refs/remotes/upstream/version-15-hotfix\nPull: +refs/tags/v15.*:refs/remotes/upstream/tags/v15.*\n"}'';
}
