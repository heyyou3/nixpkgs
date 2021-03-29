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

  sha256 = "1xqzk7k9kjnjvrr8c1ndgn6121l784lzk4z5g7hvxgl232sfxvf4";

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
