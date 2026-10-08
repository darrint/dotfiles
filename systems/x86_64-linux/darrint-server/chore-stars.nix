{config, ...}: {
  systemd.services.postgresql-setup.preStart = ''
    ${config.services.postgresql.package}/bin/psql -d postgres -c "ALTER DATABASE template1 REFRESH COLLATION VERSION;"
    ${config.services.postgresql.package}/bin/psql -d postgres -c "ALTER DATABASE postgres REFRESH COLLATION VERSION;"
    ${config.services.postgresql.package}/bin/psql -d postgres -c "ALTER DATABASE authentik REFRESH COLLATION VERSION;" || true
  '';

  sops.secrets = {
    chores_session_secret = {
      sopsFile = ../../../secrets/chore-stars.yaml;
      format = "yaml";
    };
    chores_oidc_client_id = {
      sopsFile = ../../../secrets/chore-stars.yaml;
      format = "yaml";
    };
    chores_oidc_client_secret = {
      sopsFile = ../../../secrets/chore-stars.yaml;
      format = "yaml";
    };
  };

  sops.templates."chore-stars.env" = {
    content = ''
      CHORES_SESSION_SECRET=${config.sops.placeholder.chores_session_secret}
      CHORES_OIDC_CLIENT_ID=${config.sops.placeholder.chores_oidc_client_id}
      CHORES_OIDC_CLIENT_SECRET=${config.sops.placeholder.chores_oidc_client_secret}
    '';
    mode = "0400";
    restartUnits = ["chore-stars.service"];
  };

  services.chore-stars = {
    enable = true;
    environmentFile = config.sops.templates."chore-stars.env".path;
  };
}
