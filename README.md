# WIP

## Local development

<!--
```sh
nix flake lock --update-input nicos --override-input nicos ../nicos
```

NB: don't push the new locked file -->

```sh
nix run github:serokell/deploy-rs -- .#fennec.lan --remote-build -- --override-input nicos ../nicos


NICOS_FLAKE=../nicos ../nicos/packages/cli/cli.py install bastion
```

```sh
darwin-rebuild --flake . --override-input nicos ../nicos switch
not working:
nix run . --override-input nicos ../nicos -- deploy fennec
```

From scratch (darwin-nix not installed):
nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake . --override-input nicos ../nicos

