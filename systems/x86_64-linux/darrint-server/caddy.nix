{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "vw.thompsons.space".extraConfig = ''
        reverse_proxy http://localhost:8222
      '';
      "au.thompsons.space".extraConfig = ''
        reverse_proxy http://localhost:9000
      '';
      "id.thompsons.space".extraConfig = ''
        reverse_proxy http://127.0.0.1:1411
      '';
      "frc.thompsons.space".extraConfig = ''
        reverse_proxy http://127.0.0.1:5173
      '';
      "he.thompsons.space".extraConfig = ''
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
      "thompsons.space".extraConfig = ''
        respond "go away"
      '';
      "ancientdad1974.duckdns.org".extraConfig = ''
        respond "go away"
      '';
    };
  };
}
