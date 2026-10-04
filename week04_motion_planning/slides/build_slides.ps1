param([switch]$NoPreview, [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$OutputBaseName='CONFIGURATION_SPACE_AND_PRM')
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
  Text 54 26 720 24 $(if ($backup) {'OPTIONAL / DEEPER DISCUSSION'} else {'WEEK 04 / CONFIGURATION SPACE & PRM'}) 16 $C.teal $true
  Text 54 64 852 60 $title 40 $C.ink $true
  if ($subtitle) { Text 54 124 852 64 $subtitle 26 $C.muted }
  Line 54 494 906 494 $C.line
  Text 54 504 660 24 'Robotics & Autonomous Systems · Motion Planning' 16 $C.muted
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

$C.red=Color 'C43C47'; $C.pink=Color 'F4DDE1'; $C.orange=Color 'E88932'; $C.green=Color '21965B'
Add-Type -Path (Join-Path $PSScriptRoot 'GeometryChecks.cs')
$numericChecks=[Week4Geometry]::Check()
$plannerSource=Get-Content (Join-Path $root 'demo/planner.py') -Raw -Encoding UTF8
$robotSource=Get-Content (Join-Path $root 'demo/robot.py') -Raw -Encoding UTF8
$testSource=Get-Content (Join-Path $root 'demo/test_demo.py') -Raw -Encoding UTF8
$sourceChecks=@(
 @{label='Query copies reusable points and adjacency rows';source=$plannerSource;snippet='Roadmap(list(roadmap.points), [list(row) for row in roadmap.adjacency]'},
 @{label='Exact endpoints appended to query graph';source=$plannerSource;snippet='graph.points.extend([start, goal])'},
 @{label='Attachments select k nearest preprocessing points';source=$plannerSource;snippet='nearest(roadmap.points, graph.points[i], graph.neighbors)'},
 @{label='Direct query edge is checked through connect';source=$plannerSource;snippet='connect(graph, first, first+1)'},
 @{label='Equal endpoints return one point and zero length';source=$plannerSource;snippet="QueryResult([start], 0.0, 'Start equals goal.', graph)"},
 @{label='Configuration predicate rejects padded contact';source=$robotSource;snippet='return clearance(q) > PADDING'},
 @{label='Stored edges have matching reverse weights';source=$plannerSource;snippet='graph.adjacency[b].append((a, weight))'},
 @{label='Existing tests cover immutable query and deterministic prefix';source=$testSource;snippet='def test_determinism_prefix_and_no_mutation'},
 @{label='Existing tests cover invalid, failed and equal queries';source=$testSource;snippet='def test_failures_and_equal_endpoints'}
)
foreach($audit in $sourceChecks){if(-not $audit.source.Contains($audit.snippet)){throw "Source differs from lesson: $($audit.label)"}}
$samplePoints=[Week4Geometry]::Points
$roadEdges=[Week4Geometry]::Edges($samplePoints,4)
$examplePath=[Week4Geometry]::QueryPath()
function XY([double[]]$q,[double]$x,[double]$y,[double]$side){return @(($x+($q[0]+[math]::PI)*$side/(2*[math]::PI)),($y+$side-($q[1]+[math]::PI)*$side/(2*[math]::PI)))}
function Space([double]$x,[double]$y,[double]$side,[bool]$grid=$true){
 $rect=$script:slide.Shapes.AddShape(1,$x,$y,$side,$side);$rect.Fill.ForeColor.RGB=$C.white;$rect.Line.Visible=0
 if($grid){$n=25;$cell=$side/$n;for($row=0;$row -lt $n;$row++){for($col=0;$col -lt $n;$col++){$q=@(((-[math]::PI)+($col+.5)*2*[math]::PI/$n),([math]::PI-($row+.5)*2*[math]::PI/$n));if(-not [Week4Geometry]::Free($q)){$s=$script:slide.Shapes.AddShape(1,($x+$col*$cell),($y+$row*$cell),($cell+.1),($cell+.1));$s.Fill.ForeColor.RGB=$C.pink;$s.Line.Visible=0}}}}
 Line $x $y ($x+$side) $y $C.line;Line $x ($y+$side) ($x+$side) ($y+$side) $C.line;Line $x $y $x ($y+$side) $C.line;Line ($x+$side) $y ($x+$side) ($y+$side) $C.line
 Line ($x+$side/2) $y ($x+$side/2) ($y+$side) $C.line $false $true;Line $x ($y+$side/2) ($x+$side) ($y+$side/2) $C.line $false $true
 Text ($x+$side/2-28) ($y+$side+5) 120 32 'q₁ (rad)' 24 $C.muted
 Text ($x-40) ($y-5) 38 34 'π' 24 $C.muted;Text ($x-48) ($y+$side-25) 43 34 '−π' 24 $C.muted
 Text ($x+$side+7) ($y+2) 90 32 'q₂' 24 $C.muted
}
function QPoint([double[]]$q,[double]$x,[double]$y,[double]$side,[int]$color=$C.blue,[double]$radius=4){$p=XY $q $x $y $side;Dot $p[0] $p[1] $radius $color}
function QLine([double[]]$a,[double[]]$b,[double]$x,[double]$y,[double]$side,[int]$color=$C.blue,[bool]$dashed=$false){$p=XY $a $x $y $side;$end=XY $b $x $y $side;Line $p[0] $p[1] $end[0] $end[1] $color $false $dashed}
function Road([double]$x,[double]$y,[double]$side,[bool]$edges=$true,[bool]$path=$false){
 Space $x $y $side
 if($edges){foreach($pair in $roadEdges){QLine $samplePoints[$pair[0]] $samplePoints[$pair[1]] $x $y $side $C.line}}
 if($path){for($j=1;$j -lt $examplePath.Length;$j++){QLine $examplePath[$j-1] $examplePath[$j] $x $y $side $C.teal}}
 foreach($q in $samplePoints){QPoint $q $x $y $side}
 if($path){QPoint ([Week4Geometry]::Start) $x $y $side $C.orange 6;QPoint ([Week4Geometry]::Goal) $x $y $side $C.teal 6}
}
function Arm([double[]]$q,[double]$x,[double]$y,[double]$scale,[bool]$axes=$false){
 $points=[Week4Geometry]::FK($q);$fill=if([Week4Geometry]::Free($q)){$C.blue}else{$C.red}
 $obs=$script:slide.Shapes.AddShape(9,($x+.8*$scale-.12*$scale),($y-.12*$scale),(.24*$scale),(.24*$scale));$obs.Fill.ForeColor.RGB=$C.paleAmber;$obs.Line.ForeColor.RGB=$C.amber
 $pad=$script:slide.Shapes.AddShape(9,($x+.8*$scale-.13*$scale),($y-.13*$scale),(.26*$scale),(.26*$scale));$pad.Fill.Visible=0;$pad.Line.ForeColor.RGB=$C.amber;$pad.Line.DashStyle=4
 if($axes){Line $x $y ($x+.35*$scale) $y $C.muted $true;Line $x $y $x ($y-.35*$scale) $C.muted $true;Text ($x+.35*$scale) ($y+3) 32 32 'x' 24;Text ($x-26) ($y-.35*$scale-20) 30 32 'y' 24}
 for($j=0;$j -lt 2;$j++){$a=$points[$j];$b=$points[$j+1];$color=if($j -eq 0){$fill}else{$C.orange};if(-not [Week4Geometry]::Free($q)){$color=$C.red};Line ($x+$a[0]*$scale) ($y-$a[1]*$scale) ($x+$b[0]*$scale) ($y-$b[1]*$scale) $color;$s=$script:slide.Shapes.Item($script:slide.Shapes.Count);$s.Line.Weight=.06*$scale;Dot ($x+$a[0]*$scale) ($y-$a[1]*$scale) (.03*$scale) $color;Dot ($x+$b[0]*$scale) ($y-$b[1]*$scale) (.03*$scale) $color}
 Dot $x $y 7 $C.ink
}
function Cues($item){Card 432 209 474 130 'Implement' $item.implement;Card 432 352 474 130 'Check' $item.check $C.paleTeal $C.teal}
function QueryXY([double[]]$q){return @((54+($q[0]+2.5)*348/3.6),(422-($q[1]+.3)*211/2.7))}
function QueryDiagram {
 $x=54;$y=211;$w=348;$h=211;$n=28
 Box $x $y $w $h $C.white
 for($row=0;$row -lt $n;$row++){for($col=0;$col -lt $n;$col++){$q=@((-2.5+($col+.5)*3.6/$n),(2.4-($row+.5)*2.7/$n));if(-not [Week4Geometry]::Free($q)){$s=$script:slide.Shapes.AddShape(1,($x+$col*$w/$n),($y+$row*$h/$n),($w/$n+.1),($h/$n+.1));$s.Fill.ForeColor.RGB=$C.pink;$s.Line.Visible=0}}}
 $indices=@(15,0,1,2,3,4,5,6,7)
 foreach($pair in $roadEdges){if($indices -contains $pair[0] -and $indices -contains $pair[1]){$a=QueryXY $samplePoints[$pair[0]];$b=QueryXY $samplePoints[$pair[1]];Line $a[0] $a[1] $b[0] $b[1] $C.line}}
 $q=[Week4Geometry]::Start;$p=QueryXY $q
 foreach($idx in @(1,0)){if(-not [Week4Geometry]::Edge($q,$samplePoints[$idx],.01)){throw 'Invalid illustrated attachment'};$b=QueryXY $samplePoints[$idx];Line $p[0] $p[1] $b[0] $b[1] $C.teal}
 if([Week4Geometry]::Edge($q,$samplePoints[5],.01)){throw 'Rejected connection must collide'}
 $b=QueryXY $samplePoints[5];Line $p[0] $p[1] $b[0] $b[1] $C.red $false $true
 $b=QueryXY $samplePoints[7];Line $p[0] $p[1] $b[0] $b[1] $C.orange $false $true
 foreach($idx in $indices){$a=QueryXY $samplePoints[$idx];Dot $a[0] $a[1] 5 $C.blue}
 Dot $p[0] $p[1] 8 $C.orange;Formula ($p[0]-40) ($p[1]+14) 94 40 'q_{new}' 28 $C.amber
}
function TinyGraph([double]$x,[double]$y){
 Line $x ($y+95) ($x+110) $y $C.teal;Line ($x+110) $y ($x+220) ($y+95) $C.teal;Line $x ($y+95) ($x+220) ($y+95) $C.line
 Text ($x+17) ($y+28) 55 35 '1' 26 $C.teal;Text ($x+175) ($y+28) 55 35 '1' 26 $C.teal;Text ($x+102) ($y+100) 60 35 '5' 26 $C.muted
 foreach($v in @(@($x,($y+95),'0'),@(($x+110),$y,'1'),@(($x+220),($y+95),'2'),@(($x+290),($y-15),'3'))){Dot $v[0] $v[1] 17 $C.blue;Text ($v[0]-14) ($v[1]-15) 28 35 $v[2] 24 $C.white $true 2}
 Text ($x+235) ($y+15) 140 36 'isolated' 24 $C.muted
}

# The plan and notes come from the same source, so sequence and timings agree.
$planLines=New-Object System.Collections.Generic.List[string]
$planLines.Add('# Week 4 — Configuration Space and PRM')
$planLines.Add('')
$planLines.Add('English, 16:9 deck: 22 slides, including five hidden backups. **20 minutes explanation + 25 minutes code/demo/questions.** Gazebo and ROS are not needed. Preserve demo files, demo README, and teaching notes. Minimal visible words, editable diagrams/equations, detailed speaker notes.')
$planLines.Add('')
$planLines.Add('## Sequence and timing')
$planLines.Add('')
$planLines.Add('| Deck slide | Content | Minutes |')
$planLines.Add('|---|---|---:|')
for($idx=0;$idx -lt $lesson.Count;$idx++){$item=$lesson[$idx];$planLines.Add("| $($idx+1) | $($item.title)$(if($item.backup){' (hidden)'}) | $($item.minutes) |")}
$planLines.Add('')
$planLines.Add('## Slide guidance, diagrams, implementation, and checks')
for($idx=0;$idx -lt $lesson.Count;$idx++){$item=$lesson[$idx];$planLines.Add('');$planLines.Add("### $($idx+1). $($item.title)");$planLines.Add('');$planLines.Add("Timing: $($item.minutes) min$(if($item.backup){'; optional hidden backup'}). $($item.subtitle)");$planLines.Add('');if($item.implement){$planLines.Add("**Implement:** $($item.implement) **Check:** $($item.check)");$planLines.Add('')};$planLines.Add($item.notes.Trim());$planLines.Add('');foreach($ref in $item.refs){$planLines.Add("- $($sources[$ref])")}}
$planLines.Add('')
$planLines.Add('## Validation and limitations')
$planLines.Add('')
$planLines.Add('Read all nine original Week 4 files. The separate professor PDF was not found locally; its credited section and printed-slide references are retained, without claiming review. PowerPoint generation checks include all 22 slide renders, notes, five hidden states, reopen, 22 PDF pages, text bounds, and protected-file SHA256 hashes. Independent C# numerical checks validate geometry and illustrative attachments/path at 0.002 rad. Existing Python tests and GUI were read but cannot be run here because Python is unavailable; historical 20/300-sample results belong to the documented TA-machine validation. Current checks do not claim a new classroom rehearsal. Consult slides/validation.json and slides/README.md for exact evidence. Local collision validation is sampled; a denser replay is additional evidence, not a continuous safety proof. Self-collision is unmodeled and playback is kinematic.')
[IO.File]::WriteAllText($planPath,($planLines -join "`r`n"),[Text.UTF8Encoding]::new($false))

$app=$null;$presentation=$null;$hadExistingPresentations=$true
try{
 $app=New-Object -ComObject PowerPoint.Application
 $hadExistingPresentations=($app.Presentations.Count -gt 0)
 $presentation=$app.Presentations.Add(0);$presentation.PageSetup.SlideWidth=$W;$presentation.PageSetup.SlideHeight=$H
 foreach($item in $lesson){
  $refs=($item.refs | ForEach-Object {$sources[$_]}) -join "`r`n"
  $notes="TIMING: $($item.minutes) minutes. $($item.notes.Trim())`r`n`r`nSOURCES`r`n$refs"
  NewSlide $item.title $item.subtitle $item.minutes $notes ([bool]$item.backup)
  switch($item.kind){
   'title' {
    Arm ([Week4Geometry]::Start) 90 318 205 $true
    Road 604 205 209 $true $true
    Text 54 441 472 40 '20 min concepts · 25 min demo' 26 $C.teal $true
    Text 576 454 330 32 'Illustrative roadmap' 24 $C.muted
   }
   'motivation' {
    $poses=@([Week4Geometry]::Start,@(0.0,0.0),[Week4Geometry]::Goal)
    $labels=@('Start: free','Midpoint: collision','Goal: free')
    for($j=0;$j -lt 3;$j++){$xx=54+288*$j;Text $xx 206 270 42 $labels[$j] 26 $(if($j -eq 1){$C.red}else{$C.teal}) $true;Arm $poses[$j] ($xx+30) 340 190;Text $xx 437 270 35 @('q = (−0.7, 0.6)','q = (0, 0)','q = (0.7, −0.6)')[$j] 24}
   }
   'comparison' {
    Card 54 211 272 221 'Task planning' "Approach → grasp → place`nChoose actions." $C.paleBlue $C.blue
    Card 344 211 272 221 'Graph search' "Find a route among known connections." $C.paleTeal $C.teal
    Card 634 211 272 221 'Motion planning' "Move the whole robot without collision." $C.paleBlue $C.blue
    Text 54 451 852 40 'PRM builds geometric connections, then searches them.' 26 $C.ink $true
   }
   'spaces' {
    Text 54 203 340 40 'Workspace · metres' 27 $C.blue $true
    Arm ([Week4Geometry]::Start) 94 340 205 $true
    Text 54 439 416 40 'Links: 0.6 m + 0.4 m' 26
    Space 623 208 220 $false;QPoint ([Week4Geometry]::Start) 623 208 220 $C.orange 8
    Formula 450 302 148 60 '↔' 48 $C.teal 2
    Text 525 461 381 32 'q = (−0.7, 0.6) rad' 26 $C.teal $true
   }
   'obstacles' {
    Arm @(0.0,0.0) 87 330 300 $true
    Text 54 431 412 58 'Tip is clear. Link 2 collides.' 26 $C.red $true
    Space 627 211 218;QPoint @(0.0,0.0) 627 211 218 $C.red 7
    Text 538 451 368 36 'Blocked region: approximate' 24 $C.muted
   }
   'endpoints' {
    Space 105 211 218;QLine ([Week4Geometry]::Start) ([Week4Geometry]::Goal) 105 211 218 $C.red
    QPoint ([Week4Geometry]::Start) 105 211 218 $C.teal 7;QPoint ([Week4Geometry]::Goal) 105 211 218 $C.teal 7;QPoint @(0.0,0.0) 105 211 218 $C.red 7
    Formula 441 216 465 63 'q(s) = (1−s)q_{start} + sq_{goal}' 32 $C.blue
    Tag 441 304 465 's = 0, 1: free' $C.paleTeal $C.teal
    Tag 441 373 465 's = ½: collision' $C.paleAmber $C.red
    Text 54 451 852 37 'A valid motion needs valid intermediate configurations.' 26 $C.ink $true
   }
   'pipeline' {
    $steps=@('Sample','Filter','Neighbors','Validate','Store graph','Attach query','Search','Verify')
    for($j=0;$j -lt 8;$j++){$col=$j%4;$row=[math]::Floor($j/4);$xx=54+$col*219;$yy=216+$row*134;Box $xx $yy 195 94 $(if($row -eq 0){$C.paleBlue}else{$C.paleTeal});Text ($xx+15) ($yy+14) 165 35 ($j+1) 25 $C.muted $true;Text ($xx+15) ($yy+53) 168 34 $steps[$j] 24 $C.ink $true;if($col -lt 3){Line ($xx+198) ($yy+48) ($xx+214) ($yy+48) $C.blue $true}}
    Text 54 461 852 33 'Build once → reuse for many start–goal queries.' 25 $C.teal $true
   }
   'sampling' {
    Road 106 211 211 $false
    QPoint @(0.0,0.0) 106 211 211 $C.red 5
    Text 54 458 348 31 'Attempts ≠ accepted samples' 24 $C.muted
    Cues $item
   }
   'filter' {
    Arm @(0.0,0.0) 88 307 270
    Formula 54 396 350 43 'clearance(q) > 0.01 m' 28 $C.teal
    Text 54 450 350 35 'Thickness + padding matter.' 24 $C.muted
    Cues $item
   }
   'neighbors' {
    Road 106 211 211 $false
    $q=[Week4Geometry]::Start
    foreach($idx in [Week4Geometry]::Nearest($samplePoints,$q,4,-1)){QLine $q $samplePoints[$idx] 106 211 211 $C.orange $true}
    QPoint $q 106 211 211 $C.orange 7
    Formula 54 458 357 34 'd(q,a) = ‖q−a‖₂' 27 $C.blue
    Cues $item
   }
   'local' {
    Space 106 211 211
    QLine ([Week4Geometry]::Start) ([Week4Geometry]::Goal) 106 211 211 $C.red
    foreach($q in [Week4Geometry]::Interpolate([Week4Geometry]::Start,[Week4Geometry]::Goal,.1)){QPoint $q 106 211 211 $(if([Week4Geometry]::Free($q)){$C.teal}else{$C.red}) 3}
    Text 54 458 362 31 '≤ 0.01 rad per joint per step' 24 $C.blue $true
    Cues $item
   }
   'graph' {
    Road 106 211 211
    Formula 54 458 362 34 'w_{ab} = ‖q_{a}−q_{b}‖₂' 27 $C.blue
    Cues $item
   }
   'unsampled' {
    QueryDiagram
    Line 54 448 79 448 $C.teal;Text 86 432 100 36 'valid' 24 $C.teal
    Line 183 448 209 448 $C.red $false $true;Text 215 432 119 36 'rejected' 24 $C.red
    Text 54 464 348 31 'Orange dashed: candidate' 24 $C.amber
    Cues $item
   }
   'search' {
    TinyGraph 66 283
    Text 54 438 356 44 '0 → 1 → 2: total cost 2' 26 $C.teal $true
    Cues $item
   }
   'verify' {
    Road 106 211 211 $true $true
    Text 54 458 359 31 'Replay more densely: 0.002 rad' 24 $C.teal
    Cues $item
   }
   'failure' {
    Card 54 208 410 170 '20 samples · seed 7' "91 edges`nPath length: 5.630 rad" $C.paleBlue $C.blue
    Card 486 208 420 170 '300 samples · seed 7' "1,728 edges`nPath length: 5.243 rad" $C.paleTeal $C.teal
    Text 54 399 852 40 'Both found a route in the documented TA run.' 26 $C.ink $true
    Text 54 451 852 40 'More samples can help; success and better cost are not guaranteed.' 24 $C.muted
   }
   'demo' {
    [void]$script:slide.Shapes.AddPicture((Join-Path $root 'demo/overview.png'),0,-1,54,208,510,276.25)
    Text 596 217 310 57 '5 min · read the code' 27 $C.blue $true
    Text 596 306 310 83 '12 min · reveal + animate' 27 $C.teal $true
    Text 596 412 310 69 '8 min · compare + recap' 27 $C.blue $true
   }
   'collision_backup' {
    Formula 54 209 852 50 'u = clamp(((c−a)·(b−a))/‖b−a‖², 0, 1)' 32 $C.blue
    Formula 54 280 852 50 'd = ‖c − (a + u(b−a))‖' 34
    Formula 54 350 852 50 'clearance = min(d_{link1}, d_{link2}) − 0.12 − 0.03' 32 $C.teal
    Text 54 431 852 44 'Free only when clearance > 0.01 m. Padded contact is blocked.' 26 $C.ink $true
   }
   'topology_backup' {
    Space 107 211 211 $false
    QLine @(-3.0,0.0) @(3.0,0.0) 107 211 211 $C.red
    Text 54 458 362 32 'Boundaries do not wrap.' 25 $C.red $true
    Formula 429 218 477 55 'C = [−π, π] × [−π, π]' 32 $C.blue
    Formula 429 300 477 55 'q(s) = (1−s)a + sb' 32 $C.teal
    Text 429 392 477 79 'Unrestricted revolute joints need a periodic model and metric.' 26 $C.muted
   }
   'pseudocode_backup' {
    Box 54 207 410 263 $C.paleBlue;Text 72 219 374 43 'Build roadmap' 29 $C.blue $true
    Text 72 281 374 180 "sample free q`nchoose k neighbors`nvalidate local motions`nstore weighted edges" 24 $C.ink $false 1 'Consolas'
    Box 486 207 420 263 $C.paleTeal;Text 504 219 384 43 'Attach and query' 29 $C.teal $true
    Text 504 281 384 180 "copy roadmap`nvalidate + add endpoints`ncheck attachments + direct`nDijkstra; verify route" 24 $C.ink $false 1 'Consolas'
   }
   'tests_backup' {
    TinyGraph 69 294
    Text 54 444 353 37 'Route [0,1,2], cost 2' 26 $C.teal $true
    Card 465 204 441 131 'Search' 'Known cost; disconnected; zero length.'
    Card 465 351 441 131 'Query + geometry' 'Exact endpoints; copy; blocked midpoint.' $C.paleTeal $C.teal
   }
   'limits_backup' {
    Card 54 209 272 230 'Finite failure' 'No route in this graph does not prove no physical route.'
    Card 344 209 272 230 'Completeness' 'Asymptotic claims require assumptions.' $C.paleTeal $C.teal
    Card 634 209 272 230 'Optimality' 'Shortest in this graph is not globally shortest.'
    Text 54 453 852 37 'No completeness or optimality theorem for this fixed-k demo.' 24 $C.muted
   }
  }
 }
 if($presentation.Slides.Count -ne 22){throw 'Expected 22 slides'}
 $explanation=($script:slides | Where-Object {$_.number -ge 2 -and $_.number -le 16} | Measure-Object minutes -Sum).Sum
 if($explanation -ne 20 -or ($script:slides | Measure-Object minutes -Sum).Sum -ne 45){throw 'Incorrect lesson timing'}
 foreach($item in $presentation.Slides){foreach($shape in $item.Shapes){if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){$tr=$shape.TextFrame.TextRange;if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$script:issues.Add("Slide $($item.SlideIndex): text $([math]::Round($tr.BoundWidth,1))×$([math]::Round($tr.BoundHeight,1)) exceeds box $($shape.Width)×$($shape.Height): $($tr.Text)")}}}}
 New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
 if(-not $NoPreview){foreach($item in $presentation.Slides){$item.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $item.SlideIndex)),'PNG',1600,900)}}
 $presentation.SaveAs($pdfPath,32)
 foreach($info in $script:slides){if($info.backup){$presentation.Slides.Item($info.number).SlideShowTransition.Hidden=-1}}
 $presentation.SaveAs($pptxPath,24);$presentation.Close();$presentation=$null
 $check=$app.Presentations.Open($pptxPath,-1,0,0)
 if($check.Slides.Count -ne 22){throw 'Reopened slide count incorrect'}
 for($idx=1;$idx -le 22;$idx++){$item=$check.Slides.Item($idx);if(($item.SlideShowTransition.Hidden -eq -1) -ne ($idx -ge 18)){throw "Hidden state incorrect: $idx"};if($item.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;timingMinutes=45;explanationMinutes=20;demoMinutes=25;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;numericChecks=$numericChecks;sourceChecks=@($sourceChecks | ForEach-Object {$_.label});illustrativePath=$examplePath;pythonSuiteRun=$false;pythonLimitation='No installed Python; existing tests read, not executed.';generated=@(($OutputBaseName+'.pptx'),($OutputBaseName+'.pdf'))} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created and reopened: 22 slides, 5 hidden backups, notes on every slide. Protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
} finally {
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}
