{ lib, stdenv, fetchurl, appimageTools, appimage-run, ... }:
stdenv.mkDerivation rec {
  pname = "logseq";
  # Modify the version and the sha256 hash to update
  version = "0.8.12";

  src = fetchurl {
    url = "https://github.com/logseq/logseq/releases/download/${version}/logseq-linux-x64-${version}.AppImage";
    sha256 = "sha256-I1jGPNGlZ53N3ZlN9nN/GSgQIfdoUeclyuMl+PpNVY4=";
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extract {
    inherit pname src version;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;


  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${pname} $out/share/applications $out/share/${pname}/resources/app/icons
    cp -a ${appimageContents}/resources/app/icons/logseq.png $out/share/${pname}/resources/app/icons/logseq.png
    cp -a ${appimageContents}/Logseq.desktop $out/share/applications/${pname}.desktop

    # Make the desktop entry run the app using appimage-run
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace Exec=Logseq "" \
      --replace Icon=Logseq Icon=$out/share/${pname}/resources/app/icons/logseq.png
    echo 'Exec=${appimage-run}/bin/appimage-run ${src}' >> $out/share/applications/${pname}.desktop

    runHook postInstall
  '';

  meta = with lib; {
    description = "A local-first, non-linear, outliner notebook for organizing and sharing your personal knowledge base";
    homepage = "https://github.com/logseq/logseq";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ weihua ];
    platforms = [ "x86_64-linux" ];
  };
}
