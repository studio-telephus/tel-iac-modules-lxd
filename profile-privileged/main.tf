resource "lxd_profile" "privileged_profile" {
  name        = "privileged"
  description = "LXD privileged container which may create nested cgroups"

  config = {
    #  for a privileged container which may create nested cgroups
    "security.privileged" = "true"
    "security.nesting"    = "true"

    # depending on the kernel of your host system, you need to add
    # further kernel modules here. The ones listed above are for
    # networking and for docker's overlay filesystem.
    "linux.kernel_modules" = "br_netfilter,ip_tables,ip6_tables,ip_vs,ip_vs_rr,ip_vs_wrr,ip_vs_sh,netlink_diag,nf_nat,overlay,xt_conntrack"
    # linux.kernel_modules = "overlay,nf_nat,ip_tables,ip6_tables,netlink_diag,br_netfilter,xt_conntrack,nf_conntrack,ip_vs,vxlan"

    "raw.lxc" = <<-EOF
      lxc.apparmor.profile=unconfined
      lxc.cap.drop=
      lxc.cgroup.devices.allow=a
      lxc.mount.auto=proc:rw sys:rw
    EOF
  }

  device {
    name = "kmsg"
    type = "unix-char"

    properties = {
      source = "/dev/kmsg"
      path   = "/dev/kmsg"
    }
  }
}
