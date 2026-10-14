{
    pkgs
}:

let
    v2_0_26_machine_code_x86_64_linux_gnu_libc = pkgs.stdenv.mkDerivation {
        name = "zm_opencode-machine_code.x86_64.linux.gnu_libc";
        version = "2.0.26";
        
        bin_file = pkgs.fetchurl {
            url = "https://github.com/zombiemaker/nix-zm_opencode/releases/download/v0.1.0/opencode-v2.0.26-x86_64-linux-gnu_libc";
            sha256 = "sha256-2RI7m82wox96uf6YErWKncF2itbZfnsnbf8RgYEyGMk=";
        };

        nativeBuildInputs = [
            # pkgs.autoPatchelfHook # Use this to automatically patch ELF headers
        ];

        buildInputs = [
            pkgs.coreutils
            pkgs.patchelf
            pkgs.glibc
            pkgs.zlib
            pkgs.stdenv.cc.cc.lib # Useful if your binary needs libstdc++.so
        ];

        phases = [
            "installPhase"
            "postFixup"
        ];

        installPhase = ''
            TARGET_BIN="$out/bin/opencode"

            mkdir -p $out/bin
            cp $bin_file $TARGET_BIN
            chmod +x $TARGET_BIN
        '';
        
        postFixup = ''
            # Add write permission to patch ELF file
            chmod +w $TARGET_BIN

            # Read the Nix store paths into the array
            mapfile -t TARGET_BIN_NIX_PATHS < <(ldd "$TARGET_BIN" 2>/dev/null | \
                grep -o '/nix/store/[^/]*' | \
                sort -u)

            # Append "/lib" to each path to make them valid RPATH directories
            TARGET_BIN_NIX_LIB_PATHS=( "''${TARGET_BIN_NIX_PATHS[@]/%//lib}" )

            # Join the array items with colons inside a local subshell block
            TARGET_BIN_NIX_LIB_PATHS_STRING=$(IFS=:; echo "''${TARGET_BIN_NIX_LIB_PATHS[*]}")

            # This grabs every '-L/nix/store/...' flag and turns it into a colon-separated list
            NIX_LDFLAGS_NIX_LIB_PATHS_STRING=$(echo ''${NIX_LDFLAGS} | tr ' ' '\n' | grep '^-L' | sed 's/-L//' | tr '\n' ':' | sed 's/:$//')


            # Patching ELF headers to run natively on Nix
            patchelf \
                --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                --set-rpath "''${TARGET_BIN_NIX_LIB_PATHS_STRING}:''${NIX_LDFLAGS_NIX_LIB_PATHS_STRING}" \
                "''${TARGET_BIN}"

            # De-dup path entries
            patchelf --shrink-rpath "''${TARGET_BIN}"

            # Remove write permission
            chmod -w $TARGET_BIN
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

    v2_0_26_shell_x86_64_linux_gnu_libc_powershell = pkgs.mkShell {
        name = "zm_pixi-shell-v2_0_26-powershell";
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
                        powershell = v2_0_26_shell_x86_64_linux_gnu_libc_powershell;
                    };
                };
            };
        };
    };

in
    result
