. (Join-Path $PSScriptRoot 'check_content.ps1')
function SmallCard([double]$x,[double]$y,[double]$w,[double]$h,[string]$title,[string]$body,[int]$fill=$C.paleBlue){Box $x $y $w $h $fill;Text ($x+16) ($y+12) ($w-32) 39 $title 26 $C.blue $true;if($body){Text ($x+16) ($y+57) ($w-32) ($h-63) $body 24}}
function Code([double]$x,[double]$y,[double]$w,[double]$h,[string]$body){Box $x $y $w $h $C.paleBlue;Text ($x+16) ($y+15) ($w-32) ($h-24) $body.Trim() 24 $C.ink $false 1 'Consolas'}
function Maze([double]$x=54,[double]$y=207,[double]$side=235,[bool]$route=$false){
 $cell=$side/5;$walls=@('1,1','1,2','2,2','3,1','3,3')
 for($r=0;$r -lt 5;$r++){for($col=0;$col -lt 5;$col++){$shape=$script:slide.Shapes.AddShape(1,($x+$col*$cell),($y+$r*$cell),$cell,$cell);$shape.Fill.ForeColor.RGB=$(if("$r,$col" -in $walls){$C.muted}else{$C.white});$shape.Line.ForeColor.RGB=$C.line}}
 Dot ($x+$cell/2) ($y+4.5*$cell) 11 $C.blue;Dot ($x+4.5*$cell) ($y+$cell/2) 11 $C.teal
 if($route){Line ($x+$cell/2) ($y+4.5*$cell) ($x+4.5*$cell) ($y+4.5*$cell) $C.teal $true;Line ($x+4.5*$cell) ($y+4.5*$cell) ($x+4.5*$cell) ($y+$cell/2) $C.teal $true}
 Text ($x+$side+13) ($y+$side-33) 180 33 'Start (4,0)' 24 $C.blue $true;Text ($x+$side+13) $y 180 65 'Goal (0,4)' 24 $C.teal $true
}
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add('# Week 8 — Q-Learning: Mathematics, Exploration, and Off-Policy Learning');$lines.Add('')
$lines.Add('**30 minutes explanation + 10 minutes demo + 5 minutes recap** (new selected schedule; preserved teaching notes/runbook retain their older timing). 28 slides including five hidden backups. English,16:9, light background, blue/teal accents, editable diagrams and equations. Derive the sampled Bellman update, distinguish epsilon-greedy behavior from greedy targets, and explain training/evaluation isolation. Preserve all demo files and teaching notes; no behavior, dependencies or interfaces change.')
$lines.Add('');$lines.Add('## Sequence and timing');$lines.Add('');$lines.Add('| Slide | Topic | Minutes |');$lines.Add('|---|---|---:|')
for($i=0;$i -lt $lesson.Count;$i++){$item=$lesson[$i];$lines.Add("| $($i+1) | $($item.title)$(if($item.backup){' (hidden)'}) | $($item.minutes) |")}
$lines.Add('');$lines.Add('## Speaker guidance and visuals')
for($i=0;$i -lt $lesson.Count;$i++){
 $item=$lesson[$i];$lines.Add('');$lines.Add("### $($i+1). $($item.title)");$lines.Add('');$lines.Add("$($item.subtitle) Timing: $($item.minutes) minutes. Visual: $($item.kind).");$lines.Add('');$lines.Add($item.notes)
 if($item.equations){$lines.Add('');foreach($eq in $item.equations){$lines.Add("- ``$eq``")}}
 if($item.footer){$lines.Add('');$lines.Add($item.footer)};$lines.Add('');foreach($ref in $item.refs){$lines.Add("- $($sources[$ref])")}
}
$lines.Add('');$lines.Add('## Exact examples and code excerpts');$lines.Add('')
$lines.Add('α=.2,γ=.95,ε=.2, zero5×5×4 table, seed7. NextQ=[4,1,−2,0], ordinary reward−1,old0:Q-learning target2.8,new.56; if next exploratory action has value−2, SARSA target−2.9,new−.58. First goal target10,new2. External100step cap retains bootstrapping. With one greedy action, epsilon-greedy probabilities are.85,.05,.05,.05; two tied maximizers receive.45 each. Eight-move rewards are seven−1 then+10:raw3,discounted.9501188828124985.')
foreach($key in @('update','explore','terminal')){$lines.Add('');$lines.Add("### $key — actual learning.py excerpt, whitespace rewrapped");$lines.Add('');$lines.Add('```python');$lines.Add($snippets[$key].Trim());$lines.Add('```')}
$lines.Add('');$lines.Add('## Validation and rehearsal boundaries');$lines.Add('')
$lines.Add('All ten original nonmetadata files and demo .gitignore read; no professor presentation supplied. Retain Sutton/Barto reference without claiming unavailable PDF review. Render/reopen PowerPoint, inspect28 previews, notes, five hidden backups,28 PDF pages, sources, equations and30+10+5 timing. Verify protected hashes. Independent arithmetic/source checks do not execute Python. Python unavailable locally: existing tests and headless training unexecuted here. Saved figures and documented seed7 results are historical. Classroom GUI rehearsal is separate. Evidence and reproducible commands are in slides/README.md and validation.json/review.json.')
[IO.File]::WriteAllText($planPath,($lines -join "`r`n"),[Text.UTF8Encoding]::new($false))
$app=$null;$presentation=$null;$hadExistingPresentations=$true
try{
 $app=New-Object -ComObject PowerPoint.Application;$hadExistingPresentations=($app.Presentations.Count -gt 0)
 $presentation=$app.Presentations.Add(0);$presentation.PageSetup.SlideWidth=$W;$presentation.PageSetup.SlideHeight=$H
 foreach($item in $lesson){
  $refs=($item.refs | ForEach-Object {$sources[$_]}) -join "`r`n"
  NewSlide $item.title $item.subtitle $item.minutes ("TIMING: $($item.minutes) minutes.`r`n$($item.notes)`r`n`r`nSOURCES`r`n$refs") ([bool]$item.backup)
  switch($item.kind){
   'title' {Card 54 211 410 205 'Learn values' "Bellman targets`nTemporal-difference updates";Card 486 211 420 205 'Understand behavior' "Exploration / exploitation`nOff-policy learning" $C.paleTeal $C.teal;Text 54 449 852 39 '30 min explanation · 10 min demo · 5 min recap' 27 $C.muted $true}
   'progress' {SmallCard 54 211 272 209 'Week 6 · Planning' 'Known model → Bellman backups';SmallCard 344 211 272 209 'Week 7 · Imitation' 'Expert observations → action labels' $C.paleTeal;SmallCard 634 211 272 209 'Week 8 · RL' 'Sampled transitions → reward feedback'}
   'maze' {Maze;SmallCard 440 211 466 100 'Agent' 'Select an action; update Q.';SmallCard 440 332 466 106 'Environment' 'Return next state and reward.' $C.paleTeal;Line 649 315 649 330 $C.teal $true}
   'equations' {
    $n=$item.equations.Count;$gap=if($n -ge 4){59}else{76};$size=if($n -ge 4){29}else{31}
    for($j=0;$j -lt $n;$j++){$eq=$item.equations[$j];$fs=if($eq.Length -gt 76){24}elseif($eq.Length -gt 65){27}else{$size};Formula 54 (207+$j*$gap) 852 56 $eq $fs $(if($j -eq 0){$C.blue}else{$C.ink})}
   }
   'bellman' {Formula 54 207 852 53 $item.equations[0] 34 $C.teal;Box 54 282 852 145 $C.paleBlue;Formula 72 291 816 55 $item.equations[1] 32 $C.blue;Formula 72 357 816 55 $item.equations[2] 30 $C.blue}
   'sample' {SmallCard 54 211 410 186 'Known-model backup' "Average all possible outcomes`nusing transition probabilities.";SmallCard 486 211 420 186 'Sampled experience' "Observe one outcome:`n(s, a, r, s′, d)" $C.paleTeal;Line 467 303 483 303 $C.teal $true;Formula 54 413 852 42 'Sample target:    r + γ(1−d) max_{a′} Q(s′,a′)' 29 $C.blue}
   'termination' {SmallCard 54 211 410 213 'Goal · termination' "Target = reward = 10`nOld = 0; new = 2`nNo continuation.";SmallCard 486 211 420 213 'Cap · truncation' "Target = r + γ max Q(s′,·)`nKeep continuation.`nCollection then restarts." $C.paleTeal}
   'max' {Formula 54 209 852 54 'At s′:    Q(s′,·) = [4, 1, −2, 0]' 34 $C.blue;SmallCard 54 294 410 139 'Next behavior action' 'Exploration may select value −2.';SmallCard 486 294 420 139 'Continuation target' 'The max still uses value 4.' $C.paleTeal}
   'offpolicy' {SmallCard 54 211 410 192 'Behavior policy μ' "Epsilon-greedy`nChooses experienced actions.";SmallCard 486 211 420 192 'Greedy target π_Q' "Max at the next state`nValues greedy continuation." $C.paleTeal;Formula 54 415 852 39 'Data: μ     |     Target: r + γ max_{a′} Q(s′,a′)' 29 $C.blue}
   'sarsa' {SmallCard 54 211 410 206 'Q-learning' "Uses max next Q = 4`nTarget = 2.8`nNew = 0.56";SmallCard 486 211 420 206 'SARSA' "Uses chosen next Q = −2`nTarget = −2.9`nNew = −0.58" $C.paleTeal}
   'explore' {SmallCard 54 211 410 213 'Explore' "Try alternatives.`nImprove data coverage.`nMay cost extra steps.";SmallCard 486 211 420 213 'Exploit' "Use the current best estimate.`nImprove immediate behavior.`nCan miss unknown alternatives." $C.paleTeal}
   'epsilon' {Formula 54 207 852 49 'G_Q(s) = {a : Q(s,a) = max_b Q(s,b)}' 30 $C.teal;Formula 54 267 852 58 'μ(a|s) = ε/4 + (1−ε) 𝟙[a∈G_Q(s)] / |G_Q(s)|' 30 $C.blue;SmallCard 54 345 410 96 'One greedy action' '0.8 + 0.05 = 0.85';SmallCard 486 345 420 96 'Each other action' '0.05' $C.paleTeal}
   'ties' {SmallCard 54 211 410 209 'Training' "ε = 0.2; slider adjustable`nNo automatic decay`nRandom greedy ties";SmallCard 486 211 420 209 'Display / evaluation' "Fixed tie order:`nup → right → down → left`nEvaluation stays greedy" $C.paleTeal}
   'traineval' {SmallCard 54 211 410 213 'Training' "Epsilon-greedy behavior`nUpdate visited Q entry`nContinue collecting experience";SmallCard 486 211 420 213 'Evaluation' "Frozen Q; greedy actions`nPreserve position/history/RNG`nMeasure the policy" $C.paleTeal}
   'code' {Code 54 203 852 177 $snippets.update;Code 54 383 852 62 $snippets.explore;Text 54 457 852 34 'Choose → observe → update one entry → repeat / reset.' 24 $C.muted $true}
   'results' {Maze 54 207 235 $true;SmallCard 440 211 466 100 'Training' 'Exploratory episode lengths vary.';SmallCard 440 332 466 106 'Greedy evaluation' 'Saved seed-7 result: 8 moves.' $C.paleTeal}
   'limits' {SmallCard 54 211 410 213 'What we observe' "A learned greedy route`nUnder this maze and start`nAfter finite training";SmallCard 486 211 420 213 'What needs more evidence' "Global coverage / optimality`nRobustness to changes`nGeneral convergence" $C.paleTeal}
   'demo' {[void]$script:slide.Shapes.AddPicture((Join-Path $root 'demo/after.png'),0,-1,54,203,460,248);Text 621 213 285 75 'Predict a Q update.' 29 $C.blue $true;Text 621 305 285 67 'Train; inspect values.' 29 $C.teal $true;Text 621 399 285 55 'Evaluate greedily.' 29 $C.blue $true}
   'recap' {SmallCard 54 211 272 215 'Mathematics' 'Compute target, TD error, and new Q.';SmallCard 344 211 272 215 'Off-policy' 'Separate behavior and target.' $C.paleTeal;SmallCard 634 211 272 215 'Evaluation' 'Freeze learning; measure the policy.'}
   'bias' {Formula 54 215 852 65 '𝔼[max_a Q̂(s,a)] ≥ max_a 𝔼[Q̂(s,a)]' 32 $C.blue;SmallCard 54 313 410 121 'One estimator' 'Select and evaluate its maximum.';SmallCard 486 313 420 121 'Double Q idea' 'Separate selection and evaluation.' $C.paleTeal}
   'terminalCode' {Code 54 207 852 99 $snippets.terminal;SmallCard 54 326 410 118 'Goal' 'terminated = True';SmallCard 486 326 420 118 '100-step cap' 'truncated = True; keep bootstrap' $C.paleTeal}
  }
  if($item.footer){Text 54 455 852 39 $item.footer 24 $C.muted $true}
 }
 if($presentation.Slides.Count -ne 28){throw 'Expected 28 slides'}
 $teachingMinutes=($lesson[1..20] | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum
 if($teachingMinutes -ne 30 -or ($lesson | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum -ne 45){throw 'Timing differs'}
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
 if($check.Slides.Count -ne 28){throw 'Reopened count differs'}
 for($idx=1;$idx -le 28;$idx++){$s=$check.Slides.Item($idx);if(($s.SlideShowTransition.Hidden -eq -1) -ne ($idx -ge 24)){throw "Hidden state differs: $idx"};if($s.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;totalMinutes=45;presentationMinutes=30;demoMinutes=10;recapMinutes=5;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;independentContentChecks=$contentChecks;sourceChecks=$sourceChecks;pythonSuiteRun=$false;headlessTraceRun=$false;pythonLimitation='No installed Python. PowerShell content checks are independent of the Python implementation.';professorPdfReviewed=$false;powerPointRendered=$true;powerPointReopened=$true} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created/reopened 28 slides, five hidden backups, notes on every slide. All protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
}finally{
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}
