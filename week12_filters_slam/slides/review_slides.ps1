$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$images=@(Get-ChildItem (Join-Path $PSScriptRoot 'preview/slide_*.png') | Sort-Object Name)
for($group=0;$group -lt [math]::Ceiling($images.Count/6);$group++){
 $canvas=New-Object Drawing.Bitmap(1920,820);$g=[Drawing.Graphics]::FromImage($canvas);$g.Clear([Drawing.Color]::FromArgb(231,237,244));$font=New-Object Drawing.Font('Arial',14)
 for($tile=0;$tile -lt 6;$tile++){$index=$group*6+$tile;if($index -ge $images.Count){break};$x=20+($tile%3)*640;$y=26+[math]::Floor($tile/3)*390;$im=[Drawing.Image]::FromFile($images[$index].FullName);$g.DrawString($images[$index].BaseName,$font,[Drawing.Brushes]::Black,$x,$y);$g.DrawImage($im,$x,$y+32,600,338);$im.Dispose()}
 $canvas.Save((Join-Path $PSScriptRoot ('preview/contact_{0:00}.png' -f ($group+1))),[Drawing.Imaging.ImageFormat]::Png);$g.Dispose();$font.Dispose();$canvas.Dispose()
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root=Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'content.ps1')
$zip=[IO.Compression.ZipFile]::OpenRead((Join-Path $root 'SLAM_AND_BAYESIAN_ESTIMATION.pptx'))
try{
 $slides=@($zip.Entries|Where-Object{$_.FullName -match '^ppt/slides/slide\d+\.xml$'});$notes=@($zip.Entries|Where-Object{$_.FullName -match '^ppt/notesSlides/notesSlide\d+\.xml$'})
 if($slides.Count -ne 38 -or $notes.Count -ne 38){throw 'Slide/notes count invalid'}
 foreach($entry in $slides){
  $r=New-Object IO.StreamReader($entry.Open());[xml]$xml=$r.ReadToEnd();$r.Dispose();$number=[int]([regex]::Match($entry.Name,'\d+').Value)
  if(($xml.DocumentElement.GetAttribute('show') -eq '0') -ne ($number -ge 34)){throw "Hidden XML state invalid$number"}
  $ns=New-Object Xml.XmlNamespaceManager($xml.NameTable);$ns.AddNamespace('a','http://schemas.openxmlformats.org/drawingml/2006/main');$text=($xml.SelectNodes('//a:t',$ns)|ForEach-Object{$_.InnerText}) -join ' '
  if(-not $text.Contains($lesson[$number-1].title)){throw "Slide title/order invalid$number"}
  $note=$zip.GetEntry("ppt/notesSlides/notesSlide$number.xml");$r=New-Object IO.StreamReader($note.Open());[xml]$nxml=$r.ReadToEnd();$r.Dispose();$nns=New-Object Xml.XmlNamespaceManager($nxml.NameTable);$nns.AddNamespace('a','http://schemas.openxmlformats.org/drawingml/2006/main');$noteText=($nxml.SelectNodes('//a:t',$nns)|ForEach-Object{$_.InnerText}) -join ' '
  if(-not $noteText.Contains("TIMING: $($lesson[$number-1].minutes) minutes.")){throw "Notes timing invalid$number"}
  foreach($ref in $lesson[$number-1].refs){if(-not $noteText.Contains($sources[$ref])){throw "Missing reference$number,$ref"}}
 }
 $pdf=[Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes((Join-Path $root 'SLAM_AND_BAYESIAN_ESTIMATION.pdf')));$pages=[regex]::Matches($pdf,'/Type\s*/Page(?!s)\b').Count;if($pages -ne 38){throw "PDF pages=$pages"}
 $validation=Get-Content (Join-Path $PSScriptRoot 'validation.json') -Raw -Encoding UTF8|ConvertFrom-Json
 if($validation.layoutIssues.Count){throw 'Unresolved text overflow'}
 if($images.Count -ne 38){throw 'Preview count invalid'}
 if($validation.presentationMinutes -ne 30 -or $validation.demoMinutes -ne 12 -or $validation.recapMinutes -ne 3){throw 'Timing invalid'}
 $baseline=Get-Content (Join-Path $PSScriptRoot 'protected_files.json') -Raw -Encoding UTF8|ConvertFrom-Json
 foreach($p in $baseline.PSObject.Properties){if((Get-FileHash -LiteralPath (Join-Path $root $p.Name)).Hash -ne $p.Value){throw "Protected file changed$($p.Name)"}}
 [pscustomobject]@{slideCount=38;notesCount=38;hiddenCount=5;pdfPages=$pages;previewCount=$images.Count;notesTimingsAndSourcesMatch=$true;orderedTitlesMatch=$true;protectedHashesMatch=$true;layoutOverflowCount=0;totalMinutes=45} | ConvertTo-Json | Set-Content (Join-Path $PSScriptRoot 'review.json') -Encoding UTF8
 Write-Output 'Verified38 slides/notes, five hidden,38 PDF pages, no overflow, hashes unchanged.'
}finally{$zip.Dispose()}
