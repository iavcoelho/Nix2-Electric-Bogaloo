{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.step-ca;
in
{
  options.my.services.step-ca.enable = lib.mkEnableOption "step-ca certificate authority";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {

    services.step-ca = {
      enable = true;
      address = "100.93.161.49";
      port = 6060;

      intermediatePasswordFile = config.sops.secrets.step-ca-intermediate-password.path;

      settings = {
        root = "/var/lib/step-ca/certs/root_ca.crt";
        crt = "/var/lib/step-ca/certs/intermediate_ca.crt";
        key = "/var/lib/step-ca/secrets/intermediate_ca_key";

        dnsNames = [
          "ca.creampie.lan"
          "100.93.161.49"
        ];

        logger = {
          format = "text";
        };

        db = {
          type = "badgerv2";
          dataSource = "/var/lib/step-ca/db";
          badgerFileLoadingMode = "";
        };

        authority = {
          provisioners = [
            {
              type = "ACME";
              name = "acme";
              challenges = [ "http-01" ];
            }
          ];
        };

        tls = {
          cipherSuites = [
            "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
            "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
          ];
          minVersion = 1.2;
          maxVersion = 1.3;
          renegotiation = false;
        };
      };
    };

    security.pki.certificates = [
      (builtins.readFile ../certs/step-ca-root.pem)
    ];

    security.pki.certificateFiles = [
      ../certs/step-ca-root.pem
    ];

    sops.secrets.step-ca-intermediate-password = {
      restartUnits = [ "step-ca.service" ];
    };
  };
}
