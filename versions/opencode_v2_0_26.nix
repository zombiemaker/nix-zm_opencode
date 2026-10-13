{
    pkgs
}:

let
    v2_0_26_machine_code_x86_64_linux_gnu_libc = pkgs.stdenv.mkDerivation {
        name = "zm_codex-machine_code.x86_64.linux.gnu_libc";
        version = "2.0.26";
        
        bin_file = pkgs.fetchurl {
            url = "https://github.com/zombiemaker/nix-zm_opencode/releases/download/v0.1.0/opencode-v2.0.26-x86_64-linux-gnu_libc";
            sha256 = "sha256-2RI7m82wox96uf6YErWKncF2itbZfnsnbf8RgYEyGMk=";
        };

        nativeBuildInputs = [];

        phases = [
            "installPhase"
        ];

        installPhase = ''
            mkdir -p $out/bin
            cp $bin_file $out/bin/opencode
            
        '';
    };


    v2_0_26_shell_x86_64_linux_gnu_libc_gnu_bash = pkgs.mkShell {
        name = "zm_opencode-shell-v2_0_26-gnu_bash";
        buildInputs = [
            pkgs.bashInteractive
        ];

        packages = [
            v2_0_26_machine_code_x86_64_linux_gnu_libc
        ];

        shellHook = ''
        '';
    };

    v0_154_0_shell_x86_64_linux_all_libc_powershell = pkgs.mkShell {
        name = "zm_pixi-shell-v0_154_0-powershell";
        buildInputs = [
            pkgs.bashInteractive
        ];

        packages = [
            pkgs.powershell
            v2_0_26_machine_code_x86_64_linux_gnu_libc
        ];

        shellHook = ''
            exec pwsh -NoLogo -NoExit
        '';
    };


    result = rec {
        machine_code = {
            x86_64 = {
                linux = {
                    gnu_libc = v2_0_26_machine_code_x86_64_linux_gnu_libc;
                };
            };
        };

        shells = {
            x86_64 = {
                linux = {
                    gnu_libc = {
                        gnu_bash = v2_0_26_shell_x86_64_linux_gnu_libc_gnu_bash;
                        powershell = v0_154_0_shell_x86_64_linux_all_libc_powershell;
                    };
                };
            };
        };
    };

in
    result
