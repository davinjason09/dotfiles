function Delete-TempData {
  Write-Host "Deleting temp data..."
  
  $path1 = "C" + ":\Windows\Temp"
  Get-ChildItem $path1 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

  $path2 = "C" + ":\Windows\Prefetch"
  Get-ChildItem $path2 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

  $path3 = "C" + ":\Users\*\AppData\Local\Temp"
  Get-ChildItem $path3 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

  Write-Host "Temp data deleted successfully." -ForegroundColor Green
}