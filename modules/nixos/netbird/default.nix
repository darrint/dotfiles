{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.darrint.netbird-server;
in {
  options.darrint.netbird-server.enable = lib.mkEnableOption "run central netbird server";

  config = lib.mkIf cfg.enable {
    darrint.sops.enable = true;
    systemd.tmpfiles.rules = [
      "d /var/lib/netbird-docker 0755 root root"
    ];

    systemd.services.netbird-docker-prepare = {
      description = "Prepare NetBird Docker files and inject secrets";
      before = ["netbird-docker.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        set -euo pipefail

        mkdir -p /var/lib/netbird-docker

        cp ${./docker-compose.yml} /var/lib/netbird-docker/docker-compose.yml
        cp ${./dashboard.env} /var/lib/netbird-docker/dashboard.env

        # Inject secrets into config.yaml
        cp ${./config.yaml.template} /var/lib/netbird-docker/config.yaml.tmp

        AUTH_SECRET=$(cat ${config.sops.secrets.netbird_auth_secret.path})
        ENC_KEY=$(cat ${config.sops.secrets.netbird_encryption_key.path})

        sed -e "s|AUTH_SECRET_PLACEHOLDER|$AUTH_SECRET|g" \
            -e "s|ENCRYPTION_KEY_PLACEHOLDER|$ENC_KEY|g" \
            /var/lib/netbird-docker/config.yaml.tmp > /var/lib/netbird-docker/config.yaml

        chmod 600 /var/lib/netbird-docker/config.yaml
        rm -f /var/lib/netbird-docker/config.yaml.tmp

        echo "NetBird config with secrets prepared successfully"
      '';
    };

    systemd.services.netbird-docker = {
      description = "NetBird Docker Compose stack";
      wantedBy = ["multi-user.target"];
      after = ["podman.service" "netbird-docker-prepare.service"];
      requires = ["podman.service" "netbird-docker-prepare.service"];

      path = [pkgs.podman pkgs.podman-compose];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/var/lib/netbird-docker";

        ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d --remove-orphans";
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";

        Restart = "on-failure";
        RestartSec = "10s";
      };

      restartTriggers = [
        (builtins.readFile ./docker-compose.yml)
        (builtins.readFile ./config.yaml.template)
      ];
    };
    networking.firewall.allowedUDPPorts = [ 3478 ];

    services.caddy = {
      enable = true;
      virtualHosts = {
        "nb.thompsons.space".extraConfig = ''
          # Native gRPC (needs HTTP/2 cleartext to backend)
          @grpc header Content-Type application/grpc*
          reverse_proxy @grpc h2c://127.0.0.1:8081

          # Combined server paths (relay, signal, management, OAuth2)
          @backend path /relay* /ws-proxy/* /api/* /oauth2/*
          reverse_proxy @backend 127.0.0.1:8081

          # Dashboard (everything else)
          reverse_proxy /* 127.0.0.1:8080
        '';
      };
    };
  };
}
