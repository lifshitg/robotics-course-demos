param([switch]$NoPreview, [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$OutputBaseName='TF_COORDINATE_TRANSFORMS')
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
  Text 54 26 720 24 $(if ($backup) {'OPTIONAL / DEEPER DISCUSSION'} else {'WEEK 02 / COORDINATE FRAMES'}) 16 $C.teal $true
  Text 54 64 852 60 $title 40 $C.ink $true
  if ($subtitle) { Text 54 124 852 64 $subtitle 26 $C.muted }
  Line 54 494 906 494 $C.line
  Text 54 504 660 24 'Robotics & Autonomous Systems · ROS 2 Jazzy' 16 $C.muted
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
function Axes([double]$x,[double]$y,[string]$label,[int]$color=$C.blue){
 Dot $x $y 4 $color; Line $x $y ($x+76) $y $color $true; Line $x $y $x ($y-70) $color $true; Line $x $y ($x-38) ($y+32) $color $true
 Text ($x+78) ($y-15) 30 35 'x' 24 $color; Text ($x-12) ($y-105) 30 35 'z' 24 $color; Text ($x-66) ($y+20) 30 35 'y' 24 $color; Text ($x-42) ($y+65) 180 38 $label 24 $color $true
}
function Tree([double]$y=250){
 $positions=@(54,276,498,720); $names=@('world','base_link','camera_mount','camera_frame')
 for($idx=0;$idx -lt 4;$idx++){Box $positions[$idx] $y 186 66 $(if($idx -lt 2){$C.paleBlue}else{$C.paleTeal}); Text ($positions[$idx]+4) ($y+19) 178 36 $names[$idx] 24 $C.ink $true 2; if($idx -lt 3){Line ($positions[$idx]+186) ($y+33) $positions[$idx+1] ($y+33) $C.blue $true}}
 Text 54 ($y-49) 408 38 'dynamic · moving_base' 24 $C.blue $false 2
 Text 498 ($y-49) 408 38 'static · static_frames' 24 $C.teal $false 2
}

$planBuilder=New-Object Text.StringBuilder
[void]$planBuilder.AppendLine(@'
# Week 2 — Coordinate Frames, Transformations, and tf2

Audience: Python familiarity, little robotics geometry or networking. ROS 2 Jazzy baseline. **20 minutes explanation + 25 minutes code/demo/questions = 45 minutes.** Title is untimed. Fourteen core teaching slides, demo transition, ten hidden backups: 26 slides total. Follow the Week 1 palette, editable diagrams and equations, sparse visible prose, detailed speaker notes. All mathematical formulas use column vectors, right-handed rotations, Hamilton quaternions and fixed-axis XYZ RPY unless explicitly comparing conventions. Scalar-first mathematics versus ROS xyzw fields is always labelled.

All seven existing Week 2 files were read. Preserve teaching notes, demo code, RViz configuration and demo README. The separately supplied professor PDF was not found: retain references to Robotics_AutonomousSystems.pdf printed slides 12–22, 25–35, 37–40, and 43 without claiming review.

## Sequence, visuals, and speaker guidance
'@)
foreach($entry in $lesson){
 $tag=$(if($entry.backup){'Hidden / untimed'}elseif($entry.minutes){"$($entry.minutes) minutes"}else{'Untimed title'})
 [void]$planBuilder.AppendLine("`n### $($entry.title) — $tag`n`n$($entry.notes.Trim())`n")
 foreach($key in $entry.refs){[void]$planBuilder.AppendLine("Source: $($sources[$key])`n")}
}
[void]$planBuilder.AppendLine(@'
## Deliverables and validation

- TF_COORDINATE_TRANSFORMS.pptx: 26 editable widescreen slides; 17–26 hidden; notes on every slide.
- TF_COORDINATE_TRANSFORMS.pdf: review copy including hidden references.
- TF_MATH_REFERENCE.md: complete formulas, all conversion branches, intermediate demo and mixed-axis calculations, convention caveats, time interpolation and sources.
- slides/content.ps1 and slides/build_slides.ps1: reproducible content and PowerPoint generation; slides/preview contains rendered slide images. slides/validate_math.ps1 independently checks numerical formulas.

Check demo forward (0.2,0,1)→(0,0.2,1.5), inverse recovery, direct/composed transforms; identity, ±90° axes, mixed axes, SO(3), quaternion norm and sign equivalence, stable near/exact180° conversion, Euler singular recovery and SLERP. Render all slides in installed PowerPoint, inspect legibility and layout, reopen saved deck, verify notes/hidden states/timing and PDF page count. Compare protected-file hashes. Artifact checks are separate from classroom ROS/RViz rehearsal; this local Windows slide-generation machine has no ROS installation.
'@)
[IO.File]::WriteAllText($planPath,$planBuilder.ToString(),(New-Object Text.UTF8Encoding($false)))

$app=$null; $presentation=$null; $hadExistingPresentations=$false
try {
 $app=New-Object -ComObject PowerPoint.Application
 $hadExistingPresentations=($app.Presentations.Count -gt 0)
 $presentation=$app.Presentations.Add(0); $presentation.PageSetup.SlideWidth=$W; $presentation.PageSetup.SlideHeight=$H
 foreach($entry in $lesson){
  $notes="Timing: $($entry.minutes) minutes. $(if($entry.backup){'Hidden optional reference, outside the 45-minute lesson.'})`r`n`r`n$($entry.notes.Trim())`r`n`r`nSources:`r`n"+ (($entry.refs | ForEach-Object {$sources[$_]}) -join "`r`n")
  NewSlide $entry.title $entry.subtitle $entry.minutes $notes ([bool]$entry.backup)
  switch($entry.kind){
   'title' {
    Tag 54 222 245 'Understand frames'; Tag 319 222 247 'Read the math' $C.paleTeal $C.teal; Tag 586 222 320 'Inspect the demo'
    Formula 74 324 812 63 'p_{A} = R_{AB} p_{B} + t_{AB}' 40 $C.blue
    Text 74 414 812 40 '20 min concepts  ·  25 min code, demo & questions' 26 $C.muted
   }
   'why' {
    Axes 130 330 'world'; Axes 401 330 'robot' $C.teal; Axes 694 330 'camera'
    Dot 830 220 12 $C.amber; Text 746 183 160 35 'same target' 24 $C.amber $true
    Line 130 330 824 224 $C.line $false $true; Line 401 330 824 224 $C.line $false $true; Line 694 330 824 224 $C.line $false $true
    Text 54 440 852 40 'A camera measurement needs a robot-frame destination.' 26 $C.ink
   }
   'definitions' {
    Card 54 215 270 226 'Frame' "Origin + axes`nWhere are coordinates measured?"
    Card 345 215 270 226 'Transform' "Rotate + translate`nBetween frames." $C.paleTeal $C.teal
    Card 636 215 270 226 'tf2' "Time-aware library`nFind and apply the relationship."
   }
   'conventions' {
    Card 54 202 270 160 'ROS body' 'x forward · y left · z up'
    Card 345 202 270 160 'Optical' 'x right · y down · z forward' $C.paleTeal $C.teal
    Text 642 206 264 162 "✓ Right-handed · m/rad`n✓ Transform direction`n✓ Euler sequence/axes`n✓ Column/row vectors" 24
    Box 54 385 852 82 $C.white
    Text 72 401 406 54 'Math q: (w, x, y, z)' 26 $C.blue $true
    Text 492 401 390 54 'ROS q: (x, y, z, w)' 26 $C.teal $true
   }
   'direction' {
    Box 54 215 852 94 $C.white
    Formula 75 234 815 65 '^{A}p = ^{A}R_{B} ^{B}p + ^{A}t_{B}' 38 $C.blue
    Tag 54 353 250 'B coordinates'; Tag 656 353 250 'A coordinates' $C.paleTeal $C.teal
    Line 318 374 640 374 $C.blue $true; Formula 362 323 266 52 '^{A}T_{B}' 34 $C.ink 2
    Text 54 426 852 45 'Pose of B in A  ·  maps B → A  ·  same physical point' 26
   }
   'matrices' {
    Formula 54 193 250 42 'R_{x}(φ)' 27 $C.blue 2; Formula 351 193 250 42 'R_{y}(θ)' 27 $C.teal 2; Formula 648 193 250 42 'R_{z}(ψ)' 27 $C.blue 2
    Matrix 54 239 250 111 @(@('1','0','0'),@('0','cφ','−sφ'),@('0','sφ','cφ')) 24
    Matrix 351 239 250 111 @(@('cθ','0','sθ'),@('0','1','0'),@('−sθ','0','cθ')) 24
    Matrix 648 239 250 111 @(@('cψ','−sψ','0'),@('sψ','cψ','0'),@('0','0','1')) 24
    Formula 54 384 118 70 'T =' 32
    Matrix 158 376 172 92 @(@('R','t'),@('0','1')) 30
    Formula 376 377 510 47 'R^{T}R = I      det R = +1' 28
    Text 376 430 510 40 'Point [p; 1]   ·   Direction [d; 0]' 24 $C.muted
   }
   'compose' {
    Tag 54 212 180 'A'; Tag 390 212 180 'B' $C.paleTeal $C.teal; Tag 726 212 180 'C'
    Line 378 233 246 233 $C.blue $true; Line 714 233 582 233 $C.teal $true
    Formula 54 290 852 62 '^{A}T_{C} = ^{A}T_{B} ^{B}T_{C}' 38 $C.blue 2
    Formula 54 388 264 60 'T^{-1} =' 35
    Matrix 320 374 340 95 @(@('R^{T}','−R^{T}t'),@('0','1')) 32
    Text 696 387 210 77 'Subtract t, then rotate back.' 24 $C.muted
   }
   'euler' {
    Card 54 205 270 125 'Roll φ' 'about x'
    Card 345 205 270 125 'Pitch θ' 'about y' $C.paleTeal $C.teal
    Card 636 205 270 125 'Yaw ψ' 'about z'
    Formula 54 350 852 58 'R = R_{z}(ψ) R_{y}(θ) R_{x}(φ)' 36 $C.blue 2
    Formula 54 431 852 41 '90° x then z: e_{x} → e_{y}   ·   z then x: e_{x} → e_{z}' 25
   }
   'quaternion' {
    Formula 54 211 852 67 'q = (w, v) = (cos(α/2), k sin(α/2))' 34 $C.blue 2
    Text 54 287 852 40 'k: unit rotation axis   ·   α: right-hand rotation angle' 24 $C.muted  $false 2
    Card 54 352 410 120 'Unit norm' 'w² + x² + y² + z² = 1'
    Card 486 352 420 120 'ROS identity' '(x, y, z, w) = (0, 0, 0, 1)' $C.paleTeal $C.teal
   }
   'sandwich' {
    Formula 54 222 852 65 '(0, p_{rot}) = q ⊗ (0, p) ⊗ q^{-1}' 38 $C.blue 2
    Formula 54 329 852 64 'p_{A} = p_{rot} + t_{AB}' 38 $C.teal 2
    Text 54 425 852 42 'Unit inverse = conjugate   ·   Composition: q_AB ⊗ q_BC' 24
   }
   'example' {
    Box 54 204 270 191 $C.paleBlue; Text 72 216 234 42 'Matrix' 28 $C.blue $true
    Matrix 75 267 228 111 @(@('0','−1','0'),@('1','0','0'),@('0','0','1')) 25
    Card 345 204 270 191 'Euler' "RPY = (0, 0, π/2)`nFixed XYZ" $C.paleTeal $C.teal
    Card 636 204 270 191 'Quaternion' "ROS (x,y,z,w):`n(0, 0, √2/2, √2/2)"
    Formula 54 420 852 53 '(0.2, 0, 1) → (0, 0.2, 1.5)     t_{z} = 0.5 m' 28 $C.blue 2
   }
   'tree' {
    Tree 277; Text 54 385 852 42 'One parent per child  ·  one authority per edge  ·  no cycles' 25
    Text 54 438 852 40 'Disconnected trees have no transform path.' 26 $C.muted
   }
   'pipeline' {
    Card 54 202 255 110 'static_frames' '/tf_static'
    Card 54 323 255 110 'moving_base' '/tf' $C.paleTeal $C.teal
    Box 405 244 239 132 $C.white $C.line; Text 423 260 203 91 "Listener`n+ Buffer" 28 $C.ink $true 2
    Box 729 269 177 80 $C.paleTeal; Text 741 292 153 44 'Lookup' 28 $C.teal $true 2
    Line 309 250 392 288 $C.blue $true; Line 309 370 392 332 $C.teal $true; Line 644 309 716 309 $C.teal $true
    Text 54 438 852 40 'Several publishers  ·  each listener has its own buffer' 26 $C.muted
   }
   'time' {
    Line 114 288 856 288 $C.blue $true
    Dot 252 288 8 $C.teal; Dot 708 288 8 $C.blue
    Text 108 210 350 58 'Observation at tₘ' 28 $C.teal $true 2; Text 577 210 285 58 'Now' 28 $C.blue $true 2
    Text 84 313 371 65 'Use the transform at tₘ.' 26 $C.teal $false 2
    Text 524 313 382 65 'Latest is not acquisition time.' 26 $C.blue $false 2
    Box 54 413 852 63 $C.white; Text 71 427 818 40 'Finite history  ·  consistent clocks  ·  preserve the stamp' 26
   }
   'inspect' {
    Box 54 204 852 149 $C.white
    Text 72 220 816 45 'ros2 run tf2_ros tf2_echo base_link camera_frame' 24 $C.blue $false 1 'Consolas'
    Text 72 276 816 45 'ros2 run tf2_ros tf2_echo world base_link' 24 $C.teal $false 1 'Consolas'
    Formula 54 377 852 50 'lookup_transform(target, source, time)' 29
    Text 54 435 852 40 'RViz Fixed Frame: base_link → world' 28 $C.muted
   }
   'demo' {
    Tree 267
    Text 54 366 852 43 'Camera (0.2, 0, 1)  →  Base (0, 0.2, 1.5)' 28 $C.blue $true
    Text 54 428 852 42 'Predict: missing frame?   moving base?   old timestamp?' 26
   }
   'expanded' {
    Matrix 54 232 852 177 @(@('cψcθ','cψsθsφ − sψcφ','cψsθcφ + sψsφ'),@('sψcθ','sψsθsφ + cψcφ','sψsθcφ − cψsφ'),@('−sθ','cθsφ','cθcφ')) 24
    Text 54 438 852 40 'c = cos(angle)  ·  s = sin(angle)  ·  full angles here' 25 $C.muted
   }
   'recover' {
    Formula 54 205 852 48 'θ = atan2(−r_{31}, √(r_{11}² + r_{21}²))' 30 $C.blue
    Formula 54 268 852 48 'φ = atan2(r_{32}, r_{33})      ψ = atan2(r_{21}, r_{11})' 29
    Text 54 331 852 40 'θ ∈ [−π/2, π/2]   ·   φ, ψ ∈ (−π, π]' 25 $C.muted
    Box 54 392 852 82 $C.paleTeal; Formula 72 409 816 47 'cos θ ≈ 0:   φ = 0,  ψ = atan2(−r_{12}, r_{22})' 29 $C.teal
   }
   'qmatrix' {
    Matrix 54 235 852 172 @(@('1 − 2(y²+z²)','2(xy−wz)','2(xz+wy)'),@('2(xy+wz)','1 − 2(x²+z²)','2(yz−wx)'),@('2(xz−wy)','2(yz+wx)','1 − 2(x²+y²)')) 27
    Text 54 440 852 40 'Normalize first  ·  R(q) = R(−q)  ·  ROS order is xyzw' 25 $C.muted
   }
   'stable' {
    Formula 54 202 852 43 'a_{w} = (1+r_{11}+r_{22}+r_{33})/4' 27
    Formula 54 247 852 43 'a_{x} = (1+r_{11}−r_{22}−r_{33})/4' 27
    Formula 54 292 852 43 'a_{y} = (1−r_{11}+r_{22}−r_{33})/4' 27
    Formula 54 337 852 43 'a_{z} = (1−r_{11}−r_{22}+r_{33})/4' 27
    Text 54 399 852 65 'Take √(largest), recover the others, then normalize.' 26 $C.blue $true
    Text 54 448 852 38 '180° about x: (a_w,a_x,a_y,a_z) = (0,1,0,0)' 24 $C.muted
   }
   'rpyq' {
    Formula 54 204 852 47 'w = cφ cθ cψ + sφ sθ sψ' 32 $C.blue
    Formula 54 258 852 47 'x = sφ cθ cψ − cφ sθ sψ' 32
    Formula 54 312 852 47 'y = cφ sθ cψ + sφ cθ sψ' 32
    Formula 54 366 852 47 'z = cφ cθ sψ − sφ sθ cψ' 32
    Text 54 439 852 39 'Reverse: normalized q → R(q) → Euler (singular branch)' 25 $C.teal
   }
   'qalgebra' {
    Formula 54 202 852 45 'q_{1} ⊗ q_{2} = (w_{1}w_{2} − v_{1}·v_{2},' 32 $C.blue
    Formula 54 249 852 47 '                      w_{1}v_{2} + w_{2}v_{1} + v_{1}×v_{2})' 32 $C.blue
    Formula 54 332 852 47 'q* = (w, −v)       q^{-1} = q* / ‖q‖²' 31
    Formula 54 395 852 47 'q_{rel} = q_{2} ⊗ q_{1}^{-1}       R(q) = R(−q)' 31 $C.teal
    Text 54 451 852 35 'Unit norm: inverse = conjugate. Sign flip ≠ inverse.' 24 $C.muted
   }
   'basis' {
    Card 54 207 410 119 'Active' 'Rotate the vector: p′ = Rp'
    Card 486 207 420 119 'Passive' 'Reverse basis map: use Rᵀ' $C.paleTeal $C.teal
    Formula 54 350 852 45 'Row vectors:   p′^{T} = p^{T}R^{T} + t^{T}' 30
    Formula 54 412 852 51 'Basis change:   R_{new} = S_{A} R_{old} S_{B}^{-1}' 32 $C.blue
   }
   'roles' {
    Card 54 203 410 121 'Body' 'x forward · y left · z up'
    Card 486 203 420 121 'Optical' 'x right · y down · z forward' $C.paleTeal $C.teal
    Text 54 354 852 41 'map → odom → base_link → sensor' 30 $C.blue $true
    Text 54 412 852 63 'map: corrections may jump   ·   odom: continuous, drifts' 25
   }
   'slerp' {
    Formula 54 203 852 44 'u = (τ−τ_{0})/(τ_{1}−τ_{0})     t(u) = (1−u)t_{0} + ut_{1}' 28
    Formula 54 278 852 49 'q(u) = [sin((1−u)Ω)/sin Ω] q_{0}' 31 $C.blue
    Formula 54 331 852 49 '           + [sin(uΩ)/sin Ω] q_{1}' 31 $C.blue
    Text 54 408 852 72 "Ω = acos(q₀·q₁)  ·  flip q₁ if dot < 0`nNear equality: normalize the linear blend." 25 $C.muted
   }
   'checks' {
    Matrix 54 207 500 131 @(@('0.664463','−0.733295','0.144110'),@('0.664463','0.491450','−0.562997'),@('0.342020','0.469846','0.813798')) 24
    Text 596 216 310 111 "RPY: (30°, −20°, 45°)`nFixed XYZ" 25 $C.blue $true
    Text 54 360 852 43 'q ≈ (0.861642, 0.299673, −0.057422, 0.405550)' 26
    Text 54 421 852 54 'Round trip  ·  q / −q  ·  near 180°  ·  singular Euler' 26 $C.teal
   }
  }
 }
 if($presentation.Slides.Count -ne 26){throw 'Expected 26 slides'}
 if(($script:slides | Measure-Object minutes -Sum).Sum -ne 45){throw 'Incorrect timing'}
 foreach($item in $presentation.Slides){foreach($shape in $item.Shapes){if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){$tr=$shape.TextFrame.TextRange; if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$script:issues.Add("Slide $($item.SlideIndex): overflow $($tr.Text)")}}}}
 New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
 if(-not $NoPreview){foreach($item in $presentation.Slides){$item.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $item.SlideIndex)),'PNG',1600,900)}}
 $presentation.SaveAs($pdfPath,32)
 foreach($info in $script:slides){if($info.backup){$presentation.Slides.Item($info.number).SlideShowTransition.Hidden=-1}}
 $presentation.SaveAs($pptxPath,24); $presentation.Close(); $presentation=$null
 $check=$app.Presentations.Open($pptxPath,-1,0,0)
 if($check.Slides.Count -ne 26){throw 'Reopened count incorrect'}
 for($idx=1;$idx -le 26;$idx++){$item=$check.Slides.Item($idx); if(($item.SlideShowTransition.Hidden -eq -1) -ne ($idx -ge 17)){throw "Hidden state incorrect: $idx"}; if($item.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;timingMinutes=45;explanationMinutes=20;demoMinutes=25;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;generated=@(($OutputBaseName+'.pptx'),($OutputBaseName+'.pdf'))} | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created and reopened: 26 slides, 10 hidden, speaker notes on all slides. Protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
} finally {
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect(); [GC]::WaitForPendingFinalizers()
}
