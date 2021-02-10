# escape=`

# Use the latest Windows Server Core image with .NET Framework 4.8.
FROM mcr.microsoft.com/windows/servercore:1809

# Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

RUN powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" `
    && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
# Install Chocolatey
RUN choco config set cachelocation C:\chococache `
    && choco install --confirm cmake ninja git `
    && rmdir /S /Q C:\chococache
# Install Build Tools with the VC Buili tools workload.
RUN C:\TEMP\vs_buildtools.exe --wait --norestart --nocache ` 
    --installPath C:\BuildTools `
    --add Microsoft.VisualStudio.Component.VC.CoreBuildTools `
    --add Microsoft.VisualStudio.Component.Windows10SDK `
    --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core `
    --add Microsoft.VisualStudio.Component.VC.CMake.Project `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.VC.v141.x86.x64 `
    || IF "%ERRORLEVEL%"=="3010" EXIT 0

ENV VS_BUILD_TOOL_PATH C:\BuildTools

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
# ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "pwsh.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
