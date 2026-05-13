{
  config,
  lib,
  ...
}: {
  options.darrint.authentik = {
    enable = lib.mkEnableOption "Authentik identity provider";
  };

  config = lib.mkIf config.darrint.authentik.enable {
    sops.secrets.authentik_secret_key = {
      sopsFile = ../../../secrets/authentik.yaml;
      format = "yaml";
      mode = "600";
    };

    sops.templates."authentik-env" = {
      content = ''
        AUTHENTIK_SECRET_KEY=${config.sops.placeholder.authentik_secret_key}
      '';
      mode = "600";
    };

    services.authentik = {
      enable = true;
      environmentFile = config.sops.templates."authentik-env".path;
      settings = {
        disable_startup_analytics = true;
        avatars = "initials";
      };
    };
  };
}
