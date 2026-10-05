. (Join-Path $PSScriptRoot 'check_content.ps1')
function SmallCard([double]$x,[double]$y,[double]$w,[double]$h,[string]$title,[string]$body,[int]$fill=$C.paleBlue){
 Box $x $y $w $h $fill;Text ($x+16) ($y+12) ($w-32) 36 $title 26 $C.blue $true
 if($body){Text ($x+16) ($y+54) ($w-32) ($h-61) $body 24}
}
function Steps([string[]]$labels,[double]$y=247){
 $count=$labels.Count;$gap=22;$width=(852-($count-1)*$gap)/$count
 for($j=0;$j -lt $count;$j++){$x=54+$j*($width+$gap);Box $x $y $width 85 $(if($j%2){$C.paleTeal}else{$C.paleBlue});Text ($x+8) ($y+25) ($width-16) 56 $labels[$j] 24 $C.blue $true 2;if($j -lt $count-1){Line ($x+$width+3) ($y+42) ($x+$width+$gap-3) ($y+42) $C.teal $true}}
}
function RobotSketch([double]$x=54,[double]$y=211,[double]$side=300){
 Box $x $y $side 230 $C.white $C.line
 Line ($x+40) ($y+186) ($x+$side-23) ($y+186) $C.line $true
 Line ($x+40) ($y+186) ($x+40) ($y+20) $C.line $true
 Text ($x+$side-30) ($y+193) 30 33 'x' 24 $C.muted
 Text ($x+13) ($y+11) 30 33 'y' 24 $C.muted
 Dot ($x+95) ($y+147) 21 $C.teal;Dot ($x+$side-70) ($y+60) 16 $C.amber
 Line ($x+119) ($y+137) ($x+$side-94) ($y+76) $C.blue $true $true
 Text ($x+52) ($y+177) 128 33 'Robot' 24 $C.teal $true
 Text ($x+$side-135) ($y+21) 132 33 'Target' 24 $C.amber $true
}
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add('# Week 7 — MuJoCo and Imitation Learning');$lines.Add('')
$lines.Add('Two parts: **MuJoCo 7 minutes; imitation learning 15 minutes; demo 18 minutes; recap 5 minutes.** English, 16:9, light background, blue/teal accents, editable visuals and detailed speaker notes. 25 slides including two untimed dividers and four hidden backups. Teach behavior cloning as supervised action prediction with closed-loop distribution shift. No installation/API tutorial or regression derivation. Preserve demo files and teaching notes; no interfaces or dependencies change.')
$lines.Add('');$lines.Add('## Sequence and timing');$lines.Add('');$lines.Add('| Slide | Topic | Minutes |');$lines.Add('|---|---|---:|')
for($i=0;$i -lt $lesson.Count;$i++){$item=$lesson[$i];$lines.Add("| $($i+1) | $($item.title)$(if($item.backup){' (hidden)'}) | $($item.minutes) |")}
$lines.Add('');$lines.Add('## Speaker guidance and visuals')
for($i=0;$i -lt $lesson.Count;$i++){
 $item=$lesson[$i];$lines.Add('');$lines.Add("### $($i+1). $($item.title)");$lines.Add('');$lines.Add("$($item.subtitle) Timing: $($item.minutes) minutes. Visual: $($item.kind).");$lines.Add('');$lines.Add($item.notes)
 if($item.cards){$lines.Add('');foreach($card in $item.cards){$lines.Add("- $($card[0]): $($card[1])")}}
 if($item.footer){$lines.Add('');$lines.Add($item.footer)}
 $lines.Add('');foreach($ref in $item.refs){$lines.Add("- $($sources[$ref])")}
}
$lines.Add('');$lines.Add('## Validation and preparation');$lines.Add('')
$lines.Add('All eleven original Week7 files reviewed, including comparison.png. Professor Class9-ImitationLearning.pdf not found; printed-slide references are retained without claiming review. Generate/render/reopen25 slides in installed PowerPoint; verify four hidden backups, notes, sources,25 PDF pages and22+18+5 timing. IRL/GAIL must immediately follow DAgger. Check observation/action order, controller example,100×250 rows,80/20 episode split,20 fresh shared cases and sampled distance/speed success. SHA256 protected hashes must match. Python unavailable locally; original tests and headless pipeline are unexecuted here. Historical runbook outcomes and GUI limitations are not new execution results. Classroom viewer rehearsal remains separate. See slides/README.md and validation.json/review.json.')
[IO.File]::WriteAllText($planPath,($lines -join "`r`n"),[Text.UTF8Encoding]::new($false))
$app=$null;$presentation=$null;$hadExistingPresentations=$true
try{
 $app=New-Object -ComObject PowerPoint.Application;$hadExistingPresentations=($app.Presentations.Count -gt 0)
 $presentation=$app.Presentations.Add(0);$presentation.PageSetup.SlideWidth=$W;$presentation.PageSetup.SlideHeight=$H
 foreach($item in $lesson){
  $refs=($item.refs | ForEach-Object {$sources[$_]}) -join "`r`n"
  NewSlide $item.title $item.subtitle $item.minutes ("TIMING: $($item.minutes) minutes.`r`n$($item.notes)`r`n`r`nSOURCES`r`n$refs") ([bool]$item.backup)
  switch($item.kind){
   'title' {Card 54 211 410 205 'Part 1 · MuJoCo' "Physics and experimentation`nCPU and GPU roles";Card 486 211 420 205 'Part 2 · Imitation' "Expert demonstrations`nLearning and drift" $C.paleTeal $C.teal;Text 54 449 852 39 '22 min explanation · 18 min demo · 5 min recap' 27 $C.muted $true}
   'divider' {Text 54 216 852 66 $item.headline 34 $C.blue $true;Steps $item.tags 325}
   'loop' {Steps $item.tags 230;Line 805 330 805 391 $C.teal;Line 805 391 157 391 $C.teal;Line 157 391 157 330 $C.teal $true;Text 290 360 380 40 'New observation; repeat.' 27 $C.teal $true 2}
   'four' {for($j=0;$j -lt 4;$j++){SmallCard (54+432*($j%2)) (205+119*[math]::Floor($j/2)) 420 108 $item.cards[$j][0] $item.cards[$j][1] $(if($j%2){$C.paleTeal}else{$C.paleBlue})}}
   'two' {Card 54 211 410 218 $item.cards[0][0] $item.cards[0][1];Card 486 211 420 218 $item.cards[1][0] $item.cards[1][1] $C.paleTeal $C.teal}
   'comparison' {SmallCard 54 203 410 242 'MuJoCo' "Control + learning loops`nDirect state/action access`nGPU simulation backends`n`nTradeoff: add ROS integration.";SmallCard 486 203 420 242 'Gazebo' "ROS + sensor workflows`nWorlds, systems and plugins`nHardware-like integration`n`nTradeoff: broader system setup." $C.paleTeal}
   'gpu' {SmallCard 54 211 272 137 'Rendering' 'Draw images.';SmallCard 344 211 272 137 'Policy training' 'Fit model parameters.' $C.paleTeal;SmallCard 634 211 272 137 'Physics' 'Advance robot states.';Text 54 378 852 68 'Standard MuJoCo: CPU physics. MJX / Warp: GPU simulation backends.' 28 $C.teal $true}
   'experts' {SmallCard 54 211 272 160 'Human' 'Demonstrates actions.';SmallCard 344 211 272 160 'Controller' 'Computes feedback.' $C.paleTeal;SmallCard 634 211 272 160 'Planner' 'Provides decisions.';Text 54 403 852 40 'Different experts can supply the demonstrations.' 27 $C.muted}
   'workflow' {Steps @('Collect','Label','Train','Deploy','Evaluate') 225;Tag 54 353 410 'Expert present during collection';Tag 486 353 420 'Learner independent at deployment' $C.paleTeal $C.teal}
   'dataset' {SmallCard 54 204 852 91 'Observation · input' '[error_x, error_y, velocity_x, velocity_y]';SmallCard 54 311 852 91 'Expert action · label' '[force_x, force_y]' $C.paleTeal;Text 54 417 852 35 'Example: [0.3, −0.2, 0.1, 0] → [0.9, −0.8] N' 27 $C.blue $true}
   'train' {SmallCard 54 218 240 102 'Observation' 'Input to the model.';SmallCard 340 218 250 102 'Prediction' 'Learner action.';SmallCard 340 339 250 94 'Expert label' 'Recorded action.' $C.paleTeal;SmallCard 652 272 254 111 'Compare + fit' 'Reduce action error.';Line 298 269 334 269 $C.blue $true;Line 594 268 646 306 $C.blue $true;Line 594 385 646 344 $C.teal $true;Text 54 350 252 93 'Demo: simple regression.' 28 $C.teal $true}
   'drift' {Steps @('Small error','Changed state','Unfamiliar input','Further error') 217;Text 54 332 852 35 'Expert-data path' 26 $C.teal $true;Line 310 347 885 347 $C.teal;Text 54 386 852 35 'Learner path' 26 $C.blue $true;Line 310 401 450 401 $C.blue;Line 450 401 630 427 $C.blue;Line 630 427 885 435 $C.blue $true;Text 685 361 221 64 'Conceptual illustration' 24 $C.muted}
   'dagger' {Steps @('Run learner','Ask expert','Aggregate','Retrain') 235;Line 805 331 805 394 $C.teal;Line 805 394 157 394 $C.teal;Line 157 394 157 331 $C.teal $true;Text 324 364 311 40 'Repeat with more data.' 27 $C.teal $true 2}
   'task' {RobotSketch 54 211 350;SmallCard 454 211 452 100 'Observation' 'Position error + velocity';SmallCard 454 331 452 118 'Action' 'Two forces, each limited to ±10 N.' $C.paleTeal}
   'results' {[void]$script:slide.Shapes.AddPicture((Join-Path $root 'demo/comparison.png'),0,-1,115,199,730,258);Text 54 458 852 34 'Saved comparison · simple task, not a robustness guarantee.' 24 $C.muted $true}
   'demo' {RobotSketch 54 211 350;Text 454 218 452 64 'Watch the expert.' 30 $C.blue $true;Text 454 294 452 64 'Collect and fit labels.' 30 $C.teal $true;Text 454 370 452 68 'Watch the independent learner.' 30 $C.blue $true}
   'recap' {SmallCard 54 211 272 205 'Simulation' 'Why use MuJoCo for learning experiments?';SmallCard 344 211 272 205 'Imitation' 'How do expert actions become labels?' $C.paleTeal;SmallCard 634 211 272 205 'Drift' 'Why test complete rollouts?'}
   'backend' {SmallCard 54 211 410 213 'Standard MuJoCo' "CPU physics stepping`nOpenGL visualization`nFits this small demo";SmallCard 486 211 420 213 'Accelerator backends' "MJX / MuJoCo Warp`nMany parallel environments`nCheck workload and support" $C.paleTeal}
   'weights' {Formula 54 209 852 53 'Force = clip(4 × error − 3 × velocity, −10, 10)' 31 $C.blue;Matrix 99 294 500 119 @(@('4','0','−3','0'),@('0','4','0','−3')) 34;Text 647 310 259 94 "W: 2 × 4`nb ≈ [0, 0]" 29 $C.teal $true;Text 54 417 852 34 'Example: [0.3, −0.2, 0.1, 0] → [0.9, −0.8] N' 27}
   'approaches' {SmallCard 54 205 410 112 'Behavior cloning' 'Expert action labels.';SmallCard 486 205 420 112 'DAgger' 'Labels at learner-visited states.' $C.paleTeal;SmallCard 54 331 410 112 'IRL' 'Infer reward explanations.';SmallCard 486 331 420 112 'GAIL' 'Discriminator feedback.' $C.paleTeal}
   'evaluation' {SmallCard 54 211 410 213 'Dataset' "100 episodes / 25,000 rows`n80 train / 20 validation`nRecord before the action";SmallCard 486 211 420 213 'Fresh rollouts' "20 shared test cases`nDistance < 0.03 m`nSpeed < 0.05 m/s`nThroughout final 0.5 s" $C.paleTeal}
  }
  if($item.footer){Text 54 455 852 39 $item.footer 24 $C.muted $true}
 }
 if($presentation.Slides.Count -ne 25){throw 'Expected 25 slides'}
 $teachingMinutes=($lesson[2..18] | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum
 if($teachingMinutes -ne 22 -or ($lesson | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum -ne 45){throw 'Timing differs'}
 foreach($s in $presentation.Slides){foreach($shape in $s.Shapes){
  if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){$tr=$shape.TextFrame.TextRange;if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$script:issues.Add("Slide $($s.SlideIndex): $([math]::Round($tr.BoundWidth,1))×$([math]::Round($tr.BoundHeight,1)) exceeds $($shape.Width)×$($shape.Height): $($tr.Text)")}}
 }}
 New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
 if(-not $NoPreview){foreach($s in $presentation.Slides){$s.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $s.SlideIndex)),'PNG',1600,900)}}
 # Export PDF before hiding backups so the review PDF contains every slide.
 $presentation.SaveAs($pdfPath,32)
 foreach($info in $script:slides){if($info.backup){$presentation.Slides.Item($info.number).SlideShowTransition.Hidden=-1}}
 $presentation.SaveAs($pptxPath,24);$presentation.Close();$presentation=$null
 $check=$app.Presentations.Open($pptxPath,-1,0,0)
 if($check.Slides.Count -ne 25){throw 'Reopened count differs'}
 for($idx=1;$idx -le 25;$idx++){$s=$check.Slides.Item($idx);if(($s.SlideShowTransition.Hidden -eq -1) -ne ($idx -ge 22)){throw "Hidden state differs: $idx"};if($s.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;totalMinutes=45;presentationMinutes=22;demoMinutes=18;recapMinutes=5;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;independentContentChecks=$contentChecks;sourceChecks=$sourceChecks;pythonSuiteRun=$false;headlessTraceRun=$false;pythonLimitation='No installed Python. PowerShell content checks are independent of the Python implementation.';professorPdfReviewed=$false;powerPointRendered=$true;powerPointReopened=$true} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created/reopened 25 slides, four hidden backups, notes on every slide. All protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
}finally{
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}
