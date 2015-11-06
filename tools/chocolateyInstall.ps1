$url = 'https://github.com/gosddc/packer-post-processor-vagrant-vmware-ovf/releases/download/v0.2.1/packer-post-processor-vagrant-vmware-ovf.windows-i386.zip'
$url64bit = 'https://github.com/gosddc/packer-post-processor-vagrant-vmware-ovf/releases/download/v0.2.1/packer-post-processor-vagrant-vmware-ovf.windows-amd64.zip'
$unzipLocation = "${env:APPDATA}\packer.d\plugins"

$legacyLocation = "$env:SystemDrive\HashiCorp\packer"
$pluginExe = $legacyLocation + "\packer-post-processor-vagrant-vmware-ovf.exe"

Install-ChocolateyZipPackage "packer-post-processor-vagrant-vmware-ovf" "$url" "$unzipLocation" "$url64bit"

if (Test-Path $pluginExe) {
  Write-Host "Removing old plugin from $legacyLocation"
  Remove-Item $pluginExe
}
