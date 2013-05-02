@REM Loop ten times to make sure outbound networking is up
FOR /L %%n IN (1,1,10) DO (
  PING -n 1 www.opscode.com
  IF %ERRORLEVEL% == 0 CALL :wget
  TIMEOUT 10
)

:err
ECHO "Couldn't reach Opscode even after 10 retries"
GOTO :done

:wget
@rem Install Chef using chef-client MSI installer
@setlocal

@set REMOTE_SOURCE_MSI_URL=https://www.opscode.com/chef/install.msi
@set LOCAL_DESTINATION_MSI_PATH=%TEMP%\chef-client-latest.msi
@set FALLBACK_QUERY_STRING=?DownloadContext=PowerShell

@set ALTERNATE_DOWNLOAD_COMMAND=$webClient=new-object System.Net.WebClient; $webClient.DownloadFile('%REMOTE_SOURCE_MSI_URL%%FALLBACK_QUERY_STRING%', '%LOCAL_DESTINATION_MSI_PATH%')

cscript /nologo %TEMP%\wget.vbs /url:%REMOTE_SOURCE_MSI_URL% /path:"%LOCAL_DESTINATION_MSI_PATH%"

@rem Work around issues found in Windows Server 2012 around job objects not respecting WSMAN memory quotas
@rem that cause the MSI download process to exceed the quota even when it is increased by administrators.
@rem Retry the download using a more memory-efficient mechanism that only works if PowerShell is available.
@if ERRORLEVEL 1 (
    echo Warning: Failed to download %REMOTE_SOURCE_MSI_URL% to %LOCAL_DESTINATION_MSI_PATH%
    echo Warning: Retrying download with PowerShell if available
    if EXIST "%LOCAL_DESTINATION_MSI_PATH%" del /f /q "%LOCAL_DESTINATION_MSI_PATH%"
    echo powershell -noprofile -noninteractive -command "%ALTERNATE_DOWNLOAD_COMMAND%"
    powershell -noprofile -noninteractive -command "%ALTERNATE_DOWNLOAD_COMMAND%"
    if NOT ERRORLEVEL 1 (
        echo Download succeeded
    ) else (
        echo Failed to download %REMOTE_SOURCE_MSI_URL%
        echo Subsequent attempt to install the downloaded MSI is likely to fail
    )
)

msiexec /qb /i "%LOCAL_DESTINATION_MSI_PATH%"

@endlocal
EXIT

:done
EXIT
