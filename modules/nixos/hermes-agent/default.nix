{
  config,
  lib,
  ...
}: {
  options.darrint.hermes-agent = {
    enable = lib.mkEnableOption "Hermes Agent dashboard + gateway, gated by Pocket ID";
  };

  config = lib.mkIf config.darrint.hermes-agent.enable {
    sops.secrets = {
      hermes_env = {
        sopsFile = ../../../secrets/hermes.yaml;
        format = "yaml";
        owner = "hermes";
        group = "hermes";
        mode = "0400";
      };
      oauth2_proxy_client_id = {
        sopsFile = ../../../secrets/hermes.yaml;
        format = "yaml";
      };
      oauth2_proxy_client_secret = {
        sopsFile = ../../../secrets/hermes.yaml;
        format = "yaml";
      };
      oauth2_proxy_cookie_secret = {
        sopsFile = ../../../secrets/hermes.yaml;
        format = "yaml";
      };
    };

    sops.templates."oauth2-proxy.env" = {
      content = ''
        OAUTH2_PROXY_CLIENT_ID=${config.sops.placeholder.oauth2_proxy_client_id}
        OAUTH2_PROXY_CLIENT_SECRET=${config.sops.placeholder.oauth2_proxy_client_secret}
        OAUTH2_PROXY_COOKIE_SECRET=${config.sops.placeholder.oauth2_proxy_cookie_secret}
      '';
      owner = "oauth2-proxy";
      group = "oauth2-proxy";
      mode = "0400";
    };

    services.hermes-agent = {
      enable = true;
      addToSystemPackages = true;
      backend.mode = "dashboard";
      backend.host = "127.0.0.1";
      backend.port = 9119;
      environmentFiles = [config.sops.secrets.hermes_env.path];
      settings.model = {
        default = "grok-4.6";
        provider = "xai-oauth";
        base_url = "https://api.x.ai/v1";
      };
    };

    services.oauth2-proxy = {
      enable = true;
      provider = "oidc";
      oidcIssuerUrl = "https://id.thompsons.space";
      redirectURL = "https://he.thompsons.space/oauth2/callback";
      httpAddress = "http://127.0.0.1:4180";
      upstream = ["http://127.0.0.1:9119"];
      email.domains = ["*"];
      scope = "openid email profile";
      reverseProxy = true;
      trustedProxyIP = ["127.0.0.1" "::1"];
      passHostHeader = false;
      approvalPrompt = "auto";
      keyFile = config.sops.templates."oauth2-proxy.env".path;
      extraConfig = {
        code-challenge-method = "S256";
        whitelist-domain = "he.thompsons.space";
        set-xauthrequest = true;
      };
    };
  };
}
