require File.dirname(__FILE__) + "/../.common/session.rb"

WINDOWS_SESSION =
  COMMON_SESSION.merge({ :boot_wait => "1",
                         :boot_cmd_sequence => [''],
                         :winrm_user => "vagrant",
                         :winrm_password => "vagrant",
                         :floppy_files => [
                           "Autounattend.xml",
                           "oracle-cert.cer"
                         ],
                         :postinstall_files => [
                           "install-chef.bat",
                           "install-vbox.bat", # would be interesting to only include this on vbox
                           "mount-validation.bat" # maybe test if we are within a vbox vm?
                           # because this will eventually run on kvm, openstack, etc etc
                         ],
                         :video_memory_size => '48',
                         :sudo_cmd => "%f",
                         :shutdown_cmd => "shutdown /s /t 10  /f /d p:4:1 /c \"Vagrant Shutdown\"" })
  
