{config, ...}: let
  accessLog = host: ''
    output file ${config.services.caddy.logDir}/access-${host}.log {
      roll_size 50mb
      roll_keep 5
      mode 640
    }
  '';
in {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "vw.thompsons.space" = {
        logFormat = accessLog "vw.thompsons.space";
        extraConfig = ''
          reverse_proxy http://localhost:8222
        '';
      };
      "id.thompsons.space" = {
        logFormat = accessLog "id.thompsons.space";
        extraConfig = ''
          reverse_proxy http://127.0.0.1:1411
        '';
      };
      "he.thompsons.space" = {
        logFormat = accessLog "he.thompsons.space";
        extraConfig = ''
          handle /oauth2/* {
          	reverse_proxy http://127.0.0.1:4180
          }
          handle {
          	forward_auth http://127.0.0.1:4180 {
          		uri /oauth2/auth
          		copy_headers X-Auth-Request-User X-Auth-Request-Email
          		@error status 401 403
          		handle_response @error {
          			redir * /oauth2/start?rd={scheme}://{host}{uri}
          		}
          	}
          	reverse_proxy http://127.0.0.1:9119 {
          		header_up Host 127.0.0.1:9119
          		header_up Origin http://127.0.0.1:9119
          		header_up -X-Forwarded-For
          		header_up -X-Forwarded-Host
          	}
          }
        '';
      };
      "cs.thompsons.space".logFormat = accessLog "cs.thompsons.space";
      "thompsons.space" = {
        logFormat = accessLog "thompsons.space";
        extraConfig = ''
          respond "go away"
        '';
      };
      "ancientdad1974.duckdns.org" = {
        logFormat = accessLog "ancientdad1974.duckdns.org";
        extraConfig = ''
          respond "go away"
        '';
      };
    };
  };
}
