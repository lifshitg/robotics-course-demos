. (Join-Path $PSScriptRoot 'check_content.ps1')
function SmallCard([double]$x,[double]$y,[double]$w,[double]$h,[string]$title,[string]$body,[int]$fill=$C.paleBlue){Box $x $y $w $h $fill;Text ($x+16) ($y+12) ($w-32) 61 $title 26 $C.blue $true;if($body){Text ($x+16) ($y+75) ($w-32) ($h-79) $body 24}}
function Grid([double]$x,[double]$y,[double]$w,[object[]]$rows,[double]$rh=48){
 $cols=$rows[0].Count;$cw=$w/$cols
 for($row=0;$row -lt $rows.Count;$row++){for($col=0;$col -lt $cols;$col++){
  Box ($x+$col*$cw) ($y+$row*$rh) ($cw-2) ($rh-2) $(if($row -eq 0){$C.paleBlue}elseif($col -eq 0){$C.paleTeal}else{$C.white})
  Text ($x+$col*$cw+9) ($y+$row*$rh+7) ($cw-18) ($rh-9) ([string]$rows[$row][$col]) 25 $C.ink ($row -eq 0 -or $col -eq 0)
 }}
}
function ValuePlot([double]$x,[double]$y,[double]$w,[double]$h,[bool]$sensing=$false){
 $px0=$x+45;$px1=$x+$w-14;$py0=$y+18;$py1=$y+$h-37;$mid=($py0+$py1)/2
 Line $px0 $py0 $px0 $py1 $C.muted;Line $px0 $mid $px1 $mid $C.line;Line $px0 $py1 $px1 $py1 $C.muted
 Text $x ($py0-12) 37 28 '10' 24;Text $x ($mid-12) 37 28 '0' 24;Text $x ($py1-12) 43 28 '−10' 24
 Text ($px0-6) ($py1+5) 36 31 '0' 24;Text ((($px0+$px1)/2)-15) ($py1+5) 60 31 '0.5' 24;Text ($px1-8) ($py1+5) 36 31 '1' 24
 Line $px0 $py1 $px1 $py0 $C.blue;Line $px0 $py0 $px1 $py1 $C.amber
 if($sensing){Line $px0 ($mid-5*($py1-$py0)/20) $px1 ($mid-7*($py1-$py0)/20) $C.teal}
 $prevX=$px0;$prevValue=10;$prevY=$mid-$prevValue*($py1-$py0)/20
 for($step=1;$step -le 60;$step++){$p=$step/60;$value=[math]::Max(20*$p-10,10-20*$p);if($sensing){$value=[math]::Max($value,5+2*$p)};$px=$px0+$p*($px1-$px0);$py=$mid-$value*($py1-$py0)/20;Line $prevX $prevY $px $py $C.ink $false $true;$prevX=$px;$prevY=$py}
 $val=$(if($sensing){6}else{0});Dot (($px0+$px1)/2) ($mid-$val*($py1-$py0)/20) 6 $C.teal
}
function PolicyTree{
 Box 333 205 294 94 $C.paleTeal;Text 350 214 260 40 'Sense: cost 1' 28 $C.teal $true 2;Text 350 258 260 36 'b = (0.5,0.5)' 24 $C.teal $false 2
 Line 406 303 254 355 $C.blue $true;Line 554 303 706 355 $C.amber $true
 Text 154 294 243 57 'Red: 0.55' 25 $C.blue $true;Text 616 294 253 57 'Blue: 0.45' 25 $C.amber $true
 Card 54 355 350 91 'Commit L' '';Card 554 355 352 91 'Commit R' '' $C.paleTeal $C.teal
}
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add('# Week 10 — POMDPs: Beliefs, Bayesian Updates, and Information-Gathering Decisions');$lines.Add('')
$lines.Add('**38 minutes explanation/worked calculations + 4 minutes student exercise + 3 minutes questions/recap. No software-demo block.** 38 English slides: title, 30 teaching slides, one exercise, recap and five hidden backups. Preserve teaching notes, board-work README and existing SVG. The current conceptual sequence is expanded through annotated mathematics, original editable diagrams, and detailed notes. The selected schedule takes precedence over the preserved notes timing.')
$lines.Add('');$lines.Add('## Sequence and timing');$lines.Add('');$lines.Add('| Physical slide | Topic | Minutes |');$lines.Add('|---|---|---:|')
for($idx=0;$idx -lt $lesson.Count;$idx++){$item=$lesson[$idx];$lines.Add("| $($idx+1) | $($item.title)$(if($item.backup){' (hidden)'}) | $($item.minutes) |")}
$lines.Add('');$lines.Add('## Speaker guidance, formulas, and visuals')
for($idx=0;$idx -lt $lesson.Count;$idx++){
 $item=$lesson[$idx];$lines.Add('');$lines.Add("### $($idx+1). $($item.title)");$lines.Add('');$lines.Add("$($item.subtitle) Timing: $($item.minutes) minutes. Visual: $($item.kind). Existing professor reference: Class18-POMDPs.pdf printed slides $($item.lecture).")
 $lines.Add('');$lines.Add($item.notes);if($item.equations){$lines.Add('');foreach($eq in $item.equations){$lines.Add("- ``$eq``")}}
 if($item.footer){$lines.Add('');$lines.Add($item.footer)};$lines.Add('');foreach($ref in $item.refs){$lines.Add("- $($sources[$ref])")}
}
$lines.Add('');$lines.Add('## Numerical models and checks');$lines.Add('')
$lines.Add('Example A: prior (0.6,0.4), transition rows [0.8,0.2] and [0.1,0.9]; sensor rows L: red0.9/blue0.1 and R: red0.2/blue0.8. Column prediction T-transpose b = (0.52,0.48). Red weights (0.468,0.096), probability0.564, posterior(0.8297872340,0.1702127660). Blue weights(0.052,0.384), probability0.436, posterior(0.1192660550,0.8807339450). These observations are alternatives. Expected posterior equals predicted belief.')
$lines.Add('');$lines.Add('Example B: reset to (0.5,0.5), identity sensing transition, cost1, terminal correct/incorrect rewards +10/-10, gamma1, at most sense once then commit. Observation probabilities0.55/0.45, posteriors(9/11,2/11) and(1/9,8/9). Conditional best commitment values70/11 and70/9; sensing value6 and correctness0.85. At uniform prior cost threshold7. Commitment vectors(10,-10),(-10,10); fixed sensing vector(7,5), line5+2p. At cost1 the three-line envelope prefers sensing for5/22<p<5/6, with endpoint ties. The commitment-only plot is kept distinct from this expanded comparison.')
$lines.Add('');$lines.Add('## Validation and provenance');$lines.Add('')
$lines.Add('Read all four original Week10 files. Protect the three files outside the intentionally revised presentation plan via SHA-256. The professor PDF was not found locally; retain filename/title-page discrepancy and printed references without claiming review. Sources are primary paper and author tutorial. Verify38 slides, all notes, five hidden backups34–38,38 PDF pages, sequential exercise16/answer17, all previews, equations, sums, ratios and exact38+4+3 timing. No ROS, MuJoCo, software-demo execution or new homework is required. Independent PowerShell arithmetic checks and PowerPoint rendering are recorded under slides/.')
[IO.File]::WriteAllText($planPath,($lines -join "`r`n"),[Text.UTF8Encoding]::new($false))
$app=$null;$presentation=$null;$hadExistingPresentations=$true
try{
 $app=New-Object -ComObject PowerPoint.Application;$hadExistingPresentations=($app.Presentations.Count -gt 0)
 $presentation=$app.Presentations.Add(0);$presentation.PageSetup.SlideWidth=$W;$presentation.PageSetup.SlideHeight=$H
 foreach($item in $lesson){
  $refs=($item.refs | ForEach-Object {$sources[$_]}) -join "`r`n"
  NewSlide $item.title $item.subtitle $item.minutes ("TIMING: $($item.minutes) minutes.`r`n$($item.notes)`r`n`r`nEXISTING PROFESSOR REFERENCE: Class18-POMDPs.pdf printed slides $($item.lecture). PDF not found locally.`r`n`r`nSOURCES`r`n$refs") ([bool]$item.backup)
  switch($item.kind){
   'title' {Card 54 211 410 204 'Estimate what is hidden' "State and observation`nBayesian belief updates";Card 486 211 420 204 'Decide with uncertainty' "Information value`nBelief policies and vectors" $C.paleTeal $C.teal;Text 54 449 852 39 '38 min worked math · 4 min exercise · 3 min recap' 27 $C.muted $true}
   'mdp' {Card 54 211 410 223 'MDP' "Motion may be random`nResulting state is observed`nPolicy uses state";Card 486 211 420 223 'POMDP' "True state is hidden`nReceive partial evidence`nPolicy uses belief" $C.paleTeal $C.teal}
   'alias' {Tag 54 239 240 'Location L';Tag 54 359 240 'Location R' $C.paleTeal $C.teal;SmallCard 574 261 332 162 'Sensor reading' 'Red is possible in both states.';Line 297 260 570 311 $C.blue $true;Line 297 380 570 338 $C.teal $true}
   'model' {Formula 54 200 852 54 '⟨S, A, Tr, R, Ω, O⟩' 36 $C.blue;Grid 54 266 852 @(@('State/action','Transition/reward','Evidence'),@('S: hidden states','Tr: dynamics','Ω: observations'),@('A: actions','R: rewards','O: likelihoods')) 53}
   'timing' {Tag 54 211 183 'Old state s';Tag 275 211 183 'Action a' $C.paleTeal $C.teal;Tag 496 211 183 'New state s′';Tag 717 211 189 'Observe o' $C.paleTeal $C.teal;foreach($x in @(241,462,683)){Line $x 232 ($x+27) 232 $C.blue $true};Formula 54 298 852 61 $item.equations[0] 29;Formula 54 374 852 61 $item.equations[1] 29 $C.teal}
   'history' {SmallCard 54 211 410 209 'History 1' "Earlier evidence favors L`nThen a red reading";SmallCard 486 211 420 209 'History 2' "Earlier evidence favors R`nThen the SAME red reading" $C.paleTeal;Text 54 424 852 31 'Different prior knowledge → different posterior beliefs' 25 $C.blue $true}
   'equations' {
    $n=$item.equations.Count;$gap=if($n -ge 4){59}else{76};$size=if($n -ge 4){29}else{32}
    for($row=0;$row -lt $n;$row++){$eq=$item.equations[$row];$fs=if($eq.Length -gt 85){24}elseif($eq.Length -gt 68){27}else{$size};Formula 54 (207+$row*$gap) 852 56 $eq $fs $(if($row -eq 0){$C.blue}else{$C.ink})}
   }
   'beliefLine' {Formula 54 207 852 54 $item.equations[0] 34 $C.blue;Line 116 321 849 321 $C.muted;Dot 116 321 7 $C.amber;Dot 849 321 7 $C.blue;Dot 482.5 321 7 $C.teal;Dot 555.8 321 7 $C.blue;Text 77 342 192 65 'Certainly R' 24;Text 739 342 167 65 'Certainly L' 24;Text 408 274 122 36 'p = 0.5' 24 $C.teal;Text 554 342 130 36 'p = 0.6' 24 $C.blue;Formula 54 410 852 39 $item.equations[1] 25}
   'exampleA' {Text 54 202 410 38 'Move transition' 28 $C.blue $true;Text 486 202 420 38 'Sensor model' 28 $C.teal $true;Grid 54 251 410 @(@('From/to','L','R'),@('L','0.8','0.2'),@('R','0.1','0.9')) 55;Grid 486 251 420 @(@('State','Red','Blue'),@('L','0.9','0.1'),@('R','0.2','0.8')) 55}
   'predictionMatrix' {Formula 54 207 852 57 'b̄ = T_a^T b' 36 $C.blue;Matrix 90 296 209 103 @(@('0.8','0.1'),@('0.2','0.9')) 32;Formula 320 329 47 55 '×' 36;Matrix 390 296 135 103 @(@('0.6'),@('0.4')) 32;Formula 560 329 47 55 '=' 36;Matrix 650 296 154 103 @(@('0.52'),@('0.48')) 32 $C.teal}
   'sensor' {Grid 54 211 457 @(@('State','Red','Blue'),@('L','0.9','0.1'),@('R','0.2','0.8')) 59;SmallCard 546 211 360 223 'Condition on state' "Each row sums to 1.`nA likelihood column need not." $C.paleTeal}
   'posteriorRed' {Grid 54 211 852 @(@('Stage','L','R','Sum'),@('Prediction','0.52','0.48','1'),@('Likelihood','0.9','0.2','—'),@('Weights','0.468','0.096','0.564'),@('Posterior','0.829787','0.170213','1')) 44}
   'exercise' {Grid 54 211 852 @(@('Stage','L','R','Sum'),@('Prediction','0.52','0.48','1'),@('Blue likelihood','0.1','0.8','—'),@('Weights','?','?','?'),@('Posterior','?','?','1')) 44}
   'posteriorBlue' {Grid 54 211 852 @(@('Stage','L','R','Sum'),@('Prediction','0.52','0.48','1'),@('Likelihood','0.1','0.8','—'),@('Weights','0.052','0.384','0.436'),@('Posterior','0.119266','0.880734','1')) 44}
   'beliefMDP' {Tag 54 286 221 'Current belief b';Tag 369 211 194 'Red: 0.564';Tag 369 361 194 'Blue: 0.436' $C.paleTeal $C.teal;Tag 655 211 251 'b after red';Tag 655 361 251 'b after blue' $C.paleTeal $C.teal;Line 278 307 365 232 $C.blue $true;Line 278 313 365 382 $C.teal $true;Line 567 232 651 232 $C.blue $true;Line 567 382 651 382 $C.teal $true;Text 77 345 198 66 'Choose move' 24}
   'bellman' {Formula 54 207 852 56 $item.equations[0] 32 $C.teal;Box 54 281 852 148 $C.paleBlue;Formula 70 293 820 56 $item.equations[1] 34 $C.blue;Formula 70 354 820 65 $item.equations[2] 30}
   'exampleB' {SmallCard 54 211 272 223 'Prior' "Reset to (0.5,0.5)`nNo movement";SmallCard 344 211 272 223 'Commit' "Correct: +10`nIncorrect: −10`nTask ends" $C.paleTeal;SmallCard 634 211 272 223 'Sense' "State unchanged`nPay cost 1`nThen commit"}
   'senseResults' {Card 54 207 410 227 'Red · probability 0.55' "Posterior: (9/11, 2/11)`nChoose L`nValue: 70/11 ≈ 6.3636";Card 486 207 420 227 'Blue · probability 0.45' "Posterior: (1/9, 8/9)`nChoose R`nValue: 70/9 ≈ 7.7778" $C.paleTeal $C.teal}
   'tree' {PolicyTree}
   'commitPlot' {ValuePlot 54 211 455 233;Formula 556 211 350 59 'V_L(p) = 20p − 10' 30 $C.blue;Formula 556 280 350 59 'V_R(p) = 10 − 20p' 30 $C.amber;Formula 556 353 350 71 'V = max(V_L,V_R)' 28;Text 558 421 346 32 'p = b(L)' 24 $C.muted}
   'senseAlpha' {ValuePlot 54 240 390 203 $true;for($row=0;$row -lt 3;$row++){Formula 478 (207+$row*80) 428 75 $item.equations[$row] 24 $(if($row -eq 0){$C.blue}else{$C.teal})};Text 93 209 324 31 'Add the fixed sensing tree' 25 $C.teal $true}
   'complexity' {SmallCard 54 211 272 223 'Belief space' 'Infinitely many possible beliefs';SmallCard 344 211 272 223 'Policy trees' 'Branch on every future observation' $C.paleTeal;SmallCard 634 211 272 223 'Model limits' 'Our small example does not establish scalability.'}
   'recap' {SmallCard 54 211 272 223 'Belief update' 'Prediction → likelihood → normalization';SmallCard 344 211 272 223 'Information value' 'Does evidence change the best decision?' $C.paleTeal;SmallCard 634 211 272 223 'Policy values' 'Fixed tree → alpha-vector → belief dot product'}
   'generalPrior' {for($row=0;$row -lt $item.equations.Count;$row++){Formula 54 (207+$row*60) 852 55 $item.equations[$row] 29 $(if($row -eq 0){$C.blue}else{$C.ink})}}
   'solverMap' {SmallCard 54 211 272 223 'Exact planning' 'Alpha-vector candidates and pruning';SmallCard 344 211 272 223 'Approximation' 'Selected beliefs / point-based methods' $C.paleTeal;SmallCard 634 211 272 223 'Online planning' 'Focus simulations on the current belief'}
  }
  if($item.footer){Text 54 455 852 39 $item.footer 24 $C.muted $true}
 }
 if($presentation.Slides.Count -ne 38){throw 'Expected 38 slides'}
 $teachingMinutes=($lesson | Where-Object {$_.minutes -gt 0 -and $_.kind -notin 'exercise','recap'} | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum
 if($teachingMinutes -ne 38 -or ($lesson | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum -ne 45){throw 'Timing differs'}
 foreach($s in $presentation.Slides){foreach($shape in $s.Shapes){
  if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){$tr=$shape.TextFrame.TextRange;if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$script:issues.Add("Slide $($s.SlideIndex): $([math]::Round($tr.BoundWidth,1))×$([math]::Round($tr.BoundHeight,1)) exceeds $($shape.Width)×$($shape.Height): $($tr.Text)")}}
 }}
 New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
 if(-not $NoPreview){foreach($s in $presentation.Slides){$s.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $s.SlideIndex)),'PNG',1600,900)}}
 $presentation.SaveAs($pdfPath,32)
 foreach($info in $script:slides){if($info.backup){$presentation.Slides.Item($info.number).SlideShowTransition.Hidden=-1}}
 $presentation.SaveAs($pptxPath,24);$presentation.Close();$presentation=$null
 $check=$app.Presentations.Open($pptxPath,-1,0,0)
 if($check.Slides.Count -ne 38){throw 'Reopened count differs'}
 for($idx=1;$idx -le 38;$idx++){$s=$check.Slides.Item($idx);if(($s.SlideShowTransition.Hidden -eq -1) -ne ($idx -ge 34)){throw "Hidden state differs: $idx"};if($s.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;totalMinutes=45;presentationMinutes=38;exerciseMinutes=4;recapMinutes=3;softwareDemoMinutes=0;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;independentContentChecks=$contentChecks;sourceChecks=$sourceChecks;professorPdfReviewed=$false;powerPointRendered=$true;powerPointReopened=$true} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created/reopened 38 slides, five hidden backups, notes on every slide. All protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
}finally{
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}
