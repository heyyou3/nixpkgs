{ stdenv, fetchzip }:

let
  version = "v2.3.1";
in fetchzip {
  name = "hackgen-${version}";

  url = "https://github.com/yuru7/HackGen/releases/download/${version}/HackGenNerd_${version}.zip";

  postFetch = ''
    mkdir -p $out/share/fonts
    unzip -j $downloadedFile \*.ttf -d $out/share/fonts/truetype
  '';

  sha256 = "c4edeeb41882bebee179e593f929418706118c7dcd068672ded2ca99e6991ff7";

  meta = with stdenv.lib {
    description = "programming font";
  };
}
