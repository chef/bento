You can download a free trial of Windows Server 2008 R2 with Service Pack 1 from two different locations manually:

* url: http://technet.microsoft.com/en-us/evalcenter/dd459137.aspx
* url: http://msdn.microsoft.com/en-us/evalcenter/ee175713.aspx

But they seem to always generate the same url of http://care.dlservice.microsoft.com//dl/download/7/5/E/75EC4E54-5B02-42D6-8879-D8D3A25FBEF7/7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso

* 64bit
* filename: 7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso
* md5sum: 4263be2cf3c59177c45085c0a7bc6ca5  


The installation uses the Standard Windows Unattended installation. The XML file was created using the Windows AIK kit, but the file can also be edited by hand.

To edit the Autounattend.xml and validate it you can download The Windows® Automated Installation Kit (AIK) for Windows® 7:

* url: http://www.microsoft.com/download/en/details.aspx?id=5753
* file: KB3AIK_EN.iso
* md5sum: 1e73b24a89eceab9d50585b92db5482f

AIK also includes dism, which will allow you to choose a specific version:

If you want to install a different version, edit Autoattended.xml and replace the /IMAGE/NAME value with
one of the names listed in the 2008r2 install.wim on the install DVD .iso


```xml
<InstallFrom>
  <MetaData wcm:action="add">
    <Key>/IMAGE/NAME</Key>
    <Value>Windows Server 2008 R2 SERVERSTANDARD</Value>
  </MetaData>
</InstallFrom>
```


```
PS C:\Users\Administrator> Dism /Get-WIMInfo /WimFile:d:\sources\install.wim

Deployment Image Servicing and Management tool
Version: 6.1.7600.16385

Details for image : d:\sources\install.wim

Index : 1
Name : Windows Server 2008 R2 SERVERSTANDARD
Description : Windows Server 2008 R2 SERVERSTANDARD
Size : 10,510,643,622 bytes

Index : 2
Name : Windows Server 2008 R2 SERVERSTANDARDCORE
Description : Windows Server 2008 R2 SERVERSTANDARDCORE
Size : 3,564,132,307 bytes

Index : 3
Name : Windows Server 2008 R2 SERVERENTERPRISE
Description : Windows Server 2008 R2 SERVERENTERPRISE
Size : 10,511,024,733 bytes

Index : 4
Name : Windows Server 2008 R2 SERVERENTERPRISECORE
Description : Windows Server 2008 R2 SERVERENTERPRISECORE
Size : 3,564,106,331 bytes

Index : 5
Name : Windows Server 2008 R2 SERVERDATACENTER
Description : Windows Server 2008 R2 SERVERDATACENTER
Size : 10,511,131,897 bytes

Index : 6
Name : Windows Server 2008 R2 SERVERDATACENTERCORE
Description : Windows Server 2008 R2 SERVERDATACENTERCORE
Size : 3,564,144,547 bytes

Index : 7
Name : Windows Server 2008 R2 SERVERWEB
Description : Windows Server 2008 R2 SERVERWEB
Size : 10,520,222,743 bytes

Index : 8
Name : Windows Server 2008 R2 SERVERWEBCORE
Description : Windows Server 2008 R2 SERVERWEBCORE
Size : 3,562,750,400 bytes

The operation completed successfully.
```

