# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/../.windows/session.rb"

iso_src = "http://care.dlservice.microsoft.com//dl/download/7/5/E/75EC4E54-5B02-42D6-8879-D8D3A25FBEF7/7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso"

session = WINDOWS_SESSION.merge({
    :os_type_id => 'Windows2008_64',
    :iso_download_instructions => "Download and install full featured software for 180-day trial at http://technet.microsoft.com/en-us/evalcenter/dd459137.aspx",
    :iso_src => iso_src,
    :iso_file => File.basename(iso_src),
    :iso_md5 => "4263be2cf3c59177c45085c0a7bc6ca5"
  })

Veewee::Session.declare session 


