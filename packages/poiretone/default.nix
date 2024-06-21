{stdenv, ...}:
stdenv.mkDerivation rec {
  pname = "poiretone";
  version = "1.0";

  src = ./PoiretOne-Regular.ttf;
  dontUnpack = true;

  installPhase = ''
    install -D -m 0644 $src $out/share/fonts/truetype/PoiretOne-Regular.ttf
  '';
}
