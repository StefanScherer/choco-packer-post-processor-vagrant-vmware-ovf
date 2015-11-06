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

"TEST: Version of binary should match"
. packer-post-processor-vagrant-vmware-ovf --version
if (-Not $(packer-post-processor-vagrant-vmware-ovf --version).Contains("version: $version")) {
  Write-Error "FAIL: Wrong version of packer-post-processor-vagrant-vmware-ovf installed!"
}

"TEST: Uninstall show remove the binary"
. choco uninstall packer-post-processor-vagrant-vmware-ovf
try {
  . packer-post-processor-vagrant-vmware-ovf
  Write-Error "FAIL: packer-post-processor-vagrant-vmware-ovf binary still found"
} catch {
  Write-Host "PASS: packer-post-processor-vagrant-vmware-ovf not found"
}

"TEST: Finished"
