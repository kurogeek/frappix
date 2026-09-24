# Installation

To initialize a Frappix project (a more reproducible "bench"), you may use the guided install script with:

> [!IMPORTANT]
>
> `git` must be configured in your system (email / name).

```console
bash <(curl -L https://blaggacao.github.io/frappix/install) frappe myproject
```

This script does two things:

- ensure system dependencies are in place
- guide you through the project setup

> [!TIP]
>
> `frappe`, the first argument to the script represents the template to use.
> For an overview over the available templates, run:
>
> ```shell
> nix flake show github:blaggacao/frappix
> ```
>
> <sub>You'll already need to have <code>nix</code> installed to run this command.</sub>

## System dependencies

The script requires the following tools to be present on your system and
points you to their installation instructions otherwise:

- Nix: _global package manager & language interpreter_
- Direnv: _tool to manage environments per folder_

## Repository tasks

Tasks such as creating a site or launching the environment are regular flake
apps of your project and run from within its direnv environment:

```console
nix run .#new-site
nix run .#run-env
```

For an overview run `nix flake show`.

## Guided Install

It will guide you through the setup process for a Frappix project.

## Enable Extra Repository Tooling

The extra tooling provides:

- Formatter support
- Commit lint support
- Documentation support
- Editorconfig template

To enable it, change the following value in `tools/shells.nix`:

```diff
{
-   bench.enableExtraProjectTools = false;
+   bench.enableExtraProjectTools = true;
}
```
