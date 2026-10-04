$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
Add-Type -Path (Join-Path $PSScriptRoot 'MathChecks.cs')
$numeric=[Week3MathChecks]::Run()
[xml]$model=Get-Content (Join-Path $root 'demo/arm.urdf') -Raw
$modelChecks=0
foreach($pair in @(@('joint2',0.6),@('tool_fixed',0.4))){$joint=$model.SelectSingleNode("/robot/joint[@name='$($pair[0])']");$x=[double]$joint.origin.xyz.Split(' ')[0];if($x -ne $pair[1]){throw 'Joint origins disagree with math'};$modelChecks++}
foreach($pair in @(@('link1',0.6),@('link2',0.4))){$link=$model.SelectSingleNode("/robot/link[@name='$($pair[0])']");if([double]$link.visual.geometry.box.size.Split(' ')[0] -ne $pair[1]){throw 'Visual length mismatch'};$modelChecks++}
foreach($name in @('joint1','joint2')){$joint=$model.SelectSingleNode("/robot/joint[@name='$name']");if($joint.axis.xyz -ne '0 0 1' -or [double]$joint.limit.lower -ne -[math]::PI -or [double]$joint.limit.upper -ne [math]::PI){throw 'Axis/limits mismatch'};$modelChecks++}
if($model.robot.joint | Where-Object {$_.name -eq 'world_anchor' -and $_.origin.xyz -eq '0 0 0.25'}){$modelChecks++}else{throw 'Base height mismatch'}
$physics=Get-Content (Join-Path $root 'demo/world.sdf') -Raw
if($physics -notmatch '<gravity>0 0 -9.81</gravity>' -or $physics -notmatch '<max_step_size>0.001</max_step_size>'){throw 'World physics mismatch'};$modelChecks++
$blocks=[regex]::Split((Get-Content (Join-Path $root 'demo/bridge.yaml') -Raw),'(?m)^- ros_topic_name: ')
$expected=@(
@('/arm/joint1/cmd_pos','/arm/joint1/cmd_pos','std_msgs/msg/Float64','gz.msgs.Double','ROS_TO_GZ'),
@('/arm/joint2/cmd_pos','/arm/joint2/cmd_pos','std_msgs/msg/Float64','gz.msgs.Double','ROS_TO_GZ'),
@('/joint_states','/arm/joint_states','sensor_msgs/msg/JointState','gz.msgs.Model','GZ_TO_ROS'),
@('/clock','/world/kinematics/clock','rosgraph_msgs/msg/Clock','gz.msgs.Clock','GZ_TO_ROS'))
for($i=0;$i -lt 4;$i++){$block=$blocks[$i+1];$lines=$block -split '\r?\n';if($lines[0].Trim() -ne $expected[$i][0]){throw 'ROS topic mismatch'};foreach($j in 1..4){$key=@('','gz_topic_name','ros_type_name','gz_type_name','direction')[$j];if($block -notmatch ([regex]::Escape($key+': '+$expected[$i][$j]))){throw 'Bridge mapping mismatch'}};$modelChecks++}
$constants=Get-Content (Join-Path $root 'demo/kinematics.py') -Raw
if($constants -notmatch '(?m)^L1 = 0.6\r?$' -or $constants -notmatch '(?m)^L2 = 0.4\r?$'){throw 'Code constants mismatch'};$modelChecks++
[pscustomobject]@{numerical=$numeric;modelAndConfigurationChecks=$modelChecks;status='PASS'} | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $PSScriptRoot 'math_validation.json') -Encoding UTF8
Get-Content (Join-Path $PSScriptRoot 'math_validation.json') -Raw
