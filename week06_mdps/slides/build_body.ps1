# Loaded by build_slides.ps1 after the reusable PowerPoint drawing helpers.
. (Join-Path $PSScriptRoot 'check_math.ps1')
function DeliveryGraph {
 Line 199 316 365 238 $C.blue $true
 Line 535 238 729 310 $C.teal $true
 Line 199 326 729 326 $C.blue $true
 Line 199 342 365 422 $C.blue $true
 Box 54 291 145 69 $C.paleBlue;Text 66 307 121 35 'start' 28 $C.blue $true 2
 Box 365 207 170 63 $C.paleTeal;Text 377 220 146 35 'detour' 28 $C.teal $true 2
 Box 729 291 177 69 $C.paleTeal;Text 741 307 153 35 'delivered' 28 $C.teal $true 2
 Box 365 393 170 63 $C.paleAmber;Text 377 406 146 35 'failed' 28 $C.amber $true 2
 Text 168 204 187 75 "safe`np = 1; r = −1" 24 $C.blue $false 2
 Text 550 204 178 75 "finish`np = 1; r = +8" 24 $C.teal $false 2
 Box 340 281 266 39 $C.bg;Text 345 283 256 35 'risky: p = 0.8; r = +10' 24 $C.blue $false 2
 Text 62 391 287 67 "risky`np = 0.2; r = −10" 24 $C.blue $false 2
}
function ValuesTable {
 $xs=@(54,193,367,542,724);$ws=@(121,156,157,164,182)
 $headers=@('Sweep','start','detour','delivered','failed')
 for($col=0;$col -lt 5;$col++){Box $xs[$col] 203 $ws[$col] 46 $C.paleBlue;Text ($xs[$col]+6) 210 ($ws[$col]-12) 33 $headers[$col] 24 $C.blue $true 2}
 $rows=@(@('V₀','0','0','0','0'),@('V₁','6','8','0','0'),@('V₂','6.2','8','0','0'),@('V₃','6.2','8','0','0'))
 for($r=0;$r -lt 4;$r++){for($col=0;$col -lt 5;$col++){Box $xs[$col] (259+45*$r) $ws[$col] 39 $(if($r -eq 2){$C.paleTeal}else{$C.white});Text ($xs[$col]+6) (262+45*$r) ($ws[$col]-12) 33 $rows[$r][$col] 26 $C.ink ($col -eq 0) 2}}
}
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add('# Week 6 — Markov Decision Processes');$lines.Add('')
$lines.Add('Teach MDP notation and solve the existing delivery model through Bellman equations, exact policy evaluation, value iteration and policy iteration. **35 minutes explanation/worked examples + 5 minutes visualization + 5 minutes recap/HW3.** English; 16:9; editable diagrams and equations; detailed speaker notes. 30 slides, last five hidden. Preserve demo files, README and teaching notes. No interfaces or dependencies change.')
$lines.Add('');$lines.Add('## Slide order and timing');$lines.Add('');$lines.Add('| Slide | Topic | Minutes |');$lines.Add('|---|---|---:|')
for($i=0;$i -lt $lesson.Count;$i++){$item=$lesson[$i];$lines.Add("| $($i+1) | $($item.title)$(if($item.backup){' (hidden)'}) | $($item.minutes) |")}
$lines.Add('');$lines.Add('## Speaker guidance, visuals and mathematical content')
for($i=0;$i -lt $lesson.Count;$i++){
 $item=$lesson[$i];$lines.Add('');$lines.Add("### $($i+1). $($item.title)");$lines.Add('');$lines.Add("$($item.subtitle) Timing: $($item.minutes) minutes. Visual: $($item.kind); all formulas and diagram components are editable.");$lines.Add('');$lines.Add($item.notes)
 if($item.equations){$lines.Add('');$lines.Add('Displayed mathematics:');$lines.Add('');foreach($eq in $item.equations){$lines.Add("- ``$eq``")}}
 if($item.cards){foreach($card in $item.cards){$lines.Add("- $($card[0]): $($card[1])")}}
 if($item.footer){$lines.Add('');$lines.Add($item.footer)}
 $lines.Add('');foreach($ref in $item.refs){$lines.Add("- $($sources[$ref])")}
}
$lines.Add('');$lines.Add('## Exact model and worked checks');$lines.Add('')
$lines.Add(@'
| State / action | Next state | Probability | Transition reward |
|---|---|---:|---:|
| start / safe | detour | 1 | −1 |
| start / risky | delivered | 0.8 | +10 |
| start / risky | failed | 0.2 | −10 |
| detour / finish | delivered | 1 | +8 |
| delivered / stay | delivered | 1 | 0 |
| failed / stay | failed | 1 | 0 |

γ=0.9. Arrival reward is paid once; terminal future value is zero. Risky-policy value [6,8,0,0]; safe-policy value [6.2,8,0,0]. At p=0.1 optimal start value8 and action risky. VI vectors: [0,0,0,0] → [6,8,0,0] → [6.2,8,0,0] → unchanged. PI visualization explicitly starts risky, unlike the solver's default first-action initialization.

Safe-policy nonterminal matrix: Pπ=[[0,1],[0,0]], Rπ=[−1,8]ᵀ. Solve [[1,−0.9],[0,1]]V=Rπ in order [start,detour]. Risky-policy matrix is zero with reward vector [6,8]ᵀ. Omitted terminal transitions still contribute immediate rewards. Main policy-equation continuation is inside the sum over actions. Q_V is an arbitrary-value backup, Qπ follows a policy after the specified first action, and Q* uses V*.
'@)
$lines.Add('');$lines.Add('## Validation and rehearsal boundaries');$lines.Add('')
$lines.Add('Read all nine original Week6 files including both figures. Class7-MDPs.pdf was not found locally; existing printed-slide references are retained without claiming it was reviewed. Generate/render/reopen in installed PowerPoint; inspect 30 slide previews, notes, equations, five hidden slides, 30 PDF pages and protected hashes. Independent PowerShell arithmetic checks validate displayed examples and source constants; these are not execution of the Python demo. Python is currently unavailable locally: original tests, headless traces and classroom GUI rehearsal remain unexecuted here. See slides/validation.json, review.json and README.md for evidence and future commands.')
[IO.File]::WriteAllText($planPath,($lines -join "`r`n"),[Text.UTF8Encoding]::new($false))
$app=$null;$presentation=$null;$hadExistingPresentations=$true
try{
 $app=New-Object -ComObject PowerPoint.Application;$hadExistingPresentations=($app.Presentations.Count -gt 0)
 $presentation=$app.Presentations.Add(0);$presentation.PageSetup.SlideWidth=$W;$presentation.PageSetup.SlideHeight=$H
 foreach($item in $lesson){
  $refs=($item.refs | ForEach-Object {$sources[$_]}) -join "`r`n"
  NewSlide $item.title $item.subtitle $item.minutes ("TIMING: $($item.minutes) minutes.`r`n$($item.notes)`r`n`r`nSOURCES`r`n$refs") ([bool]$item.backup)
  switch($item.kind){
   'title' {
    Card 54 211 410 203 'Understand the model' "States · actions · outcomes`nRewards · policies · return"
    Card 486 211 420 203 'Solve the model' "Bellman equations`nValue and policy iteration" $C.paleTeal $C.teal
    Text 54 447 852 40 '35 min math & examples · 5 min demo · 5 min recap' 27 $C.muted $true
   }
   'cards' {Card 54 216 410 187 $item.cards[0][0] $item.cards[0][1];Card 486 216 420 187 $item.cards[1][0] $item.cards[1][1] $C.paleTeal $C.teal;Line 465 305 485 305 $C.teal $true}
   'graph' {DeliveryGraph}
   'tuple' {
    Formula 54 202 852 54 $item.equations[0] 38 $C.blue
    $labels=@('S · States','A(s) · Actions','P · Outcomes','r · Rewards','γ · Discount')
    $bodies=@('start, detour, delivered, failed','safe / risky; finish; stay','Next-state probabilities','Reward on each transition','Future-reward weight: 0.9')
    for($j=0;$j -lt 5;$j++){
     $y=267+37*$j;Box 54 $y 852 35 $(if($j%2){$C.paleTeal}else{$C.paleBlue})
     Text 66 ($y+2) 267 32 $labels[$j] 24 $C.blue $true
     Text 348 ($y+2) 546 32 $bodies[$j] 24
    }
    Text 54 459 852 33 's: one state    |    Sₜ: random state at time t' 24 $C.muted   }
   'equations' {
    $n=$item.equations.Count;$gap=if($n -ge 4){59}else{76};$size=if($n -ge 4){29}else{31}
    for($j=0;$j -lt $n;$j++){ $eq=$item.equations[$j];$fs=if($eq.Length -gt 73){24}elseif($eq.Length -gt 60){27}else{$size};Formula 54 (207+$j*$gap) 852 56 $eq $fs $(if($j -eq 0){$C.blue}else{$C.ink}) }
   }
   'policyEquation' {
    Box 54 207 852 154 $C.paleBlue
    Formula 73 221 815 60 $item.equations[0] 34 $C.blue
    Formula 73 288 815 60 $item.equations[1] 29 $C.blue
    Formula 54 393 852 55 $item.equations[2] 31 $C.teal
   }
   'matrix' {
    Formula 54 201 852 47 'P_{π} = [0  1; 0  0]        R_{π} = [−1  8]^{T}' 29 $C.muted
    Matrix 92 276 220 123 @(@('1','−0.9'),@('0','1')) 34 $C.blue
    Matrix 350 276 272 123 @(@('V^{π}(start)'),@('V^{π}(detour)')) 29
    Formula 645 316 40 47 '=' 38 $C.teal
    Matrix 724 276 130 123 @(@('−1'),@('8')) 34 $C.teal
   }
   'sweeps' {ValuesTable}
   'piTrace' {
    Card 54 211 410 216 'Round 0 · risky' "Evaluate: V(start) = 6`nCompare: safe = 6.2`nImprove: choose safe"
    Card 486 211 420 216 'Round 1 · safe' "Evaluate: V(start) = 6.2`nImprove: still safe`nStable policy; residual = 0" $C.paleTeal $C.teal
   }
   'compare' {
    Card 54 211 272 227 'Policy evaluation' "Fixed: policy + model`nCompute: Vπ"
    Card 344 211 272 227 'Value iteration' "Fixed: model`nMaximizing value backups" $C.paleTeal $C.teal
    Card 634 211 272 227 'Policy iteration' "Fixed: model`nEvaluate + improve policy"
    Text 54 451 852 35 'Known model → planning. No probability learning in this demo.' 25 $C.muted $true
   }
   'demo' {
    [void]$script:slide.Shapes.AddPicture((Join-Path $root 'demo/baseline.png'),0,-1,54,207,535,288)
    Text 623 216 283 78 'Predict the first backup.' 28 $C.blue $true
    Text 623 307 283 78 'Explain the green arrows.' 28 $C.teal $true
    Text 623 405 283 79 'Change risk. Predict again.' 28 $C.blue $true
   }
   'recap' {
    Card 54 211 410 203 $item.cards[0][0] $item.cards[0][1]
    Card 486 211 420 203 $item.cards[1][0] $item.cards[1][1] $C.paleTeal $C.teal
   }
  }
  if($item.footer){Text 54 454 852 40 $item.footer 24 $C.muted $true}
 }
 if($presentation.Slides.Count -ne 30){throw 'Expected 30 slides'}
 $teachingMinutes=($lesson[1..22] | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum
 if($teachingMinutes -ne 35 -or ($lesson | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum -ne 45){throw 'Timing differs'}
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
 if($check.Slides.Count -ne 30){throw 'Reopened count differs'}
 for($idx=1;$idx -le 30;$idx++){$s=$check.Slides.Item($idx);if(($s.SlideShowTransition.Hidden -eq -1) -ne ($idx -ge 26)){throw "Hidden state differs: $idx"};if($s.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 100){throw "Missing notes: $idx"}}
 $check.Close()
 foreach($path in $protectedPaths){if((Get-FileHash (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
 [pscustomobject]@{slides=$script:slides;totalMinutes=45;presentationMinutes=35;demoMinutes=5;recapMinutes=5;slideWidth=$W;slideHeight=$H;layoutIssues=$script:issues;protectedFiles=$protectedHashes;independentMathChecks=$mathChecks;sourceChecks=$sourceChecks;pythonSuiteRun=$false;headlessTraceRun=$false;pythonLimitation='No installed Python. PowerShell arithmetic checks are independent of the Python implementation.';professorPdfReviewed=$false;powerPointRendered=$true;powerPointReopened=$true} | ConvertTo-Json -Depth 7 | Set-Content (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
 Write-Output 'Created/reopened 30 slides, five hidden backups, notes on every slide. All protected files unchanged.'
 if($script:issues.Count){$script:issues | ForEach-Object {Write-Output $_}}else{Write-Output 'No text overflow detected.'}
}finally{
 if($null -ne $presentation){try{$presentation.Close()}catch{}}
 if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
 if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}
