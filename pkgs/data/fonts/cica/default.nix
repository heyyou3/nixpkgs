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

  sha256 = "0a1vp6v18yj5lspxk4n7l1r6ipabmpdwgjflg9alhs3gdwbg952c";

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
