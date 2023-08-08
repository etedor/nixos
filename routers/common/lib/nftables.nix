{ lib }:

let
  concatStringsSep = builtins.concatStringsSep;
  optionalString = lib.optionalString;

  join = rules: builtins.concatStringsSep "\n" rules;
  toTitle = s: "${lib.toUpper (builtins.substring 0 1 s)}${builtins.substring 1 (builtins.stringLength s) s}";

  mkSet = item:
    if builtins.isList item then
      "{ ${concatStringsSep ", " (builtins.map toString item)} }"
    else
      throw "mkSet only accepts a list, not ${builtins.typeOf item}!";

  mkRule = attrs:
    let
      name = if attrs ? name then attrs.name else throw "The 'name' attribute is mandatory!";
      action = if attrs ? action then attrs.action else throw "The 'action' attribute is mandatory!";

      iifs = optionalString (attrs ? "iifs") "iifname ${mkSet attrs.iifs}";
      oifs = optionalString (attrs ? "oifs") "oifname ${mkSet attrs.oifs}";
      sips = optionalString (attrs ? "sips") "ip saddr ${mkSet attrs.sips}";
      dips = optionalString (attrs ? "dips") "ip daddr ${mkSet attrs.dips}";
      spts = optionalString (attrs ? "spts") "${attrs.proto} sport ${mkSet attrs.spts}";
      dpts = optionalString (attrs ? "dpts") "${attrs.proto} dport ${mkSet attrs.dpts}";

      comment = "comment \"${toTitle action} ${attrs.name}\"";
    in
    "${iifs} ${oifs} ${sips} ${spts} ${dips} ${dpts} ${attrs.action} ${comment}";

  mkDNATRule = attrs:
    let
      name = if attrs ? name then attrs.name else throw "The 'name' attribute is mandatory!";

      iifs = optionalString (attrs ? "iifs") attrs.iifs; # TODO: these are mandatory
      oifs = optionalString (attrs ? "oifs") attrs.oifs;
      ip = optionalString (attrs ? "ip") attrs.ip;
      pt = optionalString (attrs ? "pt") attrs.pt;
      proto = optionalString (attrs ? "proto") attrs.proto;

      comment = "comment \"${attrs.name} DNAT\"";

      preroutingRule = "iifname ${mkSet iifs} ${proto} dport ${pt} dnat ip to ${ip}:${toString pt} ${comment}";
      forwardRules = map mkRule [
        { name = "${name} DNAT in"; iifs = iifs; oifs = oifs; dips = [ ip ]; spts = [ pt ]; action = "accept"; proto = proto; }
        { name = "${name} DNAT out"; iifs = oifs; oifs = iifs; sips = [ ip ]; dpts = [ pt ]; action = "accept"; proto = proto; }
      ];
    in
    { preroutingRule = preroutingRule; forwardRules = forwardRules; };

  # c.f. https://wiki.gbe0.com/en/linux/firewalling-and-filtering/nftables/template-inbound-only
  baseline =
    { extraInputRules ? [ ]
    , extraOutputRules ? [ ]
    , extraForwardRules ? [ ]
    , extraPreRoutingRules ? [ ]
    , extraPostRoutingRules ? [ ]
    , dnatRules ? [ ]
    }: ''
      define RFC_1918 = {
        10.0.0.0/8,
        172.16.0.0/12,
        192.168.0.0/16
      }

      table inet filter {

        chain prerouting {
          type nat hook prerouting priority -100

          ${join (map (rule: rule.preroutingRule) dnatRules)}

          # Add extra rules for the prerouting chain
          ${join extraPreRoutingRules}
        }

        chain postrouting {
          type nat hook postrouting priority 100

          # Add extra rules for the postrouting chain
          ${join extraPostRoutingRules}
        }

        chain forward {
          type filter hook forward priority 0; policy drop

          # Add extra rules to the forward chain
          ${join extraForwardRules}

          # Process traffic that is not to/from RFC 1918 space
          ip daddr != $RFC_1918 jump nat_forward;
          ip saddr != $RFC_1918 jump nat_forward;

          # Log any unmatched traffic but rate limit logging to a maximum of 60 messages/minute
          # The default policy will be applied to unmatched traffic
          limit rate 60/minute burst 100 packets \
            log prefix "nftables: CHAIN=forward RULE=default " \
            comment "Log any unmatched forward traffic"

          # Count the unmatched traffic
          counter \
            comment "Count any unmatched forward traffic"
        }

        chain nat_forward {
          ${join (builtins.concatMap (rule: rule.forwardRules) dnatRules)}
        }

        chain input {
          type filter hook input priority 0; policy drop

          # Permit inbound traffic to loopback interface
          iif lo \
            accept \
            comment "Permit all traffic in from loopback interface"

          # Permit established and related connections
          ct state established,related \
            counter \
            accept \
            comment "Permit established/related connections"

          # Log and drop new TCP non-SYN packets
          tcp flags != syn ct state new \
            limit rate 100/minute burst 150 packets \
            log prefix "nftables: CHAIN=input RULE=new_!syn " \
            comment "Rate limit logging for new connections that do not have the SYN TCP flag set"
          tcp flags != syn ct state new \
            counter \
            drop \
            comment "Drop new connections that do not have the SYN TCP flag set"

          # Log and drop TCP packets with invalid fin/syn flag set
          tcp flags & (fin|syn) == (fin|syn) \
            limit rate 100/minute burst 150 packets \
            log prefix "nftables: CHAIN=input RULE=tcp_fin|sin " \
            comment "Rate limit logging for TCP packets with invalid fin/syn flag set"
          tcp flags & (fin|syn) == (fin|syn) \
            counter \
            drop \
            comment "Drop TCP packets with invalid fin/syn flag set"

          # Log and drop TCP packets with invalid syn/rst flag set
          tcp flags & (syn|rst) == (syn|rst) \
            limit rate 100/minute burst 150 packets \
            log prefix "nftables: CHAIN=input RULE=tcp_syn|rst " \
            comment "Rate limit logging for TCP packets with invalid syn/rst flag set"
          tcp flags & (syn|rst) == (syn|rst) \
            counter \
            drop \
            comment "Drop TCP packets with invalid syn/rst flag set"

          # Log and drop invalid TCP flags
          tcp flags & (fin|syn|rst|psh|ack|urg) < (fin) \
            limit rate 100/minute burst 150 packets \
            log prefix "nftables: CHAIN=input RULE=fin " \
            comment "Rate limit logging for invalid TCP flags (fin|syn|rst|psh|ack|urg) < (fin)"
          tcp flags & (fin|syn|rst|psh|ack|urg) < (fin) \
            counter \
            drop \
            comment "Drop TCP packets with flags (fin|syn|rst|psh|ack|urg) < (fin)"

          # Log and drop invalid TCP flags
          tcp flags & (fin|syn|rst|psh|ack|urg) == (fin|psh|urg) \
            limit rate 100/minute burst 150 packets \
            log prefix "nftables: CHAIN=input RULE=fin|psh|urg " \
            comment "Rate limit logging for invalid TCP flags (fin|syn|rst|psh|ack|urg) == (fin|psh|urg)"
          tcp flags & (fin|syn|rst|psh|ack|urg) == (fin|psh|urg) \
            counter \
            drop \
            comment "Drop TCP packets with flags (fin|syn|rst|psh|ack|urg) == (fin|psh|urg)"

          # Drop traffic with invalid connection state
          ct state invalid \
            limit rate 100/minute burst 150 packets \
            log flags all prefix "CHAIN=input RULE=invalid " \
            comment "Rate limit logging for traffic with invalid connection state"
          ct state invalid \
            counter \
            drop \
            comment "Drop traffic with invalid connection state"

          # Permit IPv4 ping/ping responses but rate limit to 2000 PPS
          ip protocol icmp icmp type { echo-reply, echo-request } \
            limit rate 2000/second \
            counter \
            accept \
            comment "Permit inbound IPv4 echo (ping) limited to 2000 PPS"

          # Permit all other inbound IPv4 ICMP
          ip protocol icmp \
            counter \
            accept \
            comment "Permit all other IPv4 ICMP"

          # Permit IPv6 ping/ping responses but rate limit to 2000 PPS
          icmpv6 type { echo-reply, echo-request } \
            limit rate 2000/second \
            counter \
            accept \
            comment "Permit inbound IPv6 echo (ping) limited to 2000 PPS"

          # Permit all other inbound IPv6 ICMP
          meta l4proto { icmpv6 } \
            counter \
            accept \
            comment "Permit all other IPv6 ICMP"

          # Permit inbound traceroute UDP ports but limit to 500 PPS
          udp dport 33434-33524 \
            limit rate 500/second \
            counter \
            accept \
            comment "Permit inbound UDP traceroute limited to 500 PPS"

          # Add extra rules to the input chain
          ${join extraInputRules}

          # Log any unmatched traffic but rate limit logging to a maximum of 60 messages/minute
          # The default policy will be applied to unmatched traffic
          limit rate 60/minute burst 100 packets \
            log prefix "nftables: CHAIN=input RULE=default " \
            comment "Log any unmatched traffic"

          # Count the unmatched traffic
          counter \
            comment "Count any unmatched traffic"
        }

        chain output {
          type filter hook output priority 0; policy accept

          # Add extra rules to the output chain
          ${join extraOutputRules}
        }

      }
    '';
in
{
  mkRule = mkRule;
  mkDNATRule = mkDNATRule;
  baseline = baseline;
}
