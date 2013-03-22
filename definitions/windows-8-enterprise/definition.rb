# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/../.windows/session.rb"

iso_src = "http://care.dlservice.microsoft.com/dl/download/5/3/C/53C31ED0-886C-4F81-9A38-F58CE4CE71E8/9200.16384.WIN8_RTM.120725-1247_X64FRE_ENTERPRISE_EVAL_EN-US-HRM_CENA_X64FREE_EN-US_DV5.ISO"

session = WINDOWS_SESSION.merge({
    :os_type_id => 'Windows8_64',
    :iso_download_instructions => "Download Windows 8 Enterprise 90-day Trial at http://msdn.microsoft.com/en-us/evalcenter/jj554510.aspx",
    :iso_file => File.basename(iso_src),
    :iso_src => iso_src,
    :iso_md5 => "6beffd994574ca89417286f0dc056108",
    :winrm_host_port => "5988",
    :kickstart_port => "7150",
    :memory_size=> "512"
  })

Veewee::Session.declare session
