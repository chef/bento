You can download a free trial of Windows Server 2012R2 from Microsoft:

* url: http://technet.microsoft.com/en-US/evalcenter/dn205286.aspx

But they seem to always generate the same URL that's in the definition. If it ever changes, you can update the definition.

The installation uses the Standard Windows Unattended installation. The XML file was created using the Windows AIK kit, but the file can also be edited by hand.

To edit the Autounattend.xml and validate it you can download The Windows® Automated Deployment Kit (ADK) for Windows® 8.1. Windows Server 2012R2 is based off Windows 8.1.

* url: http://www.microsoft.com/en-us/download/details.aspx?id=39982

ADK also includes dism, which will allow you to choose a specific version of Windows 2012R2 to install.

If you want to install a different version, edit Autoattended.xml and replace the /IMAGE/NAME value with
one of the names listed in the Server 2012R2 install.wim on the install DVD .iso


```xml
<InstallFrom>
  <MetaData wcm:action="add">
    <Key>/IMAGE/NAME</Key>
    <Value>Windows Server 2012R2 SERVERSTANDARD</Value>
  </MetaData>
</InstallFrom>
```

```
PS C:\Users\Administrator> Dism /Get-WIMInfo /WimFile:D:\sources\install.wim

Deployment Image Servicing and Management tool
Version: 6.2.9200.16384

Details for image : D:\sources\install.wim

Index : 1
Name : Windows Server 2012R2 SERVERSTANDARDCORE
Description : Windows Server 2012R2 SERVERSTANDARDCORE
Size : 7,182,564,199 bytes

Index : 2
Name : Windows Server 2012R2 SERVERSTANDARD
Description : Windows Server 2012R2 SERVERSTANDARD
Size : 12,002,145,363 bytes

Index : 3
Name : Windows Server 2012R2 SERVERDATACENTERCORE
Description : Windows Server 2012R2 SERVERDATACENTERCORE
Size : 7,177,138,892 bytes

Index : 4
Name : Windows Server 2012R2 SERVERDATACENTER
Description : Windows Server 2012R2 SERVERDATACENTER
Size : 11,997,664,663 bytes

The operation completed successfully.
```

