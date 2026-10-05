$contentChecks=New-Object System.Collections.Generic.List[string]
$sourceChecks=New-Object System.Collections.Generic.List[string]
function Near([string]$name,[double]$actual,[double]$expected,[double]$tol=1e-9){if([math]::Abs($actual-$expected) -gt $tol){throw "Arithmetic failed: $name, $actual != $expected"};$contentChecks.Add($name)}
$prior=@(.6,.4);$transition=@(@(.8,.2),@(.1,.9));$sensor=@(@(.9,.1),@(.2,.8))
for($row=0;$row -lt 2;$row++){Near "Transition row $row sums to one" ($transition[$row][0]+$transition[$row][1]) 1;Near "Sensor row $row sums to one" ($sensor[$row][0]+$sensor[$row][1]) 1}
function Predict([double[]]$b){return @(($b[0]*.8+$b[1]*.1),($b[0]*.2+$b[1]*.9))}
function Correct([double[]]$b,[double[]]$likelihood){$w0=$b[0]*$likelihood[0];$w1=$b[1]*$likelihood[1];$z=$w0+$w1;if($z -eq 0){return $null};return [pscustomobject]@{weights=@($w0,$w1);z=$z;belief=@(($w0/$z),($w1/$z))}}
$pred=Predict $prior;$red=Correct $pred @(.9,.2);$blue=Correct $pred @(.1,.8)
Near 'Predicted L' $pred[0] .52;Near 'Predicted R' $pred[1] .48
Near 'Red L weight' $red.weights[0] .468;Near 'Red R weight' $red.weights[1] .096;Near 'Red probability' $red.z .564
Near 'Red L posterior' $red.belief[0] .8297872340425532;Near 'Red R posterior' $red.belief[1] .1702127659574468
Near 'Blue L weight' $blue.weights[0] .052;Near 'Blue R weight' $blue.weights[1] .384;Near 'Blue probability' $blue.z .436
Near 'Blue L posterior' $blue.belief[0] .1192660550458716;Near 'Blue R posterior' $blue.belief[1] .8807339449541284
Near 'Observation probabilities sum to one' ($red.z+$blue.z) 1
for($state=0;$state -lt 2;$state++){Near "Expected posterior recovers prediction $state" ($red.z*$red.belief[$state]+$blue.z*$blue.belief[$state]) $pred[$state]}
Near 'Identity transition retains prior' (.5*1+.5*0) .5
Near 'Zero-likelihood observation probability' (.52*0+.48*0) 0
if($null -ne (Correct $pred @(0,0))){throw 'Impossible observation should have no posterior'};$contentChecks.Add('Impossible observation is undefined; no uniform fallback')
Near 'Uninformative sensor retains prediction' (Correct $pred @(.3,.3)).belief[0] .52
$senseRed=Correct @(.5,.5) @(.9,.2);$senseBlue=Correct @(.5,.5) @(.1,.8)
Near 'Example B red probability' $senseRed.z .55;Near 'Example B blue probability' $senseBlue.z .45
Near 'Example B red posterior' $senseRed.belief[0] (9/11);Near 'Example B blue posterior' $senseBlue.belief[0] (1/9)
$redReward=10*$senseRed.belief[0]-10*$senseRed.belief[1];$blueReward=-10*$senseBlue.belief[0]+10*$senseBlue.belief[1]
Near 'Conditional red commitment reward' $redReward (70/11);Near 'Conditional blue commitment reward' $blueReward (70/9)
Near 'Sensing value' (-1+$senseRed.z*$redReward+$senseBlue.z*$blueReward) 6
Near 'Correct commitment probability' (.5*.9+.5*.8) .85
Near 'Independent sensing value cross-check' (.85*10+.15*(-10)-1) 6
Near 'Cost-seven tie' (7-7) 0;Near 'Cost-eight rejection' (7-8) -1
Near 'Sensing alpha L' (-1+.9*10+.1*(-10)) 7;Near 'Sensing alpha R' (-1+.2*(-10)+.8*10) 5
Near 'Sensing alpha uniform dot product' (.5*7+.5*5) 6
Near 'Commitment lines intersect' (20*.5-10) (10-20*.5)
Near 'Left sensing intersection' (5+2*(5/22)) (10-20*(5/22))
Near 'Right sensing intersection' (5+2*(5/6)) (20*(5/6)-10)
Near 'Red posterior action threshold' (.9*(2/11)) (.2*(1-2/11))
Near 'Blue posterior action threshold' (.1*(8/9)) (.8*(1-8/9))
Near 'Red posterior odds' ($red.belief[0]/$red.belief[1]) (39/8)
Near 'Blue posterior odds' ($blue.belief[0]/$blue.belief[1]) (13/96)
# Grid checks independently compare the Bayes/Bellman calculation with all fixed post-sense trees.
for($step=0;$step -le 100;$step++){
 $p=$step/100;$q=1-$p;$rr=Correct @($p,$q) @(.9,.2);$bb=Correct @($p,$q) @(.1,.8)
 $bayesValue=-1+$rr.z*[math]::Abs(20*$rr.belief[0]-10)+$bb.z*[math]::Abs(20*$bb.belief[0]-10)
 $allTrees=[math]::Max([math]::Max(20*$p-11,9-20*$p),[math]::Max(5+2*$p,-7-2*$p))
 if([math]::Abs($bayesValue-$allTrees) -gt 1e-9){throw "Policy-tree disagreement at prior $p"}
 $full=[math]::Max([math]::Max(20*$p-10,10-20*$p),$bayesValue)
 $three=[math]::Max([math]::Max(20*$p-10,10-20*$p),5+2*$p)
 if([math]::Abs($full-$three) -gt 1e-9){throw "Envelope disagreement at prior $p"}
}
$contentChecks.Add('101-prior Bayes decision values agree with all four post-sense trees')
$contentChecks.Add('101-prior full sense-once problem agrees with three-line plotted envelope')
for($step=0;$step -le 20;$step++){$p=$step/20;$pred=Predict @($p,(1-$p));$rr=Correct $pred @(.9,.2);$bb=Correct $pred @(.1,.8);for($state=0;$state -lt 2;$state++){if([math]::Abs($rr.z*$rr.belief[$state]+$bb.z*$bb.belief[$state]-$pred[$state]) -gt 1e-9){throw 'Posterior averaging grid check failed'}}}
$contentChecks.Add('21-prior prediction/normalization/expected-posterior checks pass')
function ContainsSource([string]$file,[string]$pattern){$txt=Get-Content (Join-Path $root $file) -Raw -Encoding UTF8;if(-not $txt.Contains($pattern)){throw "Source pattern missing: $file / $pattern"};$sourceChecks.Add("$file / $pattern")}
foreach($pair in @(
 @('TEACHING_NOTES.md','| L | 0.8 | 0.2 |'),@('TEACHING_NOTES.md','| R | 0.1 | 0.9 |'),
 @('TEACHING_NOTES.md','| L | 0.9 | 0.1 |'),@('TEACHING_NOTES.md','| R | 0.2 | 0.8 |'),
 @('TEACHING_NOTES.md','0.829787'),@('TEACHING_NOTES.md','0.119266'),
 @('TEACHING_NOTES.md','7−c'),@('TEACHING_NOTES.md','Class18-POMDPs.pdf'),
 @('demo/README.md','software commands'),@('demo/README.md','blue alternative from the same prediction'),
 @('visuals/commitment_values.svg','Commit L: 20p'),@('visuals/commitment_values.svg','Commit R: 10'),
 @('visuals/commitment_values.svg','Best immediate commitment')
)){ContainsSource $pair[0] $pair[1]}
if($lesson.Count -ne 38 -or @($lesson | Where-Object {$_.backup}).Count -ne 5){throw 'Slide/backup count differs'}
if($lesson[15].kind -ne 'exercise' -or $lesson[16].kind -ne 'posteriorBlue'){throw 'Exercise/answer order differs'}
$contentChecks.Add('38 slides; five hidden backups; exercise precedes answer')
$teaching=($lesson | Where-Object {$_.minutes -gt 0 -and $_.kind -notin 'exercise','recap'} | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum
Near 'Explanation minutes' $teaching 38;Near 'Exercise minutes' $lesson[15].minutes 4;Near 'Recap minutes' $lesson[32].minutes 3
