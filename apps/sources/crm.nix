{
  pname = "crm";
  version = "v1.71.0";
  meta = {
    url = "https://github.com/frappe/crm/releases/tag/v1.71.0";
    description = "Sources for crm (v1.71.0)";
  };
  src = builtins.fetchTree {
    type = "git";
    url = "https://github.com/frappe/crm.git"; submodules = true; allRefs = true;
    narHash = "sha256-3nWYvFqoGzArxHn0ydZYRgXDbquLH0Pk+t6kUKpikLQ=";
    rev = "20e87b3f899bfcedaaf326bef7869cdd890bb956";
  };
  passthru = builtins.fromJSON ''{}'';
}
