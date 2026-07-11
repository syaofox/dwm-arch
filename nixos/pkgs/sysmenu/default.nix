{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  xorg,
}:

stdenv.mkDerivation {
  pname = "sysmenu";
  version = "unstable-2026-07-10";

  src = fetchFromGitHub {
    owner = "syaofox";
    repo = "sysmenu";
    rev = "main";
    hash = lib.fakeHash;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = with xorg; [ libX11 libXft libXinerama libXrandr ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp sysmenu $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/syaofox/sysmenu";
    description = "Custom system menu for DWM";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "sysmenu";
  };
}
