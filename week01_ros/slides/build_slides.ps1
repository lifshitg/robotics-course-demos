param([switch]$NoPreview, [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$OutputBaseName='ROS_BASICS')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$planPath = Join-Path $root 'PRESENTATION_PLAN.md'
$pptxPath = Join-Path $root ($OutputBaseName+'.pptx')
$pdfPath = Join-Path $root ($OutputBaseName+'.pdf')
$previewPath = Join-Path $PSScriptRoot 'preview'
$plan = Get-Content -LiteralPath $planPath -Raw -Encoding UTF8
$protectedPaths = @('PRESENTATION_PLAN.md','TEACHING_NOTES.md','demo/README.md','demo/publisher.py','demo/subscriber.py')
$protectedHashes = @{}
foreach ($path in $protectedPaths) { $protectedHashes[$path] = (Get-FileHash -LiteralPath (Join-Path $root $path)).Hash }

function Color([string]$hex) {
  $hex = $hex.TrimStart('#')
  return [Convert]::ToInt32($hex.Substring(0,2),16) + 256 * [Convert]::ToInt32($hex.Substring(2,2),16) + 65536 * [Convert]::ToInt32($hex.Substring(4,2),16)
}
$C = @{ bg=(Color 'F7F9FC'); ink=(Color '15283B'); muted=(Color '526477'); blue=(Color '2459D3'); teal=(Color '137F79'); paleBlue=(Color 'EAF0FC'); paleTeal=(Color 'E5F3F0'); white=(Color 'FFFFFF'); line=(Color 'D7E0E9'); amber=(Color 'AE651D'); paleAmber=(Color 'FFF0DF') }
$W = 960; $H = 540
$script:slides = New-Object System.Collections.Generic.List[object]
$script:issues = New-Object System.Collections.Generic.List[string]
$script:slide = $null

function Text([double]$x,[double]$y,[double]$w,[double]$h,[string]$text,[double]$size=26,[int]$color=$C.ink,[bool]$bold=$false,[int]$align=1,[string]$font='Aptos') {
  $s = $script:slide.Shapes.AddTextbox(1,$x,$y,$w,$h)
  $s.Name = 'text_' + $script:slide.Shapes.Count
  $s.Fill.Visible = 0; $s.Line.Visible = 0
  $f = $s.TextFrame
  $f.MarginLeft=0; $f.MarginRight=0; $f.MarginTop=0; $f.MarginBottom=0
  $f.WordWrap=-1; $f.AutoSize=0; $f.VerticalAnchor=1
  $r=$f.TextRange; $r.Text=$text; $r.Font.Name=$font; $r.Font.Size=$size; $r.Font.Color.RGB=$color
  $r.Font.Bold = $(if ($bold) {-1} else {0})
  $r.ParagraphFormat.Alignment=$align
  $r.ParagraphFormat.SpaceBefore=0; $r.ParagraphFormat.SpaceAfter=0
  $s.TextFrame2.AutoSize=0
  $s.Width=$w; $s.Height=$h
}
function Box([double]$x,[double]$y,[double]$w,[double]$h,[int]$fill=$C.white,[int]$border=-1) {
  $s=$script:slide.Shapes.AddShape(5,$x,$y,$w,$h)
  $s.Fill.ForeColor.RGB=$fill
  $s.Adjustments.Item(1)=0.09
  if ($border -lt 0) { $s.Line.Visible=0 } else { $s.Line.ForeColor.RGB=$border; $s.Line.Weight=1.3 }
}
function Line([double]$x1,[double]$y1,[double]$x2,[double]$y2,[int]$color=$C.blue,[bool]$arrow=$false,[bool]$dashed=$false,[bool]$both=$false) {
  $s=$script:slide.Shapes.AddLine($x1,$y1,$x2,$y2)
  $s.Line.ForeColor.RGB=$color; $s.Line.Weight=2.2
  if ($arrow) { $s.Line.EndArrowheadStyle=3 }
  if ($both) { $s.Line.BeginArrowheadStyle=3 }
  if ($dashed) { $s.Line.DashStyle=4 }
}
function Dot([double]$x,[double]$y,[double]$r=6,[int]$fill=$C.blue) {
  $s=$script:slide.Shapes.AddShape(9,$x-$r,$y-$r,2*$r,2*$r)
  $s.Fill.ForeColor.RGB=$fill; $s.Line.Visible=0
}
function Tag([double]$x,[double]$y,[double]$w,[string]$text,[int]$fill=$C.paleBlue,[int]$color=$C.blue) {
  Box $x $y $w 42 $fill
  Text ($x+12) ($y+7) ($w-24) 30 $text 24 $color $true
}
function NoteText([string]$s) {
  $s=[regex]::Replace($s,'\[([^\]]+)\]\(([^)]+)\)','$1: $2')
  $s=$s -replace '\*\*','' -replace '`','' -replace '(?m)^#{1,6}\s*',''
  return $s.Trim()
}
function Section([string]$pattern) {
  $m=[regex]::Match($plan,$pattern,[System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $m.Success) { throw "Missing presentation-plan section: $pattern" }
  return (NoteText $m.Groups[1].Value)
}
function NewSlide([string]$title,[string]$subtitle,[int]$minutes,[string]$notes,[bool]$backup=$false) {
  $script:slide=$presentation.Slides.Add($presentation.Slides.Count+1,12)
  $script:slide.FollowMasterBackground=0
  $script:slide.Background.Fill.Solid()
  $script:slide.Background.Fill.ForeColor.RGB=$C.bg
  Text 54 26 720 24 $(if ($backup) {'OPTIONAL / DEEPER DISCUSSION'} else {'WEEK 01 / ROS BASICS'}) 16 $C.teal $true
  Text 54 64 852 60 $title 40 $C.ink $true
  if ($subtitle) { Text 54 124 852 64 $subtitle 26 $C.muted }
  Line 54 494 906 494 $C.line
  Text 54 504 660 24 'Robotics & Autonomous Systems · ROS 2 Jazzy' 16 $C.muted
  Text 836 504 70 24 ('{0:00}' -f $script:slide.SlideIndex) 16 $C.muted $false 3
  $noteBody=$script:slide.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange
  $noteBody.Text=$notes
  $noteBody.Font.Name='Aptos'; $noteBody.Font.Size=12
  $script:slide.SlideShowTransition.AdvanceOnTime=0
  $script:slides.Add([pscustomobject]@{number=$script:slide.SlideIndex; title=$title; minutes=$minutes; backup=$backup})
}
function Graph([double]$y=232) {
  Box 54 $y 326 82 $C.paleBlue
  Text 70 ($y+25) 294 42 '/greeting_publisher' 24 $C.blue $true 2 'Consolas'
  Box 410 $y 140 82 $C.white $C.line
  Text 420 ($y+25) 120 42 '/chatter' 24 $C.ink $true 2 'Consolas'
  Box 580 $y 326 82 $C.paleTeal
  Text 592 ($y+25) 302 42 '/greeting_subscriber' 24 $C.teal $true 2 'Consolas'
  Line 380 ($y+41) 410 ($y+41) $C.blue $true
  Line 550 ($y+41) 580 ($y+41) $C.teal $true
  Text 54 ($y+95) 326 36 'std_msgs/msg/String' 24 $C.muted $false 2 'Consolas'
}

$app=$null; $presentation=$null; $hadExistingPresentations=$false
try {
  $app=New-Object -ComObject PowerPoint.Application
  $hadExistingPresentations=($app.Presentations.Count -gt 0)
  # Add and open presentations without a visible document window.
  $presentation=$app.Presentations.Add(0)
  $presentation.PageSetup.SlideWidth=$W; $presentation.PageSetup.SlideHeight=$H

  NewSlide 'ROS basics' '' 0 @"
Week 1 — Robotics & Autonomous Systems
Audience: Python familiarity; little networking knowledge.
Use this title while students settle; begin the timed teaching content on the next slide.
Timing: explanation 25 minutes; code 7; run/inspect 6; experiments 4; questions/recap 3. Total 45 minutes. Five hidden backup slides are outside the schedule.
ROS 2 Jazzy is the teaching baseline, not a claim about the newest ROS distribution.
"@
  Text 54 142 740 76 'Connect the pieces of a robot.' 36 $C.muted
  Tag 54 239 224 'Understand ROS'
  Tag 298 239 212 'Read the code' $C.paleTeal $C.teal
  Tag 530 239 224 'Inspect it live'
  Box 54 327 852 114 $C.white
  $titleNodes=@(@{x=86;t='Sense'},@{x=366;t='Decide'},@{x=646;t='Act'})
  foreach ($n in $titleNodes) { Text $n.x 363 184 44 $n.t 32 $C.ink $true 2 }
  Line 270 384 356 384 $C.blue $true
  Line 550 384 636 384 $C.teal $true

  $durations=@(2,2,2,2,2,2,4,2,3,2)
  $sections=@()
  for ($i=1;$i -le 10;$i++) { $sections += (Section "## Slide $i .*?\r?\n(.*?)(?=\r?\n## |\z)") }

  NewSlide 'What is ROS?' 'A shared framework for building robotics software.' 2 ("Timing: 2 minutes.`r`n`r`n"+$sections[0])
  Text 54 212 352 56 'Robot Operating System' 30 $C.blue $true
  Text 54 276 352 146 "Connect software across`nlanguages and machines.`nShare common interfaces." 28
  $layerYs=@(206,280,354); $layerTexts=@('Robot application','ROS libraries + tools + packages','Host OS + hardware'); $layerFills=@($C.white,$C.paleBlue,$C.white)
  for ($j=0;$j -lt 3;$j++) { Box 444 $layerYs[$j] 462 64 $layerFills[$j]; Text 460 ($layerYs[$j]+17) 430 40 $layerTexts[$j] 24 $C.ink $true 2 }
  Text 54 443 852 34 'Reuse drivers and algorithms. Focus on your robot''s behavior.' 24 $C.muted

  NewSlide 'What is ROS used for?' 'Integrate sensing, decisions, and actuation in one system.' 2 ("Timing: 2 minutes.`r`n`r`n"+$sections[1])
  $xs=@(54,238,450,626,794); $widths=@(156,184,148,140,112); $labels=@('Sensors',"Perception`nLocalization",'Planning','Control','Drivers')
  for ($j=0;$j -lt 5;$j++) { Box $xs[$j] 211 $widths[$j] 80 $(if($j%2 -eq 0){$C.paleBlue}else{$C.paleTeal}); Text ($xs[$j]+6) 229 ($widths[$j]-12) 60 $labels[$j] 24 $C.ink $true 2; if($j -lt 4){Line ($xs[$j]+$widths[$j]) 251 $xs[$j+1] 251 $C.blue $true} }
  Line 850 305 340 305 $C.teal $true
  Text 401 311 340 35 'Motion feedback' 24 $C.teal $false 2
  Box 54 361 414 102 $C.white
  Text 74 374 374 35 'LOGISTICS' 24 $C.blue $true
  Text 74 413 374 35 'BMW + Microsoft / interoperability' 24
  Box 492 361 414 102 $C.white
  Text 512 374 374 35 'MANUFACTURING' 24 $C.teal $true
  Text 512 413 374 35 'Foundries / scan → plan → blend' 24

  NewSlide 'ROS 1 → ROS 2' 'Familiar concepts. A redesigned foundation.' 2 ("Timing: 2 minutes. Keep the timeline brief to allow 2 minutes for the whole-network overview.`r`n`r`n"+$sections[2])
  Line 126 204 838 204 $C.line
  $timeline=@(@{x=126;y='2007';t='ROS begins'},@{x=360;y='2017';t='ROS 2 Ardent'},@{x=600;y='2024';t='Jazzy'},@{x=838;y='2025';t='ROS 1 EOL'})
  foreach($t in $timeline) { Dot $t.x 204 6 $C.blue; Text ($t.x-90) 219 180 36 $t.y 24 $C.blue $true 2; Text ($t.x-104) 254 208 34 $t.t 24 $C.ink $false 2 }
  Box 54 310 414 114 $C.white
  Text 74 324 374 36 'ROS 1' 28 $C.blue $true
  Text 74 365 374 48 'Master discovery · TCPROS' 24
  Box 492 310 414 114 $C.paleTeal
  Text 512 324 374 36 'ROS 2' 28 $C.teal $true
  Text 512 365 374 48 'DDS discovery · QoS · lifecycle' 24
  Text 54 439 852 38 'ROS 2 = generation. Jazzy = distribution.' 26 $C.muted

  NewSlide 'Nodes and the ROS graph' 'A node has a responsibility. A process hosts running code.' 2 ("Timing: 2 minutes.`r`n`r`n"+$sections[3])
  Box 54 206 414 235 $C.white $C.line
  Text 76 221 370 36 'THIS DEMO: TWO PROCESSES' 24 $C.blue $true
  Box 76 273 370 61 $C.paleBlue
  Text 88 289 346 36 '/greeting_publisher' 24 $C.blue $true 2 'Consolas'
  Box 76 358 370 61 $C.paleTeal
  Text 88 374 346 36 '/greeting_subscriber' 24 $C.teal $true 2 'Consolas'
  Line 261 334 261 358 $C.teal $true
  Box 492 206 414 235 $C.white $C.line
  Text 514 221 370 36 'ALSO VALID: ONE PROCESS' 24 $C.teal $true
  Box 516 294 162 93 $C.paleBlue
  Text 526 317 142 50 'Node A' 28 $C.blue $true 2
  Box 720 294 162 93 $C.paleTeal
  Text 730 317 142 50 'Node B' 28 $C.teal $true 2
  Line 678 340 720 340 $C.blue $true
  Text 54 452 852 32 'The graph describes nodes and their communication connections.' 24 $C.muted

  NewSlide 'Topics carry typed messages' 'Publishers send. Subscribers receive. One topic can connect many.' 2 ("Timing: 2 minutes. Save the detailed code explanation for the live walkthrough.`r`n`r`n"+$sections[4])
  Graph 210
  Line 480 292 480 343 $C.teal
  Line 480 343 725 343 $C.teal $true
  Text 742 330 164 36 'Another reader' 24 $C.teal
  Box 54 385 852 91 $C.white
  Text 74 400 240 34 'String interface' 24 $C.blue $true
  Text 74 438 240 30 'string data' 24 $C.ink $false 1 'Consolas'
  Text 354 400 532 62 "message = String()`nmessage.data = 'Hello, robotics!'" 24 $C.ink $false 1 'Consolas'

  NewSlide 'Choose the right interface' 'Match the communication pattern to the task.' 2 ("Timing: 2 minutes.`r`n`r`n"+$sections[5])
  $cards=@(@{x=54;y=202;t='Topic';a='data → data → data';e='Sensor readings';c=$C.blue;f=$C.paleBlue},@{x=492;y=202;t='Service';a='request → response';e='Reset odometry';c=$C.teal;f=$C.paleTeal},@{x=54;y=338;t='Action';a='goal → feedback → result';e='Navigate + cancel';c=$C.teal;f=$C.paleTeal},@{x=492;y=338;t='Parameter';a='node configuration';e='Exposure / frame name';c=$C.blue;f=$C.paleBlue})
  foreach($interfaceCard in $cards) { Box $interfaceCard.x $interfaceCard.y 414 120 $interfaceCard.f; Text ($interfaceCard.x+20) ($interfaceCard.y+10) 374 36 $interfaceCard.t 28 $interfaceCard.c $true; Text ($interfaceCard.x+20) ($interfaceCard.y+49) 374 32 $interfaceCard.a 24; Text ($interfaceCard.x+20) ($interfaceCard.y+83) 374 30 $interfaceCard.e 24 $C.muted }

  NewSlide 'One graph, multiple computers' 'Nodes communicate locally or across computers in one ROS domain.' 2 @"
Timing: 2 minutes. This is the high-level overview after introducing topics, services, actions, and parameters.

Explain the nesting from the outside inward: the outer boundary is one logical ROS domain (ROS_DOMAIN_ID=42); the two inner boxes are physical computers; the smaller boxes are ROS nodes. A computer can host several processes, and a process can contain several nodes, as the earlier node/process slide showed. The diagram does not assign one process per node.

Read the connections:
TOPIC: the Camera node on the robot publishes images; the Perception node on the operator computer subscribes. Topics support multiple publishers and readers; only one reader is drawn for clarity.
SERVICE: the Diagnostics node is a client requesting a reset from the Motor node's service server. The response travels back to Diagnostics. The double arrow represents request and response, not a continuously bidirectional stream.
ACTION: the Mission node sends a navigation goal to the Navigation node's action server. Feedback and the final result return to Mission; Mission can request cancellation. The double arrow summarizes these interactions.
LOCAL CONNECTION: Navigation publishes velocity commands to Motor on the robot computer. Point to the short upward arrow between those two nodes. The same graph supports communication within a computer and across computers.

Nodes can combine roles. Motor subscribes to commands and offers a reset service; Navigation offers an action and publishes commands. Nodes connect through named, typed interfaces rather than needing the consumer's physical location. A topic is not a separate broker process. Services and actions do not require a central ROS master. Parameters belong to individual nodes and are configuration, so they were introduced on the previous slide rather than drawn as another network-wide bus.

The ROS domain groups discoverable participants; it is neither a computer nor a subnet nor a security boundary. Several domains can coexist on the same physical network. In the ordinary DDS setup, different domain IDs do not communicate directly; bridging/routing is outside this overview. The same ID alone is insufficient: discovery must be allowed across machines, transport must be reachable (including firewall/network configuration), and endpoint names/types and topic QoS must be compatible. Nodes need not all connect to one another.

This diagram is a conceptual two-computer deployment. The existing demo stays on one machine because ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST. Do not change the demo or its README; briefly contrast that setup with this larger deployment.

Quick comprehension check: Can Mission stay on the laptop while Navigation runs on the robot? Yes, with the matching action interface and working middleware/network configuration. Does joining domain 42 mean every node exchanges data with every other node? No; interfaces and matching determine connections.

References:
ROS domain ID: https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Intermediate/About-Domain-ID.rst
Discovery range: https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Advanced/Improved-Dynamic-Discovery.rst
Actions and client/server roles: https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Actions.rst
Nodes: https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Nodes.rst
Interfaces: https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Interfaces.rst
"@
  Box 54 193 852 255 $C.white $C.teal
  Text 74 203 600 34 'ROS_DOMAIN_ID = 42' 24 $C.teal $true 1 'Consolas'
  Box 74 246 246 190 $C.paleBlue
  Box 640 246 246 190 $C.paleTeal
  Text 90 252 214 34 'Robot computer' 24 $C.blue $true 2
  Text 656 252 214 34 'Operator computer' 24 $C.teal $true 2
  $networkRows=@(@{y=286;left='Camera node';right='Perception node';label='Topic: images';color=$C.blue;both=$false},@{y=342;left='Motor node';right='Diagnostics node';label='Service: reset';color=$C.teal;both=$true},@{y=398;left='Navigation node';right='Mission node';label='Action: navigate';color=$C.blue;both=$true})
  foreach($networkRow in $networkRows){
    Box 90 $networkRow.y 214 34 $C.white
    Box 656 $networkRow.y 214 34 $C.white
    Text 98 ($networkRow.y+3) 198 30 $networkRow.left 24 $C.ink $true 2
    Text 664 ($networkRow.y+3) 198 30 $networkRow.right 24 $C.ink $true 2
    Line 304 ($networkRow.y+17) 656 ($networkRow.y+17) $networkRow.color $true $false $networkRow.both
    Text 330 ($networkRow.y-17) 300 30 $networkRow.label 24 $networkRow.color $true 2
  }
  Line 197 398 197 376 $C.teal $true
  Text 54 459 852 32 'Same domain + reachable network + compatible interfaces.' 24 $C.muted

  NewSlide 'ROS 2 architecture and DDS' 'DDS = Data Distribution Service. RTPS = its wire protocol.' 4 ("Timing: 4 minutes.`r`n`r`n"+$sections[6]+"`r`n`r`nPoint to the dashed discovery arrow and solid data arrow. Serializing converts typed fields into bytes; the receiving side reconstructs the message. DomainParticipant joins a domain; it need not equal one ROS node. Discovery uses endpoint metadata before application data can flow.")
  $stack=@('Application','rclpy / rclcpp','rcl: shared C core','rmw: adapter interface','DDS implementation','Transport')
  for($j=0;$j -lt $stack.Count;$j++) { $sy=194+45*$j; Box 54 $sy 344 38 $(if($j%2 -eq 0){$C.white}else{$C.paleBlue}); Text 66 ($sy+3) 320 32 $stack[$j] 24 $C.ink $false 2; if($j -lt 5){Line 226 ($sy+38) 226 ($sy+45) $C.blue $true} }
  Box 438 210 200 74 $C.paleBlue
  Text 448 225 180 45 'DataWriter' 26 $C.blue $true 2
  Box 706 210 200 74 $C.paleTeal
  Text 716 225 180 45 'DataReader' 26 $C.teal $true 2
  Line 538 310 806 310 $C.teal $true $true $true
  Text 535 320 274 34 'Discover + match' 24 $C.teal $false 2
  Line 538 378 806 378 $C.blue $true
  Text 530 389 288 34 'Serialize → deliver' 24 $C.blue $false 2
  Text 438 447 468 35 'Shared domain · type · compatible QoS' 24 $C.muted

  NewSlide 'QoS shapes delivery' 'Quality of Service sets the contract between endpoints.' 2 ("Timing: 2 minutes.`r`n`r`n"+$sections[7])
  $qos=@(@{x=54;t='Reliability';v='RELIABLE';d='Retry lost samples';f=$C.paleBlue;c=$C.blue},@{x=346;t='Durability';v='VOLATILE';d='New data after joining';f=$C.paleTeal;c=$C.teal},@{x=638;t='History';v='KEEP_LAST: 10';d='Keep 10 samples';f=$C.paleBlue;c=$C.blue})
  foreach($q in $qos) { Box $q.x 212 268 173 $q.f; Text ($q.x+16) 226 236 35 $q.t 28 $q.c $true; Text ($q.x+16) 282 236 40 $q.v 24 $C.ink $true; Text ($q.x+16) 335 236 40 $q.d 24 $C.muted }
  Text 54 415 414 42 '10 = history depth' 28 $C.blue $true
  Text 492 415 414 42 '1.0 = timer interval (s)' 28 $C.teal $true
  Text 54 456 852 30 'A restarted subscriber does not replay missed greetings.' 24 $C.muted

  NewSlide 'Execution and lifecycle' 'DDS delivers data. The executor runs your callbacks.' 3 ("Timing: 3 minutes.`r`n`r`n"+$sections[8])
  Box 54 202 414 266 $C.white
  Text 74 218 374 38 'ORDINARY NODE: OUR DEMO' 24 $C.blue $true
  $runtime=@('init → construct node','spin → ready callbacks','Ctrl+C → cleanup')
  for($j=0;$j -lt 3;$j++) { Box 76 (270+$j*60) 370 48 $C.paleBlue; Text 88 (279+$j*60) 346 37 $runtime[$j] 24 $C.blue $false 2; if($j -lt 2){Line 261 (318+$j*60) 261 (330+$j*60) $C.blue $true} }
  Box 492 202 414 266 $C.white
  Text 512 218 374 38 'MANAGED NODE: OPTIONAL' 24 $C.teal $true
  $stateYs=@(270,336,402); $stateNames=@('Unconfigured','Inactive','Active')
  for($j=0;$j -lt 3;$j++) { Box 516 $stateYs[$j] 220 44 $C.paleTeal; Text 526 ($stateYs[$j]+7) 200 35 $stateNames[$j] 24 $C.teal $true 2 }
  Line 626 314 626 336 $C.teal $true; Text 752 309 134 32 'configure' 24 $C.teal
  Line 626 380 626 402 $C.teal $true; Text 752 375 134 32 'activate' 24 $C.teal
  Line 736 292 870 292 $C.muted
  Line 736 358 870 358 $C.muted
  Line 736 424 870 424 $C.muted
  Line 870 292 870 452 $C.muted $true
  Text 748 261 138 32 'shutdown' 24 $C.muted
  Text 748 440 138 32 'Finalized' 24 $C.muted

  NewSlide 'Inspect before debugging' 'Source Jazzy in every terminal. Run these scripts directly.' 2 ("Timing: 2 minutes.`r`n`r`n"+$sections[9])
  $cmds=@(@{c='ros2 node list';d='Find nodes'},@{c='ros2 topic list';d='Find topics'},@{c='ros2 topic info /chatter --verbose';d='Type + QoS'},@{c='ros2 interface show std_msgs/msg/String';d='Read fields'},@{c='ros2 topic echo /chatter';d='Observe data'})
  for($j=0;$j -lt $cmds.Count;$j++) { $cy=203+52*$j; Box 54 $cy 852 44 $(if($j%2 -eq 0){$C.white}else{$C.paleBlue}); Text 68 ($cy+8) 624 34 $cmds[$j].c 24 $C.ink $false 1 'Consolas'; Text 710 ($cy+8) 182 34 $cmds[$j].d 24 $C.teal $true }
  Text 54 462 852 30 'topic echo becomes another subscriber.' 24 $C.muted

  $demoNotes=Section '## Code Walkthrough and Live Demo .*?\r?\n(.*?)(?=\r?\n## |\z)'
  NewSlide 'Let''s read it. Then run it.' 'Predict the behavior before changing the running system.' 20 ("Timing: 20 minutes total — code 7; run/inspect 6; experiments 4; recap 3.`r`n`r`n"+$demoNotes+"`r`n`r`nCODE: Identify imports, class/base class, super().__init__ names, String and /chatter, queue depth, count initialization, create_timer, publish_greeting, receive_greeting, rclpy.init, spin, and finally cleanup. Read actual publisher.py and subscriber.py outside the deck.`r`nRUN: Use three terminals sourced with /opt/ros/jazzy/setup.bash, ROS_DOMAIN_ID=42, and ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST. Run both scripts and inspect before echo. Echo adds a reader; stop it before rechecking counts.`r`nPREDICTIONS: Subscriber stops: publisher continues. Subscriber restarts: new messages, no replay, possible discovery delay. Publisher restarts: publisher counter resets to zero; reader may first see a later number.`r`nRECAP: Ask which patterns fit sensor data, reset, and navigation; identify DDS versus executor responsibilities; distinguish 10 from 1.0 and ordinary runtime from managed lifecycle. Stop scripts with Ctrl+C.")
  Graph 208
  $prompts=@(@{x=54;t='Subscriber stops?';n='01'},@{x=346;t='Subscriber restarts?';n='02'},@{x=638;t='Publisher restarts?';n='03'})
  foreach($p in $prompts) { Box $p.x 374 268 93 $C.white; Text ($p.x+16) 383 236 32 $p.n 24 $C.teal $true; Text ($p.x+16) 421 236 38 $p.t 24 $C.ink $true }

  $backupSections=@()
  for($i=1;$i -le 5;$i++) { $backupSections+=(Section "### B$i .*?\r?\n(.*?)(?=\r?\n### |\r?\n## |\z)") }

  NewSlide 'DDS discovery and RTPS' 'Find participants. Match endpoints. Exchange application data.' 0 ("Optional backup — outside the timed core.`r`n`r`n"+$backupSections[0]) $true
  Tag 54 205 218 'Participants'
  Tag 314 205 248 'Endpoint discovery' $C.paleTeal $C.teal
  Tag 604 205 302 'Application data'
  Line 272 226 314 226 $C.blue $true; Line 562 226 604 226 $C.teal $true
  Text 54 275 852 36 'SPDP → SEDP → matching writers and readers' 26 $C.muted
  Box 54 335 852 135 $C.white
  Text 76 349 808 36 'Reliable delivery can recover missing samples.' 28 $C.blue $true
  Text 76 402 808 45 'Sequence → heartbeat → ACK/NACK → retransmission' 26

  NewSlide 'QoS compatibility' 'The publisher must satisfy the subscriber''s requested policy.' 0 ("Optional backup — outside the timed core.`r`n`r`n"+$backupSections[1]) $true
  $colX=@(54,357,660); $cw=@(282,282,246)
  Text 66 207 270 36 'Publisher offers' 26 $C.blue $true
  Text 369 207 270 36 'Reader requests' 26 $C.teal $true
  Text 672 207 222 36 'Compatible?' 26 $C.ink $true
  $rows=@(@('Best effort','Best effort','Yes'),@('Best effort','Reliable','No'),@('Reliable','Best effort','Yes'),@('Reliable','Reliable','Yes'))
  for($j=0;$j -lt 4;$j++) { $ry=250+$j*47; Box 54 $ry 852 40 $(if($j -eq 1){$C.paleAmber}else{$C.white}); for($k=0;$k -lt 3;$k++){Text ($colX[$k]+12) ($ry+5) ($cw[$k]-24) 35 $rows[$j][$k] 24 $(if($j -eq 1){$C.amber}else{$C.ink})} }
  Text 54 451 852 34 'Reliability shown here; other policies must also be compatible.' 24 $C.muted

  NewSlide 'Executors and concurrency' 'Threads help only when callback groups allow work to overlap.' 0 ("Optional backup — outside the timed core.`r`n`r`n"+$backupSections[2]) $true
  Text 54 206 852 38 'Single-threaded: one callback at a time' 28 $C.blue $true
  Line 220 284 892 284 $C.line $true
  Box 238 257 320 48 $C.paleBlue; Text 252 267 292 34 'Slow callback' 24 $C.blue $true 2
  Box 574 257 190 48 $C.paleTeal; Text 588 267 162 34 'Next callback' 24 $C.teal $true 2
  Text 54 329 852 38 'Multithreaded: eligible callbacks can overlap' 28 $C.teal $true
  Text 54 382 156 36 'Worker 1' 24 $C.muted
  Text 54 433 156 36 'Worker 2' 24 $C.muted
  Box 238 375 320 43 $C.paleBlue; Text 250 382 296 33 'Callback A' 24 $C.blue $true 2
  Box 238 426 190 43 $C.paleTeal; Text 248 432 170 33 'Callback B' 24 $C.teal $true 2

  NewSlide 'Managed lifecycle transitions' 'A supervisor requests transitions; callbacks manage resources.' 0 ("Optional backup — outside the timed core.`r`n`r`n"+$backupSections[3]+"`r`n`r`nDiagram shows the normal path and reversals. Shutdown is possible from primary operational states. Transition callbacks can return success, failure, or error; failure normally returns to the previous primary state, while error handling uses ErrorProcessing with transition-specific results. Finalized retains the node for introspection until destruction. Managed lifecycle requires appropriate application behavior; arbitrary subscribers/services are not automatically disabled.") $true
  $sx=@(54,372,690); $sn=@('Unconfigured','Inactive','Active')
  for($j=0;$j -lt 3;$j++){Box $sx[$j] 237 216 64 $C.paleTeal; Text ($sx[$j]+8) 253 200 38 $sn[$j] 24 $C.teal $true 2}
  Line 270 257 372 257 $C.teal $true; Text 266 209 114 34 'configure' 24 $C.teal $false 2
  Line 588 257 690 257 $C.teal $true; Text 588 209 104 34 'activate' 24 $C.teal $false 2
  Line 372 287 270 287 $C.blue $true; Text 270 309 106 34 'cleanup' 24 $C.blue $false 2
  Line 690 287 588 287 $C.blue $true; Text 563 309 152 34 'deactivate' 24 $C.blue $false 2
  for($j=0;$j -lt 3;$j++){Line ($sx[$j]+108) 350 ($sx[$j]+108) 374 $C.muted; Line ($sx[$j]+108) 374 480 374 $C.muted}
  Line 480 374 480 396 $C.muted $true
  Box 372 398 216 50 $C.white $C.line; Text 384 407 192 35 'Finalized' 24 $C.muted $true 2
  Text 608 401 298 38 'shutdown' 24 $C.muted
  Text 54 456 852 30 'Callbacks: success / failure; errors → ErrorProcessing' 24 $C.muted

  NewSlide 'Migrating from ROS 1' 'Keep the architectural ideas. Port the implementation.' 0 ("Optional backup — outside the timed core.`r`n`r`n"+$backupSections[4]) $true
  Box 54 218 228 87 $C.paleBlue; Text 74 246 188 42 'ROS 1 graph' 28 $C.blue $true 2
  Box 366 218 228 87 $C.white $C.line; Text 386 246 188 42 'Bridge' 28 $C.ink $true 2
  Box 678 218 228 87 $C.paleTeal; Text 698 246 188 42 'ROS 2 graph' 28 $C.teal $true 2
  Line 282 261 366 261 $C.blue $true $false $true; Line 594 261 678 261 $C.teal $true $false $true
  Text 54 350 852 42 'APIs · build · parameters · launch · QoS' 28 $C.ink $true
  Text 54 406 852 65 'Bridge support depends on interfaces, distributions, and operating systems.' 26 $C.muted

  if($presentation.Slides.Count -ne 18){throw 'Expected exactly 18 slides'}
  if(($script:slides | Measure-Object -Property minutes -Sum).Sum -ne 45){throw 'Timing must total 45 minutes'}
  Write-Output 'Built 18 slides; checking layout and exporting.'

  # Inspect PowerPoint's actual text bounds before exporting.
  foreach($s in $presentation.Slides){
    foreach($shape in $s.Shapes){
      if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){
        $tr=$shape.TextFrame.TextRange
        if($tr.BoundHeight -gt ($shape.Height+2)){$script:issues.Add("Slide $($s.SlideIndex): text height $([math]::Round($tr.BoundHeight,1)) exceeds box height $($shape.Height): $($tr.Text)")}
        if($tr.BoundWidth -gt ($shape.Width+2)){$script:issues.Add("Slide $($s.SlideIndex): text width $([math]::Round($tr.BoundWidth,1)) exceeds box width $($shape.Width): $($tr.Text)")}
      }
    }
  }
  if(-not $NoPreview){
    New-Item -ItemType Directory -Path $previewPath -Force | Out-Null
    foreach($s in $presentation.Slides){$s.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $s.SlideIndex)),'PNG',1600,900)}
  }
  # Export the review PDF while all slides are visible, so backups are included.
  $presentation.SaveAs($pdfPath,32)
  foreach($slideInfo in $script:slides){if($slideInfo.backup){$presentation.Slides.Item($slideInfo.number).SlideShowTransition.Hidden=-1}}
  $presentation.SaveAs($pptxPath,24)
  $presentation.Close(); $presentation=$null
  # Reopen the saved file in PowerPoint to check persistence and format validity.
  $check=$app.Presentations.Open($pptxPath,-1,0,0)
  if($check.Slides.Count -ne 18){throw 'Reopened presentation has wrong slide count'}
  for($i=1;$i -le $check.Slides.Count;$i++){
    $s=$check.Slides.Item($i)
    $shouldHide=$script:slides[$i-1].backup
    if(($s.SlideShowTransition.Hidden -eq -1) -ne $shouldHide){throw "Unexpected hidden-slide state: $i"}
    if($s.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text.Length -lt 80){throw "Missing notes on slide $i"}
  }
  $check.Close()
  foreach($path in $protectedPaths){if((Get-FileHash -LiteralPath (Join-Path $root $path)).Hash -ne $protectedHashes[$path]){throw "Protected file changed: $path"}}
  [pscustomobject]@{slides=$script:slides; timingMinutes=45; slideWidth=$W; slideHeight=$H; layoutIssues=$script:issues; protectedFiles=$protectedHashes; generated=@(($OutputBaseName+'.pptx'),($OutputBaseName+'.pdf'))} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
  Write-Output "Created $pptxPath"
  Write-Output "Created $pdfPath"
  Write-Output "Reopened in PowerPoint: 18 slides, 5 hidden backups, all speaker notes present; protected files unchanged."
  if($script:issues.Count){Write-Output ('LAYOUT ISSUES: '+$script:issues.Count); $script:issues | ForEach-Object { Write-Output $_ }}else{Write-Output 'No text overflow detected.'}
} finally {
  if($null -ne $presentation){try{$presentation.Close()}catch{}}
  if($null -ne $app -and -not $hadExistingPresentations){try{$app.Quit()}catch{}}
  if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
  [GC]::Collect(); [GC]::WaitForPendingFinalizers()
}
