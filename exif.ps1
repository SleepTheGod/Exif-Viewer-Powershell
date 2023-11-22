# Install ExifTool utility (requires elevated privileges)
try {
    # Check if ExifTool is installed
    if (!(Test-Path 'C:\Program Files\ExifTool\exiftool.exe')) {
        # Download and install ExifTool
        $downloadUrl = 'https://www.exiftool.org/latest-version/exiftool-win32.exe'
        $downloadPath = Join-Path $env:TEMP 'exiftool-win32.exe'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

        # Made By Taylor Christian Newsome Twitter.com/ClumsyLulz
        # Tracking your malware because you started it!

        # Install ExifTool
        Start-Process -FilePath $downloadPath -ArgumentList '/S /Q' -Wait
    }
} catch {
    Write-Error "Error installing ExifTool: $($_.Exception)"
    exit
}

# Function to check EXIF data of a photo
function Get-EXIFData($photoPathOrUrl) {
    # Determine if the input is a path or a URL
    if (Test-Path $photoPathOrUrl) {
        # Check if file exists and is a photo
        if (!(Test-Path $photoPathOrUrl) -or !(Get-Item $photoPathOrUrl).Extension -match 'jpg|png|gif') {
            Write-Error "Invalid photo file: $photoPathOrUrl"
            return
        }
    } else {
        # Download the image from the URL
        $downloadUrl = $photoPathOrUrl
        $downloadPath = Join-Path $env:TEMP 'downloaded_image.jpg'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
        $photoPathOrUrl = $downloadPath
    }

    # Extract EXIF data using ExifTool
    try {
        $exifData = exiftool -json-pretty $photoPathOrUrl
        return ConvertTo-Json -InputObject $exifData
    } catch {
        Write-Error "Error extracting EXIF data for $photoPathOrUrl: $($_.Exception)"
        return
    } finally {
        # If a temporary file was created, delete it
        if (Test-Path $downloadPath) {
            Remove-Item -Path $downloadPath
        }
    }
}

# Check EXIF data for a specified photo
$photoPathOrUrl = Read-Host "Enter photo path or URL: "
$exifData = Get-EXIFData $photoPathOrUrl

if ($exifData) {
    Write-Output "EXIF Data for $photoPathOrUrl:"
    Write-Output $exifData
} else {
    Write-Output "Failed to extract EXIF data for $photoPathOrUrl"
}
