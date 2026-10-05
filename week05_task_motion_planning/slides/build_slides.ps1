param([switch]$NoPreview, [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$OutputBaseName='CLASSICAL_PLANNING_AND_TAMP')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$planPath = Join-Path $root 'PRESENTATION_PLAN.md'
$pptxPath = Join-Path $root ($OutputBaseName+'.pptx')
$pdfPath = Join-Path $root ($OutputBaseName+'.pdf')
$previewPath = Join-Path $PSScriptRoot 'preview'
$plan = Get-Content -LiteralPath $planPath -Raw -Encoding UTF8
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
function NoteText([string]$s) {
  $s=[regex]::Replace($s,'\[([^\]]+)\]\(([^)]+)\)','$1: $2')
  $s=$s -replace '\*\*','' -replace '`','' -replace '(?m)^#{1,6}\s*',''
  return $s.Trim()
}
function Section([string]$pattern) {
  $m=[regex]::Match($plan,$pattern,[System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $m.Success) { throw "Missing presentation-plan section: $pattern" }
  return (NoteText $m.Groups[1].Value)
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
  $script:slides.Add([pscustomobject]@{number=$script:slide.SlideIndex; title=$title; minutes=$minutes; backup=$backup})
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
 foreach($match in [regex]::Matches($value.Trim(),':[a-z-]+|\band\b|\bnot\b')){$r=$range.Characters($match.Index+1,$match.Length);$r.Font.Color.RGB=$(if($match.Value -eq 'not'){$C.red}else{$C.blue});$r.Font.Bold=-1}
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
$planLines.Add('Teach practical PDDL reading from scratch, then clearly separate TAMP and geometric feedback. **30 minutes presentation (20 PDDL + 10 TAMP), 10 minutes demo, 5 minutes questions/recap.** 27 slides, including four hidden backups. Use English, 16:9, light background, blue/teal accents, editable diagrams and readable code. Do not teach requirement flags, dialects or advanced language details. Preserve the demo, README, and teaching notes.')
$planLines.Add('');$planLines.Add('## Sequence and timing');$planLines.Add('');$planLines.Add('| Slide | Topic | Minutes |');$planLines.Add('|---|---|---:|')
for($idx=0;$idx -lt $lesson.Count;$idx++){$item=$lesson[$idx];$planLines.Add("| $($idx+1) | $($item.title)$(if($item.backup){' (hidden)'}) | $($item.minutes) |")}
$planLines.Add('');$planLines.Add('## Speaker guidance, visuals, and code reading')
for($idx=0;$idx -lt $lesson.Count;$idx++){$item=$lesson[$idx];$planLines.Add('');$planLines.Add("### $($idx+1). $($item.title)");$planLines.Add('');$planLines.Add("$($item.subtitle) Timing: $($item.minutes) minutes.");$planLines.Add('');$planLines.Add($item.notes.Trim());$planLines.Add('');foreach($ref in $item.refs){$planLines.Add("- $($sources[$ref])")}}
$planLines.Add('');$planLines.Add('## Source excerpts');$planLines.Add('')
foreach($key in @('predicate','fact','types','objects','init','goal','pickhead','pickeffect','loadedpre','moveeffect','permission','emptypermission','reversepermission','place')){$excerpt=$snippets[$key];$planLines.Add("### $key — demo/$($excerpt.file)");$planLines.Add('');$planLines.Add('```lisp');$planLines.Add($excerpt.code.Trim());$planLines.Add('```');$planLines.Add('')}
$planLines.Add('## Validation');$planLines.Add('')
$planLines.Add('All 14 original Week 5 files read; no separate professor presentation was supplied. Check 27 PowerPoint renders, saved-deck reopen, note timings/sources, four hidden slides, 27 PDF pages, readable text and all 13 protected-file SHA256 hashes. PDDL excerpt token sequences must match authored files. Independent C# parsing/grounding/BFS and geometry checks reproduce the four/six-action sequences, third-action failure, exact permission removal, state changes and contact/boundary behavior. This independent checker is scoped to the demo and is not Pyperplan execution. Python is unavailable locally, so the existing ten Python test methods, headless trace and GUI/classroom rehearsal are not run here. Distinguish these checks from historical TA-machine validation. See slides/README.md, validation.json and review.json for reproducible commands and evidence.')
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
  switch($item.kind){
   'title' {
    Card 54 211 410 199 'Part 1 · Read PDDL' 'Facts → actions → a task plan'
    Card 486 211 420 199 'Part 2 · Connect motion' 'Geometry → feedback → TAMP' $C.paleTeal $C.teal
    Text 54 451 852 37 '30 min presentation · 10 min demo · 5 min recap' 26 $C.muted $true
   }
   'part1' {
    Text 54 214 852 59 'Read facts. Understand actions. Predict a plan.' 32 $C.blue $true
    Tag 54 309 246 'State';Tag 356 309 246 'Action';Tag 660 309 246 'Goal'
    Line 306 330 347 330 $C.blue $true;Line 608 330 651 330 $C.blue $true
    Text 54 431 852 45 '20 minutes · read the demo PDDL files' 28 $C.muted
   }
   'classical' {
    Card 54 211 246 185 'Initial state' 'Robot at delivery; parcel at pickup.'
    Card 357 211 246 185 'Actions' 'Move, pick, move, place.' $C.paleTeal $C.teal
    Card 660 211 246 185 'Goal' 'Parcel at delivery.'
    Line 307 298 349 298 $C.blue $true;Line 609 298 651 298 $C.teal $true
    Text 54 438 852 42 'Known state · deterministic outcomes · discrete actions' 26 $C.muted
   }
   'facts' {
    Code 54 211 518 113 'Predicate declaration · domain.pddl' $snippets.predicate.code
    Code 54 349 518 113 'Concrete fact · problem.pddl' $snippets.fact.code $C.paleTeal
    Text 616 221 290 72 'A pattern with a location placeholder.' 26 $C.blue $true
    Text 616 359 290 92 'A statement about one actual location.' 26 $C.teal $true
   }
   'goal' {
    Code 54 211 852 116 'Goal excerpt · problem.pddl' $snippets.goal.code
    Card 54 351 410 131 'Initially true' 'Robot at delivery; hand empty.'
    Card 486 351 420 131 'Initially false' 'Holding parcel; parcel at delivery.' $C.paleTeal $C.teal
   }
   'domain' {
    Card 54 211 410 217 'domain.pddl' "Vocabulary`nAction rules`nReusable model"
    Card 486 211 420 217 'problem.pddl' "Objects`nInitial facts + goal`nOne delivery instance" $C.paleTeal $C.teal
    Text 54 451 852 35 'PDDL describes the task. Pyperplan searches for a plan.' 26 $C.muted $true
   }
   'objects' {
    Code 54 201 664 106 'Types excerpt · domain.pddl' $snippets.types.code
    Code 54 325 664 157 'Objects excerpt · problem.pddl' $snippets.objects.code $C.paleTeal
    Text 744 213 162 93 'parcel: a package object' 25 $C.blue $true
    Text 744 344 162 134 "?p: variable`n-: type label" 25 $C.teal $true
   }
   'initial' {
    Code 54 201 520 199 'Initial facts · opening excerpt' $snippets.init.code
    Box 54 412 590 70 $C.paleTeal;Text 72 417 554 30 'Goal excerpt' 24 $C.muted $true;Text 72 450 554 32 $snippets.goal.code 24 $C.teal $false 1 'Consolas'
    Scene 651 209 245
   }
   'anatomy' {
    Card 54 207 272 171 'Parameters' 'Which package and location?'
    Card 344 207 272 171 'Preconditions' 'What must be true before?' $C.paleTeal $C.teal
    Card 634 207 272 171 'Effects' 'What changes afterward?'
    Tag 54 411 195 'move-empty';Tag 273 411 195 'move-loaded';Tag 492 411 195 'pick';Tag 711 411 195 'place'
   }
   'pick' {
    Code 54 201 636 269 'pick excerpt · domain.pddl' $snippets.pickhead.code
    Text 708 216 198 90 'Robot and parcel together.' 26 $C.blue $true
    Text 718 325 188 67 'Hand empty.' 26 $C.teal $true
    Text 718 416 188 59 'and = all three' 24 $C.muted
   }
   'effects' {
    Code 54 199 852 178 'pick effects excerpt · domain.pddl' $snippets.pickeffect.code
    Text 54 389 407 32 'Before pick · at pickup' 24 $C.blue $true
    Text 500 389 406 32 'After pick' 24 $C.teal $true
    Text 54 430 407 59 "(package-at parcel pickup)`n(hand-empty)" 24 $C.red $false 1 'Consolas'
    Text 500 430 406 59 "(holding parcel)`nkept: (robot-at pickup)" 24 $C.teal $false 1 'Consolas'
   }
   'loaded' {
    Code 54 205 450 211 'move-loaded · preconditions' $snippets.loadedpre.code
    Code 522 205 384 211 'Same action · effects' $snippets.moveeffect.code
    Text 54 440 852 43 'Holding persists; only the robot location changes.' 27 $C.teal $true
   }
   'grounding' {
    Code 54 209 410 111 'Schema pattern' '(pick ?p ?l)'
    Code 486 209 420 111 'Grounded instance' '(pick parcel pickup)' $C.paleTeal
    Line 468 271 483 271 $C.blue $true
    Card 54 351 410 131 'Initially' 'Exists, but is not applicable.'
    Card 486 351 420 131 'After the empty move' 'Its preconditions now hold.' $C.paleTeal $C.teal
   }
   'search' {
    PlanList $candidate 54 205 852 -1 47
    $labels=@('Initial','At pickup','Holding','At delivery','Delivered')
    for($idx=0;$idx -lt 5;$idx++){$xx=54+$idx*173;Box $xx 414 160 49 $C.paleBlue;Text ($xx+8) 425 144 33 $labels[$idx] 24 $C.blue $true 2;if($idx -lt 4){Line ($xx+162) 439 ($xx+169) 439 $C.blue $true}}
   }
   'part2' {
    Text 54 211 852 57 'Task and Motion Planning' 36 $C.teal $true
    Card 54 302 410 150 'Symbolic task' 'What should happen?'
    Card 486 302 420 150 'Geometric motion' 'Can it happen in this scene?' $C.paleTeal $C.teal
   }
   'connect' {
    Card 54 211 372 177 'Task level' "Named locations`nPossession + actions"
    Card 534 211 372 177 'Motion level' "Coordinates + footprint`nCollision-free motion" $C.paleTeal $C.teal
    Line 442 303 518 303 $C.teal $true $false $true
    Text 54 432 852 53 'PRM can support motion queries. This demo checks straight segments.' 26 $C.muted
   }
   'failure' {
    PlanList $candidate 54 207 594 2 43
    Tag 54 409 455 'Candidate only · not executed' $C.paleAmber $C.amber
    Text 54 464 455 29 'Third action fails geometric validation.' 24 $C.red $true
    Scene 671 226 210 'rejected'
   }
   'footprints' {
    Passage 54 211 .12 'Empty · diameter 0.24 m' $C.teal
    Passage 516 211 .25 'Loaded · diameter 0.50 m' $C.red
    Text 54 463 852 31 'Gap: 0.40 m   |   Centerline clearance: 0.20 m' 26 $C.muted $true
   }
   'loop' {
    Tag 54 214 255 'Symbolic search';Tag 360 214 240 'Candidate';Tag 651 214 255 'Geometric check' $C.paleTeal $C.teal
    Line 315 235 350 235 $C.blue $true;Line 606 235 641 235 $C.blue $true
    Tag 651 322 255 'Execute if valid' $C.paleTeal $C.teal;Line 777 262 777 312 $C.teal $true
    Tag 54 322 406 'Refine permission if rejected' $C.paleAmber $C.amber
    Line 658 271 468 340 $C.red $true;Line 177 316 177 265 $C.amber $true
    Text 54 432 852 46 'Hypothetical checking; replan from the original initial state.' 26 $C.muted $true
   }
   'refine' {
    Code 54 202 852 86 'REMOVE · one loaded direction' $snippets.permission.code $C.pink
    Code 54 300 852 86 'KEEP · empty shortcut' $snippets.emptypermission.code $C.paleTeal
    Code 54 398 852 86 'KEEP · reverse permission' $snippets.reversepermission.code $C.paleTeal
   }
   'revised' {
    Scene 54 207 276 'revised'
    Text 384 210 522 274 "1 (move-empty delivery pickup)`n2 (pick parcel pickup)`n3 (move-loaded parcel pickup`n   upper-left)`n4 (move-loaded parcel upper-left`n   upper-right)`n5 (move-loaded parcel upper-right`n   delivery)`n6 (place parcel delivery)" 24 $C.ink $false 1 'Consolas'
   }
   'stages' {
    Card 54 211 272 211 'Plan' 'Propose actions from symbolic facts.'
    Card 344 211 272 211 'Validate' 'Check motions in a hypothetical state.' $C.paleTeal $C.teal
    Card 634 211 272 211 'Execute' 'Animate only the validated plan.'
    Text 54 449 852 42 'Facts update when an action finishes.' 27 $C.teal $true
   }
   'demo' {
    [void]$script:slide.Shapes.AddPicture((Join-Path $root 'demo/rejected.png'),0,-1,54,208,470,274.17)
    Text 598 214 308 59 'Predict the failure.' 28 $C.blue $true
    Text 598 306 308 86 'Inspect the refinement.' 28 $C.teal $true
    Text 598 420 308 68 '10 min demo + 5 min recap' 27 $C.muted $true
   }
   'place' {
    Code 54 201 852 269 'Complete action · domain.pddl' $snippets.place.code
   }
   'state_backup' {
    Formula 54 209 852 57 'S_{next} = (S ∖ Delete) ∪ Add' 36 $C.blue
    Formula 54 288 852 57 'Preconditions ⊆ S' 34 $C.teal
    Card 54 364 410 118 'Grounding' 'Substitute concrete objects.'
    Card 486 364 420 118 'BFS' 'Search by action count.' $C.paleTeal $C.teal
   }
   'geometry_backup' {
    Formula 54 210 852 58 'min_{s∈[0,1]} distance((1−s)a + sb, wall) > radius' 31 $C.blue
    Text 54 302 852 40 'Shortcut: 0.20 m clearance' 30 $C.ink $true
    Card 54 371 410 111 'Empty radius: 0.12 m' 'Passes.' $C.paleTeal $C.teal
    Card 486 371 420 111 'Loaded radius: 0.25 m' 'Fails; contact also fails.' $C.pink $C.red
   }
   'limits' {
    Card 54 211 272 225 'Symbolic failure' 'No plan with the remaining connections.'
    Card 344 211 272 225 'Geometric failure' 'A candidate footprint or motion is blocked.' $C.paleTeal $C.teal
    Card 634 211 272 225 'Broader TAMP' 'Search grasps, poses, placements, and paths.'
    Text 54 453 852 35 '16 permissions → at most 17 searches in this finite demo.' 25 $C.muted
   }
  }
 }
 if($presentation.Slides.Count -ne 27){throw 'Expected 27 slides'}
 $pddl=($script:slides | Where-Object {$_.number -ge 2 -and $_.number -le 14} | Measure-Object minutes -Sum).Sum
 $tamp=($script:slides | Where-Object {$_.number -ge 15 -and $_.number -le 22} | Measure-Object minutes -Sum).Sum
 if($pddl -ne 20 -or $tamp -ne 10 -or ($script:slides | Measure-Object minutes -Sum).Sum -ne 45){throw 'Timing differs'}
 foreach($item in $presentation.Slides){foreach($shape in $item.Shapes){if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){$tr=$shape.TextFrame.TextRange;if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$script:issues.Add("Slide $($item.SlideIndex): $([math]::Round($tr.BoundWidth,1))×$([math]::Round($tr.BoundHeight,1)) exceeds $($shape.Width)×$($shape.Height): $($tr.Text)")}}}}
 New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
 if(-not $NoPreview){foreach($item in $presentation.Slides){$item.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $item.SlideIndex)),'PNG',1600,900)}}
 $presentation.SaveAs($pdfPath,32)
 foreach($info in $script:slides){if($info.backup){$presentation.Slides.Item($info.number).SlideShowTransition.Hidden=-1}}
 $presentation.SaveAs($pptxPath,24);$presentation.Close();$presentation=$null
 $check=$app.Presentations.Open($pptxPath,-1,0,0)
 if($check.Slides.Count -ne 27){throw 'Reopened count differs'}
 for($idx=1;$idx -le 27;$idx++){$item=$check.Slides.Item($idx);if(($item.SlideShowTransition.Hidden -eq -1) -ne ($idx -ge 24)){throw "Hidden state differs: $idx"};if($item.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;totalMinutes=45;presentationMinutes=30;pddlMinutes=20;tampMinutes=10;demoMinutes=10;recapMinutes=5;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;independentChecks=$lessonChecks;excerptChecks=$excerptChecks;sourceChecks=$sourceChecks;pythonSuiteRun=$false;pythonLimitation='Python unavailable; independent C# checks are not Pyperplan or GUI execution.'} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created/reopened 27 slides, four hidden backups, notes on every slide. All 13 protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
}finally{
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}

