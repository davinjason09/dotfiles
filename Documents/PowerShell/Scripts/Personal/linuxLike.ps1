# Compute file hashes

function md5 {
  Get-FileHash -Algorithm MD5 $args
}

function sha1 {
  Get-FileHash -Algorithm SHA1 $args
}

function sha256 {
  Get-FileHash -Algorithm SHA256 $args
}

function sha512 {
  Get-FileHash -Algorithm SHA512 $args
}

# Drive shortcuts
function HKLM: {
  Set-Location HKLM:
}

function HKCU: {
  Set-Location HKCU:
}

function Env: {
  Set-Location Env:
}

