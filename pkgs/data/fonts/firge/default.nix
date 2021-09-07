{ lib, fetchzip }:

let
  version = "v0.1.0";
in fetchzip {
  name = "firge-${version}";

  url = "https://github.com/yuru7/Firge/releases/download/${version}/FirgeNerd_${version}.zip";

  postFetch = ''
    mkdir -p $out/share/fonts
    unzip -j $downloadedFile \*.ttf -d $out/share/fonts/firge
  '';

  sha256 = "0x8vqs125dsbnxggc577j82v06nxrij9i7prpaipqw7byar107di";

  meta = with lib; {
    description = "Fira Mono と源真ゴシックを合成したプログラミングフォントです。";
    longDescription = ''
    '';
    homepage = "https://github.com/yuru7/Firge";

    license = licenses.free;
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.all;
  };
}
