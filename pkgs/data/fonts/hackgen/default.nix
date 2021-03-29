{ lib, fetchzip }:

let
  version = "v2.3.1";
in fetchzip {
  name = "hackgen-${version}";

  url = "https://github.com/yuru7/HackGen/releases/download/${version}/HackGenNerd_${version}.zip";

  postFetch = ''
    mkdir -p $out/share/fonts
    unzip -j $downloadedFile \*.ttf -d $out/share/fonts/hackgen
  '';

  sha256 = "05l0g8qahhzfr9lxankw93pfqgiyqlki1wy39jrhpp9y317g1391";

  meta = with lib; {
    description = "A typeface designed for source code";
    longDescription = ''
    '';
    homepage = "";

    license = licenses.free;
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.all;
  };
}
