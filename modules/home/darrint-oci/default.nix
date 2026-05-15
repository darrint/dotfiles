{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.darrint.oci;
  ociAutocomplete = "${pkgs.oci-cli}/lib/python3.13/site-packages/oci_cli/bin/oci_autocomplete.sh";
  dag = lib.home-manager.hm.dag;
  writeOciConfig = pkgs.writeShellApplication {
    name = "write-oci-config";
    runtimeInputs = [pkgs.coreutils pkgs.sops];
    text = ''
      install -dm 700 "$HOME/.oci"
      install -m 600 /dev/null "$HOME/.oci/config"
      cat > "$HOME/.oci/config" <<'EOF'
      [DEFAULT]
      user=ocid1.user.oc1..aaaaaaaa47ztztmqph4yllozlnr7vibh7jf5i54nvmir5hescocolr5ozw3a
      fingerprint=1a:68:ea:b1:2a:e0:7d:13:df:9f:ef:4e:30:e5:83:8a
      tenancy=ocid1.tenancy.oc1..aaaaaaaayrvhnkpenp4mke63lwefajwo6gxpfelvqg4x25zxvzunbkmfi2ra
      region=us-chicago-1
      key_file=~/.oci/oci_api_key.pem
      EOF
      sops decrypt --extract '["oci-api-key"]' ${../../../secrets/oci.yaml} \
        | install -m 600 /dev/stdin "$HOME/.oci/oci_api_key.pem"
    '';
  };
in {
  options.darrint.oci = {
    enable = lib.mkEnableOption "Enable OCI CLI and shell completions";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.oci-cli];

    home.activation.ociConfig = dag.entryAfter ["writeBoundary"] ''
      ${writeOciConfig}/bin/write-oci-config
    '';

    programs.bash.initExtra = ''
      source ${ociAutocomplete}
    '';
    programs.zsh.initContent = ''
      source ${ociAutocomplete}
    '';
  };
}
