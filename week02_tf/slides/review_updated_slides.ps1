$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing
$root=Split-Path -Parent $PSScriptRoot
$reviewPath=Join-Path $PSScriptRoot 'updated_review'
$previewPath=Join-Path $reviewPath 'preview'
$report=Get-Content -LiteralPath (Join-Path $reviewPath 'build_validation.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if($report.slideCount -ne 18){throw 'Rebuild the revised 18-slide deck first.'}
if($report.layoutIssues.Count){throw 'Unresolved text overflow in build report.'}
if(-not $report.previewsGenerated -or $report.unchangedSlides.Count -ne 4){throw 'Full review requires a fresh build without -NoPreview.'}
if($report.demoExecuted){throw 'The presentation workflow must not execute the demo.'}
foreach($property in $report.protectedFiles.PSObject.Properties){
    if((Get-FileHash -LiteralPath (Join-Path $root $property.Name)).Hash -ne $property.Value){throw "Protected file changed: $($property.Name)"}
}
function ReadXml($zip,[string]$name){
    $entry=$zip.GetEntry($name);if($null -eq $entry){throw "Missing package part: $name"}
    $reader=New-Object IO.StreamReader($entry.Open())
    try{return [xml]$reader.ReadToEnd()}finally{$reader.Dispose()}
}
function ResolvePart([string]$basePart,[string]$target){
    return ([Uri]::new([Uri]('http://package/'+$basePart),$target)).AbsolutePath.TrimStart('/')
}
function RelPart([string]$part){
    $at=$part.LastIndexOf('/');return $part.Substring(0,$at)+'/_rels/'+$part.Substring($at+1)+'.rels'
}
function OrderedSlides($zip){
    $presentation=ReadXml $zip 'ppt/presentation.xml'
    $relationships=ReadXml $zip 'ppt/_rels/presentation.xml.rels'
    foreach($id in $presentation.SelectNodes('//*[local-name()="sldIdLst"]/*')){
        $rid=$id.GetAttribute('id','http://schemas.openxmlformats.org/officeDocument/2006/relationships')
        $rel=@($relationships.Relationships.Relationship | Where-Object {$_.Id -eq $rid})
        if($rel.Count -ne 1){throw "Invalid ordered-slide relationship $rid"}
        ResolvePart 'ppt/presentation.xml' $rel[0].Target
    }
}
function ShapeSignature([xml]$xml){
    $tree=$xml.SelectSingleNode('//*[local-name()="spTree"]').CloneNode($true)
    $shapes=@($tree.SelectNodes('*[local-name()="sp"]'))
    $tree.RemoveChild($shapes[4]) | Out-Null # fifth text shape = footer; line is a cxnSp
    foreach($node in @($tree.SelectNodes('.//*[local-name()="extLst"]'))){$node.ParentNode.RemoveChild($node) | Out-Null}
    foreach($node in $tree.SelectNodes('.//*[local-name()="cNvPr"]')){$node.SetAttribute('id','0')}
    return $tree.OuterXml
}
$zip=[IO.Compression.ZipFile]::OpenRead((Join-Path $root 'TF_COORDINATE_TRANSFORMS_UPDATED.pptx'))
$source=[IO.Compression.ZipFile]::OpenRead((Join-Path $root 'TF_COORDINATE_TRANSFORMS.pptx'))
try{
    $parts=@($zip.Entries | Where-Object {$_.FullName -match '^ppt/slides/slide\d+\.xml$'})
    $noteParts=@($zip.Entries | Where-Object {$_.FullName -match '^ppt/notesSlides/notesSlide\d+\.xml$'})
    $ordered=@(OrderedSlides $zip);$originalOrdered=@(OrderedSlides $source)
    if($parts.Count -ne 18 -or $ordered.Count -ne 18 -or $noteParts.Count -ne 18){throw 'Expected 18 physical, ordered and notes parts.'}
    $allText=@{};$allNotes=@{};$titles=@();$slideXml=@{};$preserved=@{1=1;2=2;15=13;16=14}
    for($i=1;$i -le 18;$i++){
        $xml=ReadXml $zip $ordered[$i-1];$slideXml[$i]=$xml
        if($xml.DocumentElement.GetAttribute('show') -eq '0'){throw "Hidden slide: $i"}
        $texts=@($xml.SelectNodes('//*[local-name()="t"]') | ForEach-Object {$_.InnerText})
        $titles+=$texts[1]
        $allText[$i]=@($xml.SelectNodes('//*[local-name()="p"]') | ForEach-Object { @($_.SelectNodes('.//*[local-name()="t"]') | ForEach-Object {$_.InnerText}) -join '' }) -join ' '
        if($texts[4] -ne ('{0:00}' -f $i)){throw "Incorrect footer: $i"}
        if($texts[1] -ne $report.titles[$i-1]){throw "Incorrect title/order: $i"}
        if($preserved.ContainsKey($i)){
            $original=ReadXml $source $originalOrdered[$preserved[$i]-1]
            if((ShapeSignature $xml) -ne (ShapeSignature $original)){throw "Preserved slide content/format changed: $i"}
        }
        $rels=ReadXml $zip (RelPart $ordered[$i-1])
        $nr=@($rels.Relationships.Relationship | Where-Object {$_.Type -match '/notesSlide$'})
        if($nr.Count -ne 1){throw "Missing notes link: $i"}
        $noteXml=ReadXml $zip (ResolvePart $ordered[$i-1] $nr[0].Target)
        $allNotes[$i]=@($noteXml.SelectNodes('//*[local-name()="t"]') | ForEach-Object {$_.InnerText}) -join ' '
        if($allNotes[$i] -match '(?i)hidden (slides|derivations|backup)|PDF was not found|not reviewed|same result as slide 11'){throw "Obsolete notes: $i"}
        $pics=$xml.SelectNodes('//*[local-name()="pic"]')
        if(($i -eq 4 -and $pics.Count -ne 1) -or ($i -ne 4 -and $pics.Count -ne 0)){throw "Unexpected picture count: $i"}
    }
    if(@($titles | Select-Object -Unique).Count -ne 18){throw 'Duplicate titles.'}
    if(($allText.Values -join ' ') -match 'One example, three representations|Active rotation|Passive transformation|same result as slide 11'){throw 'Removed teaching content remains.'}
    if(($allText[13]+' '+$allNotes[13]) -match 'TransformStamped'){throw 'Slide 13 must not introduce a message type.'}
    if($allText[4] -match 'Math q:|ROS q:'){throw 'Slide 4 still contains the removed quaternion strip.'}
    $requirements=@{
        3=@('Transform \(TF\)','tf2','time-dependent','chains');
        4=@('ROS body','ROS optical','meters','radians','Always check','data source, library, and API');
        5=@('B coordinates','A coordinates','same physical point|point stays still','Origin of frame B');
        6=@('roll','pitch','yaw','±90°','gimbal lock','2:20');
        7=@('Three columns','B axes','det\(R\)','x̂','ŷ','ẑ');
        8=@('Block form','Expanded form','Same 4 × 4 transformation','3 × 3','3 × 1','1 × 3','includes translation','Direction');
        9=@('Match the inner frame indices','Subtract the translation');
        10=@('Avoid Euler gimbal lock','Compose 3D rotations','SLERP');
        11=@('scalar part','vector part','rotation angle','same 3D rotation','kx','ky','kz');
        12=@('Hamilton product','⊗','×','inverse = conjugate','translation');
        13=@('behind the scenes','separate 3D vector','x, y, z, w','0, 0, 0, 1','Unit norm','composition and inversion');
        14=@('camera_mount','One parent','no cycles','Disconnected','forward kinematics');
        17=@('lookup_transform\(target, source, time\)','RViz Fixed Frame','base_link to world');
        18=@('1  Inspect','2  Transform','3  Explain','0.2, 0, 1','0, 0.2, 1.5')
    }
    foreach($i in $requirements.Keys){foreach($pattern in $requirements[$i]){if($allText[$i] -notmatch $pattern){throw "Missing slide ${i} content: $pattern"}}}
    $boldV=$false;$boldK=$false
    foreach($run in $slideXml[11].SelectNodes('//*[local-name()="r"]')){
        $t=$run.SelectSingleNode('*[local-name()="t"]');$pr=$run.SelectSingleNode('*[local-name()="rPr"]')
        if($null -ne $t -and $null -ne $pr -and $pr.GetAttribute('b') -eq '1'){
            if($t.InnerText -cmatch 'v'){$boldV=$true};if($t.InnerText -cmatch 'K'){$boldK=$true}
        }
    }
    if(-not $boldV -or -not $boldK){throw 'Slide 11 vector v/K are not bold.'}
    $picture=$slideXml[4].SelectSingleNode('//*[local-name()="pic"]')
    $rid=$picture.SelectSingleNode('.//*[local-name()="blip"]').GetAttribute('embed','http://schemas.openxmlformats.org/officeDocument/2006/relationships')
    $rels=ReadXml $zip (RelPart $ordered[3]);$pictureRel=@($rels.Relationships.Relationship | Where-Object {$_.Id -eq $rid})[0]
    $imagePart=ResolvePart $ordered[3] $pictureRel.Target
    $sha=[Security.Cryptography.SHA256]::Create();$imageStream=$zip.GetEntry($imagePart).Open()
    try{$embeddedHash=[BitConverter]::ToString($sha.ComputeHash($imageStream)).Replace('-','')}finally{$imageStream.Dispose();$sha.Dispose()}
    if($embeddedHash -ne $report.handImageHash){throw 'Embedded hand picture differs from supplied asset.'}
    $linkXml=ReadXml $zip (RelPart $ordered[5])
    $video=@($linkXml.Relationships.Relationship | Where-Object {$_.Type -match '/hyperlink$' -and $_.Target -eq 'https://www.youtube.com/watch?v=BczeMqU_u2Y&t=140s' -and $_.TargetMode -eq 'External'})
    if($video.Count -ne 1){throw 'Missing exact video URL on slide 6.'}
    $click=@($slideXml[6].SelectNodes('//*[local-name()="hlinkClick"]') | Where-Object {$_.GetAttribute('id','http://schemas.openxmlformats.org/officeDocument/2006/relationships') -eq $video[0].Id})
    if($click.Count -lt 1){throw 'Video link is not connected to a click action.'}
    $pdf=[Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes((Join-Path $root 'TF_COORDINATE_TRANSFORMS_UPDATED.pdf')))
    $pageCount=[regex]::Matches($pdf,'/Type\s*/Page(?!s)\b').Count
    if($pageCount -ne 18){throw "PDF page count: $pageCount"}
}finally{$zip.Dispose();$source.Dispose()}
Add-Type -Path (Join-Path $PSScriptRoot 'MathChecks.cs')
$math=[TfMathChecks]::Run()
if($math.status -ne 'PASS'){throw 'Independent mathematical checks failed.'}
# Additional homogeneous point/direction checks validate the two block layouts.
$expanded=@(@(0,-1,0,0),@(1,0,0,0),@(0,0,1,.5),@(0,0,0,1))
foreach($case in @(@(@(.2,0,1,1),@(0,.2,1.5,1)),@(@(.2,0,1,0),@(0,.2,1,0)))){
    for($r=0;$r -lt 4;$r++){
        $result=0.0;for($c=0;$c -lt 4;$c++){$result+=$expanded[$r][$c]*$case[0][$c]}
        if([math]::Abs($result-$case[1][$r]) -gt 1e-12){throw 'Homogeneous point/direction check failed.'}
    }
}
[ordered]@{existingChecks=$math;homogeneousChecks=2;totalChecks=($math.checks+2);status='PASS'} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $reviewPath 'math_validation.json') -Encoding UTF8
$images=@(Get-ChildItem -LiteralPath $previewPath -Filter 'slide_*.png' | Sort-Object Name)
if($images.Count -ne 18){throw 'Expected 18 updated slide renders.'}
for($group=0;$group -lt 5;$group++){
    $canvas=New-Object Drawing.Bitmap(1960,1160);$graphics=[Drawing.Graphics]::FromImage($canvas)
    $graphics.Clear([Drawing.Color]::FromArgb(231,237,244));$font=New-Object Drawing.Font('Arial',16)
    try{
        for($tile=0;$tile -lt 4;$tile++){
            $index=$group*4+$tile;if($index -ge $images.Count){break}
            $x=20+($tile%2)*970;$y=14+[math]::Floor($tile/2)*575
            $graphics.DrawString($images[$index].BaseName,$font,[Drawing.Brushes]::Black,$x,$y)
            $img=[Drawing.Image]::FromFile($images[$index].FullName)
            try{$graphics.DrawImage($img,$x,$y+28,940,529)}finally{$img.Dispose()}
        }
        $canvas.Save((Join-Path $previewPath ('contact_{0:00}.png' -f ($group+1))),[Drawing.Imaging.ImageFormat]::Png)
    }finally{$graphics.Dispose();$font.Dispose();$canvas.Dispose()}
}
[ordered]@{status='PASS';physicalSlides=18;orderedSlides=18;hiddenSlides=0;pdfPages=$pageCount;notes=18;unchangedContentSlides=@(1,2,15,16);unchangedRenderSlides=$report.unchangedSlides;mathematicalChecks=($math.checks+2);boldVectorSymbols=$true;suppliedImagePreserved=$true;hyperlinkSlide=6;hyperlinkTimestampSeconds=140;demoExecuted=$false;protectedFilesUnchanged=$true;visualInspection='Inspect contact_01.png through contact_05.png and full-resolution slide renders.'} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $reviewPath 'review_validation.json') -Encoding UTF8
Write-Output "PASS: 18 visible/physical slides, 18 PDF pages, zero hidden; $($math.checks+2) math checks; exact supplied image, vector bolding, video URL and protected files verified."
