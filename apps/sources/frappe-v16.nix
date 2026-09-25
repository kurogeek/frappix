let
version = "v16.35.0";
in
{
  pname = "frappe-v16";
  inherit version;
  meta = {
    url = "https://github.com/frappe/frappe/releases/tag/${version}";
    description = "Sources for frappe-v16 (${version})";
  };
  src = builtins.fetchTree {
    type = "github";
    owner = "frappe"; repo = "frappe";
    narHash = "sha256-oCDfhjFrkRi6SfMVlDjtlCN06z3+3Auf64LtwP7IvA4=";
    rev = "012667b9c4e7f66d5e1ff5858d2e922331d4300a";
  };
  passthru = builtins.fromJSON ''{"clone": {"since": "version-15", "upstream": {"fetch": ["+refs/heads/develop:refs/remotes/upstream/develop", "+refs/heads/version-16:refs/remotes/upstream/version-16", "+refs/heads/version-16-hotfix:refs/remotes/upstream/version-16-hotfix", "+refs/tags/v16.*:refs/remotes/upstream/tags/v16.*"], "url": "https://github.com/frappe/frappe"}}}'';
}
