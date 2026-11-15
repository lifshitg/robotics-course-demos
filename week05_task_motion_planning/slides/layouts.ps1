# Native editable layouts. Invoked once per lesson item by build_slides.ps1.
switch($item.kind){
 'title' {
  Scene 54 203 270
  Card 370 205 536 110 'Part 1 · Why PDDL?' 'Facts + reusable action rules → a task plan'
  Card 370 332 536 110 'Part 2 · How TAMP works' 'Geometric choices + feedback → a feasible plan' $C.paleTeal $C.teal
  Text 370 455 536 31 '15 min PDDL · 15 min TAMP · 10 min demo · 5 min recap' 20 $C.muted $true
 }
 'classical' {
  Card 54 209 250 178 'Initial state' "Robot at delivery.`nParcel at pickup."
  Card 354 209 250 178 'Action rules' 'Move empty, pick, move loaded, place.' $C.paleTeal $C.teal
  Card 654 209 252 178 'Goal condition' 'Parcel at delivery.'
  Line 310 296 346 296 $C.blue $true;Line 610 296 646 296 $C.teal $true
  Text 54 422 852 62 'Known symbolic state · deterministic outcomes · discrete actions' 26 $C.muted $true
 }
 'motivation' {
  Box 54 202 365 183 $C.paleBlue
  Text 72 214 329 38 'Listing transitions grows fast' 25 $C.blue $true
  $points=@(@(94,302),@(175,269),@(175,344),@(260,257),@(260,302),@(260,354),@(350,260),@(350,310),@(350,359))
  foreach($pair in @(@(0,1),@(0,2),@(1,3),@(1,4),@(2,4),@(2,5),@(3,6),@(4,7),@(5,8))){$a=$points[$pair[0]];$b=$points[$pair[1]];Line $a[0] $a[1] $b[0] $b[1] $C.line $true}
  foreach($p in $points){Dot $p[0] $p[1] 9 $C.blue}
  Text 365 294 34 42 '…' 30 $C.blue $true
  Box 444 202 462 183 $C.paleTeal
  Text 462 214 426 38 'Factor the description' 28 $C.teal $true
  Text 462 263 426 95 "State: individual true facts`nAction: conditions + local changes`nOne schema → many instances" 24
  Text 54 398 365 33 '40 Boolean facts: up to' 24 $C.blue $true
  Formula 54 438 365 43 '2^{40} > 10^{12} states' 30 $C.blue
  Text 444 398 462 63 "Implicit search still needs`nstates, goals, and successors." 24 $C.teal $true
  Text 444 463 462 27 'Compact input; potentially huge search.' 24 $C.muted $true
 }
 'facts' {
  Code 54 202 535 106 'Predicate declaration · domain.pddl' $snippets.predicate.code
  Code 54 326 535 106 'One ground fact · problem.pddl' $snippets.fact.code $C.paleTeal
  Text 54 450 535 35 'Absent from the state → false.' 25 $C.muted $true
  Scene 626 204 280
 }
 'domain' {
  Card 54 204 410 202 'domain.pddl' "Types + predicates`nParameterized action schemas`nReusable across instances"
  Card 486 204 420 202 'problem.pddl' "Concrete objects`nInitial facts + goal`nOne delivery instance" $C.paleTeal $C.teal
  Text 54 430 852 52 'PDDL describes the factored model; Pyperplan searches it.' 27 $C.muted $true
 }
 'objects' {
  Code 54 202 664 104 'Types · domain.pddl' $snippets.types.code
  Code 54 321 664 158 'Objects · problem.pddl' $snippets.objects.code $C.paleTeal
  Text 744 210 162 100 'parcel: concrete package' 25 $C.blue $true
  Text 744 335 162 139 "?p: variable`n-: type label" 25 $C.teal $true
 }
 'initial' {
  Code 54 202 545 185 'Opening :init excerpt · more facts follow' $snippets.init.code
  Box 54 405 545 79 $C.paleTeal
  Text 72 413 509 30 'Goal · problem.pddl' 24 $C.muted $true
  Text 72 447 509 31 $snippets.goal.code 24 $C.teal $false 1 'Consolas'
  Scene 626 204 280
 }
 'pick' {
  Code 54 202 660 282 'Complete action · domain.pddl' $snippets.pick.code
  Text 738 244 168 47 'Parameters' 25 $C.blue $true
  Text 738 300 168 70 'All conditions must hold.' 24 $C.teal $true
  Text 738 395 168 82 'Add / delete facts.' 24 $C.red $true
 }
 'ground_effects' {
  Box 54 202 852 51 $C.paleBlue
  Text 72 214 816 33 '(pick ?p ?l) → (pick parcel pickup)' 26 $C.blue $false 1 'Consolas'
  Text 54 274 410 34 'Before · after arriving at pickup' 24 $C.blue $true
  Text 500 274 406 34 'After picking' 24 $C.teal $true
  Text 54 321 410 100 "(robot-at pickup)`n(package-at parcel pickup)`n(hand-empty)" 24 $C.ink $false 1 'Consolas'
  Text 500 321 406 100 "(robot-at pickup)`n(holding parcel)" 24 $C.teal $false 1 'Consolas'
  Line 468 354 490 354 $C.teal $true
  Text 54 440 852 42 'Unchanged facts persist; grounding does not imply applicability.' 25 $C.muted $true
 }
 'loaded' {
  Code 54 205 450 211 'move-loaded · conditions' $snippets.loadedpre.code
  Code 522 205 384 211 'Same action · effects' $snippets.moveeffect.code
  Text 54 440 852 43 'Holding persists; permission is a symbolic assumption.' 27 $C.teal $true
 }
 'search' {
  Tag 54 202 258 'Domain + problem';Tag 363 202 234 'Grounding';Tag 648 202 258 'BFS search' $C.paleTeal $C.teal
  Line 319 223 354 223 $C.blue $true;Line 604 223 639 223 $C.teal $true
  PlanList $candidate 54 265 852 -1 42
  Text 54 450 852 35 'A shortest action sequence · does every motion fit?' 27 $C.muted $true
 }
 'hidden_geometry' {
  $xx=@(54,354,654)
  $labels=@('Pick object','Move base','Place object')
  $bodies=@("Choose grasp`nIK + approach path","Base configurations`nCollision-free path","Choose placement`nIK + retreat path")
  for($i=0;$i -lt 3;$i++){
   Tag $xx[$i] 203 252 $labels[$i]
   Line ($xx[$i]+126) 257 ($xx[$i]+126) 316 $C.teal $true
   Card $xx[$i] 315 252 139 'Geometry' $bodies[$i] $C.paleTeal $C.teal
  }
  Line 312 224 346 224 $C.blue $true;Line 612 224 646 224 $C.blue $true
  Line 54 284 906 284 $C.red $false $true
  Text 54 454 852 31 'A choice for one action can constrain the actions that follow.' 24 $C.muted $true
 }
 'blocked_mug' {
  [void]$script:slide.Shapes.AddPicture((Join-Path $PSScriptRoot 'assets/ronen-blocked-mug.png'),0,-1,54,195,405,283)
  Text 494 207 412 37 'Goal: pick the mug' 28 $C.blue $true
  Text 494 258 412 73 'The box blocks access. Geometry forces task revision.' 26
  Tag 494 355 412 'Pick box → place box aside' $C.paleAmber $C.amber
  Tag 494 408 412 'Then pick mug' $C.paleTeal $C.teal
  Text 54 478 852 16 'Illustration: Ronen I. Brafman · Class 9, slide 4 · supplied PDF page 5' 12 $C.muted
 }
 'tamp_loop' {
  Box 54 217 233 79 $C.paleBlue;Text 72 231 197 62 "Task-level`nsearch" 25 $C.blue $true 2
  Box 402 217 270 79 $C.paleTeal;Text 420 231 234 62 "Geometric`nrefinement" 25 $C.teal $true 2
  Box 744 217 162 79 $C.paleTeal;Text 754 231 142 62 "Validated`nplan" 24 $C.teal $true 2
  Line 294 258 393 258 $C.blue $true;Text 297 218 98 33 'Candidate' 18 $C.blue $true 2
  Line 679 258 736 258 $C.teal $true;Text 681 221 54 28 'Pass' 18 $C.teal $true 2
  Line 537 302 537 322 $C.red;Line 537 322 170 322 $C.red;Line 170 322 170 303 $C.red $true
  Text 200 299 326 24 'Feedback: constrain task choices' 18 $C.red $true
  Line 650 213 650 194 $C.teal;Line 650 194 426 194 $C.teal;Line 426 194 426 213 $C.teal $true
  Tag 54 339 852 '1  Retry geometry · another grasp or path' $C.paleTeal $C.teal
  Tag 54 389 852 '2  Rebind earlier parameters · same task skeleton' $C.paleTeal $C.teal
  Tag 54 439 852 '3  Revise the task · insert, reorder, or choose other actions' $C.paleAmber $C.amber
 }
 'response_table' {
  $tableShape=$script:slide.Shapes.AddTable(4,3,54,194,852,288)
  $table=$tableShape.Table
  $table.Columns.Item(1).Width=200;$table.Columns.Item(2).Width=270;$table.Columns.Item(3).Width=382
  $heights=@(34,72,92,90)
  $headers=@('Response','Meaning','Example')
  for($row=1;$row -le 4;$row++){
   $table.Rows.Item($row).Height=$heights[$row-1]
   for($col=1;$col -le 3;$col++){
    $cell=$table.Cell($row,$col);$shape=$cell.Shape;$frame=$shape.TextFrame
    $frame.MarginLeft=10;$frame.MarginRight=10;$frame.MarginTop=5;$frame.MarginBottom=5
    $frame.VerticalAnchor=1
    $range=$frame.TextRange
    if($row -eq 1){$range.Text=$headers[$col-1]}else{$entry=$tampResponses[$row-2];$range.Text=$(switch($col){1{$entry.response};2{$entry.meaning};3{$entry.example}})}
    $range.Font.Name='Aptos';$range.Font.Size=24
    $range.Font.Bold=$(if($row -eq 1 -or $col -eq 1){-1}else{0})
    $range.Font.Color.RGB=$(if($row -eq 1){$C.white}elseif($col -eq 1 -and $row -eq 4){$C.amber}elseif($col -eq 1){$C.teal}else{$C.ink})
    $range.ParagraphFormat.SpaceBefore=0;$range.ParagraphFormat.SpaceAfter=0
    $range.ParagraphFormat.LineRuleWithin=0;$range.ParagraphFormat.SpaceWithin=24
    $shape.Fill.Solid();$shape.Fill.ForeColor.RGB=$(if($row -eq 1){$C.blue}elseif($row -eq 4){$C.paleAmber}elseif($col -eq 1){$C.paleTeal}else{$C.white})
    foreach($edge in 1..4){$cell.Borders.Item($edge).ForeColor.RGB=$C.line;$cell.Borders.Item($edge).Weight=1}
   }
  }
  if($tableShape.Top+$tableShape.Height -gt 490){$script:issues.Add('Response table extends into the slide footer.')}
  for($row=1;$row -le 4;$row++){for($col=1;$col -le 3;$col++){
   $cellShape=$table.Cell($row,$col).Shape;$frame=$cellShape.TextFrame;$range=$frame.TextRange
   if($range.BoundHeight -gt $cellShape.Height-8 -or $range.BoundWidth -gt $cellShape.Width-18){$script:issues.Add("Response table cell ${row},${col} exceeds its bounds: $($range.Text)")}
  }}
 }
 'architectures' {
  $xs=@(54,344,634)
  $titles=@('Task-first','Interleaved','Joint / constraints')
  $bodies=@("Build whole task plan.`nThen refine geometry.","Extend a task prefix.`nCheck geometry as it grows.","Choose actions + geometry in a coupled model.")
  for($i=0;$i -lt 3;$i++){Box $xs[$i] 202 272 228 $(if($i -eq 1){$C.paleTeal}else{$C.paleBlue});Text ($xs[$i]+16) 215 240 36 $titles[$i] 26 $(if($i -eq 1){$C.teal}else{$C.blue}) $true;Text ($xs[$i]+16) 333 240 88 $bodies[$i] 24}
  foreach($i in 0..2){Dot (95+$i*61) 278 12 $C.blue;if($i -lt 2){Line (109+$i*61) 278 (140+$i*61) 278 $C.blue $true}}
  Line 218 278 218 310 $C.teal $true;Text 80 304 214 30 'Geometry for the plan' 18 $C.teal $true
  for($i=0;$i -lt 3;$i++){Dot (381+$i*78) 278 10 $C.blue;Dot (414+$i*78) 278 8 $C.teal;Line (393+$i*78) 278 (403+$i*78) 278 $C.teal $true;if($i -lt 2){Line (424+$i*78) 278 (447+$i*78) 278 $C.blue $true}}
  Text 365 304 230 30 'Geometry with each step' 18 $C.teal $true
  foreach($p in @(@(692,273),@(769,270),@(847,277))){Dot $p[0] $p[1] 10 $C.blue;Line $p[0] ($p[1]+10) 769 312 $C.line}
  Dot 769 312 10 $C.teal;Line 702 273 759 270 $C.line;Line 779 270 837 277 $C.line
  Tag 54 445 852 'Our demo: task-first refinement with geometric feedback.' $C.paleAmber $C.amber
 }
 'demo_loop' {
  Card 54 205 250 165 'PDDL → BFS' "domain.pddl`nproblem.pddl`nPyperplan searches"
  Card 354 205 250 165 'Geometry' "geometry.py`nCheck swept disks`nFeedback to search" $C.paleTeal $C.teal
  Card 654 205 252 165 'Playback' "demo.py`nOnly validated plans`nFacts from PDDL"
  Line 310 278 346 278 $C.blue $true;Line 610 278 646 278 $C.teal $true
  Line 477 376 477 402 $C.amber;Line 477 402 179 402 $C.amber;Line 179 402 179 376 $C.amber $true
  Text 54 431 852 55 'planning.py refines a temporary problem, then replans.' 27 $C.muted $true
 }
 'footprints' {
  Text 54 202 570 34 'Which action fails geometric validation?' 25 $C.blue $true
  PlanList $candidate 54 254 570 -1 44
  foreach($mode in @('empty','loaded')){
   $yy=if($mode -eq 'empty'){209}else{354};$rr=if($mode -eq 'empty'){12}else{25};$cc=if($mode -eq 'empty'){$C.teal}else{$C.red}
   Box 650 $yy 256 103 $C.white
   foreach($wallY in @(($yy+6),($yy+72))){$wall=$script:slide.Shapes.AddShape(1,765,$wallY,24,26);$wall.Fill.ForeColor.RGB=$C.muted;$wall.Line.Visible=0}
   Line 670 ($yy+52) 886 ($yy+52) $C.line $true $true
   Dot 777 ($yy+52) $rr $cc
   Text 650 ($yy+107) 256 35 $(if($mode -eq 'empty'){'Empty · Ø 0.24 m'}else{'Loaded · Ø 0.50 m'}) 24 $cc $true 2
  }
  Text 54 450 570 34 'Gap 0.40 m · clearance 0.20 m' 25 $C.muted $true
 }
 'refine' {
  Code 54 202 852 86 'REMOVE · one loaded direction, in a temporary problem' $snippets.permission.code $C.pink
  Code 54 300 852 86 'KEEP · empty shortcut' $snippets.emptypermission.code $C.paleTeal
  Text 54 404 852 77 'Replan from the original initial state. The authored PDDL and execution state stay unchanged.' 27 $C.muted $true
 }
 'revised' {
  Scene 54 204 280 'revised'
  Text 372 210 534 274 "1 (move-empty delivery pickup)`n2 (pick parcel pickup)`n3 (move-loaded parcel pickup`n   upper-left)`n4 (move-loaded parcel upper-left`n   upper-right)`n5 (move-loaded parcel upper-right`n   delivery)`n6 (place parcel delivery)" 24 $C.ink $false 1 'Consolas'
 }
 'limits' {
  Card 54 206 410 206 'This demonstration' "Named waypoints`nStraight motions`nDisks + abstract handling"
  Card 486 206 420 206 'Broader TAMP' "Grasps + placements`nConfigurations + paths`nCoupled task choices" $C.paleTeal $C.teal
  Text 54 438 852 46 'A failed search or timeout is not proof of impossibility.' 25 $C.muted $true
 }
 'demo' {
  Scene 54 204 280
  Text 384 211 522 47 '1  Read domain.pddl + problem.pddl' 26 $C.blue $true
  Text 384 268 522 42 '2  Predict the candidate failure' 26
  Text 384 319 522 42 '3  Inspect geometric feedback' 26
  Text 384 370 522 42 '4  Match the revised plan to its route' 26
  Text 384 421 522 57 '5  Play; pause after pickup; finish' 26 $C.teal $true
 }
 'recap' {
  Tag 54 202 852 'Facts + schemas → compact model → symbolic candidate'
  Tag 54 258 852 'Geometry → feedback → revised plan → execution' $C.paleTeal $C.teal
  Text 54 329 852 44 'Why factor the representation? What does PDDL provide?' 26 $C.blue $true
  Text 54 385 852 44 'What can change after geometric refinement fails?' 26 $C.teal $true
  Text 54 441 852 44 'Which TAMP architecture does our demo illustrate?' 26 $C.muted $true
 }
 default {throw "Unknown slide layout: $($item.kind)"}
}
