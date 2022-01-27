{ pkgs, config, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 20;
    };

    extraConfig = ''
      # Fonts
      italic_font      auto
      bold_font        auto
      bold_italic_font auto
      
      adjust_line_height 0
      adjust_column_width 0
      box_drawing_scale 0.001, 1, 1.5, 2
      
      # Cursor
      cursor_shape     underline
      cursor_blink_interval     0
      cursor_stop_blinking_after 15.0
      
      # Scrollback
      scrollback_lines 10000
      scrollback_pager /usr/bin/less
      wheel_scroll_multiplier 5.0
      
      # URLs
      url_style double
      open_url_modifiers ctrl+shift
      open_url_with google-chrome
      copy_on_select yes
      
      # Selection
      rectangle_select_modifiers ctrl+shift
      select_by_word_characters :@-./_~?&=%+#
      
      # Mouse
      click_interval 0.5
      mouse_hide_wait 0
      focus_follows_mouse no
      
      # Performance
      repaint_delay    20
      input_delay 2
      sync_to_monitor no
      
      # Bell
      visual_bell_duration 0.0
      enable_audio_bell no
      
      # Window
      window_border_width 0
      window_margin_width 0
      window_padding_width 0
      inactive_text_alpha 1.0
      background_opacity 1.0
      
      # layout
      enabled_layouts Tall
      
      # Shell
      # shell .
      # close_on_child_death no
      # allow_remote_control yes
      # term xterm-256color

      # spaceduck 
      background #0f111b
      foreground #ecf0c1
      cursor #ecf0c1
      selection_background #686f9a
      color0 #000000
      color8 #686f9a
      color1 #e33400
      color9 #e33400
      color2 #5ccc96
      color10 #5ccc96
      color3 #b3a1e6
      color11 #b3a1e6
      color4 #00a3cc
      color12 #00a3cc
      color5 #f2ce00
      color13 #f2ce00
      color6 #7a5ccc
      color14 #7a5ccc
      color7 #686f9a
      color15 #f0f1ce
      selection_foreground #ffffff
    '';

  };
}
