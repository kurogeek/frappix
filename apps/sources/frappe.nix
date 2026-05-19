{
  pname = "frappe";
  version = "v15.107.5";
  meta = {
    url = "https://github.com/frappe/frappe/releases/tag/v15.107.5";
    description = "Sources for frappe (v15.107.5)";
  };
  src = builtins.fetchTree {
    type = "github";
    owner = "frappe"; repo = "frappe";
    narHash = "sha256-DqKULmL1iobcjgQAjblzjhrt6vdHgZIVKXfGK8/gAFY=";
    rev = "ca70cb3c2e7a82d17776d6e1bba4ea2c3521d169";
  };
  passthru = builtins.fromJSON ''{"clone": {"since": "version-14", "upstream": {"fetch": ["+refs/heads/develop:refs/remotes/upstream/develop", "+refs/heads/version-15:refs/remotes/upstream/version-15", "+refs/heads/version-15-hotfix:refs/remotes/upstream/version-15-hotfix", "+refs/tags/v15.*:refs/remotes/upstream/tags/v15.*"], "url": "https://github.com/frappe/frappe"}}}'';
}
