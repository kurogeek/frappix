let
version = "v15.113.3";
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
    narHash = "sha256-nmhd3QJ0G3MeHs/GrdxNuY4GzNS18FTcM1LMaqnpSwA=";
    rev = "9efaadee08453fbee4ddf7bd7018d271d9f79bcf";
  };
  passthru = builtins.fromJSON ''{"clone": {"since": "version-14", "upstream": {"fetch": ["+refs/heads/develop:refs/remotes/upstream/develop", "+refs/heads/version-15:refs/remotes/upstream/version-15", "+refs/heads/version-15-hotfix:refs/remotes/upstream/version-15-hotfix", "+refs/tags/v15.*:refs/remotes/upstream/tags/v15.*"], "url": "https://github.com/frappe/frappe"}}}'';
}
