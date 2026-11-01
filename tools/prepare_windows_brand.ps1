# Generates Windows resources from the compact official DSL logo thumbnail.
# The thumbnail comes from the user-supplied base.png; no external downloads.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$brand = Join-Path $root 'assets/brand'
$input = Join-Path $brand 'official-logo-thumb.jpg.b64'
$png = Join-Path $brand 'dsl-logo-square.png'
$ico = Join-Path $brand 'DSL-MODS.ico'
$bytes = [Convert]::FromBase64String(([IO.File]::ReadAllText($input)).Trim())
$sourceStream = New-Object IO.MemoryStream(,$bytes)
$source = [Drawing.Image]::FromStream($sourceStream)
try {
    if ($source.Width -ne 80 -or $source.Height -ne 80) { throw 'Unexpected logo thumbnail dimensions' }
    $sizes = @(32, 64, 128, 256)
    $pngs = @()
    foreach ($side in $sizes) {
        $bitmap = New-Object Drawing.Bitmap($side, $side, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear([Drawing.Color]::Black)
            $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.DrawImage($source, 0, 0, $side, $side)
            $data = New-Object IO.MemoryStream
            $bitmap.Save($data, [Drawing.Imaging.ImageFormat]::Png)
            $pngs += ,($data.ToArray())
            $data.Dispose()
            if ($side -eq 256) { $bitmap.Save($png, [Drawing.Imaging.ImageFormat]::Png) }
        }
        finally {
            $graphics.Dispose()
            $bitmap.Dispose()
        }
    }
    $output = [IO.File]::Create($ico)
    $writer = New-Object IO.BinaryWriter($output)
    try {
        $writer.Write([uint16]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]$sizes.Count)
        $offset = [uint32](6 + 16 * $sizes.Count)
        for ($i = 0; $i -lt $sizes.Count; $i++) {
            $side = $sizes[$i]
            $writer.Write([byte]($side % 256))
            $writer.Write([byte]($side % 256))
            $writer.Write([byte]0)
            $writer.Write([byte]0)
            $writer.Write([uint16]1)
            $writer.Write([uint16]32)
            $writer.Write([uint32]$pngs[$i].Length)
            $writer.Write([uint32]$offset)
            $offset += [uint32]$pngs[$i].Length
        }
        foreach ($data in $pngs) { $writer.Write([byte[]]$data) }
    }
    finally { $writer.Dispose() }
    Write-Host "Prepared official DSL MODS UI resources: $png and $ico"
}
finally {
    $source.Dispose()
    $sourceStream.Dispose()
}
