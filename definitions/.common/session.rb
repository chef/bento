COMMON_SESSION = {
  :boot_wait => "10",
  :cpu_count => "1",
  :disk_format => "VDI",
  :disk_size => "40960",
  :hostiocache => "off",
  :iso_download_timeout => "1000",
  :kickstart_port => "7122",
  :kickstart_timeout => "10000",
  :memory_size=> "384",
  :postinstall_timeout => "10000",
  :ssh_guest_port => "22",
  :ssh_host_port => "7222",
  :ssh_key => "",
  :ssh_login_timeout => "10000",
  :ssh_password => "vagrant",
  :ssh_user => "vagrant",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :virtualbox => {
    :vm_options => {
      :ioapic => "on",
      :pae => "on"
    }
  }
 
}
