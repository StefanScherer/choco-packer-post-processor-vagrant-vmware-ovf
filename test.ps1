"Running tests"
$ErrorActionPreference = "Stop"
$version = $env:APPVEYOR_BUILD_VERSION -replace('\.[^.\\/]+$')

"TEST: Install dependencies should work"
. choco install -y packer

"TEST: Version $version in packer-post-processor-vagrant-vmware-ovf.nuspec file should match"
[xml]$spec = Get-Content packer-post-processor-vagrant-vmware-ovf.nuspec
Write-Host $spec.package.metadata.version
if ($spec.package.metadata.version.CompareTo($version)) {
  Write-Error "FAIL: Wrong version in nuspec file!"
}

"TEST: Package should contain only install script"
Add-Type -assembly "system.io.compression.filesystem"
$zip = [IO.Compression.ZipFile]::OpenRead("$pwd\packer-post-processor-vagrant-vmware-ovf.$version.nupkg")
Write-Host $zip.Entries.Count
if ($zip.Entries.Count -ne 6) {
  Write-Error "FAIL: Wrong count in nupkg!"
}
$zip.Dispose()

"TEST: Installation of package should work"
. choco install -y packer-post-processor-vagrant-vmware-ovf -source .

"TEST: Packer should find the plugin"
$env:PACKER_LOG="debug"
if (-Not (Select-String -Path version.txt -pattern "Discovered plugin: vagrant-vmware-ovf =").Length) {
  Write-Error "FAIL: Packer could not find the installed plugin!"
}

"TEST: Uninstall show remove the binary"
. choco uninstall packer-post-processor-vagrant-vmware-ovf
if ((Select-String -Path version.txt -pattern "Discovered plugin: vagrant-vmware-ovf =").Length) {
  Write-Error "FAIL: Packer still can find the installed plugin!"
}

"TEST: Finished"
