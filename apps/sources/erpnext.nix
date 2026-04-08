{
  pname = "erpnext";
  version = "v15.104.0";
  meta = {
    url = "https://github.com/frappe/erpnext/releases/tag/v15.104.0";
    description = "Sources for erpnext (v15.105.0)";
  };
  src = builtins.fetchTree {
    type = "github";
    owner = "frappe"; repo = "erpnext";
    narHash = "sha256-JYuyeoV7bbMj+oS9cyXsmBOuwHsXGqaHrHTN9l+1u3E=";
    rev = "a2626ed55f437f69b99a29cfb0b9ead219f59458";
  };
  passthru = builtins.fromJSON ''{"since": "version-14", "upstream": "URL: https://github.com/frappe/erpnext\nPull: +refs/heads/develop:refs/remotes/upstream/develop\nPull: +refs/heads/version-15:refs/remotes/upstream/version-15\nPull: +refs/heads/version-15-hotfix:refs/remotes/upstream/version-15-hotfix\nPull: +refs/tags/v15.*:refs/remotes/upstream/tags/v15.*\n"}'';
}
