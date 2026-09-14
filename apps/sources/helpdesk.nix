{
  pname = "helpdesk";
  version = "v1.30.1";
  meta = {
    url = "https://github.com/frappe/helpdesk/releases/tag/v1.30.1";
    description = "Sources for helpdesk (v1.30.1)";
  };
  src = builtins.fetchTree {
    type = "github";
    owner = "frappe"; repo = "helpdesk";
    narHash = "sha256-0WCH98QkquGh91ejYpYkvLH0M0drGm9+TXL0oYgv79s=";
    rev = "1c3361cc0019deec6f84035a9352270b4e4eb5cb";
  };
  passthru = builtins.fromJSON ''{}'';
}
