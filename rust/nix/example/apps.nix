# A common `std` idiom is to place all buildables for a cell in a `apps.nix`
# cell block. This is not required, and you can name this cell block anything
# that makes sense for your project.
#
# This cell block is used to define how our example application is built.
# Ultimately, this means it produces a nix derivation that, when evalulated,
# produces our binary.

# The function arguments shown here are universal to all cell blocks. We are
# provided with the inputs from our flake and a `cell` attribute which refers
# to the parent cell this block falls under. Note that the inputs are
# "desystematized" and are not in the same format as the `inputs` attribute in
# the flake. This is a key benefit afforded by `std`.
{ inputs
, cell
}:
let
  # The `inputs` attribute allows us to access all of our flake inputs.
  inherit (inputs) nixpkgs std;

  # This is a common idiom for combining lib with builtins.
  l = nixpkgs.lib // builtins;
in
{
  # We can think of this attribute set as what would normally be contained under
  # `outputs.packages` in our flake.nix. In this case, we're defining a default
  # package which contains a derivation for building our binary.
  default = with inputs.nixpkgs; rustPlatform.buildRustPackage {
    pname = "example";
    version = "0.1.0";

    # `std` includes some useful helper functions, one of which is `incl` which
    # handles filtering out unwanted files from our package src. The benefit
    # here is it reduces unecessary builds by limiting the input files of our
    # derivation to only those that are needed to build it.
    src = std.incl (inputs.self) [
      (inputs.self + /Cargo.toml)
      (inputs.self + /Cargo.lock)
      (inputs.self + /src)
    ];
    cargoLock = {
      lockFile = inputs.self + "/Cargo.lock";
    };

    meta = {
      description = "An example Rust binary which greets the user";
    };
  };
}
