# Source and arithmetic checks for authored material, not Python runtime tests.
$sourceChecks=New-Object System.Collections.Generic.List[string]
$contentChecks=New-Object System.Collections.Generic.List[string]
function ContainsSource([string]$file,[string]$fragment){$source=Get-Content (Join-Path $root ('demo/'+$file)) -Raw -Encoding UTF8;if(-not $source.Contains($fragment)){throw "Source differs: $file / $fragment"};$sourceChecks.Add("$file / $fragment")}
foreach($pair in @(
 @('expert.py','np.clip(4*obs[:2] - 3*obs[2:], -LIMIT, LIMIT)'),
 @('learning.py','np.linalg.lstsq(design[train_mask],y[train_mask],rcond=None)'),
 @('learning.py','train_mask=ids<80'),
 @('learning.py','np.clip(self.weights@x+self.bias,-LIMIT,LIMIT)'),
 @('task.py','CONTROL_DT = .02'),@('task.py','STEPS = 250'),@('task.py','LIMIT = 10.'),
 @('task.py','obs = np.r_[self.target-self.data.qpos, self.data.qvel]'),
 @('task.py','observations.append(obs.copy())'),@('task.py','obs, applied = task.step(policy(obs))'),
 @('task.py','np.all(distances[-26:] < .03) and np.all(speeds[-26:] < .05)'),
 @('task.py','mujoco.mj_step(self.model, self.data, nstep=2)'),
 @('demo.py','cases=scenarios(7,100)'),@('demo.py','cases=scenarios(42,20)'),
 @('demo.py',"for name in ['expert','learner','zero']"),
 @('demo.py','return Policy.load(output/'),
 @('robot.xml','timestep="0.01" gravity="0 0 0"'),
 @('robot.xml','mass="1"'),@('requirements.txt','mujoco==3.14.0')
)){ContainsSource $pair[0] $pair[1]}
$learning=Get-Content (Join-Path $root 'demo/learning.py') -Raw -Encoding UTF8
if($learning -match '(?m)^\s*(from expert|import expert)'){throw 'Learner imports expert'}
$contentChecks.Add('Learning module does not import expert')
$task=Get-Content (Join-Path $root 'demo/task.py') -Raw -Encoding UTF8
if($task.IndexOf('observations.append(obs.copy())') -gt $task.IndexOf('obs, applied = task.step(policy(obs))')){throw 'Observation/action order differs'}
$contentChecks.Add('Observation recorded before applied action')
function AssertNear([string]$label,[double]$actual,[double]$expected){if([math]::Abs($actual-$expected) -gt 1e-11){throw "${label}: $actual != $expected"};$contentChecks.Add($label)}
AssertNear 'Expert example force x' (4*.3-3*.1) .9
AssertNear 'Expert example force y' (4*(-.2)-3*0) (-.8)
AssertNear 'Dataset row count' (100*250) 25000
AssertNear 'Training row count' (80*250) 20000
AssertNear 'Validation row count' (20*250) 5000
AssertNear 'Episode duration' (250*.02) 5
AssertNear 'Control frequency' (1/.02) 50
AssertNear 'Physics frequency' (1/.01) 100
AssertNear 'Last sample window includes 26 points' ((5-4.5)/.02+1) 26
$daggerIndex=-1;$irlIndex=-1
for($i=0;$i -lt $lesson.Count;$i++){if($lesson[$i].kind -eq 'dagger'){$daggerIndex=$i};if($lesson[$i].title -eq 'Other approaches: IRL and GAIL'){$irlIndex=$i}}
if($irlIndex -ne $daggerIndex+1){throw 'IRL/GAIL must immediately follow DAgger'}
$contentChecks.Add('IRL/GAIL immediately follows DAgger')
if($lesson.Count -ne 25 -or @($lesson | Where-Object {$_.backup}).Count -ne 4){throw 'Slide/backup count differs'}
$contentChecks.Add('25 slides; four hidden backups')
