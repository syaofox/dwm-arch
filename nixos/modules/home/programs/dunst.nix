{ config, pkgs, ... }:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "10x50";
        notification_limit = 20;
        progress_bar = true;
        progress_bar_height = 10;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        icon_position = "left";
        mouse_left_click = "close_current";
        mouse_middle_click = "close_all";
        mouse_right_click = "context";
        frame_width = 2;
        font = "JetBrainsMono Nerd Font 10";
        line_height = 0;
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 8;
        startup_notification = false;
      };
      urgency_low = {
        timeout = 5;
        foreground = "#c0caf5";
        background = "#1a1b26";
        highlight = "#bb9af7";
      };
      urgency_normal = {
        timeout = 10;
        foreground = "#c0caf5";
        background = "#1a1b26";
        highlight = "#bb9af7";
      };
      urgency_critical = {
        timeout = 0;
        foreground = "#f7768e";
        background = "#1a1b26";
        highlight = "#f7768e";
      };
    };
  };
}
