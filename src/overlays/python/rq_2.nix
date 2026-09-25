{
  rq,
  fetchFromGitHub,
}:
# frappe v16 pins rq==2.6.1 and imports rq internals (e.g. rq.worker.StopRequested)
# that were dropped in later 2.x releases
rq.overridePythonAttrs (old: rec {
  version = "2.6.1";
  src = fetchFromGitHub {
    owner = "rq";
    repo = "rq";
    tag = "v${version}";
    hash = "sha256-4+zP3pOiZ+r/dt9F2NyxgJsyGPIHgj9XokuPxlWyS1g=";
  };
  # 2.6.1's test-suite predates python 3.14 (`cannot pickle '_thread.RLock'`)
  doCheck = false;
})
