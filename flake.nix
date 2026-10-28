{
    description = "ZombieMaker derivation for Opencode";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/26.05";
    };

    outputs = {
        self,
        nixpkgs
    }:

    let
        nixpkgs_runtime_system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${nixpkgs_runtime_system};

        opencode_v2_0_26 = pkgs.callPackage ./versions/opencode_v2_0_26.nix;
        opencode_v2_20_0 = pkgs.callPackage ./versions/opencode_v2_20_0.nix;

    in {
        v2_0_26 = opencode_v2_0_26 {pkgs = pkgs;};
        v2_20_0 = opencode_v2_20_0 {pkgs = pkgs;};

        latest = self.outputs.v2_20_0;
    };
}

