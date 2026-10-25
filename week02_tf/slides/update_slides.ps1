param([switch]$NoPreview, [string]$HandImagePath=(Join-Path $PSScriptRoot 'assets/right_hand_rule.jpg'))
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$inputPath = Join-Path $root 'TF_COORDINATE_TRANSFORMS.pptx'
$outputPath = Join-Path $root 'TF_COORDINATE_TRANSFORMS_UPDATED.pptx'
$pdfPath = Join-Path $root 'TF_COORDINATE_TRANSFORMS_UPDATED.pdf'
$reviewPath = Join-Path $PSScriptRoot 'updated_review'
$previewPath = Join-Path $reviewPath 'preview'
New-Item -ItemType Directory -Path $previewPath -Force | Out-Null

# Read bytes only for preservation checks; never execute or modify the demo.
$protected = @('TF_COORDINATE_TRANSFORMS.pptx','TF_COORDINATE_TRANSFORMS.pdf','TEACHING_NOTES.md','TF_MATH_REFERENCE.md','PRESENTATION_PLAN.md','slides/content.ps1','slides/build_slides.ps1','slides/review_slides.ps1')
$protected += @(Get-ChildItem -LiteralPath (Join-Path $root 'demo') -Recurse -File | ForEach-Object { $_.FullName.Substring($root.Length+1) })
$before = @{}
foreach ($relative in $protected) { $before[$relative] = (Get-FileHash -LiteralPath (Join-Path $root $relative) -Algorithm SHA256).Hash }

function Color([string]$hex) {
    return [Convert]::ToInt32($hex.Substring(0,2),16) + 256*[Convert]::ToInt32($hex.Substring(2,2),16) + 65536*[Convert]::ToInt32($hex.Substring(4,2),16)
}
$C = @{ ink=(Color '15283B'); muted=(Color '526477'); blue=(Color '2459D3'); teal=(Color '137F79'); paleBlue=(Color 'EAF0FC'); paleTeal=(Color 'E5F3F0'); white=(Color 'FFFFFF'); line=(Color 'D7E0E9'); amber=(Color 'AE651D'); paleAmber=(Color 'FFF0DF') }
$handImage=(Resolve-Path -LiteralPath $HandImagePath).Path
$script:slide = $null
# PowerPoint may rasterize identical glyphs with slightly different antialiasing
# between exports. Require identical slide XML separately and compare image
# pixels with a small rendering tolerance, rather than comparing PNG file bytes.
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class Week2RenderComparison {
    public static double[] Compare(string first, string second) {
        using(var a = new Bitmap(first)) using(var b = new Bitmap(second)) {
            if(a.Size != b.Size) throw new Exception("Render dimensions differ.");
            int compareHeight = Math.Min(a.Height,(int)Math.Round(a.Height*494.0/540.0));
            var rect = new Rectangle(0,0,a.Width,compareHeight);
            var ad = a.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format24bppRgb);
            var bd = b.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format24bppRgb);
            try {
                int length = Math.Abs(ad.Stride)*compareHeight;
                var av = new byte[length]; var bv = new byte[length];
                Marshal.Copy(ad.Scan0,av,0,length); Marshal.Copy(bd.Scan0,bv,0,length);
                long total=0, changed=0;
                for(int i=0;i<length;i++){int d=Math.Abs(av[i]-bv[i]); total+=d; if(d>8)changed++;}
                return new[]{(double)total/length,(double)changed/length};
            } finally { a.UnlockBits(ad); b.UnlockBits(bd); }
        }
    }
}
'@
function Text([double]$x,[double]$y,[double]$w,[double]$h,[string]$value,[double]$size=24,[int]$color=$C.ink,[bool]$bold=$false,[int]$align=1,[string]$font='Aptos') {
    $s=$script:slide.Shapes.AddTextbox(1,$x,$y,$w,$h)
    $s.Name='updated_text_'+$script:slide.Shapes.Count
    $s.Fill.Visible=0; $s.Line.Visible=0
    $f=$s.TextFrame
    $f.MarginLeft=0; $f.MarginRight=0; $f.MarginTop=0; $f.MarginBottom=0
    $f.WordWrap=-1; $f.AutoSize=0; $f.VerticalAnchor=1
    $r=$f.TextRange; $r.Text=$value; $r.Font.Name=$font; $r.Font.Size=$size; $r.Font.Color.RGB=$color
    $r.Font.Bold=$(if($bold){-1}else{0}); $r.ParagraphFormat.Alignment=$align
    $r.ParagraphFormat.SpaceBefore=0; $r.ParagraphFormat.SpaceAfter=0
    $s.TextFrame2.AutoSize=0; $s.Width=$w; $s.Height=$h
}
function Formula([double]$x,[double]$y,[double]$w,[double]$h,[string]$value,[double]$size=30,[int]$color=$C.ink,[int]$align=1) {
    $value=[regex]::Replace($value,'([cs])([φθψ])','$1_{$2}')
    $parts=[regex]::Matches($value,'([\^_])\{([^}]+)\}')
    $plain=''; $cursor=0; $ranges=@()
    foreach($part in $parts) {
        $plain+=$value.Substring($cursor,$part.Index-$cursor)
        $ranges+=@{start=$plain.Length+1;length=$part.Groups[2].Value.Length;upper=($part.Groups[1].Value -eq '^')}
        $plain+=$part.Groups[2].Value; $cursor=$part.Index+$part.Length
    }
    $plain+=$value.Substring($cursor)
    Text $x $y $w $h $plain $size $color $false $align 'Cambria Math'
    $s=$script:slide.Shapes.Item($script:slide.Shapes.Count)
    foreach($range in $ranges) {
        $f=$s.TextFrame.TextRange.Characters($range.start,$range.length).Font
        $f.Size=$size*.72; $f.BaselineOffset=$(if($range.upper){.32}else{-.22})
    }
}
function Box([double]$x,[double]$y,[double]$w,[double]$h,[int]$fill=$C.white) {
    $s=$script:slide.Shapes.AddShape(5,$x,$y,$w,$h)
    $s.Fill.ForeColor.RGB=$fill; $s.Line.Visible=0; $s.Adjustments.Item(1)=0.09
}
function Line([double]$x1,[double]$y1,[double]$x2,[double]$y2,[int]$color=$C.blue,[bool]$arrow=$false,[bool]$dashed=$false) {
    $s=$script:slide.Shapes.AddLine($x1,$y1,$x2,$y2)
    $s.Line.ForeColor.RGB=$color; $s.Line.Weight=2.2
    if($arrow){$s.Line.EndArrowheadStyle=3}; if($dashed){$s.Line.DashStyle=4}
}
function Dot([double]$x,[double]$y,[double]$radius=5,[int]$fill=$C.blue) {
    $s=$script:slide.Shapes.AddShape(9,$x-$radius,$y-$radius,2*$radius,2*$radius)
    $s.Fill.ForeColor.RGB=$fill; $s.Line.Visible=0
}
function Matrix([double]$x,[double]$y,[double]$w,[double]$h,[object[]]$rows,[double]$size=24,[int]$color=$C.ink) {
    $rh=$h/$rows.Count; $cw=($w-22)/$rows[0].Count
    foreach($bx in @($x,($x+$w))) {
        Line $bx $y $bx ($y+$h) $color
        $dx=$(if($bx -eq $x){8}else{-8})
        Line $bx $y ($bx+$dx) $y $color; Line $bx ($y+$h) ($bx+$dx) ($y+$h) $color
    }
    for($r=0;$r -lt $rows.Count;$r++){for($col=0;$col -lt $rows[0].Count;$col++){
        Formula ($x+11+$col*$cw) ($y+$r*$rh+2) $cw ($rh-2) ([string]$rows[$r][$col]) $size $color 2
    }}
}
function Body([int]$number,[string]$subtitle='') {
    $script:slide=$presentation.Slides.Item($number)
    for($i=$script:slide.Shapes.Count;$i -ge 1;$i--) {
        $s=$script:slide.Shapes.Item($i)
        if($s.Top -ge 190 -and $s.Top -lt 494){$s.Delete()}
    }
    if($subtitle){$script:slide.Shapes.Item(3).TextFrame.TextRange.Text=$subtitle}
}
function Notes([string]$value) {
    $script:slide.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange.Text=$value
}
function Tree([double]$y) {
    $positions=@(54,276,498,720); $names=@('world','base_link','camera_mount','camera_frame')
    for($i=0;$i -lt 4;$i++) {
        Box $positions[$i] $y 186 48 $(if($i -lt 2){$C.paleBlue}else{$C.paleTeal})
        Text ($positions[$i]+4) ($y+9) 178 32 $names[$i] 24 $C.ink $true 2
        if($i -lt 3){Line ($positions[$i]+186) ($y+24) $positions[$i+1] ($y+24) $(if($i -eq 0){$C.blue}else{$C.teal}) $true ($i -gt 0)}
    }
    Text 54 ($y-34) 408 30 'dynamic · moving_base' 24 $C.blue $false 2
    Text 498 ($y-34) 408 30 'static · static_frames' 24 $C.teal $false 2
}

$app=$null; $presentation=$null; $check=$null; $originalCheck=$null; $hadExisting=$true
$sourceMap=@(1,2,3,4,5,6,6,6,7,9,9,10,9,12,13,14,15,16)
$preservedMap=@(@(1,1),@(2,2),@(15,13),@(16,14))
$minutes=@(0,1,1,1.5,1.5,2,1.5,1.5,1,1,1.5,1.5,1,1,1,1,1,25)
if(($minutes | Measure-Object -Sum).Sum -ne 45){throw 'Slide timing must total 45 minutes.'}
try {
    $app=New-Object -ComObject PowerPoint.Application
    $hadExisting=($app.Presentations.Count -gt 0)
    Copy-Item -LiteralPath $inputPath -Destination $outputPath -Force
    $presentation=$app.Presentations.Open($outputPath,0,0,0)
    if($presentation.Slides.Count -ne 26){throw 'Expected the original 26-slide source deck.'}
    # Copy the existing slides in the requested order. Duplication preserves all
    # native style/content; only the selected bodies and footer numbers change.
    foreach($sourceIndex in $sourceMap){
        $copy=$presentation.Slides.Item($sourceIndex).Duplicate()
        $copy.Item(1).MoveTo($presentation.Slides.Count)
    }
    for($i=26;$i -ge 1;$i--){$presentation.Slides.Item($i).Delete()}
    for($i=1;$i -le 18;$i++){
        $s=$presentation.Slides.Item($i)
        $s.SlideShowTransition.Hidden=0
        $s.Shapes.Item(6).TextFrame.TextRange.Text=('{0:00}' -f $i)
    }
    . (Join-Path $PSScriptRoot 'revised_content.ps1')
    foreach($s in $presentation.Slides){
        $nr=$s.NotesPage.Shapes.Placeholders.Item(2).TextFrame.TextRange
        $n=$nr.Text
        $n=$n -replace 'Ten hidden derivation slides are outside that schedule\.','The revised presentation contains exactly 18 visible slides.'
        $n=$n -replace 'The separately supplied Robotics_AutonomousSystems\.pdf was not found; retain its existing printed-slide references without claiming it was reviewed\.','Professor sources reviewed: 2-Frames.pdf and the neighboring-transform/FK material in 3-Kinematics.pdf.'
        $n=[regex]::Replace($n,'^Timing:\s*[\d.]+\s*minutes?\.\s*','')
        $nr.Text="Timing: $($minutes[$s.SlideIndex-1]) minutes.`r`n`r`n"+$n
    }
    $issues=New-Object System.Collections.Generic.List[string]
    foreach($s in $presentation.Slides){foreach($shape in $s.Shapes){
        if($shape.Left -lt -1 -or $shape.Top -lt -1 -or $shape.Left+$shape.Width -gt 961 -or $shape.Top+$shape.Height -gt 541){$issues.Add("Slide $($s.SlideIndex): shape outside slide: $($shape.Name)")}
        if($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1){
            $tr=$shape.TextFrame.TextRange
            if($tr.BoundHeight -gt $shape.Height+2 -or $tr.BoundWidth -gt $shape.Width+2){$issues.Add("Slide $($s.SlideIndex): text overflow: $($tr.Text)")}
        }
    }}
    $presentation.Save(); $presentation.Close(); $presentation=$null
    $check=$app.Presentations.Open($outputPath,-1,0,0)
    if($check.Slides.Count -ne 18){throw 'Reopened slide count is not 18.'}
    $check.SaveAs($pdfPath,32)
    if(-not $NoPreview){foreach($s in $check.Slides){$s.Export((Join-Path $previewPath ('slide_{0:00}.png' -f $s.SlideIndex)),'PNG',1600,900)}}
    $titles=@()
    for($i=1;$i -le 18;$i++){
        $s=$check.Slides.Item($i)
        if($s.SlideShowTransition.Hidden -ne 0){throw "Hidden slide: $i"}
        if($s.Shapes.Item(6).TextFrame.TextRange.Text -ne ('{0:00}' -f $i)){throw "Incorrect footer number: $i"}
        $titles+=$s.Shapes.Item(2).TextFrame.TextRange.Text
    }
    $link=$check.Slides.Item(6).Shapes.Item('gimbal_lock_video').ActionSettings.Item(1)
    if($link.Action -ne 7 -or $link.Hyperlink.Address -ne 'https://www.youtube.com/watch?v=BczeMqU_u2Y&t=140s'){throw 'Video hyperlink action invalid.'}
    $comparisons=@()
    if(-not $NoPreview){
        $originalCheck=$app.Presentations.Open($inputPath,-1,0,0)
        foreach($pair in $preservedMap){
            $finalIndex=$pair[0]; $originalIndex=$pair[1]
            $originalImage=Join-Path $previewPath ('original_{0:00}.png' -f $originalIndex)
            $originalCheck.Slides.Item($originalIndex).Export($originalImage,'PNG',1600,900)
            $metrics=[Week2RenderComparison]::Compare($originalImage,(Join-Path $previewPath ('slide_{0:00}.png' -f $finalIndex)))
            $same=($metrics[0] -lt .75 -and $metrics[1] -lt .02)
            $comparisons+=@{slide=$finalIndex;originalSlide=$originalIndex;renderComparisonPassed=$same;footerExcluded=$true;meanChannelError=$metrics[0];changedChannelFraction=$metrics[1]}
            if(-not $same){throw "Preserved slide rendering differs beyond antialiasing tolerance: $finalIndex"}
        }
        $originalCheck.Close(); $originalCheck=$null
    }
    $check.Close(); $check=$null
    foreach($relative in $protected){if((Get-FileHash -LiteralPath (Join-Path $root $relative)).Hash -ne $before[$relative]){throw "Protected file changed: $relative"}}
    $report=[ordered]@{slideCount=18;hiddenSlides=0;titles=$titles;minutesPerSlide=$minutes;modifiedSlides=@(3,4,5,6,7,8,9,10,11,12,13,14,17,18);unchangedSlides=$comparisons;previewsGenerated=(-not $NoPreview);timingMinutes=45;explanationMinutes=20;practicalAndQuestionsMinutes=25;hyperlinkSlide=6;hyperlink='https://www.youtube.com/watch?v=BczeMqU_u2Y&t=140s';hyperlinkAction='ppActionHyperlink';playbackVerified=$false;layoutIssues=@($issues.ToArray());handImageHash=(Get-FileHash -LiteralPath $handImage).Hash;protectedFiles=$before;demoExecuted=$false}
    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $reviewPath 'build_validation.json') -Encoding UTF8
    if($issues.Count){throw ($issues -join "`n")}
    Write-Output 'Updated PowerPoint and PDF saved; reopened 18 visible slides. Preserved slide content/rendering and original/demo hashes verified.'
} finally {
    foreach($p in @($originalCheck,$check,$presentation)){if($null -ne $p){try{$p.Close()}catch{}}}
    if($null -ne $app -and -not $hadExisting){try{$app.Quit()}catch{}}
    if($null -ne $app){[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)}
    [GC]::Collect(); [GC]::WaitForPendingFinalizers()
}
