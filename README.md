# WIP

## Local development

<!--
```sh
nix flake lock --update-input nicos --override-input nicos ../nicos
```

NB: don't push the new locked file -->

```sh
nix run github:serokell/deploy-rs -- .#fennec.lan --remote-build -- --override-input nicos ../nicos
```

not working:
nix run . --override-input nicos ../nicos -- deploy fennec

(it runs the right CLI locally, but then the CLI doesn't set --override-input when evaluating the flake)
