<#
.SYNOPSIS
    A simple powershell script that save the login-screens displayed by Windows to your desktop 
.DESCRIPTION
    A simple powershell script that save the login-screens displayed by Windows.
    Only 16/9 pictures will be saved to Desktop/screen
.NOTES
    File Name      : save_screen.ps1
    Author         : Taknok (pg.developper.fr@gmail.com)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2019 - Taknok
.LINK
    Script posted over:
   https://github.com/Taknok/Windows-LoginScreen
.EXAMPLE
    ./save_screen.ps1
.LICENCE
	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#>

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

# Pictures are in full 16/9 version and also in version cropped to vertical plus various ad-icons
# Set the ratio and the tolerance of 5%
$upperLimit = 16/9 + 0.05
$lowerLimit = 16/9 - 0.05

# Location of backgrounds
Set-Location "$home\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"

# Copy the files greater than 10kB to the desktop
robocopy . $home/Desktop/screen /s /min:10000 /lev:1

Set-Location $home/Desktop/screen

# Set a .jpg extension to the files
Get-ChildItem -File -Filter *. | ForEach-Object {
    $NewName = "$_.jpg"
    $Destination = Join-Path -Path $_.Directory.FullName -ChildPath $NewName
    Move-Item -Path $_.FullName -Destination $Destination -Force
}

# Remove the picture not in 16/9 ration
foreach ($item in Get-ChildItem -Recurse | Where-Object Extension -In ".jpg", ".bmp", ".png") {
    try {
        $image = New-Object System.Drawing.Bitmap $item.FullName
        $aspectRatio = $image.Width / $image.Height
    } finally {
        $image.Dispose()
    }

    if ($aspectRatio -gt $upperLimit -or $aspectRatio -lt $lowerLimit) {
       echo "out $item"
       Remove-Item $item
    }
}
