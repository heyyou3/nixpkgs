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

  sha256 = "0a1vp6v18yj5lspxk4n7l1r6ipabmpdwgjflg9alhs3gdwbg952c";

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
