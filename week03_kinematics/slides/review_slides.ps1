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
$zip=[IO.Compression.ZipFile]::OpenRead((Join-Path $root 'GAZEBO_AND_KINEMATICS.pptx'))
try{
 $slides=@($zip.Entries | Where-Object {$_.FullName -match '^ppt/slides/slide\d+\.xml$'})
 $notes=@($zip.Entries | Where-Object {$_.FullName -match '^ppt/notesSlides/notesSlide\d+\.xml$'})
 if($slides.Count -ne 19 -or $notes.Count -ne 19){throw 'Slide/notes count invalid'}
 $reader=New-Object IO.StreamReader($zip.GetEntry('ppt/presentation.xml').Open());[xml]$presentationXml=$reader.ReadToEnd();$reader.Dispose()
 $reader=New-Object IO.StreamReader($zip.GetEntry('ppt/_rels/presentation.xml.rels').Open());[xml]$relationships=$reader.ReadToEnd();$reader.Dispose()
 $number=0
 foreach($slideId in $presentationXml.presentation.sldIdLst.sldId){
  $number++
  $id=$slideId.GetAttribute('id','http://schemas.openxmlformats.org/officeDocument/2006/relationships')
  $target=($relationships.Relationships.Relationship | Where-Object {$_.Id -eq $id}).Target
  $entry=$zip.GetEntry('ppt/'+$target.TrimStart('/'))
  $reader=New-Object IO.StreamReader($entry.Open());[xml]$xml=$reader.ReadToEnd();$reader.Dispose()
  if(($xml.DocumentElement.GetAttribute('show') -eq '0') -ne ($number -ge 16)){throw "Hidden XML state invalid: $number"}
 }
 $pdf=[Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes((Join-Path $root 'GAZEBO_AND_KINEMATICS.pdf')))
 $pages=[regex]::Matches($pdf,'/Type\s*/Page(?!s)\b').Count
 if($pages -ne 19){throw "PDF page count: $pages"}
 $validation=Get-Content (Join-Path $PSScriptRoot 'validation.json') -Raw | ConvertFrom-Json
 if($validation.layoutIssues.Count){throw 'Unresolved text overflow'}
 Write-Output 'ZIP: 19 slides and notes, 4 hidden; PDF: 19 pages; layout: no overflow.'
}finally{$zip.Dispose()}
