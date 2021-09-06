{ lib, fetchzip }:

let
  version = "v5.0.2";
in fetchzip {
  name = "cica-${version}";

  url = "https://github.com/miiton/Cica/releases/download/${version}/Cica_${version}_with_emoji.zip";

  postFetch = ''
    mkdir -p $out/share/fonts
    unzip -j $downloadedFile \*.ttf -d $out/share/fonts/cica
  '';

  sha256 = "0zh1n5x1swgh72pyzgkvajs9r4xn172v6shl7978gjbh9xlqb8a2";

  meta = with lib; {
    description = "Programming Font";
    longDescription = ''
    '';
    homepage = "";

    license = licenses.free;
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.all;
  };
}
