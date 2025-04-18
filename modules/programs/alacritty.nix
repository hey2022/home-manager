{ config, lib, pkgs, ... }:
let
  cfg = config.programs.alacritty;
  tomlFormat = pkgs.formats.toml { };
in {
  options = {
    programs.alacritty = {
      enable = lib.mkEnableOption "Alacritty";

      package = lib.mkPackageOption pkgs "alacritty" { };

      settings = lib.mkOption {
        type = tomlFormat.type;
        default = { };
        example = lib.literalExpression ''
          {
            window.dimensions = {
              lines = 3;
              columns = 200;
            };
            keyboard.bindings = [
              {
                key = "K";
                mods = "Control";
                chars = "\\u000c";
              }
            ];
          }
        '';
        description = ''
          Configuration written to
          {file}`$XDG_CONFIG_HOME/alacritty/alacritty.yml` or
          {file}`$XDG_CONFIG_HOME/alacritty/alacritty.toml`
          (the latter being used for alacritty 0.13 and later).
          See <https://github.com/alacritty/alacritty/tree/master#configuration>
          for more info.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."alacritty/alacritty.toml" = lib.mkIf (cfg.settings != { }) {
      source = (tomlFormat.generate "alacritty.toml" cfg.settings).overrideAttrs
        (finalAttrs: prevAttrs: {
          buildCommand = lib.concatStringsSep "\n" [
            prevAttrs.buildCommand
            # TODO: why is this needed? Is there a better way to retain escape sequences?
            "substituteInPlace $out --replace-quiet '\\\\' '\\'"
          ];
        });
    };
  };
}
