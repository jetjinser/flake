{
  boot.kernelModules = [
    "tcp_bbr"
    # preload to make sysctl options avaliable
    "nf_conntrack"
  ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.core.somaxconn" = 65536;
    "net.core.netdev_max_backlog" = 65536;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    "net.ipv4.tcp_keepalive_probes" = 6;
    "net.ipv4.tcp_mtu_probing" = true;

    "net.ipv4.tcp_adv_win_scale" = -2;

    # tcp pending
    "net.ipv4.tcp_max_syn_backlog" = 65536;
    "net.ipv4.tcp_max_tw_buckets" = 2000000;
    "net.ipv4.tcp_tw_reuse" = true;
    "net.ipv4.tcp_fin_timeout" = 10;
    "net.ipv4.tcp_slow_start_after_idle" = false;

    # net mem
    "net.core.rmem_default" = 1048576;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_default" = 1048576;
    "net.core.wmem_max" = 16777216;
    "net.core.optmem_max" = 65536;
    "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.udp_rmem_min" = 8192;
    "net.ipv4.udp_wmem_min" = 8192;

    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.default.forwarding" = true;
    "net.ipv4.conf.all.rp_filter" = false;
    "net.ipv4.conf.default.rp_filter" = false;

    "net.netfilter.nf_conntrack_buckets" = 65536;
    "net.netfilter.nf_conntrack_max" = 65536;
    "net.netfilter.nf_conntrack_generic_timeout" = 60;
    "net.netfilter.nf_conntrack_tcp_timeout_fin_wait" = 10;
    "net.netfilter.nf_conntrack_tcp_timeout_established" = 600;
    "net.netfilter.nf_conntrack_tcp_timeout_time_wait" = 1;
  };

  # required to set hostname, see <https://github.com/systemd/systemd/issues/16656>
  security.polkit.enable = true;

  networking = {
    useDHCP = true;
    dhcpcd.enable = true;
    firewall.enable = false;

    # TODO: ref #1
    useNetworkd = false;
  };

  # =======

  # TODO: ref #2
  systemd.network.enable = false;
}
