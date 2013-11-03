# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/../.windows/session.rb"

iso_src = "http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO"

session = WINDOWS_SESSION.merge({
    :os_type_id => 'Windows8_64',
    :iso_download_instructions => "Download and install full featured software for 180-day trial at http://technet.microsoft.com/en-US/evalcenter/hh670538.aspx",
    :iso_src => iso_src,
    :iso_file => File.basename(iso_src),
    :iso_md5 => "458ff91f8abc21b75cb544744bf92e6a",
    :kickstart_port => "7122",
    :winrm_host_port => "2012",
    :memory_size=> "512",
    :virtualbox => {
      :extradata => 'VBoxInternal/CPUM/CMPXCHG16B 1',
    }
  })

Veewee::Session.declare session 
