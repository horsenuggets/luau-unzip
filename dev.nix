{ pkgs ? import <nixpkgs> { } }:

let
  # Keep the Debian builds used by the output-comparison tests, even after mirrors
  # remove those versions from their rolling package pools.
  buildDerivation = name: version: snapshot: sha256: library:
    pkgs.stdenv.mkDerivation {
      name = "${name}-${version}";
      src = pkgs.fetchurl {
        url = "https://snapshot.debian.org/archive/debian/${snapshot}/pool/main/${builtins.substring 0 1 name}/${name}/${name}_${version}_amd64.deb";
        inherit sha256;
      };
      nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.binutils ];
      buildInputs = [ library ];
      dontStrip = true;
      unpackPhase = ''
        runHook preUnpack
        ar x "$src"
        tar -xf data.tar.xz
        runHook postUnpack
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p "$out/bin"
        cp -a usr/bin/. "$out/bin/"
        runHook postInstall
      '';
    };

  fromGithubRelease = { name, exeName, version, sha256, url ? null, artifactName ? null }:
    pkgs.stdenv.mkDerivation {
      name = "${exeName}-${version}";
      src =
        if url != null then
          pkgs.fetchzip
            {
              url = url;
              sha256 = sha256;
            }
        else if artifactName != null then
          pkgs.fetchzip
            {
              url = "https://github.com/${name}/releases/download/${version}/${artifactName}";
              sha256 = sha256;
            }
        else
          throw "Either artifactName or url must be supplied";

      nativeBuildInputs = [ pkgs.autoPatchelfHook ];
      buildInputs = [ pkgs.dbus pkgs.openssl pkgs.stdenv.cc.cc.lib pkgs.zlib ];

      installPhase = ''
        ls -lah
        mkdir -p $out/bin
        mv ${exeName} $out/bin/
      '';
    };

  fromReleaseArchive = { name, exeName, version, artifactName, sha256 }:
    pkgs.stdenv.mkDerivation {
      name = "${exeName}-${version}";
      src = pkgs.fetchurl {
        url = "https://github.com/${name}/releases/download/${version}/${artifactName}";
        inherit sha256;
      };
      nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.unzip ];
      buildInputs = [ pkgs.stdenv.cc.cc.lib ];
      sourceRoot = ".";
      dontStrip = true;
      installPhase = ''
        runHook preInstall
        install -Dm755 ${exeName} "$out/bin/${exeName}"
        runHook postInstall
      '';
    };

in
pkgs.mkShell {
  buildInputs = [
    # General devtools and test requirements
    pkgs.curl
    pkgs.git
    (buildDerivation "unzip" "6.0-29" "20250311T215724Z" "YY30d9W3BOQ3z45mBtA68pGtCzPc+5ZNQI940weTOpU=" pkgs.bzip2)
    (buildDerivation "zip" "3.0-15" "20250426T024229Z" "e/y9Af0ZyPdFMzVh/AbEra2fS0FtRfhoXNgfsYf1Wcs=" pkgs.bzip2)

    # Luau tooling
    (fromGithubRelease {
      name = "lune-org/lune";
      exeName = "lune";
      version = "v0.10.2";
      artifactName = "lune-0.10.2-linux-x86_64.zip";
      sha256 = "8U1qktadMqgLtz2aKFCkOSMn4CrOhxaJWOZaBuaoQvA=";
    })
    (fromGithubRelease {
      name = "pesde-pkg/pesde";
      exeName = "pesde";
      version = "v0.7.1+registry.0.2.3";
      artifactName = "pesde-0.7.1-linux-x86_64.zip";
      sha256 = "Df1tyq0cDt6dvU7usPdOVwcaY6yNF7ths/TGhhq2X24=";
    })
    (fromGithubRelease {
      name = "evaera/moonwave";
      exeName = "moonwave-extractor";
      version = "v1.3.0";
      artifactName = "moonwave-extractor-v1.3.0-linux.zip";
      sha256 = "RMFdmEat+F/4WdLtcl/d8r1D6eRp8xsk05zEmMiYi2M=";
    })
    (fromReleaseArchive {
      name = "horsenuggets/luau-lsp";
      exeName = "luau-lsp";
      version = "1.70.1-horse.2.0";
      artifactName = "luau-lsp-linux-x86_64.zip";
      sha256 = "259b0271e79b78fe12804c176398439c8b7fee2d42874f61d37aee888b4de638";
    })
    (fromReleaseArchive {
      name = "horsenuggets/styluau";
      exeName = "styluau";
      version = "2.6.0-horse.1.0";
      artifactName = "styluau-linux-x86_64.zip";
      sha256 = "534fd84923fd9e39adbb61be494ed632d42f8bdf6d2cf3f9edaa19bf37cfaafb";
    })
  ];

  shellHook = ''
    # Add pesde bins dir to path
    export PATH="$PATH:$HOME/.pesde/bin"
  '';
}

