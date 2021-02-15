{ config, pkgs, ... }:
{
#  services.nginx.enable = true;
#  services.nginx.virtualHosts."localhost" = { 
#  };


#  sops.secrets.nextcloud-admin-password.owner = "nextcloud";

#  users.users.nextcloud.extraGroups = [ "keys" ];
#  systemd.services.nextcloud.serviceConfig.SupplementaryGroups = [ "keys" ];



  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud19;
    nginx.enable = true;
    hostName = "localhost";
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminpassFile = "/adminpassfile";
      adminuser = "root";
      extraTrustedDomains = [
        "localhost"
      ];
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
     { name = "nextcloud";
       ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
     }
    ];
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}


