{config, ...}: {
  sops.secrets.chores_session_secret = {
    sopsFile = ../../../secrets/chore-stars.yaml;
    format = "yaml";
  };

  sops.templates."chore-stars.env" = {
    content = ''
      CHORES_SESSION_SECRET=${config.sops.placeholder.chores_session_secret}
    '';
    mode = "0400";
  };

  services.chore-stars = {
    enable = true;
    environmentFile = config.sops.templates."chore-stars.env".path;
  };
}
