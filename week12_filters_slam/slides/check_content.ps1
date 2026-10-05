$contentChecks=New-Object System.Collections.Generic.List[string]
function Near($name,[double]$actual,[double]$expected,[double]$tol=1e-9){if([math]::Abs($actual-$expected) -gt $tol){throw "Arithmetic failed$name"};$contentChecks.Add($name)}
Near 'Initial L1 range' ([math]::Sqrt(8)) 2.82842712474619
Near 'Initial L2/L3 range' ([math]::Sqrt(20)) 4.47213595499958
$likelihood=@(.6,.3,.1);$exampleWeights=@($likelihood|ForEach-Object{$_/3});$normalizer=($exampleWeights|Measure-Object -Sum).Sum
Near 'Weight normalizer' $normalizer (1/3)
for($i=0;$i -lt 3;$i++){Near "Posterior weight$i" ($exampleWeights[$i]/$normalizer) $likelihood[$i];Near "Expected copies$i" (10*$exampleWeights[$i]/$normalizer) @(6,3,1)[$i]}
Near 'Rotated local x coordinate' (2+[math]::Cos([math]::PI/2)) 2
Near 'Rotated local y coordinate' (2+[math]::Sin([math]::PI/2)) 3
$variance=.36+.0064;$gain=$variance/($variance+.0225)
Near 'Kalman gain' $gain .9421445101568526
Near 'Kalman mean' (2.25+$gain*.15) 2.391321676523528
Near 'Kalman posterior variance' ((1-$gain)*$variance) .021198251478529183
Near 'Joseph covariance agrees' ((1-$gain)*(1-$gain)*$variance+$gain*$gain*.0225) ((1-$gain)*$variance)
Near 'Occupancy two hits' (1/(1+[math]::Exp(-2*[math]::Log(7/3)))) (49/58)
Near 'Grid spacing' ((8-(-2))/80) .125
Near 'Conditional map MiB' (500*3*6561*8/1MB) 75.08468627929688
Near 'Lecture timing' (($lesson|Where-Object{-not $_.demo -and $_.kind -ne 'recap'}|Measure-Object minutes -Sum).Sum) 30
Near 'Demo timing' (($lesson|Where-Object{$_.demo}|Measure-Object minutes -Sum).Sum) 12
Near 'Recap timing' (($lesson|Where-Object{$_.kind -eq 'recap'}|Measure-Object minutes -Sum).Sum) 3
Near 'Total timing' (($lesson|Measure-Object minutes -Sum).Sum) 45
Near 'Slide count' $lesson.Count 38
Near 'Hidden count' @($lesson|Where-Object{$_.backup}).Count 5
