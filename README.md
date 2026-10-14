# Nix Flake For OpenCode CLI

This Nix Flake uses a non-conventional Nix attribute path.

## Nix Attibute Path
- v2_0_26
  - machine_code
    - x86_64
      - linux
        - gnu_libc
  - shells
    - x86_64
      - linux
        - gnu_libc
          - gnu_bash
          - powershell
- latest

## To Use In A Nix Flake Shell Environment
The Flake is defined only for the following environments
- Machine Processors
    - x86_64
- Machine OS
    - linux
- Linux libc ABI
    - gnu_libc


flake.nix file
```nix
{
  description = "Your Awesome Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/26.05";
    zm_opencode_repo.url = "github:zombiemaker/nix-zm_opencode";
  };

  outputs = {
    self,
    nixpkgs,
    zm_opencode_repo
  }:

  let
    nixpkgs_runtime_system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${nixpkgs_runtime_system};
    zm_opencode = zm_opencode_repo.v0_154_0; # Set the version you want to use ("latest" is the most current version)

  in {
    latest = {
      shells = {
        x86_64 = {
          linux = {
            gnu_libc = {
              gnu_bash = pkgs.mkShell {
                name = "gnu_bash_opencode";

                buildInputs = [
                  pkgs.bashInteractive
                ];

                packages = [
                  zm_opencode.machine_code.x86_64.linux.gnu_libc
                ];
              };

              pwsh = pkgs.mkShell {
                name = "pwsh_opencode";

                buildInputs = [
                  pkgs.bashInteractive
                ];

                packages = [
                  pkgs.powershell
                  zm_opencode.machine_code.x86_64.linux.gnu_libc
                ];
              };
            };
          };
        };
      };
    };
  };
}

```

## Instantiate Nix Shell
```bash
nix develop .#latest.shells.x86_64.linux.gnu_libc
```

## Licenses
The license for this code repository is [[LICENSE.md]].  Please review the licenses for the binary files (i.e. OpenCode) that this Nix Flake patches for NixOS and packages. 