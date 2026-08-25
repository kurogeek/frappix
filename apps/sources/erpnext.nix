let
version = "v15.119.3";
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
    narHash = "sha256-kkO9h1yZ2+KM+Q6NbNiYqeTNfbae0cOEjARIykH1EFQ=";
    rev = "0526834071315bbbd6b1ae52511c0b4659f17395";
  };
  passthru = builtins.fromJSON ''{"since": "version-14", "upstream": "URL: https://github.com/frappe/erpnext\nPull: +refs/heads/develop:refs/remotes/upstream/develop\nPull: +refs/heads/version-15:refs/remotes/upstream/version-15\nPull: +refs/heads/version-15-hotfix:refs/remotes/upstream/version-15-hotfix\nPull: +refs/tags/v15.*:refs/remotes/upstream/tags/v15.*\n"}'';
}
