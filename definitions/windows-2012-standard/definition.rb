# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/../.windows/session.rb"

iso_src ="http://care.dlservice.microsoft.com//dl/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO"
#"http://care.dlservice.microsoft.com//dl/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO?lcid=1033&cprod=winsvr2012rtmisotn"
#"http://care.dlservice.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO"

session = WINDOWS_SESSION.merge({
    :os_type_id => 'Windows8_64',
    :iso_download_instructions => "Download and install full featured software for 180-day trial at http://technet.microsoft.com/en-US/evalcenter/hh670538.aspx",
    :iso_src => iso_src,
    :iso_file => File.basename(iso_src),
    :iso_md5 => "8503997171f731d9bd1cb0b0edc31f3d",
    :kickstart_port => "7140",
    :winrm_host_port => "2012",
    :memory_size=> "512"
  })

Veewee::Session.declare session 


