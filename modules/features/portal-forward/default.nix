{ ... }:
{
  flake.nixosModules.portal-forward =
    { config, lib, ... }:
    let
      cfg = config.my.portal-forward.forwards;
      rule = _: f: "${f.proto} dport ${toString f.port} dnat to ${f.to}";
      ports = proto: map (f: f.port) (lib.filter (f: f.proto == proto) (lib.attrValues cfg));
    in
    {
      options.my.portal-forward.forwards = lib.mkOption {
        default = { };
        description = "Public port forwards from this host to a tailnet host.";
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              proto = lib.mkOption {
                type = lib.types.enum [
                  "tcp"
                  "udp"
                ];
                default = "tcp";
              };
              port = lib.mkOption { type = lib.types.port; };
              to = lib.mkOption {
                type = lib.types.str;
                description = "tailnet IP:port";
              };
            };
          }
        );
      };

      config = lib.mkIf (cfg != { }) {
        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
        networking.nftables.enable = true;
        networking.nftables.tables.portforward = {
          family = "ip";
          content = ''
            chain prerouting {
              type nat hook prerouting priority dstnat;
              ${lib.concatStringsSep "\n" (lib.mapAttrsToList rule cfg)}
            }
            chain postrouting {
              type nat hook postrouting priority srcnat;
              oifname "tailscale0" masquerade
            }
          '';
        };
        networking.firewall.allowedTCPPorts = ports "tcp";
        networking.firewall.allowedUDPPorts = ports "udp";
      };
    };
}
