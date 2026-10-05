function Oval($x,$y,$w,$h,$color=$C.blue,$fill=$false){$s=$script:slide.Shapes.AddShape(9,$x,$y,$w,$h);$s.Line.ForeColor.RGB=$color;$s.Line.Weight=2.2;if($fill){$s.Fill.ForeColor.RGB=$color;$s.Fill.Transparency=.8}else{$s.Fill.Visible=0}}
function Picture($relative,$x,$y,$w,$h){$path=Join-Path $root $relative;if(-not(Test-Path -LiteralPath $path)){throw "Missing figure $path"};$s=$script:slide.Shapes.AddPicture($path,0,-1,$x,$y,-1,-1);$ratio=[math]::Min($w/$s.Width,$h/$s.Height);$targetW=$s.Width*$ratio;$targetH=$s.Height*$ratio;$s.LockAspectRatio=0;$s.Width=$targetW;$s.Height=$targetH}
function Axes($x,$y,$w,$h){Line $x ($y+$h) ($x+$w) ($y+$h) $C.muted $true;Line $x ($y+$h) $x $y $C.muted $true;Text ($x+$w-10) ($y+$h+4) 50 31 'x' 24;Text ($x-24) ($y-12) 40 30 'y' 24}
function DrawWorkflow{
 $labels=@('Predict','Observe','Associate','Update');for($k=0;$k -lt 4;$k++){Tag (54+$k*219) 234 192 $labels[$k] $(if($k%2){$C.paleTeal}else{$C.paleBlue}) $(if($k%2){$C.teal}else{$C.blue});if($k -lt 3){Line (249+$k*219) 255 (269+$k*219) 255 $C.blue $true}}
 Card 160 335 640 101 'Joint estimate' 'Robot belief + landmark map + uncertainty' $C.paleTeal $C.teal
}
function Coupling{
 Card 54 231 350 159 'Robot pose' 'Where was the sensor?' $C.paleBlue $C.blue;Card 556 231 350 159 'Landmark map' 'What generated the reading?' $C.paleTeal $C.teal
 Line 409 270 550 270 $C.blue $true;Line 550 350 409 350 $C.teal $true
 Text 418 210 137 56 'Place data' 24 $C.blue $true 2;Text 412 368 137 59 'Match data' 24 $C.teal $true 2
}
function Equations($item){
 $n=$item.equations.Count;$gap=if($n -gt 3){58}else{76};
 for($k=0;$k -lt $n;$k++){$eq=[string]$item.equations[$k];$size=if($eq.Length -gt 78){25}elseif($eq.Length -gt 62){28}else{32};Formula 54 (203+$k*$gap) 852 59 $eq $size $(if($k -eq 0){$C.blue}else{$C.ink})}
}
. (Join-Path $PSScriptRoot 'check_content.ps1')
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add('# Week 12 — SLAM and Bayesian Estimation');$lines.Add('');$lines.Add('**30 minutes explanation + 12 minutes integrated visualization + 3 minutes recap.** 38 English slides, including five hidden backups. The new schedule supersedes timing in the preserved teaching notes. The updated range-only demo selects known-map localization or unknown-map joint estimation; all physical landmarks stay fixed.');$lines.Add('');$lines.Add('## Sequence and timing');$lines.Add('');$lines.Add('| Slide | Topic | Minutes |');$lines.Add('|---|---|---:|')
for($i=0;$i -lt $lesson.Count;$i++){$s=$lesson[$i];$lines.Add("| $($i+1) | $($s.title)$(if($s.backup){' (hidden)'}) | $($s.minutes) |")}
$lines.Add('');$lines.Add('## Slide guidance, mathematics, and references')
for($i=0;$i -lt $lesson.Count;$i++){$s=$lesson[$i];$lines.Add('');$lines.Add("### $($i+1). $($s.title)");$lines.Add('');$lines.Add("$($s.subtitle) Visual: $($s.kind). Timing: $($s.minutes) minutes.");$lines.Add('');$lines.Add($s.notes);foreach($eq in $s.equations){$lines.Add('');$lines.Add("``$eq``")};if($s.footer){$lines.Add('');$lines.Add($s.footer)};foreach($ref in $s.refs){$lines.Add('');$lines.Add("Source: $($sources[$ref])")}}
$lines.Add('');$lines.Add('## Demo and validation boundaries');$lines.Add('');$lines.Add('Both modes use identified ranges only, fixed heading, 500 particles, 32 commands, unchanged sensor presets and simulation streams. SLAM uses three conditional81x81 landmark grids at0.125m spacing over[-2,8]m. These normalized location distributions are not occupancy grids. Grid bounds are priors, not walls. The estimator never receives true landmark positions; truth is an independent display overlay. Mode changes pause/reset while retaining seed/noise. Resampling copies complete robot/map hypotheses. There is no explicit loop-closure detector, pose-graph optimizer, moving-landmark model, or heading estimation.');$lines.Add('');$lines.Add('All11 original files were read. No professor presentation was supplied. Preserve original teaching notes, requirements, five localization tests and four localization images using SHA-256. Validate Bayesian updates independently, test both complete noise runs, inspect new images, render/reopen PowerPoint, check38 slides/notes, five hidden backups34–38,38 PDF pages and exact45-minute total. Run results and versions are recorded separately from historical README validation; current Python3.13.5 uses NumPy2.2.6 rather than the preserved pinned1.26.4. Full human classroom rehearsal remains separate.');
[IO.File]::WriteAllText($planPath,($lines -join "`r`n"),[Text.UTF8Encoding]::new($false))
$app=$null;$presentation=$null;$hadExisting=$true
try{
 $app=New-Object -ComObject PowerPoint.Application;$hadExisting=$app.Presentations.Count -gt 0
 $presentation=$app.Presentations.Add(0);$presentation.PageSetup.SlideWidth=$W;$presentation.PageSetup.SlideHeight=$H
 foreach($item in $lesson){
  $refs=($item.refs|ForEach-Object{$sources[$_]}) -join "`r`n"
  NewSlide $item.title $item.subtitle $item.minutes ("TIMING: $($item.minutes) minutes.`r`n$($item.notes)`r`n`r`nSOURCES`r`n$refs") $item.backup
  switch($item.kind){
   'title'{Card 54 224 410 190 'Estimate the robot' "Bayesian beliefs`nParticles and Gaussian filters";Card 486 224 420 190 'Estimate the map' "Range-only landmarks`nJoint uncertainty" $C.paleTeal $C.teal;Text 54 443 852 38 '30 min mathematics · 12 min integrated demo · 3 min recap' 26 $C.muted}
   'coupling'{Coupling;if($item.equations.Count){Formula 54 409 852 49 $item.equations[0] 30 $C.blue}}
   'comparison'{Card 54 217 272 214 'Localization' "Given: map`nEstimate: robot";Card 344 217 272 214 'Mapping' "Given: poses`nEstimate: map" $C.paleTeal $C.teal;Card 634 217 272 214 'SLAM' "Estimate both`nKeep their coupling"}
   'notation'{Equations $item;Tag 54 391 410 't: time · j: landmark';Tag 486 391 420 'i: particle · m: map' $C.paleTeal $C.teal}
   'workflow'{DrawWorkflow}
   'equations'{Equations $item}
   'scene'{Axes 80 210 350 204;foreach($p in @(@(90,404,'L1'),@(410,404,'L2'),@(90,220,'L3'))){Box $p[0] $p[1] 15 15 $C.ink;Text ($p[0]+21) ($p[1]-6) 55 35 $p[2] 24};Oval 180 300 116 84 $C.blue $true;Dot 234 346 9 $C.teal;Card 510 214 396 220 'Model' "500 robot particles`nThree identified ranges`nFixed heading`nTwo noise presets" $C.paleTeal $C.teal}
   'particles'{for($k=0;$k -lt 25;$k++){Dot (110+($k%5)*27+($k%3)*7) (237+[math]::Floor($k/5)*24) (4+$k%5) $C.teal};Formula 365 220 541 96 $item.equations[0] 28 $C.blue;Formula 365 338 541 96 $item.equations[1] 28}
   'weights'{
    $rows=@(@('Particle','Prior × likelihood','Posterior','Copies / 10'),@('A','(1/3) × 0.6 = 0.2','0.6','6'),@('B','(1/3) × 0.3 = 0.1','0.3','3'),@('C','(1/3) × 0.1 = 1/30','0.1','1'))
    $widths=@(140,300,185,227);$left=54
    for($col=0;$col -lt 4;$col++){for($r=0;$r -lt 4;$r++){Box $left (211+$r*52) ($widths[$col]-3) 49 $(if($r -eq 0){$C.paleBlue}else{$C.white});Text ($left+9) (219+$r*52) ($widths[$col]-18) 40 $rows[$r][$col] 24 $C.ink ($r -eq 0)};$left+=$widths[$col]}
   }
   'resample'{for($k=0;$k -lt 10;$k++){Dot (87+$k*78) 295 14 $(if($k -lt 6){$C.blue}elseif($k -lt 9){$C.teal}else{$C.amber})};Text 54 221 852 40 'Expected copies: 6 blue · 3 teal · 1 amber' 28 $C.blue $true;Formula 54 366 852 60 $item.equations[0] 32}
   'cards'{Card 54 213 410 217 'Evidence uncertainty' "Noisy readings`nAmbiguous geometry`nIncorrect noise model";Card 486 213 420 217 'Approximation uncertainty' "Finite robot hypotheses`nResampling diversity`nBounded landmark grids" $C.paleTeal $C.teal}
   'transform'{Axes 90 230 260 184;Dot 205 360 8 $C.blue;Line 205 360 205 255 $C.teal $true;Dot 205 255 8 $C.teal;Line 205 360 300 360 $C.amber $true;Text 235 263 190 36 '(2,3): correct' 24 $C.teal;Text 325 340 120 60 '(3,2): wrong' 24 $C.amber;Formula 480 224 426 90 $item.equations[0] 30 $C.blue;Text 480 327 426 94 "Local point (1,0)`nRobot (2,2), heading 90°" 26}
   'association'{Card 54 216 272 212 'Match' "An existing landmark`nUse its map belief";Card 344 216 272 212 'Initialize' "A new landmark`nKeep uncertainty" $C.paleTeal $C.teal;Card 634 216 272 212 'Reject / defer' "Ambiguous match`nAvoid false certainty"}
   'circles'{Oval 100 218 219 219 $C.blue;Oval 229 218 219 219 $C.teal;Dot 209 329 7 $C.blue;Dot 338 329 7 $C.teal;Dot 274 241 7 $C.amber;Dot 274 415 7 $C.amber;Text 514 221 392 98 "One range: a band`nTwo views: ambiguity" 28;Formula 514 348 392 76 $item.equations[0] 29 $C.blue}
   'loop'{Axes 78 210 344 204;$pts=@(@(100,411),@(354,402),@(360,241),@(117,230),@(145,375));for($k=0;$k -lt 4;$k++){Line $pts[$k][0] $pts[$k][1] $pts[$k+1][0] $pts[$k+1][1] $C.blue $true};Line 145 375 100 411 $C.teal $true $true;Card 510 215 396 215 'Recognized revisit' "Adds a consistency constraint`nRequires correct matching`nCan inform correlated poses" $C.paleTeal $C.teal}
   'conditional'{Card 54 207 310 227 'Particle i' "Robot position`nL1 distribution`nL2 distribution`nL3 distribution" $C.paleTeal $C.teal;Formula 393 231 513 79 $item.equations[0] 29 $C.blue;Formula 393 347 513 79 $item.equations[1] 29}
   'methods'{Card 54 213 272 219 'Particles' "Sampled hypotheses`nMultiple modes`nSampling cost";Card 344 213 272 219 'EKF / UKF' "Mean + covariance`nNonlinear approximations`nCorrelated state" $C.paleTeal $C.teal;Card 634 213 272 219 'Graph SLAM' "Pose/map constraints`nOptimize residuals`nDifferent architecture"}
   'covariance'{Matrix 79 226 340 148 @(@('Σ_{xx}','Σ_{xm}'),@('Σ_{mx}','Σ_{mm}')) 32;Card 510 220 396 211 'Shared uncertainty' "Robot ↔ landmarks`nLandmark ↔ landmark`nUse the full covariance" $C.paleTeal $C.teal}
   'demo'{
    $name=switch($item.title){'Live: inspect the initial belief'{'initial'};'Live: predict before pressing'{'prediction'};'Live: reveal weighting'{'weighting'};default{'resampling'}}
    Picture "demo/figures/$name.png" 54 202 550 240
    Card 627 208 279 218 'Predict → reveal' $(switch($name){'initial'{"Which information`nis known?"};'prediction'{"What moves?`nWhat stays fixed?"};'weighting'{"Dots or weights?`nWhy does the mean move?"};default{"Another measurement?`nWhat gets copied?"}}) $C.paleTeal $C.teal
   }
   'slamdemo'{Picture 'demo/figures/slam_low/weighting.png' 54 202 550 240;Card 627 208 279 218 'Change modes' "Unknown locations`nRange-only bands`nMultiple viewpoints" $C.paleTeal $C.teal}
   'recap'{Card 54 211 410 224 'Explain the updates' "Prediction versus evidence`nLikelihood versus weight`nResampling versus sensing";Card 486 211 420 224 'Explain SLAM' "Known versus unknown map`nPose–map coupling`nParticles versus Gaussian filters" $C.paleTeal $C.teal}
  }
  if($item.footer){Text 54 449 852 41 $item.footer 24 $C.muted}
 }
 if($presentation.Slides.Count -ne 38){throw 'Slide count differs'}
 foreach($s in $presentation.Slides){foreach($shape in $s.Shapes){if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){$tr=$shape.TextFrame.TextRange;if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$script:issues.Add("Slide $($s.SlideIndex): $([math]::Round($tr.BoundWidth,1)) x $([math]::Round($tr.BoundHeight,1)) exceeds $($shape.Width) x $($shape.Height): $($tr.Text)")}}}}
 New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
 if(-not $NoPreview){foreach($s in $presentation.Slides){$s.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $s.SlideIndex)),'PNG',1600,900)}}
 $presentation.SaveAs($pdfPath,32)
 foreach($info in $script:slides){if($info.backup){$presentation.Slides.Item($info.number).SlideShowTransition.Hidden=-1}}
 $presentation.SaveAs($pptxPath,24);$presentation.Close();$presentation=$null
 $check=$app.Presentations.Open($pptxPath,-1,0,0)
 if($check.Slides.Count -ne 38){throw 'Reopened count differs'}
 for($i=1;$i -le 38;$i++){$s=$check.Slides.Item($i);if(($s.SlideShowTransition.Hidden -eq -1) -ne ($i -ge 34)){throw "Hidden state differs$i"};if($s.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes$i"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed$path"}}
 [pscustomobject]@{slides=$script:slides;totalMinutes=45;presentationMinutes=30;demoMinutes=12;recapMinutes=3;slideWidth=$W;slideHeight=$H;layoutIssues=@($script:issues);protectedFiles=$protectedHashes;contentChecks=@($contentChecks);powerPointRendered=$true;powerPointReopened=$true} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created/reopened38 slides; five hidden backups; notes on every slide.'
 if($script:issues.Count){$script:issues|ForEach-Object{Write-Output $_}}else{Write-Output 'No text overflow detected.'}
}finally{if($null -ne $presentation){try{$presentation.Close()}catch{}};if($null -ne $app -and -not $hadExisting){try{$app.Quit()}catch{}};if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)};[GC]::Collect();[GC]::WaitForPendingFinalizers()}
