. (Join-Path $PSScriptRoot 'check_content.ps1')
function SmallCard([double]$x,[double]$y,[double]$w,[double]$h,[string]$title,[string]$body,[int]$fill=$C.paleBlue){Box $x $y $w $h $fill;Text ($x+16) ($y+12) ($w-32) 65 $title 26 $C.blue $true;if($body){Text ($x+16) ($y+77) ($w-32) ($h-81) $body 24}}
function Plot([string]$file,[double]$x,[double]$y,[double]$w,[double]$h){[void]$script:slide.Shapes.AddPicture((Join-Path $root $file),0,-1,$x,$y,$w,$h)}
function BellCurve{
 Line 488 400 900 400 $C.muted $true
 $prevX=488;$prevY=400-145*[math]::Exp(-[math]::Pow((488-672)/72,2)/2)
 for($step=1;$step -le 55;$step++){$px=488+$step*7.4;$py=400-145*[math]::Exp(-[math]::Pow(($px-672)/72,2)/2);Line $prevX $prevY $px $py $C.blue;$prevX=$px;$prevY=$py}
 Line 672 255 672 402 $C.teal $false $true;Text 631 409 99 34 'Mean' 24 $C.teal $true
 Line 600 327 744 327 $C.teal $false $false $true;Text 620 289 111 33 'Spread' 24 $C.teal $true
 Dot 788 400 7 $C.amber;Line 788 400 788 362 $C.amber;Text 762 323 137 67 'Sampled action' 24 $C.amber $true
}
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add('# Week 9 — Policy Gradients and Actor–Critic');$lines.Add('')
$lines.Add('**30 minutes presentation/worked mathematics + 10 minutes visual demo + 5 minutes questions/recap.** This selected schedule replaces the older presentation timing; preserved teaching notes and demo runbook retain their previous schedule. 30 English slides: title, 22 teaching slides, demo transition, recap, and five hidden backups. Light background, blue/teal accents, editable diagrams and equations. Preserve all demo files, checkpoints, README and teaching notes.')
$lines.Add('');$lines.Add('## Sequence and timing');$lines.Add('');$lines.Add('| Slide | Topic | Minutes |');$lines.Add('|---|---|---:|')
for($idx=0;$idx -lt $lesson.Count;$idx++){$item=$lesson[$idx];$lines.Add("| $($idx+1) | $($item.title)$(if($item.backup){' (hidden)'}) | $($item.minutes) |")}
$lines.Add('');$lines.Add('## Speaker guidance, mathematics and visuals')
for($idx=0;$idx -lt $lesson.Count;$idx++){
 $item=$lesson[$idx];$lines.Add('');$lines.Add("### $($idx+1). $($item.title)");$lines.Add('');$lines.Add("$($item.subtitle) Timing: $($item.minutes) minutes. Visual: $($item.kind).");$lines.Add('');$lines.Add($item.notes)
 if($item.equations){$lines.Add('');foreach($eq in $item.equations){$lines.Add("- ``$eq``")}}
 if($item.footer){$lines.Add('');$lines.Add($item.footer)};$lines.Add('');foreach($ref in $item.refs){$lines.Add("- $($sources[$ref])")}
}
$lines.Add('');$lines.Add('## Actual source excerpts');$lines.Add('')
foreach($key in @('losses','action')){$lines.Add("### $key — demo source, whitespace may be rewrapped");$lines.Add('');$lines.Add('```python');$lines.Add($snippets[$key].Trim());$lines.Add('```');$lines.Add('')}
$lines.Add('## Validation and rehearsal boundaries');$lines.Add('')
$lines.Add('Read existing plan, teaching notes, demo runbook, all Python sources/tests, dependency pins, ignore rules, saved settings/results and both plots. Checkpoints are preserved binary artifacts; source review does not claim their execution. No professor deck supplied. Verify all 30 previews, notes, timing, hidden slides 26–30, PDF pages, numerical calculations and source excerpts. Report protected SHA-256 hashes. Python availability is rechecked; if unavailable, existing tests/checkpoint evaluation remain unexecuted locally. Historical training results are clearly labeled and classroom viewer rehearsal remains separate from PowerPoint checks. Reproduction commands and machine-readable evidence are under slides/.')
[IO.File]::WriteAllText($planPath,($lines -join "`r`n"),[Text.UTF8Encoding]::new($false))
$app=$null;$presentation=$null;$hadExistingPresentations=$true
try{
 $app=New-Object -ComObject PowerPoint.Application;$hadExistingPresentations=($app.Presentations.Count -gt 0)
 $presentation=$app.Presentations.Add(0);$presentation.PageSetup.SlideWidth=$W;$presentation.PageSetup.SlideHeight=$H
 foreach($item in $lesson){
  $refs=($item.refs | ForEach-Object {$sources[$_]}) -join "`r`n"
  $extra=$(if($item.kind -in 'demo','density'){"`r`nACTUAL SOURCE EXCERPT`r`n$($snippets.losses)"}else{''})
  NewSlide $item.title $item.subtitle $item.minutes ("TIMING: $($item.minutes) minutes.`r`n$($item.notes)$extra`r`n`r`nSOURCES`r`n$refs") ([bool]$item.backup)
  switch($item.kind){
   'title' {Card 54 211 410 205 'Learn a policy' "Expected return`nPolicy-gradient derivation";Card 486 211 420 205 'Guide its learning' "Baseline and advantage`nActor and critic" $C.paleTeal $C.teal;Text 54 449 852 39 '30 min mathematics · 10 min visual demo · 5 min recap' 27 $C.muted $true}
   'tableSize' {SmallCard 54 207 410 128 '4 state dimensions' '100 bins each → 100⁴ states';SmallCard 486 207 420 128 '1 action dimension' '100 bins → 100 actions' $C.paleTeal;Formula 54 361 852 69 '100^4 × 100 = 10^{10} Q entries' 42 $C.blue}
   'policy' {Card 54 211 410 223 'Week 8 · Q estimates' "Observation → Q table`nRead action values`nChoose an action";Card 486 211 420 223 'Week 9 · Actor' "Observation → network`nDescribe likely actions`nSample an action" $C.paleTeal $C.teal}
   'cart' {Line 75 428 418 428 $C.muted;Box 142 365 182 48 $C.blue;Dot 178 419 9 $C.ink;Dot 288 419 9 $C.ink;Line 232 365 290 216 $C.teal;Dot 232 365 7 $C.teal;Dot 290 216 10 $C.teal;Line 232 357 232 209 $C.muted $false $true;Line 128 339 340 339 $C.blue $true $false $true;SmallCard 460 207 446 144 'Observe' "Position, angle`nTwo velocities";SmallCard 460 365 446 79 'Act' '' $C.paleTeal;Text 590 384 297 42 'Continuous command' 24}
   'distribution' {SmallCard 54 249 181 154 'Observe' 'Robot state';SmallCard 254 249 192 154 'Policy' 'Mean + spread' $C.paleTeal;Line 237 317 252 317 $C.teal $true;Line 448 317 484 317 $C.teal $true;Text 505 206 369 40 'Action distribution' 28 $C.blue $true;BellCurve}
   'equations' {
    $n=$item.equations.Count;$gap=if($n -ge 4){59}else{76};$size=if($n -ge 4){29}else{32}
    for($row=0;$row -lt $n;$row++){$eq=$item.equations[$row];$fs=if($eq.Length -gt 79){24}elseif($eq.Length -gt 65){27}else{$size};Formula 54 (207+$row*$gap) 852 56 $eq $fs $(if($row -eq 0){$C.blue}else{$C.ink})}
   }
   'reinforce' {Formula 54 211 852 74 $item.equations[0] 32 $C.blue;SmallCard 54 317 410 122 'Positive weight' 'Encourage sampled likelihood.';SmallCard 486 317 420 122 'Negative weight' 'Discourage sampled likelihood.' $C.paleTeal}
   'variance' {SmallCard 54 211 272 223 'Different starts' 'Some states are easier than others.';SmallCard 344 211 272 223 'Sampled actions' 'Different choices change the trajectory.' $C.paleTeal;SmallCard 634 211 272 223 'Delayed effects' 'Many decisions contribute to return.'}
   'baselineExample' {Formula 54 213 852 59 'Centered weight = return − baseline' 34 $C.blue;Card 54 305 410 130 'Return 8; baseline 6' '8 − 6 = +2';Card 486 305 420 130 'Return 4; baseline 6' '4 − 6 = −2' $C.paleTeal $C.teal}
   'actorCritic' {Card 54 271 294 161 'Observation' 'Current robot state';SmallCard 464 207 442 109 'Actor · θ' '';Text 480 272 410 39 'Action distribution' 24;SmallCard 464 337 442 109 'Critic · φ' '' $C.paleTeal;Text 480 402 410 39 'One value: Vφ(s)' 24;Line 351 344 461 256 $C.blue $true;Line 351 351 461 392 $C.teal $true}
   'loop' {SmallCard 54 236 198 194 'Collect' 'Fresh policy experience';SmallCard 272 236 198 194 'Targets' 'Rewards + tail' $C.paleTeal;SmallCard 490 236 198 194 'Advantage' 'Target − value';SmallCard 708 236 198 194 'Update' 'Both networks' $C.paleTeal;foreach($pos in @(254,472,690)){Line $pos 330 ($pos+15) 330 $C.blue $true};Line 799 214 150 214 $C.teal $true}
   'evaluation' {Card 54 211 410 226 'Training' "Sample from the policy`nLearn from rewards`nUpdate actor and critic";Card 486 211 420 226 'Evaluation' "Use a representative action`nFreeze all weights`nUse held-out starts" $C.paleTeal $C.teal}
   'ppo' {for($row=0;$row -lt 4;$row++){Formula 54 (207+$row*58) 852 54 $item.equations[$row] 30 $(if($row -eq 0){$C.blue}else{$C.ink})}}
   'sac' {for($row=0;$row -lt 4;$row++){Formula 54 (207+$row*58) 852 54 $item.equations[$row] $(if($row -eq 0){25}else{29}) $(if($row -eq 0){$C.blue}else{$C.ink})}}
   'results' {Plot 'demo/classroom/comparison.png' 54 207 852 234}
   'demo' {Plot 'demo/classroom/comparison.png' 54 221 552 185;Text 637 209 269 70 'Watch initial / trained.' 28 $C.blue $true;Text 637 290 269 71 'Explain the two roles.' 28 $C.teal $true;Text 637 371 269 72 'Compare three seeds.' 28 $C.blue $true}
   'recap' {SmallCard 54 211 272 223 'Policy gradient' 'How do rewards change action likelihood?';SmallCard 344 211 272 223 'Baseline' 'Why subtract a reference?' $C.paleTeal;SmallCard 634 211 272 223 'Actor–critic' 'Who acts, and who evaluates?'}
   'density' {Formula 54 207 852 68 $item.equations[0] 32 $C.blue;Formula 54 278 852 65 $item.equations[1] 28;Tag 54 384 258 'Fixed action sample';Tag 351 384 258 'Fixed advantage' $C.paleTeal $C.teal;Tag 648 384 258 'Fixed return target'}
   'comparison' {SmallCard 54 211 272 223 'A2C · this demo' "Fresh rollouts`nV critic`nOne batch update";SmallCard 344 211 272 223 'PPO · overview' "Rollout minibatches`nV critic`nClipped objective" $C.paleTeal;SmallCard 634 211 272 223 'SAC · overview' "Replay data`nTwin Q critics`nEntropy objective"}
  }
  if($item.footer){Text 54 455 852 39 $item.footer 24 $C.muted $true}
 }
 if($presentation.Slides.Count -ne 30){throw 'Expected 30 slides'}
 $teachingMinutes=($lesson[1..22] | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum
 if($teachingMinutes -ne 30 -or ($lesson | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum -ne 45){throw 'Timing differs'}
 foreach($s in $presentation.Slides){foreach($shape in $s.Shapes){
  if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){$tr=$shape.TextFrame.TextRange;if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$script:issues.Add("Slide $($s.SlideIndex): $([math]::Round($tr.BoundWidth,1))×$([math]::Round($tr.BoundHeight,1)) exceeds $($shape.Width)×$($shape.Height): $($tr.Text)")}}
 }}
 New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
 if(-not $NoPreview){foreach($s in $presentation.Slides){$s.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $s.SlideIndex)),'PNG',1600,900)}}
 # Export all slides before hiding backups.
 $presentation.SaveAs($pdfPath,32)
 foreach($info in $script:slides){if($info.backup){$presentation.Slides.Item($info.number).SlideShowTransition.Hidden=-1}}
 $presentation.SaveAs($pptxPath,24);$presentation.Close();$presentation=$null
 $check=$app.Presentations.Open($pptxPath,-1,0,0)
 if($check.Slides.Count -ne 30){throw 'Reopened count differs'}
 for($idx=1;$idx -le 30;$idx++){$s=$check.Slides.Item($idx);if(($s.SlideShowTransition.Hidden -eq -1) -ne ($idx -ge 26)){throw "Hidden state differs: $idx"};if($s.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;totalMinutes=45;presentationMinutes=30;demoMinutes=10;recapMinutes=5;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;independentContentChecks=$contentChecks;sourceChecks=$sourceChecks;pythonSuiteRun=$false;checkpointEvaluationRun=$false;pythonLimitation='No installed Python. Independent PowerShell arithmetic and source checks do not execute the learner.';professorPdfReviewed=$false;powerPointRendered=$true;powerPointReopened=$true} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created/reopened 30 slides, five hidden backups, notes on every slide. All protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
}finally{
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}
