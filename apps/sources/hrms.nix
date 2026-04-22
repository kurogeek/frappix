rec {
  pname = "hrms";
  version = "v15.58.8";
  meta = {
    url = "https://github.com/frappe/hrms/releases/tag/v15.58.8";
    description = "Sources for hrms (v15.58.8)";
  };
  src = builtins.fetchTree {
    type = "git";
    url = "https://github.com/frappe/hrms.git"; submodules = true; allRefs = true;
    narHash = "sha256-EQE8BxgAbOVWjVV9OsF3RE/9NWt+FZdlqjkAT8ZVPL0=";
    rev = "e620b9af9c995eb796b2fce8873a5b252bd079b9";
  };
  passthru = builtins.fromJSON ''{}'';
}
