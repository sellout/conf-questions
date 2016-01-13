let pkgs = (import <nixpkgs> {});
    haskellPackages = pkgs.recurseIntoAttrs(pkgs.haskellPackages.override {
      overrides = self: super:
      let callPackage = self.callPackage; in {
        thisPackage = callPackage (import ./default.nix) {};
      };
    }); in haskellPackages.thisPackage.env
