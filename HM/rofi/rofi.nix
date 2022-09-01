{ pkgs, system, config, ... }:

{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = ./nord.rasi;
    extraConfig = {
      columns = 1;
      dpi = 1;
      fixed-num-lines = true;
      hide-scrollbar = true;
      kb-remove-char-forward = "Delete";
      kb-remove-to-sol = "";
      kb-row-down = "Down,Control+d";
      kb-row-up = "Up,Control+u";
      kb-primary-paste = "Control+V,Shift+Insert";
      run-shell-command = "{terminal} -e {cmd}";
      show-icons = true;
      sidebar-mode = false;
      ssh-client = "ssh";
      ssh-command = "{terminal} -e ssh {host}";
      separator = "dash";
      borderWidth = 1;
      lines = 12;
    };
  };
}

