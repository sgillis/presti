with import <nixpkgs> {};

myEnvFun {
    name = "presti";
    buildInputs = [
        haskellPackages.elmMake
        haskellPackages.elmCompiler
        haskellPackages.elmPackage
        haskellPackages.elmRepl
        haskellPackages.elmReactor
    ];
}
