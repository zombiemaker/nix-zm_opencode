# Nix Flake For OpenCode CLI

This Nix Flake uses a non-conventional Nix attribute path.

## Nix Attibute Path
- v2_0_26
  - machine_code
    - x86_64
      - linux_nixos
        - gnu_libc
      - linux
        - gnu_libc
  - shells
    - x86_64
      - linux_os
        - gnu_libc
          - gnu_bash
          - powershell
      - linux
        - gnu_libc
          - gnu_bash
          - powershell
- latest (points to v2_0_26)

## To Use In A Nix Flake Shell Environment
The Flake is defined only for the following environments
- Machine Processor ISA Families
  - x86_64
- Machine OS Families
  - linux_nixos
  - linux
- Linux libc ABI Families
  - gnu_libc
- Shell Families
  - gnu_bash
  - powershell

### Example flake.nix File To Use Either NixOS-Native ELF & Traditional & nix-ld Shimmed NixOS ELF Environments
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
    zm_opencode = zm_opencode_repo.v2_0_26; # Set the version you want to use ("latest" is the most current version)

  in {
    latest = {
      shells = {
        x86_64 = {
          linux_nixos = {
            gnu_libc = {
              gnu_bash = pkgs.mkShell {
                name = "opencode-gnu_bash";

                buildInputs = [
                  pkgs.bashInteractive
                ];

                packages = [
                  zm_opencode.machine_code.x86_64.linux_nixos.gnu_libc
                ];
              };

              powershell = pkgs.mkShell {
                name = "opencode-powershell";

                buildInputs = [
                  pkgs.bashInteractive
                ];

                packages = [
                  pkgs.powershell
                  zm_opencode.machine_code.x86_64.linux_nixos.gnu_libc
                ];
              };
            };
          };

          linux = {
            gnu_libc = {
              gnu_bash = pkgs.mkShell {
                name = "opencode-gnu_bash";

                buildInputs = [
                  pkgs.bashInteractive
                ];

                packages = [
                  zm_opencode.machine_code.x86_64.linux.gnu_libc
                ];
              };

              powershell = pkgs.mkShell {
                name = "opencode-powershell";

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



## For NixOS-Native Linux ELF Environments
### Instantiate Nix Shell
```bash
nix develop .#latest.shells.x86_64.linux_nixos.gnu_libc.gnu_bash

which opencode
/nix/store/wm64855iqw41aqn9qk1slqg1jwq5mw2j-zm_opencode-machine_code.x86_64.linux_nixos.gnu_libc/bin/opencode

opencode --version
opencode v2.0.26

opencode serve
server listening on http://127.0.0.1:4096
server password Toe9IMHetRp5f5ELmwygz8ruLaWJsUL-m-2rtGRDphA
```

### View ELF File Info
```bash
file $(which opencode)
/nix/store/wm64855iqw41aqn9qk1slqg1jwq5mw2j-zm_opencode-machine_code.x86_64.linux_nixos.gnu_libc/bin/opencode: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /nix/store/57iz36553175g3178pvxjij8z5rcsd4n-glibc-2.42-61/lib/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=5afca2666bfab8605a934f1b6231dacae0518a5f, not stripped


readelf -d $(which opencode)

Dynamic section at offset 0x2a8 contains 32 entries:
  Tag        Type                         Name/Value
 0x000000000000001d (RUNPATH)            Library runpath: [/nix/store/57iz36553175g3178pvxjij8z5rcsd4n-glibc-2.42-61/lib]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [ld-linux-x86-64.so.2]
 0x0000000000000001 (NEEDED)             Shared library: [libpthread.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libdl.so.2]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000015 (DEBUG)              0x0
 0x0000000000000007 (RELA)               0x210058
 0x0000000000000008 (RELASZ)             1368 (bytes)
 ...
```

## For Traditional Linux ELF Environments & nix-ld Shimmed NixOS Linux ELF Environments
### Example flake.nix File
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
    zm_opencode = zm_opencode_repo.v2_0_26; # Set the version you want to use ("latest" is the most current version)

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


### Instantiate Nix Shell
```bash
nix develop .#latest.shells.x86_64.linux.gnu_libc

which opencode
/nix/store/f7a3y2ry3769ihs5bpyi7kpm8vw6swc7-zm_opencode-machine_code.x86_64.linux.gnu_libc/bin/opencode

opencode --version
opencode v2.0.26

opencode serve
server listening on http://127.0.0.1:4096
server password 6WHwsueAplfZdCqNYY0SWXTJ60wgGNE1zNHMemPBkTs
```

### View ELF File Info
```bash
file $(which opencode)
/nix/store/f7a3y2ry3769ihs5bpyi7kpm8vw6swc7-zm_opencode-machine_code.x86_64.linux.gnu_libc/bin/opencode: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=5afca2666bfab8605a934f1b6231dacae0518a5f, not stripped


readelf -d $(which opencode)

Dynamic section at offset 0x4bc4000 contains 31 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [ld-linux-x86-64.so.2]
 0x0000000000000001 (NEEDED)             Shared library: [libpthread.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libdl.so.2]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000015 (DEBUG)              0x0
 0x0000000000000007 (RELA)               0x210058
 0x0000000000000008 (RELASZ)             1368 (bytes)
 ...
```


## Licenses
The license for this code repository is [[LICENSE.md]].  Please review the licenses for the binary files (i.e. OpenCode) that this Nix Flake patches for NixOS and packages. 