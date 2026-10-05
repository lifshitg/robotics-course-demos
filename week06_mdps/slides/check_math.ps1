# Independent arithmetic assertions for authored slides, not execution of model.py.
$mathChecks=New-Object System.Collections.Generic.List[string]
function AssertNear([string]$label,[double]$actual,[double]$expected){if([math]::Abs($actual-$expected) -gt 1e-11){throw "${label}: $actual != $expected"};$mathChecks.Add($label)}
AssertNear 'Risky baseline' (.8*10+.2*(-10)) 6
AssertNear 'Safe return' (-1+.9*8) 6.2
AssertNear 'Lower-risk return' (.9*10+.1*(-10)) 8
$v=@(0.,0.,0.,0.);$history=@(,$v.Clone())
for($i=0;$i -lt 3;$i++){$old=$v;$v=@([math]::Max(-1+.9*$old[1],.8*(10+.9*$old[2])+.2*(-10+.9*$old[3])),(8+.9*$old[2]),0.,0.);$history+=,$v.Clone()}
$expected=@(@(0,0,0,0),@(6,8,0,0),@(6.2,8,0,0),@(6.2,8,0,0))
for($i=0;$i -lt 4;$i++){for($j=0;$j -lt 4;$j++){AssertNear "VI V$i component$j" $history[$i][$j] $expected[$i][$j]}}
AssertNear 'Greedy safe using V1' (-1+.9*$history[1][1]) 6.2
# Back substitution in the actual safe-policy matrix.
$vDetour=8.;$vStart=(-1+.9*$vDetour)
AssertNear 'Safe matrix row 1 residual' ($vStart-.9*$vDetour+1) 0
AssertNear 'Safe matrix row 2 residual' ($vDetour-8) 0
AssertNear 'Risky-policy improvement advantage' (($vStart)-6) .2
AssertNear 'Stochastic policy return' (.5*6.2+.5*6) 6.1
AssertNear 'Stochastic matrix evaluation' (2.5+.9*.5*8) 6.1
AssertNear 'Cyclic system' (1/(1-.9)) 10
AssertNear 'Failure threshold' ((10-6.2)/20) .19
AssertNear 'Discount threshold' ((6+1)/8) .875
AssertNear 'Returned-vector stopping factor' (.9/(1-.9)) 9
$model=Get-Content (Join-Path $root 'demo/model.py') -Raw -Encoding UTF8
$ui=Get-Content (Join-Path $root 'demo/demo.py') -Raw -Encoding UTF8
$sourceChecks=@("gamma: float = 0.9","'safe': [(1., 'detour', -1.)]","(1-failure, 'delivered', 10.)","(failure, 'failed', -10.)","'finish': [(1., 'delivered', 8.)]","'delivered': {'stay': [(1., 'delivered', 0.)]}","'failed': {'stay': [(1., 'failed', 0.)]}","np.linalg.solve(matrix, rewards)","tolerance=1e-10, max_iterations=1000","new = {s: max(action_values(mdp, s, values).values())","if delta < tolerance:","if improved == policy and residual < tolerance:")
foreach($snippet in $sourceChecks){if(-not $model.Contains($snippet)){throw "Source differs: $snippet"}}
foreach($snippet in @("self.mdp = delivery_mdp(self.failure)","policy_iteration(self.mdp, {'start':'risky','detour':'finish'})","self.failure = float(label)")){if(-not $ui.Contains($snippet)){throw "UI differs: $snippet"};$sourceChecks+=$snippet}
