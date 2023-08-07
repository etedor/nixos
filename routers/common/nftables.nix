{ extraInputRules ? [ ], extraOutputRules ? [ ], extraForwardRules ? [ ], extraPreRoutingRules ? [ ], extraPostRoutingRules ? [ ] }:

let
  # c.f. https://wiki.gbe0.com/en/linux/firewalling-and-filtering/nftables/template-inbound-only
  baseline = ''
    table inet filter {

      chain prerouting {
        type nat hook prerouting priority -100

        # Add extra rules for the prerouting chain
        ${builtins.concatStringsSep "\n" extraPreRoutingRules}
      }

      chain postrouting {
        type nat hook postrouting priority 100

        # Add extra rules for the postrouting chain
        ${builtins.concatStringsSep "\n" extraPostRoutingRules}
      }

      chain forward {
        type filter hook forward priority 0; policy drop

        # Add extra rules to the forward chain
        ${builtins.concatStringsSep "\n" extraForwardRules}

        # Log any unmatched traffic but rate limit logging to a maximum of 60 messages/minute
        # The default policy will be applied to unmatched traffic
        limit rate 60/minute burst 100 packets \
          log prefix "nftables: CHAIN=forward RULE=default " \
          comment "Log any unmatched forward traffic"

        # Count the unmatched traffic
        counter \
          comment "Count any unmatched forward traffic"
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
        ${builtins.concatStringsSep "\n" extraInputRules}

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
        ${builtins.concatStringsSep "\n" extraOutputRules}
      }

    }
  '';
in
baseline
