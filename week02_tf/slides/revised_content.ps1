# Editable content for the revised 18-slide teaching sequence.
# Dot-source only from update_slides.ps1 after copying/reordering the source deck.
function Set-Title([string]$title) {
    $script:slide.Shapes.Item(2).TextFrame.TextRange.Text=$title
}
function Bold-Vectors {
    $shape=$script:slide.Shapes.Item($script:slide.Shapes.Count)
    $range=$shape.TextFrame.TextRange
    foreach($match in [regex]::Matches($range.Text,'(?<![A-Za-z])[vK](?![A-Za-z])')) {
        $range.Characters($match.Index+1,1).Font.Name='Cambria'
        $range.Characters($match.Index+1,1).Font.Bold=-1
    }
}

Body 3 'A geometric relationship, managed by a ROS 2 library.'
Box 54 198 410 224 $C.paleBlue; Box 486 198 420 224 $C.paleTeal
Text 72 211 374 38 'Transform (TF) · mathematics' 27 $C.blue $true
Text 72 257 374 90 "Relationship between frames`nRotation + translation`nConverts point coordinates" 24
Formula 72 364 374 48 '^{A}p = ^{A}R_{B} ^{B}p + ^{A}t_{B}' 30 $C.blue
Text 504 211 384 38 'tf2 · ROS 2 library' 27 $C.teal $true
Text 504 257 384 150 "Manages frame relationships`nStatic + time-dependent data`nLooks up and applies transforms`nFollows multi-frame chains" 24
Text 54 432 852 30 'Frame = origin + coordinate axes.' 24 $C.muted
Text 54 458 852 33 'A transform is the mathematics; tf2 manages and applies it in ROS 2.' 24 $C.ink $true
Notes 'Timing: 1 minute. A rigid transform is a geometric mapping. TF is also used informally for the ROS frame system; distinguish the mathematical operation from the tf2 library. tf2 buffers static/time-dependent relationships and composes or inverts connected paths. Another component supplies calibration or estimated poses. Leading superscripts follow professor Lecture 2, printed slides 7 and 13–14.'

Body 4 'ROS defines the standard. Always check the conventions you use.'
Box 54 198 270 117 $C.paleBlue; Box 345 198 270 117 $C.paleTeal
Text 70 208 238 34 'ROS body' 27 $C.blue $true
Text 70 250 238 62 "x forward · y left`nz up" 24
Text 361 208 238 34 'ROS optical' 27 $C.teal $true
Text 361 250 238 62 "x right · y down`nz forward" 24
Text 54 332 561 62 "Translation: meters (m)`nRotation angles: radians (rad)" 25 $C.ink $true
Box 636 198 270 200 $C.white
if(Test-Path -LiteralPath $handImage) {
    $image=[Drawing.Image]::FromFile($handImage)
    try {
        $imageWidth=[math]::Min(248,($image.Width/$image.Height)*164)
        $imageHeight=$imageWidth*$image.Height/$image.Width
        $picture=$script:slide.Shapes.AddPicture($handImage,0,-1,(771-$imageWidth/2),(211+(164-$imageHeight)/2),$imageWidth,$imageHeight)
        $picture.Name='provided_right_hand_rule'; $picture.LockAspectRatio=-1
    } finally {$image.Dispose()}
} else { throw "Missing supplied right-hand image: $handImage" }
Text 650 366 242 36 'Right-handed: x × y = z' 22 $C.ink $true 2
Text 54 410 852 34 'Check: handedness · transform direction · Euler axes/order · row/column vectors' 23
Box 54 454 852 36 $C.paleTeal
Text 66 456 828 31 'Check the conventions of every data source, library, and API.' 25 $C.teal $true
Notes 'Timing: 1.5 minutes. ROS standards use right-handed frames, meters and radians. Body axes are x forward, y left, z up; optical axes are x right, y down, z forward. Always verify the actual data and library: transform direction, Euler axes/sequence, handedness, units and column/row vectors. A generic right-hand picture demonstrates chirality, not a prescribed attachment of each axis to one finger. Keep the labels in the supplied picture unchanged. ROS quaternion ordering is discussed later on slide 13. The existing teaching camera frame is simplified, not an optical frame. Sources: REP 103 and professor Lecture 2 printed slides 7, 15 and 50.'

Body 5 'The point stays still; its coordinate tuple changes.'
Box 54 205 852 79 $C.white
Formula 75 216 810 63 '^{A}p = ^{A}R_{B} ^{B}p + ^{A}t_{B}' 38 $C.blue
Box 54 326 186 42 $C.paleBlue; Text 66 331 162 33 'B coordinates' 24 $C.blue $true
Box 441 326 186 42 $C.paleTeal; Text 453 331 162 33 'A coordinates' 24 $C.teal $true
Line 250 347 430 347 $C.blue $true; Formula 260 290 160 45 '^{A}T_{B}' 32 $C.ink 2
Text 54 387 576 37 'Pose of B in A · maps B → A' 25
# Retain the point/two-frame illustration from the right-hand panel of the prior revision.
Line 716 377 778 377 $C.blue $true; Line 716 377 716 318 $C.blue $true
Line 764 362 826 341 $C.teal $true; Line 764 362 744 305 $C.teal $true
Text 696 380 30 29 'A' 22 $C.blue $true; Text 763 381 30 29 'B' 22 $C.teal $true
Dot 841 313 7 $C.amber; Text 850 296 30 32 'p' 24 $C.amber
Line 716 377 836 316 $C.line $false $true; Line 764 362 836 316 $C.line $false $true
Formula 54 442 99 42 '^{A}t_{B}' 32 $C.blue
Text 147 442 759 44 'Origin of frame B, expressed in frame A.' 26
Notes 'Timing: 1.5 minutes. Read ^A T_B as the pose of B expressed in A, mapping B coordinates into A coordinates. The leading superscript names the expression/destination frame. The translation ^A t_B is the origin of B expressed in A. Keep the physical point fixed in the two-frame diagram: only its coordinate representation changes. The equation and B-to-A flow restore the original math-reading approach. Professor Lecture 2 printed slides 13 and 19–22.'

Body 6 'Fixed-axis XYZ: roll about x, pitch about y, yaw about z.'
Set-Title 'Elementary rotations & Euler angles'
Formula 54 190 250 36 'R_{x}(φ) · roll' 26 $C.blue 2
Formula 351 190 250 36 'R_{y}(θ) · pitch' 26 $C.teal 2
Formula 648 190 250 36 'R_{z}(ψ) · yaw' 26 $C.blue 2
Matrix 54 231 250 91 @(@('1','0','0'),@('0','cφ','−sφ'),@('0','sφ','cφ')) 24
Matrix 351 231 250 91 @(@('cθ','0','sθ'),@('0','1','0'),@('−sθ','0','cθ')) 24
Matrix 648 231 250 91 @(@('cψ','−sψ','0'),@('sψ','cψ','0'),@('0','0','1')) 24
Formula 54 331 852 43 'R = R_{z}(ψ) R_{y}(θ) R_{x}(φ)' 32 $C.blue 2
Formula 54 375 852 34 '90° x then z: e_{x} → e_{y}   ·   z then x: e_{x} → e_{z}' 24
Text 54 410 852 55 "Pitch = ±90°: roll and yaw couple (gimbal lock).`nEuler singularity; physical rotation remains possible." 23
Text 54 466 852 27 '▶ Gimbal Lock — Video Demonstration (start at 2:20)' 22 $C.teal $true
$video=$script:slide.Shapes.Item($script:slide.Shapes.Count); $video.Name='gimbal_lock_video'
$video.ActionSettings.Item(1).Action=7
$video.ActionSettings.Item(1).Hyperlink.Address='https://www.youtube.com/watch?v=BczeMqU_u2Y&t=140s'
Notes 'Timing: 2 minutes. c and s denote full-angle cosine and sine for the indicated angle. Matrices use right-handed positive rotations on column vectors. Fixed/extrinsic XYZ RPY means rotate about the original x, then y, then z axes; the product acts rightmost first. Rz(+90 degrees)e_x=e_y. Reversing the x/z rotation order changes the result. At pitch +90 degrees only yaw-roll is identifiable; at -90 degrees only yaw+roll is identifiable. This is an Euler-coordinate singularity, not a physical inability to rotate. The optional video opens at 140 seconds (2:20); keep video viewing brief within the session timing. Professor Lecture 2 printed slides 15–16, 26 and 29.'

Body 7 'Each column is an axis of frame B expressed in frame A.'
Set-Title 'Rotation matrices describe frame axes'
Box 54 200 560 280 $C.paleBlue
Text 72 216 524 36 'Three columns · three unit axes' 27 $C.blue $true
Formula 72 277 524 64 '^{A}R_{B} = [ ^{A}x̂_{B}   ^{A}ŷ_{B}   ^{A}ẑ_{B} ]' 34 $C.blue
Text 72 357 524 37 'B axes, written using A coordinates.' 25
Formula 72 419 524 43 'R^{T}R = I      det(R) = +1' 29
Line 752 378 872 378 $C.blue $true; Line 752 378 752 251 $C.blue $true
Line 752 378 856 318 $C.teal $true; Line 752 378 692 274 $C.teal $true
Formula 874 365 32 35 'x_{A}' 24 $C.blue; Formula 740 219 40 35 'y_{A}' 24 $C.blue
Formula 857 291 49 35 'x_{B}' 24 $C.teal; Formula 650 247 48 35 'y_{B}' 24 $C.teal
Dot 752 378 5 $C.ink
Formula 647 398 259 39 '⊙ z_{A} = z_{B} (out)' 24 $C.muted 2
Text 642 447 264 34 'A: blue · B: teal' 24 $C.muted $false 2
Notes 'Timing: 1.5 minutes. Each column of ^A R_B is one unit axis of B expressed in A. The picture uses coincident origins and common +z pointing out of the page, with B rotated relative to A. Read a column by asking where a unit step along that B axis points in A. Orthogonal unit columns give R^T R=I; determinant +1 selects a right-handed proper rotation. Professor Lecture 2 printed slides 12–13.'

Body 8 'Same 4 × 4 transformation, two notations.'
Set-Title 'Homogeneous transformations'
Text 54 196 397 35 'Block form · 2 × 2 blocks' 26 $C.blue $true
Text 486 196 420 35 'Expanded form · 4 × 4 entries' 26 $C.teal $true
Formula 54 281 135 51 '^{A}T_{B} =' 32 $C.blue
Matrix 198 245 238 123 @(@('^{A}R_{B}','^{A}t_{B}'),@('0^{T}','1')) 31 $C.blue
Formula 449 281 42 51 '=' 36 $C.ink 2
Matrix 509 235 397 144 @(@('r_{11}','r_{12}','r_{13}','t_{x}'),@('r_{21}','r_{22}','r_{23}','t_{y}'),@('r_{31}','r_{32}','r_{33}','t_{z}'),@('0','0','0','1')) 26
Formula 54 390 440 36 'R: 3 × 3 · t: 3 × 1 · 0^{T}: 1 × 3' 23 $C.muted
Text 509 391 397 35 'Bottom row: 0  0  0  1' 24 $C.muted
Formula 54 440 440 47 '^{A}p = ^{A}R_{B} ^{B}p + ^{A}t_{B}' 30 $C.blue
Text 509 435 397 57 "Point [p; 1] includes translation.`nDirection [d; 0] does not." 24
Notes 'Timing: 1.5 minutes. These are two notations for the same 4x4 matrix, not a 2x2 numerical transform versus a 4x4 transform. The left side partitions the matrix into a 3x3 rotation, 3x1 translation, 1x3 zero row, and scalar 1. The right side expands those blocks into all 16 entries. The vector t is the B origin expressed in A. For a homogeneous point [p;1], multiplication includes translation. A direction [d;0] ignores translation. Professor Lecture 2 printed slides 19–22.'

Body 9 'Apply right to left. Matrix multiplication order matters.'
Box 54 202 180 40 $C.paleBlue; Text 54 206 180 32 'A' 25 $C.blue $true 2
Box 390 202 180 40 $C.paleTeal; Text 390 206 180 32 'B' 25 $C.teal $true 2
Box 726 202 180 40 $C.paleBlue; Text 726 206 180 32 'C' 25 $C.blue $true 2
Line 378 222 246 222 $C.blue $true; Line 714 222 582 222 $C.teal $true
Formula 54 270 852 62 '^{A}T_{C} = ^{A}T_{B} ^{B}T_{C}' 40 $C.blue 2
$range=$script:slide.Shapes.Item($script:slide.Shapes.Count).TextFrame.TextRange
for($j=1;$j -le $range.Length;$j++){if($range.Characters($j,1).Text -eq 'B'){$range.Characters($j,1).Font.Color.RGB=$C.teal; $range.Characters($j,1).Font.Bold=-1}}
Text 54 337 852 34 'Match the inner frame indices: B → B.' 24 $C.teal $true 2
Formula 54 401 230 54 'T^{-1} =' 35
Matrix 290 383 340 90 @(@('R^{T}','−R^{T}t'),@('0','1')) 32
Text 660 386 246 96 'Subtract the translation, then rotate back.' 24 $C.muted
Notes 'Timing: 1 minute. Match B in ^A T_B ^B T_C: C coordinates first map to B, then A. Frame-index cancellation is a mnemonic, not cancellation of matrices. Order matters. Inverse translation is -R^T t, not merely -t. Subtract t from the input point, then rotate back. Tree arrows on later slides name parent-child relationships rather than coordinate flow. Professor Lecture 2 printed slides 16 and 22.'

Body 10 'Three practical reasons for a different rotation representation.'
Set-Title 'Why use quaternions?'
$reasons=@(@('01','Avoid Euler gimbal lock','Represent every orientation without Euler-angle singularities.'),@('02','Compose 3D rotations','Combine rotations using ordered quaternion multiplication.'),@('03','Interpolate smoothly','SLERP gives smooth changes between orientations.'))
for($j=0;$j -lt 3;$j++){
    $y=199+94*$j; $fill=$(if($j -eq 1){$C.paleTeal}else{$C.paleBlue}); $accent=$(if($j -eq 1){$C.teal}else{$C.blue})
    Box 54 $y 852 82 $fill; Text 70 ($y+20) 58 45 $reasons[$j][0] 30 $accent $true
    Text 145 ($y+7) 743 35 $reasons[$j][1] 28 $accent $true
    Text 145 ($y+46) 743 32 $reasons[$j][2] 24
}
Notes 'Timing: 1 minute. Introduce motivation before formulas: quaternions do not have Euler-angle gimbal-lock singularities, compose rotations conveniently, and support smooth orientation interpolation with SLERP. They still need an agreed convention, normalization, and separate translation. They are not unique: sign equivalence is introduced on the next slide. Professor Lecture 2 printed slide 40.'

Body 11 'A quaternion has one scalar component and three vector components.'
Set-Title 'Quaternion representation'
Box 54 199 852 77 $C.paleBlue
Formula 72 211 816 54 'q = (w, v) = (w, x, y, z)' 36 $C.blue 2; Bold-Vectors
Text 54 295 410 35 'w: scalar part' 26 $C.ink $true
Formula 486 291 420 43 'v = (x, y, z): vector part' 28 $C.teal; Bold-Vectors
Formula 54 347 410 49 'w = cos(α/2)' 34 $C.blue
Formula 486 347 420 49 'v = K sin(α/2)' 34 $C.teal; Bold-Vectors
Formula 54 404 852 39 'K = (k_{x}, k_{y}, k_{z}), ‖K‖ = 1 · α: rotation angle' 27 $C.muted; Bold-Vectors
Formula 54 454 410 38 'w² + x² + y² + z² = 1' 26 $C.blue
Text 486 455 420 36 'q and −q: same 3D rotation' 24 $C.ink $true
Notes 'Timing: 1.5 minutes. q=(w,v)=(w,x,y,z) uses mathematical scalar-first Hamilton notation. The bold v is a three-vector, not a fifth component. With unit rotation axis K=(kx,ky,kz) and right-hand angle alpha: w=cos(alpha/2), v=K sin(alpha/2). Thus x=kx sin(alpha/2), y=ky sin(alpha/2), z=kz sin(alpha/2). Four numbers constrained to unit norm give three orientation degrees of freedom. q and -q encode the same rotation, not inverse rotations. Professor Lecture 2 printed slides 34 and 40.'

Body 12 'The Hamilton product ⊗ composes rotations. Its order matters.'
Set-Title 'Quaternion multiplication & points'
Formula 54 198 852 46 'q_{1} ⊗ q_{2} = (w_{1}w_{2} − v_{1}·v_{2},' 31 $C.blue; Bold-Vectors
Formula 54 248 852 47 '                  w_{1}v_{2} + w_{2}v_{1} + v_{1}×v_{2})' 31 $C.teal; Bold-Vectors
Box 54 313 852 81 $C.white
Formula 72 322 816 53 '(0, ^{A}p_{rot}) = q_{AB} ⊗ (0, ^{B}p) ⊗ q_{AB}^{-1}' 32 $C.blue 2
Formula 54 412 852 48 '^{A}p = ^{A}p_{rot} + ^{A}t_{B}' 34 $C.teal 2
Text 54 463 852 30 'Unit q: inverse = conjugate · rotate first, then add translation.' 24 $C.muted
Notes 'Timing: 1.5 minutes. For q1=(w1,v1) and q2=(w2,v2), the first component of the Hamilton product is scalar w1w2-v1 dot v2. The second is vector w1v2+w2v1+v1 cross v2. Read the formula as scalar/vector parts, not component-wise multiplication. Composition is ordered: q_AC=q_AB tensor q_BC. Use a pure quaternion (0,p) in the sandwich q tensor (0,p) tensor q inverse; read the vector part as the rotated point. The q_AB orientation maps B coordinates to A coordinates. Add the separately expressed translation ^A t_B afterward. Unit inverse is the conjugate (w,-v). Sign flip is not generally the inverse. Professor Lecture 2 printed slides 35–38.'

Body 13 'The library handles the rotation algebra for you.'
Set-Title 'How tf2 uses quaternions'
Box 54 199 852 85 $C.paleBlue
Text 72 210 816 70 "tf2 uses quaternions behind the scenes for rotations.`nTranslation remains a separate 3D vector." 26 $C.blue $true
Box 54 307 410 109 $C.white; Box 486 307 420 109 $C.paleTeal
Text 72 316 374 34 'ROS component order' 26 $C.blue $true
Formula 72 359 374 44 '(x, y, z, w)' 32 $C.blue 2
Text 504 316 384 34 'Identity rotation' 26 $C.teal $true
Formula 504 359 384 44 '(0, 0, 0, 1)' 32 $C.teal 2
Text 54 435 852 59 "Unit norm is required. tf2 handles composition and inversion`nwhen you look up transforms between frames." 24
Notes 'Timing: 1 minute. tf2 represents buffered rotation samples with quaternions alongside separate translation vectors. You normally ask for a transform between frames; the library follows the chain and handles composition and inversion. Some internal geometry operations also use rotation matrices, so do not imply every operation is performed exclusively in quaternion algebra. ROS ordering is x,y,z,w, while the previous mathematical slide used scalar-first w,x,y,z. A rotation quaternion must have unit norm; normalize valid nonzero numerical values before use. Identity is (0,0,0,1); all-zero is invalid. This slide focuses on the role of quaternions inside tf2. Sources: ROS 2 Jazzy tf2 Quaternion and TransformStorage implementations; Quaternion Fundamentals.'

Body 14 'Parent → child edges describe the frame relationships.'
Tree 241
Text 54 309 852 36 'One parent per child · one authority per edge · no cycles' 25
Text 54 353 852 36 'Disconnected trees have no transform path.' 26 $C.muted
Box 54 406 852 79 $C.white
Text 70 412 820 66 "Robot joints create dynamic transforms between neighboring links.`nChain them to obtain the end-effector pose: forward kinematics." 24
Notes 'Timing: 1 minute. world -> base_link is dynamic (solid blue); the camera edges are static (dashed teal). Arrows name parent-child relationships; a stored child pose in its parent maps child coordinates to parent coordinates. One parent per child, one authoritative broadcaster per edge, no cycles. Disconnected trees have no connecting transform path. A frame is not a ROS node. Movable robot joints determine transforms between neighboring links; chaining them gives forward kinematics. This is a conceptual connection, not a change to the existing teaching frames. Professor Lecture 3 printed slides 12–13.'

# Slides 15 and 16 retain the source publisher/buffer and timestamp content.
$script:slide=$presentation.Slides.Item(15)
Notes ('Timing: 1 minute. '+$script:slide.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text)
$script:slide=$presentation.Slides.Item(16)
Notes ('Timing: 1 minute. '+$script:slide.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text)

Body 17 'Predict the display before changing its reference frame.'
Box 54 198 852 119 $C.white
Text 72 210 816 42 'ros2 run tf2_ros tf2_echo base_link camera_frame' 24 $C.blue $false 1 'Consolas'
Text 72 267 816 42 'ros2 run tf2_ros tf2_echo world base_link' 24 $C.teal $false 1 'Consolas'
Text 54 335 852 43 'lookup_transform(target, source, time)' 29 $C.ink $false 1 'Consolas'
Box 54 398 852 87 $C.paleTeal
Text 70 407 820 70 "Predict: what happens when we change the RViz Fixed Frame`nfrom base_link to world?" 27 $C.teal $true
Notes 'Timing: 1 minute. tf2_echo base_link camera_frame shows camera pose in base. lookup_transform(target,source,time) converts source coordinates into target coordinates. Ask for a prediction before switching the display reference. Expected insight: the display reference and apparent coordinates/motion can change, while the physical relationships remain unchanged. Coordinate descriptions of the same physical point still coincide when expressed in a common frame. The world frame must be connected. Preserve all existing commands and demo behavior.'

Body 18 'Three steps · predict first, then connect the output to the mathematics.'
Tree 225
Text 54 287 852 32 '1  Inspect the transform · camera coordinates → base coordinates' 25 $C.blue $true
Text 79 325 827 33 'ros2 run tf2_ros tf2_echo base_link camera_frame' 24 $C.blue $false 1 'Consolas'
Text 54 367 852 33 '2  Transform the point · compare with the mathematics' 25 $C.teal $true
Formula 79 404 827 38 '^{C}p = (0.2, 0, 1)   →   ^{B}p = (0, 0.2, 1.5)' 29 $C.teal
Text 54 449 852 36 '3  Explain a failure · missing frame or disconnected tree?' 25 $C.ink $true
Notes 'Timing: 25 minutes for the existing demonstration and questions. 1 INSPECT: tf2_echo base_link camera_frame reports camera pose in base: Rz(+90 degrees), translation (0,0,0.5) m. 2 TRANSFORM: use the existing lookup and point transformation to connect the original camera point (0.2,0,1) to the base point (0,0.2,1.5). Rotate about +z by 90 degrees, then add 0.5 m along base z. Connect this to the homogeneous-transform and quaternion formulas. There is no separate numerical-example slide. 3 FAILURE: explain a missing-frame startup/recovery or disconnected-tree case; a buffer cannot infer a missing relationship. Unavailable timestamps on dynamic edges are a conceptual additional failure because transform history is finite. Static camera/base edges do not demonstrate dynamic extrapolation. RViz is optional: compare fixed frames base_link and world when the world transform is connected; the same physical points remain coincident. Presentation production does not run, modify, or rehearse the demo.'
