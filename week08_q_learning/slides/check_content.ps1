# Independent checks of authored arithmetic/code excerpts, not Python execution.
$contentChecks=New-Object System.Collections.Generic.List[string]
$sourceChecks=New-Object System.Collections.Generic.List[string]
function AssertNear([string]$label,[double]$actual,[double]$expected){if([math]::Abs($actual-$expected) -gt 1e-11){throw "${label}: $actual != $expected"};$contentChecks.Add($label)}
AssertNear 'Nonterminal target' (-1+.95*4) 2.8
AssertNear 'Nonterminal new Q' (.2*2.8) .56
AssertNear 'Terminal target' 10 10
AssertNear 'First goal new Q' (.2*10) 2
AssertNear 'First ordinary zero-table update' (.2*(-1)) (-.2)
AssertNear 'SARSA target' (-1+.95*(-2)) (-2.9)
AssertNear 'SARSA new Q' (.2*(-2.9)) (-.58)
AssertNear 'Unique greedy probability' (.2/4+(1-.2)) .85
AssertNear 'Each nongreedy probability' (.2/4) .05
AssertNear 'Total probability' (.85+3*.05) 1
AssertNear 'Nongreedy probability' (3*.05) .15
AssertNear 'Two-way greedy tie probability' (.2/4+(1-.2)/2) .45
AssertNear 'Four-way tie probability' (.2/4+(1-.2)/4) .25
$discounted=0.;for($i=0;$i -lt 7;$i++){$discounted-=[math]::Pow(.95,$i)};$discounted+=10*[math]::Pow(.95,7)
AssertNear 'Eight-step raw return' (-7+10) 3
AssertNear 'Eight-step discounted return' $discounted .9501188828124985
function ContainsSource([string]$file,[string]$fragment){$source=Get-Content (Join-Path $root ('demo/'+$file)) -Raw -Encoding UTF8;if(-not $source.Contains($fragment)){throw "Source differs: $file / $fragment"};$sourceChecks.Add("$file / $fragment")}
foreach($pair in @(
 @('learning.py','TRAINING_EPSILON = 0.2'),@('learning.py','alpha=.2, gamma=.95'),
 @('learning.py','q[state+(action,)] = new'),@('learning.py','self.q = np.zeros((5,5,4))'),
 @('learning.py','exploratory = bool(self.rng.random() < eps)'),
 @('learning.py','int(self.rng.integers(4)) if exploratory'),
 @('learning.py','self.rng.choice(np.flatnonzero(self.q[state] == self.q[state].max()))'),
 @('learning.py','truncated = self.steps >= 100 and not terminated'),
 @('learning.py','action = int(q[state].argmax())'),
 @('demo.py','self.learner=Learner(self.seed, self.learner.epsilon)'),
 @('demo.py','self.learner.set_epsilon(percent/100)'),
 @('gridworld.py','START = (4, 0)'),@('gridworld.py','GOAL = (0, 4)'),
 @('gridworld.py','{(1, 1), (1, 2), (2, 2), (3, 1), (3, 3)}'),
 @('gridworld.py','return nxt, 10. if terminated else -1., terminated')
)){ContainsSource $pair[0] $pair[1]}
$learning=Get-Content (Join-Path $root 'demo/learning.py') -Raw -Encoding UTF8
function Compact([string]$s){return [regex]::Replace($s,'\s+','')}
foreach($key in $snippets.Keys){if(-not (Compact $learning).Contains((Compact $snippets[$key]))){throw "Excerpt differs: $key"};$contentChecks.Add("Authored excerpt $key matches learning.py")}
$stepStart=$learning.IndexOf('    def step(self):');$stepEnd=$learning.IndexOf('    def train(');$step=$learning.Substring($stepStart,$stepEnd-$stepStart)
if($step.IndexOf('details = update(') -gt $step.IndexOf('truncated =')){throw 'Update/reset ordering differs'}
$contentChecks.Add('Update uses pre-reset next state; truncation determined afterwards')
$evaluation=$learning.Substring($learning.IndexOf('def evaluate(q):'))
if($evaluation -match 'update\(|q\[[^\]]+\]\s*=|rng'){throw 'Evaluation mutates training-related state'}
$contentChecks.Add('Evaluation source reads Q; no update or RNG access')
if($lesson.Count -ne 28 -or @($lesson | Where-Object {$_.backup}).Count -ne 5){throw 'Slide/backup count differs'}
$contentChecks.Add('28 slides; five hidden backups')
