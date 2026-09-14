{
  pname = "telephony";
  version = "20260818.095416";
  meta = {
    url = "https://github.com/frappe/telephony/commit/039cf39f245d6818ead03cf94eea6ce7f9c1e1f7";
    description = "Sources for telephony (20260818.095416)";
  };
  src = builtins.fetchTree {
    type = "github";
    owner = "frappe"; repo = "telephony";
    narHash = "sha256-hjYFO+b6qo335/Rdgnqeb5GwvIRTRTCXhe6SH7UVHS0=";
    rev = "039cf39f245d6818ead03cf94eea6ce7f9c1e1f7";
  };
  passthru = builtins.fromJSON ''{}'';
}
