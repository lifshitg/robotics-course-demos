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
. (Join-Path $PSScriptRoot 'content.ps1')
$zip=[IO.Compression.ZipFile]::OpenRead((Join-Path $root 'CLASSICAL_PLANNING_AND_TAMP.pptx'))
try{
 $slides=@($zip.Entries | Where-Object {$_.FullName -match '^ppt/slides/slide\d+\.xml$'})
 $notes=@($zip.Entries | Where-Object {$_.FullName -match '^ppt/notesSlides/notesSlide\d+\.xml$'})
 if($slides.Count -ne 27 -or $notes.Count -ne 27){throw 'Slide/notes count invalid'}
 foreach($entry in $slides){
  $reader=New-Object IO.StreamReader($entry.Open());[xml]$xml=$reader.ReadToEnd();$reader.Dispose();$number=[int]([regex]::Match($entry.Name,'\d+').Value)
  if(($xml.DocumentElement.GetAttribute('show') -eq '0') -ne ($number -ge 24)){throw "Hidden XML state invalid: $number"}
  $ns=New-Object Xml.XmlNamespaceManager($xml.NameTable);$ns.AddNamespace('a','http://schemas.openxmlformats.org/drawingml/2006/main')
  $text=($xml.SelectNodes('//a:t',$ns) | ForEach-Object {$_.InnerText}) -join ' '
  if(-not $text.Contains($lesson[$number-1].title)){throw "Slide order/title differs from source: $number"}
  $notesEntry=$zip.GetEntry("ppt/notesSlides/notesSlide$number.xml");$reader=New-Object IO.StreamReader($notesEntry.Open());[xml]$notesXml=$reader.ReadToEnd();$reader.Dispose()
  $noteNs=New-Object Xml.XmlNamespaceManager($notesXml.NameTable);$noteNs.AddNamespace('a','http://schemas.openxmlformats.org/drawingml/2006/main')
  $notesText=($notesXml.SelectNodes('//a:t',$noteNs) | ForEach-Object {$_.InnerText}) -join ' '
  if(-not $notesText.Contains("TIMING: $($lesson[$number-1].minutes) minutes.")){throw "Notes timing differs: $number"}
  foreach($ref in $lesson[$number-1].refs){if(-not $notesText.Contains($sources[$ref])){throw "Missing source in notes: slide $number, $ref"}}
 }
 $pdf=[Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes((Join-Path $root 'CLASSICAL_PLANNING_AND_TAMP.pdf')))
 $pages=[regex]::Matches($pdf,'/Type\s*/Page(?!s)\b').Count
 if($pages -ne 27){throw "PDF page count: $pages"}
 $validation=Get-Content (Join-Path $PSScriptRoot 'validation.json') -Raw | ConvertFrom-Json
 if($validation.layoutIssues.Count){throw 'Unresolved text overflow'}
 [pscustomobject]@{slideCount=27;notesCount=27;hiddenCount=4;pdfPages=$pages;orderedTitlesMatch=$true;notesTimingsMatch=$true;notesSourcesMatch=$true;contactSheets=5;previewCount=$images.Count} | ConvertTo-Json | Set-Content (Join-Path $PSScriptRoot 'review.json') -Encoding UTF8
 Write-Output 'ZIP: 27 slides and notes, 4 hidden; PDF: 27 pages; layout: no overflow.'
}finally{$zip.Dispose()}
