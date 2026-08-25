let
version = "v15.118";
in
{
  pname = "frappe";
  inherit version;
  meta = {
    url = "https://github.com/frappe/frappe/releases/tag/${version}";
    description = "Sources for frappe (${version})";
  };
  src = builtins.fetchTree {
    type = "github";
    owner = "frappe"; repo = "frappe";
    narHash = "sha256-VcZM09M20wO0EXRNOHcv1O1A1A1niMXSOyw/xtdA6lI=";
    rev = "9b8d265b27a1dfb11c7aef21a533a127e14a0a5a";
  };
  passthru = builtins.fromJSON ''{"clone": {"since": "version-14", "upstream": {"fetch": ["+refs/heads/develop:refs/remotes/upstream/develop", "+refs/heads/version-15:refs/remotes/upstream/version-15", "+refs/heads/version-15-hotfix:refs/remotes/upstream/version-15-hotfix", "+refs/tags/v15.*:refs/remotes/upstream/tags/v15.*"], "url": "https://github.com/frappe/frappe"}}}'';
}
