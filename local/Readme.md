# Hacking on Frappix

Frappix' `./local` cell contrains the full specification of the local contribution environment.

Prerequisites:

- Nix: _orchestrate the environment_
- Direnv: _enable the environment when entering the folder_

With both installed, `direnv allow` in the repository root drops you into the
contribution environment (see `.envrc`), which brings formatter, commit lint,
editorconfig and mdbook tooling via `nixago`.
