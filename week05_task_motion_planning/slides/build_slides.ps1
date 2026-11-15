param([switch]$NoPreview, [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$OutputBaseName='CLASSICAL_PLANNING_AND_TAMP')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$planPath = Join-Path $root 'PRESENTATION_PLAN.md'
$pptxPath = Join-Path $root ($OutputBaseName+'.pptx')
$pdfPath = Join-Path $root ($OutputBaseName+'.pdf')
$previewPath = Join-Path $PSScriptRoot 'preview'
. (Join-Path $PSScriptRoot 'content.ps1')
$baseline = Get-Content (Join-Path $PSScriptRoot 'protected_files.json') -Raw | ConvertFrom-Json
$protectedPaths = @($baseline.PSObject.Properties.Name)
$protectedHashes = @{}
foreach ($path in $protectedPaths) { $protectedHashes[$path] = (Get-FileHash -LiteralPath (Join-Path $root $path)).Hash; if ($protectedHashes[$path] -ne $baseline.$path) { throw "Protected file differs from baseline: $path" } }
function Color([string]$hex) {
  $hex = $hex.TrimStart('#')
  return [Convert]::ToInt32($hex.Substring(0,2),16) + 256 * [Convert]::ToInt32($hex.Substring(2,2),16) + 65536 * [Convert]::ToInt32($hex.Substring(4,2),16)
}
$C = @{ bg=(Color 'F7F9FC'); ink=(Color '15283B'); muted=(Color '526477'); blue=(Color '2459D3'); teal=(Color '137F79'); paleBlue=(Color 'EAF0FC'); paleTeal=(Color 'E5F3F0'); white=(Color 'FFFFFF'); line=(Color 'D7E0E9'); amber=(Color 'AE651D'); paleAmber=(Color 'FFF0DF') }
$W = 960; $H = 540
$script:slides = New-Object System.Collections.Generic.List[object]
$script:issues = New-Object System.Collections.Generic.List[string]
$script:slide = $null

function Text([double]$x,[double]$y,[double]$w,[double]$h,[string]$text,[double]$size=26,[int]$color=$C.ink,[bool]$bold=$false,[int]$align=1,[string]$font='Aptos') {
  $s = $script:slide.Shapes.AddTextbox(1,$x,$y,$w,$h)
  $s.Name = 'text_' + $script:slide.Shapes.Count
  $s.Fill.Visible = 0; $s.Line.Visible = 0
  $f = $s.TextFrame
  $f.MarginLeft=0; $f.MarginRight=0; $f.MarginTop=0; $f.MarginBottom=0
  $f.WordWrap=-1; $f.AutoSize=0; $f.VerticalAnchor=1
  $r=$f.TextRange; $r.Text=$text; $r.Font.Name=$font; $r.Font.Size=$size; $r.Font.Color.RGB=$color
  $r.Font.Bold = $(if ($bold) {-1} else {0})
  $r.ParagraphFormat.Alignment=$align
  $r.ParagraphFormat.SpaceBefore=0; $r.ParagraphFormat.SpaceAfter=0
  $s.TextFrame2.AutoSize=0
  $s.Width=$w; $s.Height=$h
}
function Box([double]$x,[double]$y,[double]$w,[double]$h,[int]$fill=$C.white,[int]$border=-1) {
  $s=$script:slide.Shapes.AddShape(5,$x,$y,$w,$h)
  $s.Fill.ForeColor.RGB=$fill
  $s.Adjustments.Item(1)=0.09
  if ($border -lt 0) { $s.Line.Visible=0 } else { $s.Line.ForeColor.RGB=$border; $s.Line.Weight=1.3 }
}
function Line([double]$x1,[double]$y1,[double]$x2,[double]$y2,[int]$color=$C.blue,[bool]$arrow=$false,[bool]$dashed=$false,[bool]$both=$false) {
  $s=$script:slide.Shapes.AddLine($x1,$y1,$x2,$y2)
  $s.Line.ForeColor.RGB=$color; $s.Line.Weight=2.2
  if ($arrow) { $s.Line.EndArrowheadStyle=3 }
  if ($both) { $s.Line.BeginArrowheadStyle=3 }
  if ($dashed) { $s.Line.DashStyle=4 }
}
function Dot([double]$x,[double]$y,[double]$r=6,[int]$fill=$C.blue) {
  $s=$script:slide.Shapes.AddShape(9,$x-$r,$y-$r,2*$r,2*$r)
  $s.Fill.ForeColor.RGB=$fill; $s.Line.Visible=0
}
function Tag([double]$x,[double]$y,[double]$w,[string]$text,[int]$fill=$C.paleBlue,[int]$color=$C.blue) {
  Box $x $y $w 42 $fill
  Text ($x+12) ($y+7) ($w-24) 30 $text 24 $color $true
}
function NewSlide([string]$title,[string]$subtitle,[double]$minutes,[string]$notes,[bool]$backup=$false) {
  $script:slide=$presentation.Slides.Add($presentation.Slides.Count+1,12)
  $script:slide.FollowMasterBackground=0
  $script:slide.Background.Fill.Solid()
  $script:slide.Background.Fill.ForeColor.RGB=$C.bg
  Text 54 26 852 24 $(if ($backup) {'OPTIONAL / DEEPER DISCUSSION'} elseif($script:currentPart -eq 1){'WEEK 05 / PART 1 · CLASSICAL PLANNING & PDDL'} elseif($script:currentPart -eq 2){'WEEK 05 / PART 2 · TASK AND MOTION PLANNING'} else {'WEEK 05 / CLASSICAL PLANNING & TAMP'}) 16 $C.teal $true
  Text 54 64 852 60 $title 40 $C.ink $true
  if ($subtitle) { Text 54 124 852 64 $subtitle 26 $C.muted }
  Line 54 494 906 494 $C.line
  Text 54 504 660 24 'Robotics & Autonomous Systems · Task & Motion Planning' 16 $C.muted
  Text 836 504 70 24 ('{0:00}' -f $script:slide.SlideIndex) 16 $C.muted $false 3
  $noteBody=$script:slide.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange
  $noteBody.Text=$notes
  $noteBody.Font.Name='Aptos'; $noteBody.Font.Size=12
  $script:slide.SlideShowTransition.AdvanceOnTime=0
  $script:slides.Add([pscustomobject]@{number=$script:slide.SlideIndex; title=$title; minutes=$minutes; part=$script:currentPart; backup=$backup})
}
function Formula([double]$x,[double]$y,[double]$w,[double]$h,[string]$value,[double]$size=32,[int]$color=$C.ink,[int]$align=1) {
  # Editable text with true superscript/subscript offsets, never a raster equation.
  $value=[regex]::Replace($value,'([cs])([φθψ])','$1_{$2}')
  $matches=[regex]::Matches($value,'([\^_])\{([^}]+)\}')
  $plain=''; $cursor=0; $ranges=@()
  foreach($match in $matches){
    $plain+=$value.Substring($cursor,$match.Index-$cursor)
    $ranges+=@{start=$plain.Length+1;length=$match.Groups[2].Value.Length;upper=($match.Groups[1].Value -eq '^')}
    $plain+=$match.Groups[2].Value; $cursor=$match.Index+$match.Length
  }
  $plain+=$value.Substring($cursor)
  Text $x $y $w $h $plain $size $color $false $align 'Cambria Math'
  $shape=$script:slide.Shapes.Item($script:slide.Shapes.Count)
  foreach($range in $ranges){$font=$shape.TextFrame.TextRange.Characters($range.start,$range.length).Font; $font.Size=$size*.72; $font.BaselineOffset=$(if($range.upper){.32}else{-.22})}
}
function Matrix([double]$x,[double]$y,[double]$w,[double]$h,[object[]]$rows,[double]$size=26,[int]$color=$C.ink) {
  $columns=$rows[0].Count; $rh=$h/$rows.Count; $cw=($w-22)/$columns
  foreach($bx in @($x,($x+$w))){Line $bx $y $bx ($y+$h) $color; $dx=$(if($bx -eq $x){8}else{-8}); Line $bx $y ($bx+$dx) $y $color; Line $bx ($y+$h) ($bx+$dx) ($y+$h) $color}
  for($r=0;$r -lt $rows.Count;$r++){for($col=0;$col -lt $columns;$col++){Formula ($x+11+$col*$cw) ($y+$r*$rh+4) $cw ($rh-4) ([string]$rows[$r][$col]) $size $color 2}}
}
function Card([double]$x,[double]$y,[double]$w,[double]$h,[string]$label,[string]$body,[int]$fill=$C.paleBlue,[int]$color=$C.blue){
 Box $x $y $w $h $fill; Text ($x+18) ($y+15) ($w-36) 42 $label 28 $color $true; Text ($x+18) ($y+64) ($w-36) ($h-68) $body 24
}

$C.red=Color 'C43C47';$C.orange=Color 'E88932';$C.pink=Color 'F4DDE1'
Add-Type -Path (Join-Path $PSScriptRoot 'LessonChecks.cs')
$domainText=Get-Content (Join-Path $root 'demo/domain.pddl') -Raw -Encoding UTF8
$problemText=Get-Content (Join-Path $root 'demo/problem.pddl') -Raw -Encoding UTF8
$lessonChecks=[Week5Checks]::Run($domainText,$problemText)
$excerptChecks=@()
function PddlTokens([string]$s){return ([regex]::Matches($s,'\(|\)|[^\s()]+') | ForEach-Object {$_.Value}) -join ' '}
foreach($key in $snippets.Keys){$excerpt=$snippets[$key];$source=Get-Content (Join-Path $root ('demo/'+$excerpt.file)) -Raw -Encoding UTF8;if(-not (PddlTokens $source).Contains((PddlTokens $excerpt.code))){throw "Excerpt differs from authored PDDL: $key"};$excerptChecks+=$key}
$scene=Get-Content (Join-Path $root 'demo/scene.json') -Raw | ConvertFrom-Json
if($scene.empty_radius -ne .12 -or $scene.loaded_radius -ne .25 -or ($scene.size -join ',') -ne '6,6'){throw 'Scene differs from illustrations'}
foreach($name in [Week5Checks]::Positions.Keys){if(($scene.locations.$name -join ',') -ne ([Week5Checks]::Positions[$name] -join ',')){throw "Location differs: $name"}}
for($idx=0;$idx -lt 2;$idx++){if(($scene.obstacles[$idx] -join ',') -ne ([Week5Checks]::Rectangles[$idx] -join ',')){throw 'Obstacle differs'}}
$planningSource=Get-Content (Join-Path $root 'demo/planning.py') -Raw -Encoding UTF8
$sourceChecks=@('after = op.apply(state)','state = frozenset(task.initial_state)','plan = breadth_first_search(task)','range(len(permissions)+1)','task = load_task(refine_problem(original,rejected))')
foreach($snippet in $sourceChecks){if(-not $planningSource.Contains($snippet)){throw "Implementation differs: $snippet"}}

function Code([double]$x,[double]$y,[double]$w,[double]$h,[string]$label,[string]$value,[int]$fill=$C.paleBlue){
 Box $x $y $w $h $fill
 Text ($x+18) ($y+12) ($w-36) 35 $label 24 $C.muted $true
 Text ($x+18) ($y+48) ($w-36) ($h-55) $value.Trim() 24 $C.ink $false 1 'Consolas'
 # Highlight actual PDDL keywords without changing tokens or font size.
 $range=$script:slide.Shapes.Item($script:slide.Shapes.Count).TextFrame.TextRange
 foreach($match in [regex]::Matches($range.Text,':[a-z-]+|\band\b|\bnot\b')){$r=$range.Characters($match.Index+1,$match.Length);$r.Font.Color.RGB=$(if($match.Value -eq 'not'){$C.red}else{$C.blue});$r.Font.Bold=-1}
}
function SceneXY([double[]]$p,[double]$x,[double]$y,[double]$side){return @(($x+$p[0]*$side/6),($y+$side-$p[1]*$side/6))}
function Scene([double]$x,[double]$y,[double]$side,[string]$mode='initial'){
 Box $x $y $side $side $C.white $C.line
 foreach($rect in $scene.obstacles){$shape=$script:slide.Shapes.AddShape(1,($x+$rect[0]*$side/6),($y+$side-$rect[3]*$side/6),(($rect[1]-$rect[0])*$side/6),(($rect[3]-$rect[2])*$side/6));$shape.Fill.ForeColor.RGB=$C.muted;$shape.Line.Visible=0}
 foreach($pair in $scene.connections){$a=SceneXY $scene.locations.($pair[0]) $x $y $side;$b=SceneXY $scene.locations.($pair[1]) $x $y $side;Line $a[0] $a[1] $b[0] $b[1] $C.line $false $true}
 if($mode -eq 'rejected'){$a=SceneXY $scene.locations.pickup $x $y $side;$b=SceneXY $scene.locations.delivery $x $y $side;Line $a[0] $a[1] $b[0] $b[1] $C.red $false $true}
 if($mode -eq 'revised'){
  $motions=@(@('delivery','pickup',1),@('pickup','upper-left',3),@('upper-left','upper-right',4),@('upper-right','delivery',5))
  foreach($motion in $motions){$a=SceneXY $scene.locations.($motion[0]) $x $y $side;$b=SceneXY $scene.locations.($motion[1]) $x $y $side;$color=if($motion[2] -eq 1){$C.blue}else{$C.teal};Line $a[0] $a[1] $b[0] $b[1] $color $true}
 }
 foreach($name in @('pickup','delivery','upper-left','upper-right')){$p=SceneXY $scene.locations.$name $x $y $side;Dot $p[0] $p[1] 3 $C.ink;if($side -lt 270 -and $name.StartsWith('upper')){continue};$labelW=if($name.StartsWith('upper')){132}else{115};$labelX=$p[0]-$labelW/2;if($name -eq 'upper-left'){$labelX-=40};if($name -eq 'upper-right'){$labelX+=40};Text $labelX ($p[1]-34) $labelW 32 $name 24 $C.ink $false 2}
 $robotName=if($mode -eq 'rejected'){'pickup'}else{'delivery'};$p=SceneXY $scene.locations.$robotName $x $y $side;$r=if($mode -eq 'rejected'){.25}else{.12};Dot $p[0] $p[1] ($r*$side/6) $C.teal
 $parcelName=if($mode -eq 'rejected'){'pickup'}else{'pickup'};$p=SceneXY $scene.locations.$parcelName $x $y $side;$s=$script:slide.Shapes.AddShape(1,($p[0]-5),($p[1]-5),10,10);$s.Fill.ForeColor.RGB=$C.orange;$s.Line.Visible=0
 if($mode -eq 'revised'){
  foreach($motion in $motions){$a=SceneXY $scene.locations.($motion[0]) $x $y $side;$b=SceneXY $scene.locations.($motion[1]) $x $y $side;$mx=($a[0]+$b[0])/2;$my=($a[1]+$b[1])/2;switch($motion[2]){1{$mx-=35;$my+=22};3{$mx-=23};4{$my-=22};5{$mx+=23}};$color=if($motion[2] -eq 1){$C.blue}else{$C.teal};Dot $mx $my 16 $color;Text ($mx-15) ($my-15) 30 32 $motion[2] 24 $C.white $true 2}
 }
}
function PlanList([string[]]$actions,[double]$x,[double]$y,[double]$w,[int]$bad=-1,[double]$spacing=43){
 for($idx=0;$idx -lt $actions.Count;$idx++){Text $x ($y+$idx*$spacing) 29 33 ($idx+1) 24 $C.muted $true;Text ($x+34) ($y+$idx*$spacing) ($w-34) 36 $actions[$idx] 24 $(if($idx -eq $bad){$C.red}else{$C.ink}) $false 1 'Consolas'}
}
function Fact([double]$x,[double]$y,[double]$w,[string]$value,[int]$fill=$C.paleBlue,[int]$color=$C.ink){Box $x $y $w 49 $fill;Text ($x+13) ($y+10) ($w-26) 34 $value 24 $color $false 1 'Consolas'}
function Passage([double]$x,[double]$y,[double]$radius,[string]$label,[int]$color){
 Box $x $y 390 197 $C.white
 $s=$script:slide.Shapes.AddShape(1,($x+181),($y+17),28,50);$s.Fill.ForeColor.RGB=$C.muted;$s.Line.Visible=0
 $s=$script:slide.Shapes.AddShape(1,($x+181),($y+131),28,50);$s.Fill.ForeColor.RGB=$C.muted;$s.Line.Visible=0
 Line ($x+44) ($y+99) ($x+346) ($y+99) $C.line $true $true
 Dot ($x+195) ($y+99) ($radius*160) $color
 Text ($x+17) ($y+203) 365 39 $label 26 $color $true
}

$planLines=New-Object System.Collections.Generic.List[string]
$planLines.Add('# Week 5 — Classical Planning, PDDL, and TAMP');$planLines.Add('')
$planLines.Add('Explain why compact factored models and PDDL are useful, teach practical PDDL reading from scratch, then center TAMP on Ronen slides 8 and 9. **15 minutes classical planning/PDDL + 15 minutes TAMP + 10 minutes unchanged demo + 5 minutes recap = 45 minutes.** 23 visible slides with no hidden slides. English, 16:9, light background, editable diagrams/code. No PDB or related heuristic-abstraction content. All demo files and the original teaching notes remain unchanged; see TEACHING_NOTES_UPDATED.md for the current session guide.')
$planLines.Add('');$planLines.Add('## Sequence and timing');$planLines.Add('');$planLines.Add('| Slide | Topic | Minutes |');$planLines.Add('|---|---|---:|')
for($idx=0;$idx -lt $lesson.Count;$idx++){$item=$lesson[$idx];$planLines.Add("| $($idx+1) | $($item.title)$(if($item.backup){' (hidden)'}) | $($item.minutes) |")}
$planLines.Add('');$planLines.Add('## Speaker guidance, visuals, and code reading')
for($idx=0;$idx -lt $lesson.Count;$idx++){$item=$lesson[$idx];$planLines.Add('');$planLines.Add("### $($idx+1). $($item.title)");$planLines.Add('');$planLines.Add("$($item.subtitle) Timing: $($item.minutes) minutes.");$planLines.Add('');$planLines.Add($item.notes.Trim());$planLines.Add('');if($item.kind -eq 'response_table'){$planLines.Add('| Response | Meaning | Example |');$planLines.Add('|---|---|---|');foreach($response in $tampResponses){$planLines.Add(('| {0} | {1} | {2} |' -f ($response.response -replace '[\r\n]+',' '),($response.meaning -replace '[\r\n]+',' '),($response.example -replace '[\r\n]+',' ')))};$planLines.Add('')};foreach($ref in $item.refs){$planLines.Add("- $($sources[$ref])")}}
$planLines.Add('');$planLines.Add('## Source excerpts');$planLines.Add('')
foreach($key in ($snippets.Keys | Sort-Object)){$excerpt=$snippets[$key];$planLines.Add("### $key — demo/$($excerpt.file)");$planLines.Add('');$planLines.Add('```lisp');$planLines.Add($excerpt.code.Trim());$planLines.Add('```');$planLines.Add('')}
$planLines.Add('## Validation');$planLines.Add('')
$planLines.Add('Check all 23 rendered/exported pages, 23 visible slides, no hidden slides, notes/timings/lecture citations, and unchanged hashes for all 13 protected files. Authored PDDL excerpts are compared by tokens; the independent C# checker reproduces the four/six-action plans, exact rejection/refinement, and geometry. Actual Python-suite/headless results are recorded separately in slides/python_validation.json. Rendered contact sheets receive visual review. No classroom rehearsal or live hardware execution is claimed.')
[IO.File]::WriteAllText($planPath,($planLines -join "`r`n"),[Text.UTF8Encoding]::new($false))

$app=$null;$presentation=$null;$hadExistingPresentations=$true
try{
 $app=New-Object -ComObject PowerPoint.Application;$hadExistingPresentations=($app.Presentations.Count -gt 0)
 $presentation=$app.Presentations.Add(0);$presentation.PageSetup.SlideWidth=$W;$presentation.PageSetup.SlideHeight=$H
 foreach($item in $lesson){
  $script:currentPart=$item.part
  $refs=($item.refs | ForEach-Object {$sources[$_]}) -join "`r`n"
  $notes="TIMING: $($item.minutes) minutes. $($item.notes.Trim())`r`n`r`nSOURCES`r`n$refs"
  NewSlide $item.title $item.subtitle $item.minutes $notes ([bool]$item.backup)
  . (Join-Path $PSScriptRoot 'layouts.ps1')
 }
 if($presentation.Slides.Count -ne 23){throw 'Expected 23 slides'}
 $pddl=($script:slides | Where-Object {$_.part -eq 1} | Measure-Object minutes -Sum).Sum
 $tamp=($script:slides | Where-Object {$_.part -eq 2} | Measure-Object minutes -Sum).Sum
 if($pddl -ne 15 -or $tamp -ne 15 -or ($script:slides | Measure-Object minutes -Sum).Sum -ne 45){throw 'Timing differs'}
 foreach($item in $presentation.Slides){foreach($shape in $item.Shapes){if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){$tr=$shape.TextFrame.TextRange;if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$script:issues.Add("Slide $($item.SlideIndex): $([math]::Round($tr.BoundWidth,1))×$([math]::Round($tr.BoundHeight,1)) exceeds $($shape.Width)×$($shape.Height): $($tr.Text)")}}}}
 New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
 if(-not $NoPreview){Get-ChildItem -LiteralPath $previewPath -File | Where-Object {$_.Name -match '^(slide|contact)_\d+\.png$'} | ForEach-Object {Remove-Item -LiteralPath $_.FullName};foreach($item in $presentation.Slides){$item.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $item.SlideIndex)),'PNG',1600,900)}}
 $presentation.SaveAs($pdfPath,32)
 foreach($info in $script:slides){if($info.backup){$presentation.Slides.Item($info.number).SlideShowTransition.Hidden=-1}}
 $presentation.SaveAs($pptxPath,24);$presentation.Close();$presentation=$null
 $check=$app.Presentations.Open($pptxPath,-1,0,0)
 if($check.Slides.Count -ne 23){throw 'Reopened count differs'}
 for($idx=1;$idx -le 23;$idx++){$item=$check.Slides.Item($idx);if(($item.SlideShowTransition.Hidden -eq -1) -ne $false){throw "Hidden state differs: $idx"};if($item.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;totalMinutes=45;presentationMinutes=30;pddlMinutes=15;tampMinutes=15;demoMinutes=10;recapMinutes=5;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;independentChecks=$lessonChecks;excerptChecks=$excerptChecks;sourceChecks=$sourceChecks;pythonVerification='Actual Python results: python_validation.json; independent C# checks are separate.'} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created/reopened 23 slides, no hidden slides, notes on every slide. All 13 protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
}finally{
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}

