$contentChecks=New-Object System.Collections.Generic.List[string]
$sourceChecks=New-Object System.Collections.Generic.List[string]
function Near([string]$name,[double]$actual,[double]$expected,[double]$tolerance=1e-9){if([math]::Abs($actual-$expected) -gt $tolerance){throw "Arithmetic failed: $name, $actual != $expected"};$contentChecks.Add($name)}
Near 'Illustrative table entries' ([math]::Pow(100,4)*100) 1e10
Near 'One-step target' (1+.99*6) 6.94
Near 'Estimated advantage' (1+.99*6-5) 1.94
Near 'Critic squared error' ([math]::Pow(5-6.94,2)) 3.7636
Near 'Centered positive return' (8-6) 2
Near 'Centered negative return' (4-6) -2
Near 'Expected baseline score is zero' (.25*6*.75+.75*6*(-.25)) 0
Near 'Expected uncentered gradient' (.25*8*.75+.75*4*(-.25)) .75
Near 'Expected centered gradient unchanged' (.25*2*.75+.75*(-2)*(-.25)) .75
Near 'Three-step target with bootstrap' (1+.99+[math]::Pow(.99,2)+[math]::Pow(.99,3)*2) 4.910698
Near 'Five-step healthy target with tail 2' (1+.99+[math]::Pow(.99,2)+[math]::Pow(.99,3)+[math]::Pow(.99,4)+[math]::Pow(.99,5)*2) 6.8029751098
Near 'Termination example ignores tail' (0+.99*(1-1)*999) 0
Near 'Truncation example retains final value' (1+.99*6) 6.94
Near 'Illustrative Gaussian mean step' (.1*2*(1-0)/1) .2
Near 'PPO positive-advantage clipping' ([math]::Min(1.5*2,1.2*2)) 2.4
Near 'PPO negative-advantage clipping' ([math]::Min(.5*(-2),.8*(-2))) -1.6
Near 'Rollout transition count' (8*5) 40
function ContainsSource([string]$file,[string]$pattern){$txt=Get-Content (Join-Path $root ('demo/'+$file)) -Raw -Encoding UTF8;if(-not $txt.Contains($pattern)){throw "Source pattern missing: $file / $pattern"};$sourceChecks.Add("$file / $pattern")}
foreach($pair in @(
 @('algorithm.py','GAMMA=.99'),@('algorithm.py',"ENV_ID='InvertedPendulum-v5'"),
 @('algorithm.py','def __init__(self,seed,count=8)'),@('algorithm.py','def collect(self,model,steps=5)'),
 @('algorithm.py','continuation=torch.where(truncated[t],next_values[t].detach(),tail)'),
 @('algorithm.py','continuation=torch.where(terminated[t],torch.zeros_like(continuation),continuation)'),
 @('algorithm.py','advantage=targets.detach()-values'),
 @('algorithm.py','actor_loss=-(model.log_probability(obs,latent.detach())*advantage.detach()).mean()'),
 @('algorithm.py','critic_loss=(values-targets.detach()).square().mean()'),
 @('algorithm.py','a=model.deterministic(x)[0].numpy()'),
 @('networks.py','nn.Linear(4,64),nn.Tanh(),nn.Linear(64,64)'),
 @('networks.py','self.distribution(obs).sample()'),@('networks.py','return 3*latent.tanh(), latent'),
 @('networks.py','return 3*self.actor(obs).tanh()'),
 @('networks.py','log_jacobian = math.log(3.) + 2*(math.log(2.)-latent-F.softplus(-2*latent))'),
 @('train.py','loss=al+.5*cl'),@('train.py','torch.optim.RMSprop(model.parameters(),lr=7e-4'),
 @('train.py','torch.nn.utils.clip_grad_norm_(model.parameters(),.5)'),
 @('train.py','def train(output,seed=7,steps=250000)'),@('train.py','entropy_bonus=0')
)){ContainsSource $pair[0] $pair[1]}
function Compact([string]$s){return [regex]::Replace($s,'\s+','')}
$algorithm=Get-Content (Join-Path $root 'demo/algorithm.py') -Raw -Encoding UTF8
$networks=Get-Content (Join-Path $root 'demo/networks.py') -Raw -Encoding UTF8
if(-not (Compact $algorithm).Contains((Compact $snippets.losses))){throw 'Loss excerpt differs'}
if(-not (Compact $networks).Contains((Compact $snippets.action))){throw 'Action excerpt differs'}
$contentChecks.Add('Both actual excerpts match source after whitespace normalization')
$start=$algorithm.IndexOf('    def collect(');$finish=$algorithm.IndexOf('    def close(');$collect=$algorithm.Substring($start,$finish-$start)
if($collect.IndexOf('nv=model.value(') -gt $collect.IndexOf('next_obs[i]=e.reset()')){throw 'Final-observation values evaluated after reset'}
$contentChecks.Add('Collector evaluates final observation before reset')
$evaluation=$algorithm.Substring($algorithm.IndexOf('def evaluate('))
if($evaluation -match '\.backward\(|optimizer|\.sample\(|collector|torch\.manual_seed'){throw 'Unexpected evaluation mutation or exploration'}
$contentChecks.Add('Evaluation source uses deterministic actions and separate environment; no training update')
$results=Get-Content (Join-Path $root 'demo/classroom/results.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$expected=@{7=@(28.45,1000,100000,20);0=@(28,220.15,25000,0);1=@(27.95,1000,75000,20)}
foreach($record in $results){$values=$expected[[int]$record.training_seed];Near "Historical seed $($record.training_seed) initial length" $record.initial.mean_length $values[0];Near "Historical seed $($record.training_seed) trained length" $record.trained.mean_length $values[1];Near "Historical seed $($record.training_seed) checkpoint" $record.trained.checkpoint_steps $values[2];Near "Historical seed $($record.training_seed) cap count" $record.trained.reached_limit $values[3];if($record.trained.per_episode.Count -ne 20){throw 'Historical test count differs'}}
if($lesson.Count -ne 30 -or @($lesson | Where-Object {$_.backup}).Count -ne 5){throw 'Slide/backup count differs'}
$contentChecks.Add('30 slides; five hidden backups')
if(($lesson[1..22] | ForEach-Object {[pscustomobject]$_} | Measure-Object minutes -Sum).Sum -ne 30){throw 'Teaching timing differs'}
$contentChecks.Add('22 teaching slides sum to 30 minutes')
if($lesson[4].kind -ne 'distribution' -or $lesson[4].equations){throw 'Introductory distribution slide unexpectedly contains formulas'}
$contentChecks.Add('Teaching slide 4 is conceptual; bounding equation is confined to backup content')
