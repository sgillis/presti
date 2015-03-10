{ pkgs ? (import <nixpkgs> {}) }:

let inherit (pkgs.haskellPackages)
            elmMake
            elmCompiler
            elmPackage
            elmRepl
            elmReactor;

in pkgs.buildEnv {
    name = "prestiEnv";
    paths = [
        elmMake
        elmCompiler
        elmPackage
        elmRepl
        elmReactor
        pkgs.nix
    ];
}
