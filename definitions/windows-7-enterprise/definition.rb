# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/../.windows/session.rb"

iso_src = "http://wb.dlservice.microsoft.com/dl/download/release/Win7/3/b/a/3bac7d87-8ad2-4b7a-87b3-def36aee35fa/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso"

session = WINDOWS_SESSION.merge({
    :os_type_id => 'Windows7_64',
    :iso_download_instructions => "Download Windows 7 Enterprise 90-day Trial at http://technet.microsoft.com/en-us/evalcenter/cc442495.aspx",
    :iso_file => File.basename(iso_src),
    :iso_src => iso_src,
    :iso_md5 => "1d0d239a252cb53e466d39e752b17c28",
    :kickstart_port => "7150"
  })

Veewee::Session.declare session
