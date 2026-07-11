{
  name = "tokyonight";

  colors = {
    black   = "#404768";
    red     = "#f7768e";
    green   = "#9ece6a";
    yellow  = "#e0af68";
    blue    = "#7aa2f7";
    magenta = "#bb9af7";
    cyan    = "#7dcfff";
    white   = "#c0caf5";
    comment = "#565f89";

    bg     = "#1a1b26";
    fg     = "#e5e8f7";
    border = "#25293a";
    selBg  = "#191a20";

    whiter        = "#FFFFFF";
    magentaLight  = "#af9afc";
    magentaDark   = "#8971b4";

    gtkWinBg      = "#1a1b26";
    gtkWinFg      = "#c0caf5";
    gtkSurfaceBg  = "#25293a";
    gtkSurfaceFg  = "#c0caf5";
    gtkAccentBg   = "#bb9af7";
    gtkAccentFg   = "#1a1b26";
    gtkErrorBg    = "#f2b8b5";
    gtkErrorFg    = "#601410";
    gtkSuccessBg  = "#9ece6a";
    gtkSuccessFg  = "#1a1b26";
    gtkWarningBg  = "#e0af68";
    gtkWarningFg  = "#1a1b26";

    gtkWinBgLight     = "#f2f4fa";
    gtkWinFgLight     = "#1a1b26";
    gtkSurfaceBgLight = "#f2f4fa";
    gtkSurfaceFgLight = "#1a1b26";
    gtkAccentBgLight  = "#bb9af7";
    gtkAccentFgLight  = "#f2f4fa";
  };

  theme = {
    gtkTheme     = "Mint-Y-Purple";
    gtkIcon      = "Mint-Y-Purple";
    gtkFont      = "Noto Sans 11";
    lightdmTheme = "Mint-Y-Dark-Purple";
    lightdmIcon  = "Mint-Y-Purple";
    darkTheme    = false;
    yaziDark     = "tokyo-night";
    yaziLight    = "tokyo-night";
    nvimTheme    = "tokyonight";
  };

  dwm = {
    normFg      = "black";
    normBg      = "bg";
    normBorder  = "border";
    selFg       = "cyan";
    selBg       = "selBg";
    selBorder   = "magenta";
    occFg       = "fg";
    occBg       = "bg";
    occBorder   = "border";
    seloccFg    = "cyan";
    seloccBg    = "selBg";
    seloccBorder = "magenta";
    statusFg    = "white";
    statusBg    = "bg";
    statusBorder = "bg";
    titleFg     = "fg";
    titleBg     = "bg";
    titleBorder = "black";
    titleselFg  = "fg";
    titleselBg  = "bg";
    titleselBorder = "bg";
    tagunderline = "magentaLight";
    tagunderlineEnable = 1;
    tagiconsEnable = 1;
  };

  slstatus = {
    sep  = "black";
    net  = "white";
    cpu  = "green";
    ram  = "green";
    temp = "green";
    gpu  = "yellow";
    kbd  = "red";
    swap = "blue";
    time = "cyan";
  };

  slock = {
    init  = "bg";
    input = "magentaDark";
    fail  = "red";
    text  = "white";
  };

  wallpick = {
    background     = "bg";
    borderSelected = "magenta";
  };

  sysmenu = {
    background         = "bg";
    foreground         = "fg";
    backgroundSelected = "magenta";
    foregroundSelected = "whiter";
    backgroundHover    = "border";
    countdown          = 5;
  };
}
