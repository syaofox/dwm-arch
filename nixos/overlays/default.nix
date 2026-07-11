self: super: {
  dwm = super.dwm.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "syaofox";
      repo = "dwm";
      rev = "main";
      hash = super.lib.fakeHash;
    };
    version = "unstable-2026-07-10";
  });

  slstatus = super.slstatus.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "syaofox";
      repo = "slstatus";
      rev = "main";
      hash = super.lib.fakeHash;
    };
    version = "unstable-2026-07-10";
  });

  slock = super.slock.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "syaofox";
      repo = "slock";
      rev = "main";
      hash = super.lib.fakeHash;
    };
    version = "unstable-2026-07-10";
  });

  wallpick = super.callPackage ../pkgs/wallpick { };
  sysmenu = super.callPackage ../pkgs/sysmenu { };
  generate-app-themes = super.callPackage ../pkgs/generate-app-themes { };
}
