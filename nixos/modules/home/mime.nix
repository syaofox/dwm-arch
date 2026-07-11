{ config, pkgs, ... }:

{
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "image/jpeg" = "org.gnome.gThumb.desktop";
      "image/png" = "org.gnome.gThumb.desktop";
      "image/gif" = "org.gnome.gThumb.desktop";
      "image/webp" = "org.gnome.gThumb.desktop";
      "image/bmp" = "org.gnome.gThumb.desktop";
      "image/tiff" = "org.gnome.gThumb.desktop";
      "text/plain" = "code.desktop";
      "text/html" = "chromium.desktop";
      "application/pdf" = "chromium.desktop";
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "x-scheme-handler/http" = "chromium.desktop";
      "x-scheme-handler/https" = "chromium.desktop";
      "x-scheme-handler/ftp" = "chromium.desktop";
    };
    defaultApplications = {
      "image/jpeg" = "org.gnome.gThumb.desktop";
      "image/png" = "org.gnome.gThumb.desktop";
      "image/gif" = "org.gnome.gThumb.desktop";
      "image/webp" = "org.gnome.gThumb.desktop";
      "image/bmp" = "org.gnome.gThumb.desktop";
      "image/tiff" = "org.gnome.gThumb.desktop";
      "text/plain" = "code.desktop";
      "text/html" = "chromium.desktop";
      "application/pdf" = "chromium.desktop";
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "x-scheme-handler/http" = "chromium.desktop";
      "x-scheme-handler/https" = "chromium.desktop";
      "x-scheme-handler/ftp" = "chromium.desktop";
      "inode/directory" = "nemo.desktop";
    };
  };
}
