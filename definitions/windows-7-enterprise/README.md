You can download a free trial of Windows 7 Enterprise 90-day Trial

url: http://technet.microsoft.com/en-us/evalcenter/cc442495.aspx
file: 7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso
md5sum: 1d0d239a252cb53e466d39e752b17c28  

'''
PS C:\Users\Administrator> Dism /Get-WIMInfo /WimFile:d:\sources\install.wim

Deployment Image Servicing and Management tool
Version: 6.1.7600.16385

Details for image : d:\sources\install.wim

Index : 1
Name : Windows 7 ENTERPRISE
Description : Windows 7 ENTERPRISE
Size : 11,913,037,777 bytes

The operation completed successfully.
'''

- place it in a directory called iso

The installation uses the Standard way for Windows Unattended installation.
The XML file was created using the Windows AIK kit, but the file can also be edited by hand.

To edit the Autounattend.xml and validate it:

You can download The Windows® Automated Installation Kit (AIK) for Windows® 7:
url: http://www.microsoft.com/download/en/details.aspx?id=5753
file: KB3AIK_EN.iso
md5sum: 1e73b24a89eceab9d50585b92db5482f

- Building the machine creates a floppy that contains:
  - AutoUnattend.xml (that will configure the windows)
  - winrm-install.bat (activates the http and https listener + punches the firewall hole)

AIK also includes dism, which will allow you to choose a specific version:

If you want to install a different version, edit Autoattended.xml and replace the /IMAGE/NAME value with
one of the names listed in the sources/install.wim on the install DVD .iso



    # Use the Name : from 'Dism.exe /Get-WIMInfo /WimFile:d:\sources\install.wim'
    # <InstallFrom>
    #     <MetaData wcm:action="add">
    #         <Key>/IMAGE/NAME</Key>
    #         <Value>Windows 7 ENTERPRISE</Value>
    #     </MetaData>
    # </InstallFrom>
