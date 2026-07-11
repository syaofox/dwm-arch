{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  xorg,
  imlib2,
}:

stdenv.mkDerivation {
  pname = "wallpick";
  version = "unstable-2026-07-10";

  src = fetchFromGitHub {
    owner = "syaofox";
    repo = "wallpick";
    rev = "main";
    hash = lib.fakeHash;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = with xorg; [ libX11 libXft libXinerama libXrandr imlib2 ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp wallpick $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/syaofox/wallpick";
    description = "Custom wallpaper picker for DWM";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "wallpick";
  };
}
