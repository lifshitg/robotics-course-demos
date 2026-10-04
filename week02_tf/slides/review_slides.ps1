$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$images=@(Get-ChildItem (Join-Path $PSScriptRoot 'preview/slide_*.png') | Sort-Object Name)
for($group=0;$group -lt [math]::Ceiling($images.Count/6);$group++){
 $canvas=New-Object Drawing.Bitmap(1920,820); $graphics=[Drawing.Graphics]::FromImage($canvas); $graphics.Clear([Drawing.Color]::FromArgb(231,237,244)); $font=New-Object Drawing.Font('Arial',14)
 for($tile=0;$tile -lt 6;$tile++){$index=$group*6+$tile;if($index -ge $images.Count){break};$x=20+($tile%3)*640;$y=26+[math]::Floor($tile/3)*390;$image=[Drawing.Image]::FromFile($images[$index].FullName);$graphics.DrawString($images[$index].BaseName,$font,[Drawing.Brushes]::Black,$x,$y);$graphics.DrawImage($image,$x,$y+32,600,338);$image.Dispose()}
 $canvas.Save((Join-Path $PSScriptRoot ('preview/contact_{0:00}.png' -f ($group+1))),[Drawing.Imaging.ImageFormat]::Png);$graphics.Dispose();$font.Dispose();$canvas.Dispose()
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root=Split-Path -Parent $PSScriptRoot
$zip=[IO.Compression.ZipFile]::OpenRead((Join-Path $root 'TF_COORDINATE_TRANSFORMS.pptx'))
try{
 $slides=@($zip.Entries | Where-Object {$_.FullName -match '^ppt/slides/slide\d+\.xml$'})
 $notes=@($zip.Entries | Where-Object {$_.FullName -match '^ppt/notesSlides/notesSlide\d+\.xml$'})
 if($slides.Count -ne 26 -or $notes.Count -ne 26){throw 'Slide/notes count invalid'}
 foreach($entry in $slides){$reader=New-Object IO.StreamReader($entry.Open());[xml]$xml=$reader.ReadToEnd();$reader.Dispose();$number=[int]([regex]::Match($entry.Name,'\d+').Value);if(($xml.DocumentElement.GetAttribute('show') -eq '0') -ne ($number -ge 17)){throw "Hidden XML state invalid: $number"}}
 $pdf=[Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes((Join-Path $root 'TF_COORDINATE_TRANSFORMS.pdf')))
 $pages=[regex]::Matches($pdf,'/Type\s*/Page(?!s)\b').Count
 if($pages -ne 26){throw "PDF page count: $pages"}
 $validation=Get-Content (Join-Path $PSScriptRoot 'validation.json') -Raw | ConvertFrom-Json
 if($validation.layoutIssues.Count){throw 'Unresolved text overflow'}
 Write-Output 'ZIP: 26 slides and notes, 10 hidden; PDF: 26 pages; layout: no overflow.'
}finally{$zip.Dispose()}
