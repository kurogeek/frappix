{
  pname = "frappe";
  version = "v15.104.0";
  meta = {
    url = "https://github.com/frappe/frappe/releases/tag/v15.104.0";
    description = "Sources for frappe (v15.104.0)";
  };
  src = builtins.fetchTree {
    type = "github";
    owner = "frappe"; repo = "frappe";
    narHash = "sha256-h/B2EBh90Sy+6wZQGnrAAriLujESRiz6AMsN/7bRkhk=";
    rev = "79f10f8769a9a839abaef1f220da2d2eea5eea27";
  };
  passthru = builtins.fromJSON ''{"clone": {"since": "version-14", "upstream": {"fetch": ["+refs/heads/develop:refs/remotes/upstream/develop", "+refs/heads/version-15:refs/remotes/upstream/version-15", "+refs/heads/version-15-hotfix:refs/remotes/upstream/version-15-hotfix", "+refs/tags/v15.*:refs/remotes/upstream/tags/v15.*"], "url": "https://github.com/frappe/frappe"}}}'';
}
