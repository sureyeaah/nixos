{ pkgs, config, ... }:

{
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = "32x32";
    };
    settings.global = {
      font = "JetBrainsMono Nerd Font Mono 10";
      markup = "yes";
      format = "<u>%a</u>\n<b>%s</b>\n%b\n%p";
      sort = "yes";
      indicate_hidden = "yes";
      alignment = "left";
      bounce_freq = 0;
      show_age_threshold = 60;
      word_wrap = "yes";
      ignore_newline = false;
      geometry = "400-35+35";
      shrink = "no";
      transparency = 0;
      idle_threshold = 120;
      follow = "keyboard";
      sticky_history = "yes";
      history_length = 20;
      show_indicators = "yes";
      line_height = 0;
      separator_height = 2;
      padding = 20;
      horizontal_padding = 20;
      startup_notification = true;
      dmenu = ''${pkgs.rofi}/bin/rofi -dmenu -p dunst:'';
      browser = ''${pkgs.chromium}/bin/chromium'';
      icon_position = "left";
      frame_width = 2;
      frame_color = "#e9e9f4";
      separator_color = "#e9e9f4";
    };
    settings.base16_low = {
      msg_urgency = "low";
      background = "#3a3c4e";
      foreground = "#4d4f68";
    };
    settings.base16_normal = {
      msg_urgency = "normal";
      background = "#626483";
      foreground = "#e9e9f4";
    };
    settings.base16_critical = {
      msg_urgency = "critical";
      background = "#ea51b2";
      foreground = "#f1f2f8";
    };
    settings.shortcuts = {
      close = "ctrl+space";
      close_all = "ctrl+shift+space";
      history = "ctrl+grave";
      context = "ctrl+shift+period";
    };
  };
}
