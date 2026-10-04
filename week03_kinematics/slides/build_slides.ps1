param([switch]$NoPreview, [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$OutputBaseName='GAZEBO_AND_KINEMATICS')
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
  Text 54 26 720 24 $(if ($backup) {'OPTIONAL / DEEPER DISCUSSION'} else {'WEEK 03 / GAZEBO & KINEMATICS'}) 16 $C.teal $true
  Text 54 64 852 60 $title 40 $C.ink $true
  if ($subtitle) { Text 54 124 852 64 $subtitle 26 $C.muted }
  Line 54 494 906 494 $C.line
  Text 54 504 660 24 'Robotics & Autonomous Systems · ROS 2 Jazzy / Gazebo Harmonic' 16 $C.muted
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
 Box $x $y $w $h $fill; Text ($x+18) ($y+15) ($w-36) 42 $label 28 $color $true; Text ($x+18) ($y+69) ($w-36) ($h-76) $body 24
}
$C.orange=Color 'E88932'; $C.green=Color '21965B'
$screenshotPath=Join-Path $PSScriptRoot 'assets/gazebo_screenshot.png'
# Extract the original embedded PNG without altering the protected SVG.
$svg=[IO.File]::ReadAllText((Join-Path $root 'demo/gazebo_overview.svg'))
$encoded=[regex]::Match($svg,'data:image/png;base64,([A-Za-z0-9+/=]+)')
if(-not $encoded.Success){throw 'Embedded demo screenshot missing'}
New-Item -ItemType Directory -Path (Split-Path $screenshotPath) -Force | Out-Null
[IO.File]::WriteAllBytes($screenshotPath,[Convert]::FromBase64String($encoded.Groups[1].Value))
function Screenshot([double]$x,[double]$y,[double]$w,[bool]$closeup=$false){
 $picture=$script:slide.Shapes.AddPicture($screenshotPath,0,-1,$x,$y,$w,($w*736/1300))
 if($closeup){
  # Cropping is retained as editable PowerPoint picture formatting.
  $crop=$picture.PictureFormat.Crop
  $crop.ShapeWidth=$w; $crop.ShapeHeight=220
  $crop.PictureWidth=1300*.9; $crop.PictureHeight=736*.9
  $crop.PictureOffsetX=(650-433)*.9; $crop.PictureOffsetY=(368-416)*.9
  $picture.Left=$x; $picture.Top=$y
 }
}
function Arc([double]$x,[double]$y,[double]$r,[double]$a,[double]$b,[int]$color){
 for($segment=0;$segment -lt 14;$segment++){$aa=$a+($b-$a)*$segment/14;$bb=$a+($b-$a)*($segment+1)/14;Line ($x+$r*[math]::Cos($aa)) ($y-$r*[math]::Sin($aa)) ($x+$r*[math]::Cos($bb)) ($y-$r*[math]::Sin($bb)) $color}
}
function Arm([double]$x,[double]$y,[double]$scale,[double]$q1=0,[double]$q2=([math]::PI/2),[bool]$labels=$true){
 $elbowX=$x+.6*$scale*[math]::Cos($q1);$elbowY=$y-.6*$scale*[math]::Sin($q1)
 $toolX=$elbowX+.4*$scale*[math]::Cos($q1+$q2);$toolY=$elbowY-.4*$scale*[math]::Sin($q1+$q2)
 Line ($x-10) $y ($x+65) $y $C.line $true; Line $x ($y+10) $x ($y-65) $C.line $true
 Text ($x+63) ($y+2) 25 34 'x' 24 $C.muted;Text ($x-32) ($y-76) 25 34 'y' 24 $C.muted
 Line $x $y $elbowX $elbowY $C.blue; $script:slide.Shapes.Item($script:slide.Shapes.Count).Line.Weight=10
 Line $elbowX $elbowY $toolX $toolY $C.orange; $script:slide.Shapes.Item($script:slide.Shapes.Count).Line.Weight=10
 Dot $x $y 8 $C.ink;Dot $elbowX $elbowY 7 $C.ink;Dot $toolX $toolY 9 $C.green
 Arc $x $y 29 0 $q1 $C.blue;Arc $elbowX $elbowY 26 $q1 ($q1+$q2) $C.orange
 if($labels){
  Formula ($x+30) ($y+33) 110 40 'q_{1}' 25 $C.blue
  Formula ($elbowX+32) ($elbowY-40) 80 40 'q_{2}' 25 $C.orange
  Text ($x+32) ($y-53) 146 38 '0.6 m' 24 $C.blue $true
  Text ($toolX+20) ($toolY+12) 136 38 '0.4 m' 24 $C.orange $true
 }
}
function Workspace([double]$x,[double]$y,[double]$radius){
 $outer=$script:slide.Shapes.AddShape(9,$x-$radius,$y-$radius,2*$radius,2*$radius);$outer.Fill.ForeColor.RGB=$C.paleTeal;$outer.Line.ForeColor.RGB=$C.teal;$outer.Line.Weight=2
 $hole=$script:slide.Shapes.AddShape(9,$x-.2*$radius,$y-.2*$radius,.4*$radius,.4*$radius);$hole.Fill.ForeColor.RGB=$C.bg;$hole.Line.ForeColor.RGB=$C.teal;$hole.Line.Weight=2
 Dot $x $y 4 $C.amber;Dot ($x+1.2*$radius) $y 7 $C.amber
 Line $x $y ($x+$radius) $y $C.line
}

$planBuilder=New-Object Text.StringBuilder
[void]$planBuilder.AppendLine(@'
# Week 3 — Gazebo, ROS, and Kinematics

Gazebo is the main subject: what simulation gives us, why Gazebo fits the course, and how its configuration and ROS bridge support the existing workflow. FK/IK are brief visual practice, not the main lecture. Audience has Python familiarity and Weeks 1–2 ROS/TF basics.

**20 minutes explanation + 25 minutes demo/questions = 45 minutes.** Title is untimed; twelve teaching slides, demo transition and four hidden backups give 18 slides overall. Incorporate the former separate recap into the workflow and model sketch. Use the Weeks 1–2 light background, blue/teal palette, sparse prose, editable diagrams/equations, body text at least 24 pt, and detailed speaker notes with sources.

Baseline: ROS 2 Jazzy and Gazebo Harmonic (Gazebo Sim 8). Preserve teaching notes and every demo file. All twelve existing Week 3 files were read; no separate professor Week 3 lecture was supplied. Existing TA_plan.md Session 3, HW1 and HW3 connections remain relevant. Use the existing captured screenshot honestly as an illustration of a bent arm pose; a new launch begins at zero angles.

## Presentation sequence and speaker guidance
'@)
$coreNumber=0
foreach($entry in $lesson){
 $tag=$(if($entry.backup){'Hidden / untimed'}elseif($entry.minutes -eq 25){'Demo / 25 minutes'}elseif($entry.minutes){$coreNumber++;"Teaching $coreNumber / $($entry.minutes) minutes"}else{'Untimed title'})
 [void]$planBuilder.AppendLine("`n### $($entry.title) — $tag`n`n$($entry.notes.Trim())`n")
 foreach($key in $entry.refs){[void]$planBuilder.AppendLine("Source: $($sources[$key])`n")}
}
[void]$planBuilder.AppendLine(@'
## Deliverables and validation

GAZEBO_AND_KINEMATICS.pptx contains 18 editable widescreen slides, notes on every slide, four hidden backups (slides 15–18). The PDF includes all 18 slides. Reproducible source content, PowerPoint generator, mathematical validation, rendered previews, and inspection results are under slides/.

Validate link lengths/axes/limits against URDF; bridge names/types/directions against bridge.yaml; FK zero and worked examples; both IK branches and orientations; FK/IK round trips, geometric workspace boundaries, rejected targets, transform-product agreement, and singular Jacobian determinant. Reopen the saved deck in PowerPoint, verify notes/hidden states/timing, count PDF pages, inspect every slide preview, and check actual text bounds. Compare hashes for all eleven protected files. Numeric/artifact checks do not claim a new classroom ROS/Gazebo rehearsal on this Windows slide-generation machine. Follow the unchanged README on the Jazzy/Harmonic teaching machine for that rehearsal.
'@)
[IO.File]::WriteAllText($planPath,$planBuilder.ToString(),(New-Object Text.UTF8Encoding($false)))

$app=$null;$presentation=$null;$hadExistingPresentations=$false
try {
 $app=New-Object -ComObject PowerPoint.Application;$hadExistingPresentations=($app.Presentations.Count -gt 0)
 $presentation=$app.Presentations.Add(0);$presentation.PageSetup.SlideWidth=$W;$presentation.PageSetup.SlideHeight=$H
 foreach($entry in $lesson){
  $notes="Timing: $($entry.minutes) minutes. $(if($entry.backup){'Hidden optional backup, outside the 45-minute schedule.'})`r`n`r`n$($entry.notes.Trim())`r`n`r`nSources:`r`n"+(($entry.refs | ForEach-Object {$sources[$_]}) -join "`r`n")
  NewSlide $entry.title $entry.subtitle $entry.minutes $notes ([bool]$entry.backup)
  switch($entry.kind){
   'title' {
    Tag 54 207 264 'Understand Gazebo';Tag 340 207 241 'Connect ROS' $C.paleTeal $C.teal;Tag 603 207 303 'Practice kinematics'
    Arm 118 391 190 0 ([math]::PI/2) $false
    Text 410 305 496 96 "20 min explanation`n25 min code, demo & questions" 30 $C.muted
   }
   'what' {
    Screenshot 54 204 480
    $labels=@('World + environment','Robot models','Physics + controllers','Simulation time','Optional sensors')
    for($idx=0;$idx -lt 5;$idx++){Text 575 (204+$idx*53) 331 46 $labels[$idx] 26 $(if($idx%2){$C.teal}else{$C.blue}) $true}
   }
   'why' {
    Card 54 197 410 110 'Before hardware' 'Develop early.'
    Card 486 197 420 110 'Repeat a setup' 'Compare experiments.' $C.paleTeal $C.teal
    Card 54 327 410 110 'Try commands' 'Observe virtual motion.' $C.paleTeal $C.teal
    Card 486 327 420 110 'Inspect results' 'Read joints, frames, and time.'
    Text 54 449 852 40 'Results depend on the model. Validate later on hardware.' 25 $C.muted
   }
   'fit' {
    Card 54 203 410 120 'ROS integration' 'Launch, spawn, bridge messages.'
    Card 486 203 420 120 'Configurable models' 'Robot, world, and topic mapping.' $C.paleTeal $C.teal
    Card 54 349 410 120 'Reusable systems' 'Physics, control, sensors.' $C.paleTeal $C.teal
    Card 486 349 420 120 'GUI or headless' 'Same model and physics.'
   }
   'roles' {
    Card 54 215 270 223 'Gazebo' "Simulates motion`nProduces measurements"
    Card 345 215 270 223 'ROS' "Communicates data`nRuns robot logic" $C.paleTeal $C.teal
    Card 636 215 270 223 'RViz' "Visualizes ROS data`nOptional in this demo"
    Text 54 450 852 37 'Simulation ↔ ROS data → visualization' 25 $C.muted
   }
   'bridge' {
    Text 54 198 852 38 '/arm/joint1/cmd_pos  +  /arm/joint2/cmd_pos' 24 $C.blue $true 2 'Consolas'
    Box 54 254 214 113 $C.paleBlue;Text 62 269 198 79 "ROS`ncommand_arm" 24 $C.blue $true 2
    Box 356 254 248 113 $C.white $C.line;Text 368 284 224 59 'ros_gz_bridge' 26 $C.ink $true 2
    Box 692 254 214 113 $C.paleTeal;Text 704 269 190 79 "Gazebo`ncontrollers" 26 $C.teal $true 2
    Line 268 280 344 280 $C.blue $true;Line 604 280 680 280 $C.blue $true
    Line 692 340 616 340 $C.teal $true;Line 356 340 280 340 $C.teal $true
    Text 54 376 852 37 '/joint_states  +  /clock' 25 $C.teal $true 2 'Consolas'
    Box 54 433 228 44 $C.paleTeal;Text 65 440 206 33 '/joint_states' 24 $C.teal $false 2
    Box 355 433 395 44 $C.paleBlue;Text 365 440 375 33 'robot_state_publisher + URDF' 24 $C.blue $false 2
    Box 800 433 106 44 $C.paleTeal;Text 810 440 86 33 'TF' 24 $C.teal $true 2
    Line 282 455 343 455 $C.teal $true;Line 750 455 788 455 $C.teal $true
   }
   'workflow' {
    $steps=@(@(54,205,'1 · Describe','arm.urdf + world.sdf'),@(345,205,'2 · Launch/spawn','demo.launch.py'),@(636,205,'3 · Connect','bridge.yaml'),@(636,351,'4 · Command','command_arm.py'),@(345,351,'5 · Inspect','Joint states + TF'),@(54,351,'6 · Compare','Predict ↔ measure'))
    foreach($step in $steps){Card $step[0] $step[1] 270 113 $step[2] $step[3] $(if($step[0] -eq 345){$C.paleTeal}else{$C.paleBlue})}
    Line 324 261 339 261 $C.blue $true;Line 615 261 630 261 $C.blue $true;Line 771 318 771 345 $C.blue $true
    Line 636 407 621 407 $C.teal $true;Line 345 407 330 407 $C.teal $true
   }
   'configuration' {
    Box 54 202 410 184 $C.paleBlue;Text 72 216 374 42 'URDF · joint geometry' 28 $C.blue $true
    Text 72 267 374 99 "<origin xyz=`"0.6 0 0`"/>`n<axis xyz=`"0 0 1`"/>" 24 $C.ink $false 1 'Consolas'
    Box 486 202 420 184 $C.paleTeal;Text 504 216 384 42 'SDF · world physics' 28 $C.teal $true
    Text 504 265 384 111 "<gravity>`n  0 0 -9.81`n</gravity>" 24 $C.ink $false 1 'Consolas'
    Box 54 413 852 63 $C.white;Text 72 427 236 37 'bridge.yaml' 26 $C.blue $true;Text 336 429 552 37 'direction: ROS_TO_GZ' 24 $C.ink $false 1 'Consolas'
   }
   'gui' {
    Screenshot 54 166 560
    Text 650 198 256 44 'World + robot' 25 $C.blue $true
    Text 650 264 256 44 'Entity tree' 25 $C.teal $true
    Text 650 333 256 70 "Play/pause`n+ reset" 25 $C.blue $true
    Text 650 421 256 58 'Clock statistics' 25 $C.teal $true
    Line 638 219 233 344 $C.blue $true $true;Line 638 285 524 267 $C.teal $true $true
    Line 638 373 105 462 $C.blue $true $true;Line 638 441 443 471 $C.teal $true $true
   }
   'arm' {
    Screenshot 54 226 390 $true
    Text 54 453 390 36 'The existing Gazebo demo' 24 $C.muted
    Arm 562 375 230 0 ([math]::PI/2) $true
    Text 508 207 398 43 'Top view · base_link' 26 $C.blue $true
    Text 508 447 398 36 'q₂ is relative to link1.' 25 $C.muted
   }
   'fk' {
    Arm 114 363 220 0 ([math]::PI/2) $true
    Formula 410 241 496 56 'x = L_{1} cos(q_{1}) + L_{2} cos(q_{1}+q_{2})' 29 $C.blue
    Formula 410 315 496 56 'y = L_{1} sin(q_{1}) + L_{2} sin(q_{1}+q_{2})' 29 $C.teal
    Text 54 437 852 43 '(q₁, q₂) = (0, π/2)   →   (x, y) = (0.6, 0.4) m' 28 $C.ink $true
   }
   'ik' {
    Text 54 209 178 40 'Positive q₂' 25 $C.blue $true;Text 256 209 191 40 'Negative q₂' 25 $C.teal $true
    Arm 97 365 171 0 ([math]::PI/2) $false
    Arm 290 365 171 1.176005207095135 (-[math]::PI/2) $false
    Text 54 436 393 43 'Same target: (0.6, 0.4) m' 25 $C.ink $true
    Formula 465 222 441 51 'c_{2} = (x²+y²−L_{1}²−L_{2}²)/(2L_{1}L_{2})' 26 $C.blue
    Formula 465 289 441 50 'q_{2} = ±acos(c_{2})' 31 $C.teal
    Formula 465 358 441 45 'q_{1} = atan2(y,x) −' 28
    Formula 465 405 441 65 'atan2(L_{2} sin q_{2}, L_{1}+L_{2} cos q_{2})' 26
   }
   'verify' {
    Text 54 203 315 70 'Reject (0,0) and (1.2,0).' 25 $C.amber $true
    Workspace 174 335 86
    Text 54 439 315 40 '0.2 ≤ radius ≤ 1.0 m' 26 $C.teal $true
    Tag 409 217 497 'Measured joints'
    Tag 409 310 497 'FK + end-effector TF' $C.paleTeal $C.teal
    Tag 409 403 497 'Compare with target'
    Line 657 265 657 303 $C.blue $true;Line 657 358 657 396 $C.teal $true
    Text 409 452 497 35 'IK ≠ collision-free motion planning' 24 $C.muted
   }
   'demo' {
    Screenshot 54 222 390 $true
    Text 499 207 407 54 '8 min · interface + joints' 28 $C.blue $true
    Text 499 296 407 70 '10 min · target + two branches' 28 $C.teal $true
    Text 499 399 407 70 '7 min · rejection + checkpoint' 28 $C.blue $true
    Text 54 450 390 43 'Predict → command → measure' 25 $C.muted
   }
   'tf' {
    Formula 54 197 852 55 'T = RotZ(q_{1}) TransX(L_{1}) RotZ(q_{2}) TransX(L_{2})' 29 $C.blue
    Matrix 54 283 470 158 @(@('cos α','−sin α','0','x'),@('sin α','cos α','0','y'),@('0','0','1','0'),@('0','0','0','1')) 26
    Text 589 273 317 85 "R: rotation (3×3)`nt: origin offset (3×1)" 25 $C.ink
    Formula 589 374 317 55 'T = [R  t; 0  1]' 29 $C.teal
    Formula 54 454 470 37 'α = q_{1} + q_{2}' 26 $C.muted
   }
   'ik_derivation' {
    Formula 54 210 852 48 'x²+y² = L_{1}²+L_{2}²+2L_{1}L_{2} cos(q_{2})' 32 $C.blue
    Formula 54 274 852 48 'q_{2} = ±acos((x²+y²−L_{1}²−L_{2}²)/(2L_{1}L_{2}))' 30
    Formula 54 337 852 48 'q_{1} = atan2(y,x) − atan2(L_{2} sin q_{2}, L_{1}+L_{2} cos q_{2})' 29
    Box 54 415 852 64 $C.paleTeal;Text 72 430 816 40 '(0.6,0.4): (0,1.570796) or (1.176005,−1.570796) rad' 26 $C.teal $true
   }
   'workspace' {
    Workspace 187 330 96
    Text 54 438 318 42 '0.2 ≤ radius ≤ 1.0 m' 26 $C.teal $true
    Formula 432 235 474 49 'det J = L_{1}L_{2} sin(q_{2})' 32 $C.blue
    Text 432 317 474 72 'Singular at q₂ = 0 or ±π.' 28 $C.ink $true
    Text 432 409 474 70 'Joint limits and obstacles add constraints.' 25 $C.muted
   }
   'troubleshoot' {
    Card 54 197 410 110 'No motion' 'Pause → bridge → controller'
    Card 486 197 420 110 'No feedback' 'Topic mapping + joint names' $C.paleTeal $C.teal
    Card 54 327 410 110 'No TF' 'Measured joints + URDF' $C.paleTeal $C.teal
    Card 486 327 420 110 'Clock stopped' 'Check /clock and play/pause'
    Text 54 449 852 40 'Full restart restores the baseline. GUI reset is different.' 25 $C.muted
   }
  }
 }
 if($presentation.Slides.Count -ne 18){throw 'Expected 18 slides'}
 $explanation=($script:slides | Where-Object {$_.number -ge 2 -and $_.number -le 13} | Measure-Object minutes -Sum).Sum
 if($explanation -ne 20 -or ($script:slides | Measure-Object minutes -Sum).Sum -ne 45){throw 'Incorrect lesson timing'}
 foreach($item in $presentation.Slides){foreach($shape in $item.Shapes){if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){$tr=$shape.TextFrame.TextRange;if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$script:issues.Add("Slide $($item.SlideIndex): text $([math]::Round($tr.BoundWidth,1))×$([math]::Round($tr.BoundHeight,1)) exceeds box $($shape.Width)×$($shape.Height): $($tr.Text)")}}}}
 New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
 if(-not $NoPreview){foreach($item in $presentation.Slides){$item.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $item.SlideIndex)),'PNG',1600,900)}}
 $presentation.SaveAs($pdfPath,32)
 foreach($info in $script:slides){if($info.backup){$presentation.Slides.Item($info.number).SlideShowTransition.Hidden=-1}}
 $presentation.SaveAs($pptxPath,24);$presentation.Close();$presentation=$null
 $check=$app.Presentations.Open($pptxPath,-1,0,0)
 if($check.Slides.Count -ne 18){throw 'Reopened slide count incorrect'}
 for($idx=1;$idx -le 18;$idx++){$item=$check.Slides.Item($idx);if(($item.SlideShowTransition.Hidden -eq -1) -ne ($idx -ge 15)){throw "Hidden state incorrect: $idx"};if($item.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;timingMinutes=45;explanationMinutes=20;demoMinutes=25;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;generated=@(($OutputBaseName+'.pptx'),($OutputBaseName+'.pdf'))} | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created and reopened: 18 slides, 4 hidden backups, notes on every slide. Protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
} finally {
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}
