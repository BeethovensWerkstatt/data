<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:bwu="https://www.beethovens-werkstatt.de/ns/utils"
    exclude-result-prefixes="xs math mei svg bwu"
    version="3.0">
    
    <xsl:function name="bwu:parse-facsimile-target" as="map(*)">
        <xsl:param name="target" as="xs:string"/>
        <!-- Extract xywh -->
        <xsl:variable name="xywh" select="analyze-string($target, 'xywh=(\d+),(\d+),(\d+),(\d+)')/xsl:match"/>
        <xsl:variable name="x" select="if ($xywh) then xs:double($xywh/xsl:group[1]) else 0"/>
        <xsl:variable name="y" select="if ($xywh) then xs:double($xywh/xsl:group[2]) else 0"/>
        <xsl:variable name="w" select="if ($xywh) then xs:double($xywh/xsl:group[3]) else 0"/>
        <xsl:variable name="h" select="if ($xywh) then xs:double($xywh/xsl:group[4]) else 0"/>
        <!-- Extract rotate -->
        <xsl:variable name="rot" select="analyze-string($target, 'rotate=(\d+(?:\.\d+)?)')/xsl:match"/>
        <xsl:variable name="rotate" select="if ($rot) then xs:double($rot/xsl:group[1]) else 0"/>
        <!-- Center -->
        <xsl:variable name="cx" select="$x + $w div 2"/>
        <xsl:variable name="cy" select="$y + $h div 2"/>
        <!-- Rectangle inscribed in bounding box -->
        <xsl:variable name="theta" select="$rotate * math:pi() div 180"/>
        <xsl:variable name="c" select="abs(math:cos($theta))"/>
        <xsl:variable name="s" select="abs(math:sin($theta))"/>
        <xsl:variable name="denom" select="$c * $c - $s * $s"/>
        <xsl:variable name="width" select="if ($rotate != 0 and abs($denom) gt 1e-8) 
            then ($w * $c - $h * $s) div $denom 
            else $w"/>
        <xsl:variable name="height" select="if ($rotate != 0 and abs($denom) gt 1e-8) 
            then ($h * $c - $w * $s) div $denom 
            else $h"/>
        <xsl:variable name="hw" select="$width div 2"/>
        <xsl:variable name="hh" select="$height div 2"/>
        <!-- Corners: top-left, top-right, bottom-right, bottom-left -->
        <xsl:variable name="corners" as="map(*)*">
            <xsl:sequence select="
                bwu:rotate-and-translate(-$hw, -$hh, $cx, $cy, $theta),
                bwu:rotate-and-translate($hw, -$hh, $cx, $cy, $theta),
                bwu:rotate-and-translate($hw, $hh, $cx, $cy, $theta),
                bwu:rotate-and-translate(-$hw, $hh, $cx, $cy, $theta)
                "/>
        </xsl:variable>
        <xsl:sequence select="
            map{
            'x': $x,
            'y': $y,
            'w': $w,
            'h': $h,
            'rotate': $rotate,
            'rect': map{
            'cx': $cx,
            'cy': $cy,
            'width': $width,
            'height': $height,
            'corners': $corners
            }
            }
            "/>
    </xsl:function>
    
    <!-- Helper function for rotation and translation -->
    <xsl:function name="bwu:rotate-and-translate" as="map(*)">
        <!-- $point-x, $point-y: coordinates of the point to rotate -->
        <!-- $center-x, $center-y: coordinates of the center point to rotate around -->
        <!-- $degrees: rotation angle in degrees (positive = counterclockwise) -->
        <xsl:param name="point-x" as="xs:double"/>
        <xsl:param name="point-y" as="xs:double"/>
        <xsl:param name="center-x" as="xs:double"/>
        <xsl:param name="center-y" as="xs:double"/>
        <xsl:param name="degrees" as="xs:double"/>
        
        <!-- Convert degrees to radians -->
        <xsl:variable name="theta" select="$degrees * math:pi() div 180"/>
        
        <!-- Translate point to origin (relative to center) -->
        <xsl:variable name="dx" select="$point-x - $center-x"/>
        <xsl:variable name="dy" select="$point-y - $center-y"/>
        
        <!-- Apply rotation matrix -->
        <xsl:variable name="cos-theta" select="math:cos($theta)"/>
        <xsl:variable name="sin-theta" select="math:sin($theta)"/>
        <xsl:variable name="rotated-x" select="$dx * $cos-theta - $dy * $sin-theta"/>
        <xsl:variable name="rotated-y" select="$dx * $sin-theta + $dy * $cos-theta"/>
        
        <!-- Translate back to original coordinate system -->
        <xsl:variable name="final-x" select="$rotated-x + $center-x"/>
        <xsl:variable name="final-y" select="$rotated-y + $center-y"/>
        
        <xsl:sequence select="map{ 'x': $final-x, 'y': $final-y }"/>
    </xsl:function>
    
    <xsl:function name="bwu:mm-to-px" as="map(*)">
        <!-- $mm-x, $mm-y: point in mm on the page -->
        <!-- $page-mm-width, $page-mm-height: physical page size in mm -->
        <!-- $target: facsimile target string, e.g. "...jpg#xywh=195,186,7159,5652&rotate=0" -->
        
        <!-- usage: <xsl:variable name="pt-px" select="util:mm-to-px($mm-x, $mm-y, $page-mm-width, $page-mm-height, $target)"/>
           $pt-px?x and $pt-px?y are the pixel coordinates -->
        <xsl:param name="mm-x" as="xs:double"/>
        <xsl:param name="mm-y" as="xs:double"/>
        <xsl:param name="page-mm-width" as="xs:double"/>
        <xsl:param name="page-mm-height" as="xs:double"/>
        <xsl:param name="target" as="xs:string"/>
        
        <!-- Parse facsimile target -->
        <xsl:variable name="ft" select="bwu:parse-facsimile-target($target)"/>
        <xsl:variable name="rect" select="$ft?rect"/>
        <xsl:variable name="cx" select="$rect?cx"/>
        <xsl:variable name="cy" select="$rect?cy"/>
        <xsl:variable name="width" select="$rect?width"/>
        <xsl:variable name="height" select="$rect?height"/>
        <xsl:variable name="theta" select="$ft?rotate * math:pi() div 180"/>
        
        <!-- Scale mm to px in unrotated rectangle -->
        <xsl:variable name="px-x0" select="($mm-x div $page-mm-width) * $width"/>
        <xsl:variable name="px-y0" select="($mm-y div $page-mm-height) * $height"/>
        
        <!-- Center relative -->
        <xsl:variable name="dx" select="$px-x0 - ($width div 2)"/>
        <xsl:variable name="dy" select="$px-y0 - ($height div 2)"/>
        
        <!-- Rotate by theta, then translate to image space -->
        <xsl:variable name="px-x" select="$dx * math:cos($theta) - $dy * math:sin($theta) + $cx"/>
        <xsl:variable name="px-y" select="$dx * math:sin($theta) + $dy * math:cos($theta) + $cy"/>
        
        <xsl:sequence select="map{ 'x': $px-x, 'y': $px-y }"/>
    </xsl:function>
    
    
    
    
    <xsl:function name="bwu:getPxWidth" as="xs:double">
        <xsl:param name="target" as="xs:string"/>
        
        <!-- Extract xywh values -->
        <xsl:variable name="xywh" select="$target => substring-after('#xywh=') => substring-before('&amp;') => tokenize(',')" as="xs:string+"/>
        <xsl:variable name="x" select="xs:double($xywh[1])"/>
        <xsl:variable name="y" select="xs:double($xywh[2])"/>
        <xsl:variable name="w" select="xs:double($xywh[3])"/>
        <xsl:variable name="h" select="xs:double($xywh[4])"/>
        
        <!-- Extract rotate value (default 0) -->
        <xsl:variable name="rot" select="analyze-string($target, 'rotate=(\d+(?:\.\d+)?)')"/>
        <xsl:variable name="rotate" select="if ($rot/matching-group) then xs:double($rot/matching-group[1]) else 0"/>
        
        <!-- Calculate center -->
        <xsl:variable name="cx" select="$x + $w div 2"/>
        <xsl:variable name="cy" select="$y + $h div 2"/>
        
        <!-- Calculate theta in radians -->
        <xsl:variable name="theta" select="$rotate * math:pi() div 180"/>
        <xsl:variable name="c" select="abs(math:cos($theta))"/>
        <xsl:variable name="s" select="abs(math:sin($theta))"/>
        <xsl:variable name="denom" select="$c * $c - $s * $s"/>
        
        <!-- Inscribed rectangle width/height -->
        <xsl:variable name="width" select="if ($rotate = 0 or abs($denom) lt 1e-8) then $w else ($w * $c - $h * $s) div $denom"/>
        <xsl:variable name="height" select="if ($rotate = 0 or abs($denom) lt 1e-8) then $h else ($h * $c - $w * $s) div $denom"/>
        
        <!-- Calculate corners (rotated rectangle) -->
        <xsl:variable name="hw" select="$width div 2"/>
        <xsl:variable name="hh" select="$height div 2"/>
        <xsl:variable name="corners" as="map(xs:string, xs:double)*">
            <xsl:map>
                <xsl:map-entry key="'x'" select="(-$hw) * math:cos($theta) - (-$hh) * math:sin($theta) + $cx"/>
                <xsl:map-entry key="'y'" select="(-$hw) * math:sin($theta) + (-$hh) * math:cos($theta) + $cy"/>
            </xsl:map>
            <xsl:map>
                <xsl:map-entry key="'x'" select="($hw) * math:cos($theta) - (-$hh) * math:sin($theta) + $cx"/>
                <xsl:map-entry key="'y'" select="($hw) * math:sin($theta) + (-$hh) * math:cos($theta) + $cy"/>
            </xsl:map>
            <xsl:map>
                <xsl:map-entry key="'x'" select="($hw) * math:cos($theta) - ($hh) * math:sin($theta) + $cx"/>
                <xsl:map-entry key="'y'" select="($hw) * math:sin($theta) + ($hh) * math:cos($theta) + $cy"/>
            </xsl:map>
            <xsl:map>
                <xsl:map-entry key="'x'" select="(-$hw) * math:cos($theta) - ($hh) * math:sin($theta) + $cx"/>
                <xsl:map-entry key="'y'" select="(-$hw) * math:sin($theta) + ($hh) * math:cos($theta) + $cy"/>
            </xsl:map>
        </xsl:variable>
        
        <!-- Return as map -->
        <xsl:sequence select="$width"/>
    </xsl:function>
   

    <!-- SVG bbox -->
    <!--<xsl:function name="bwu:svg-path-bbox" as="map(*)">
        <!-\- $path-d: the 'd' attribute value from an SVG path element -\->
        <xsl:param name="path-d" as="xs:string"/>
        
        <!-\- Initialize bounds -\->
        <xsl:variable name="initial-bounds" select="map{
            'min-x': xs:double('INF'),
            'min-y': xs:double('INF'), 
            'max-x': xs:double('-INF'),
            'max-y': xs:double('-INF')
            }"/>
        
        <!-\- Tokenize the path data -\->
        <xsl:variable name="tokens" select="tokenize(normalize-space($path-d), '\s+')"/>
        
        <!-\- Process tokens and extract coordinates -\->
        <xsl:variable name="bounds" select="bwu:process-path-tokens($tokens, $initial-bounds, 0, 0, '')"/>
        
        <!-\- Calculate final bounding box -\->
        <xsl:variable name="width" select="$bounds?max-x - $bounds?min-x"/>
        <xsl:variable name="height" select="$bounds?max-y - $bounds?min-y"/>
        
        <xsl:sequence select="map{
            'x': $bounds?min-x,
            'y': $bounds?min-y,
            'width': $width,
            'height': $height,
            'min-x': $bounds?min-x,
            'min-y': $bounds?min-y,
            'max-x': $bounds?max-x,
            'max-y': $bounds?max-y
            }"/>
    </xsl:function>
    
    <!-\- Helper function to process path tokens recursively -\->
    <xsl:function name="bwu:process-path-tokens" as="map(*)">
        <xsl:param name="tokens" as="xs:string*"/>
        <xsl:param name="bounds" as="map(*)"/>
        <xsl:param name="current-x" as="xs:double"/>
        <xsl:param name="current-y" as="xs:double"/>
        <xsl:param name="last-command" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="empty($tokens)">
                <xsl:sequence select="$bounds"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="token" select="$tokens[1]"/>
                <xsl:variable name="remaining" select="subsequence($tokens, 2)"/>
                
                <xsl:choose>
                    <!-\- Command token (letter) -\->
                    <xsl:when test="matches($token, '^[a-zA-Z]$')">
                        <xsl:sequence select="bwu:process-path-tokens($remaining, $bounds, $current-x, $current-y, $token)"/>
                    </xsl:when>
                    
                    <!-\- Numeric token - process based on last command -\->
                    <xsl:otherwise>
                        <xsl:choose>
                            <!-\- MoveTo, LineTo, SmoothCurveTo endpoint -\->
                            <xsl:when test="$last-command = ('M', 'L', 'T')">
                                <xsl:variable name="x" select="xs:double($token)"/>
                                <xsl:variable name="y" select="xs:double($remaining[1])"/>
                                <xsl:variable name="new-bounds" select="bwu:update-bounds($bounds, $x, $y)"/>
                                <xsl:sequence select="bwu:process-path-tokens(subsequence($remaining, 2), $new-bounds, $x, $y, $last-command)"/>
                            </xsl:when>
                            
                            <!-\- Horizontal line -\->
                            <xsl:when test="$last-command = 'H'">
                                <xsl:variable name="x" select="xs:double($token)"/>
                                <xsl:variable name="new-bounds" select="bwu:update-bounds($bounds, $x, $current-y)"/>
                                <xsl:sequence select="bwu:process-path-tokens($remaining, $new-bounds, $x, $current-y, $last-command)"/>
                            </xsl:when>
                            
                            <!-\- Vertical line -\->
                            <xsl:when test="$last-command = 'V'">
                                <xsl:variable name="y" select="xs:double($token)"/>
                                <xsl:variable name="new-bounds" select="bwu:update-bounds($bounds, $current-x, $y)"/>
                                <xsl:sequence select="bwu:process-path-tokens($remaining, $new-bounds, $current-x, $y, $last-command)"/>
                            </xsl:when>
                            
                            <!-\- Cubic Bezier curve -\->
                            <xsl:when test="$last-command = 'C'">
                                <!-\- Process all 6 coordinates (3 points) -\->
                                <xsl:variable name="coords" select="subsequence($tokens, 1, 6)"/>
                                <xsl:variable name="new-bounds" select="bwu:update-bounds-multiple($bounds, $coords)"/>
                                <xsl:variable name="end-x" select="xs:double($coords[5])"/>
                                <xsl:variable name="end-y" select="xs:double($coords[6])"/>
                                <xsl:sequence select="bwu:process-path-tokens(subsequence($tokens, 7), $new-bounds, $end-x, $end-y, $last-command)"/>
                            </xsl:when>
                            
                            <!-\- Quadratic Bezier curve -\->
                            <xsl:when test="$last-command = ('Q', 'S')">
                                <!-\- Process 4 coordinates (2 points) -\->
                                <xsl:variable name="coords" select="subsequence($tokens, 1, 4)"/>
                                <xsl:variable name="new-bounds" select="bwu:update-bounds-multiple($bounds, $coords)"/>
                                <xsl:variable name="end-x" select="xs:double($coords[3])"/>
                                <xsl:variable name="end-y" select="xs:double($coords[4])"/>
                                <xsl:sequence select="bwu:process-path-tokens(subsequence($tokens, 5), $new-bounds, $end-x, $end-y, $last-command)"/>
                            </xsl:when>
                            
                            <!-\- Close path or unknown command -\->
                            <xsl:otherwise>
                                <xsl:sequence select="bwu:process-path-tokens($remaining, $bounds, $current-x, $current-y, $last-command)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-\- Helper to update bounds with a single point -\->
    <xsl:function name="bwu:update-bounds" as="map(*)">
        <xsl:param name="bounds" as="map(*)"/>
        <xsl:param name="x" as="xs:double"/>
        <xsl:param name="y" as="xs:double"/>
        
        <xsl:sequence select="map{
            'min-x': min(($bounds?min-x, $x)),
            'min-y': min(($bounds?min-y, $y)),
            'max-x': max(($bounds?max-x, $x)),
            'max-y': max(($bounds?max-y, $y))
            }"/>
    </xsl:function>
    
    <!-\- Helper to update bounds with multiple coordinates -\->
    <xsl:function name="bwu:update-bounds-multiple" as="map(*)">
        <xsl:param name="bounds" as="map(*)"/>
        <xsl:param name="coords" as="xs:string*"/>
        
        <xsl:variable name="updated-bounds" select="
            fold-left(
            for $i in 1 to count($coords) idiv 2
            return (xs:double($coords[$i * 2 - 1]), xs:double($coords[$i * 2])),
            $bounds,
            function($acc, $point) { 
            bwu:update-bounds($acc, $point[1], $point[2]) 
            }
            )
            "/>
        
        <xsl:sequence select="$updated-bounds"/>
    </xsl:function>-->
    
    
    <!--<xsl:function name="bwu:svg-path-bbox-fast" as="map(*)">
        <xsl:param name="path-d" as="xs:string"/>
        
        <!-\- Extract all numbers in one pass -\->
        <xsl:variable name="numbers" select="
            for $match in analyze-string($path-d, '-?\d+\.?\d*')/xsl:match
            return xs:double($match)
            "/>
        
        <!-\- Simple min/max calculation -\->
        <xsl:variable name="x-coords" select="$numbers[position() mod 2 = 1]"/>
        <xsl:variable name="y-coords" select="$numbers[position() mod 2 = 0]"/>
        
        <xsl:sequence select="map{
            'min-x': min($x-coords),
            'min-y': min($y-coords), 
            'max-x': max($x-coords),
            'max-y': max($y-coords)
            }"/>
    </xsl:function>-->
   
    <!--
    <!-\-
    Utility: Parse facsimile target string (xywh, rotate)
    Returns map with x, y, w, h, rotate, cx, cy, width, height, corners
    Example: ...jpg#xywh=195,186,7159,5652&rotate=0
  -\->
    <xsl:function name="bwu:parse-facsimile-target" as="map(*)">
        <xsl:param name="target" as="xs:string"/>
        <xsl:variable name="xywh" select="replace($target, '.*xywh=([0-9]+),([0-9]+),([0-9]+),([0-9]+).*', '$1,$2,$3,$4')"/>
        <xsl:variable name="xywh-parts" select="tokenize($xywh, ',')"/>
        <xsl:variable name="x" select="number($xywh-parts[1])"/>
        <xsl:variable name="y" select="number($xywh-parts[2])"/>
        <xsl:variable name="w" select="number($xywh-parts[3])"/>
        <xsl:variable name="h" select="number($xywh-parts[4])"/>
        <xsl:variable name="rotate" select="if (matches($target, 'rotate=([0-9.]+)')) then number(replace($target, '.*rotate=([0-9.]+).*', '$1')) else 0"/>
        <xsl:variable name="theta" select="$rotate * math:pi() div 180"/>
        <xsl:variable name="c" select="abs(math:cos($theta))"/>
        <xsl:variable name="s" select="abs(math:sin($theta))"/>
        <xsl:variable name="denom" select="$c * $c - $s * $s"/>
        <xsl:variable name="width" select="if ($rotate ne 0 and abs($denom) gt 1e-8) then (($w * $c - $h * $s) div $denom) else $w"/>
        <xsl:variable name="height" select="if ($rotate ne 0 and abs($denom) gt 1e-8) then (($h * $c - $w * $s) div $denom) else $h"/>
        <xsl:variable name="cx" select="$x + $w div 2"/>
        <xsl:variable name="cy" select="$y + $h div 2"/>
        <xsl:variable name="corners" as="element()*">
            <corner x="{-1 * $width div 2}" y="{-1 * $height div 2}"/>
            <corner x="{$width div 2}" y="{-1 * $height div 2}"/>
            <corner x="{$width div 2}" y="{$height div 2}"/>
            <corner x="{-1 * $width div 2}" y="{$height div 2}"/>
        </xsl:variable>
        <xsl:variable name="rotated-corners" as="map(*)*">
            <xsl:for-each select="$corners">
                <xsl:variable name="ptx" select="number(@x)"/>
                <xsl:variable name="pty" select="number(@y)"/>
                <xsl:variable name="rx" select="$ptx * math:cos($theta) - $pty * math:sin($theta) + $cx"/>
                <xsl:variable name="ry" select="$ptx * math:sin($theta) + $pty * math:cos($theta) + $cy"/>
                <xsl:sequence select="map{'x': $rx, 'y': $ry}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="map{
            'x': $x,
            'y': $y,
            'w': $w,
            'h': $h,
            'rotate': $rotate,
            'cx': $cx,
            'cy': $cy,
            'width': $width,
            'height': $height,
            'corners': $rotated-corners
            }"/>
    </xsl:function>
    
    <!-\- Rotate a point (x, y) around (cx, cy) by theta degrees -\->
    <xsl:function name="bwu:rotate-point" as="map(*)">
        <xsl:param name="x" as="xs:double"/>
        <xsl:param name="y" as="xs:double"/>
        <xsl:param name="cx" as="xs:double"/>
        <xsl:param name="cy" as="xs:double"/>
        <xsl:param name="theta" as="xs:double"/>
        <xsl:variable name="rad" select="$theta * math:pi() div 180"/>
        <xsl:variable name="dx" select="$x - $cx"/>
        <xsl:variable name="dy" select="$y - $cy"/>
        <xsl:variable name="rx" select="$dx * math:cos($rad) - $dy * math:sin($rad) + $cx"/>
        <xsl:variable name="ry" select="$dx * math:sin($rad) + $dy * math:cos($rad) + $cy"/>
        <xsl:sequence select="map{'x': $rx, 'y': $ry}"/>
    </xsl:function>
    
    <!-\- Given rastrum geometry, loc, vu, compute the (x, y) position of a loc on the staff (in px, after rotation) -\->
    <xsl:function name="bwu:rastrum-loc-to-point" as="map(*)">
        <xsl:param name="rastrum-x" as="xs:double"/>
        <xsl:param name="rastrum-y" as="xs:double"/>
        <xsl:param name="loc" as="xs:double"/>
        <xsl:param name="vu" as="xs:double"/>
        <xsl:param name="rastrum-rotate" as="xs:double"/>
        <xsl:param name="x" as="xs:double"/>
        <!-\- Convention: rastrum-y is the top staff line (loc=8), loc=0 is bottom line -\->
        <xsl:variable name="y0" select="$rastrum-y + (8 - $loc) * $vu"/>
        <xsl:sequence select="bwu:rotate-point($x, $y0, $rastrum-x, $rastrum-y, $rastrum-rotate)"/>
    </xsl:function>
    
    <!-\- Main function: height from loc to bbox edge in staff direction, in integer vu -\->
    <xsl:function name="bwu:feature-height-vu" as="xs:integer">
        <xsl:param name="bbox" as="map(*)"/>
        <xsl:param name="loc" as="xs:double"/>
        <xsl:param name="x" as="xs:double"/>
        <xsl:param name="direction" as="xs:string"/>
        <xsl:param name="rastrum" as="map(*)"/>
        <xsl:param name="page-rotate" as="xs:double"/>
        <!-\- Step 1: Compute the (x, y) of the loc position on the staff, in page coordinates -\->
        <xsl:variable name="loc-pt"
            select="bwu:rastrum-loc-to-point(
            $rastrum('x'), $rastrum('y'), $loc, $rastrum('vu'), $rastrum('rotate') + $page-rotate, $x
            )"/>
        <!-\- Step 2: Get bbox corners (after page rotation) -\->
        <xsl:variable name="cx" select="$bbox('x') + $bbox('width') div 2"/>
        <xsl:variable name="cy" select="$bbox('y') + $bbox('height') div 2"/>
        <xsl:variable name="bbox-corners" as="map(*)*">
            <xsl:for-each select="(0,1,2,3)">
                <xsl:variable name="dx" select="(if (position() = 1 or position() = 4) then -1 else 1) * $bbox('width') div 2"/>
                <xsl:variable name="dy" select="(if (position() = 1 or position() = 2) then -1 else 1) * $bbox('height') div 2"/>
                <xsl:sequence select="bwu:rotate-point($cx + $dx, $cy + $dy, $cx, $cy, $page-rotate)"/>
            </xsl:for-each>
        </xsl:variable>
        <!-\- Step 3: Compute the staff direction vector (unit vector, up or down) -\->
        <xsl:variable name="theta" select="($rastrum('rotate') + $page-rotate) * math:pi() div 180"/>
        <xsl:variable name="dir-vx" select="0"/>
        <xsl:variable name="dir-vy" select="if ($direction='up') then -1 else 1"/>
        <xsl:variable name="ux" select="$dir-vx * math:cos($theta) - $dir-vy * math:sin($theta)"/>
        <xsl:variable name="uy" select="$dir-vx * math:sin($theta) + $dir-vy * math:cos($theta)"/>
        <xsl:variable name="norm" select="math:sqrt($ux * $ux + $uy * $uy)"/>
        <xsl:variable name="uxn" select="$ux div $norm"/>
        <xsl:variable name="uyn" select="$uy div $norm"/>
        <!-\- Step 4: Project bbox corners onto the staff direction, relative to loc-pt -\->
        <xsl:variable name="loc-x" select="$loc-pt('x')"/>
        <xsl:variable name="loc-y" select="$loc-pt('y')"/>
        <xsl:variable name="projections" as="xs:double*">
            <xsl:for-each select="$bbox-corners">
                <xsl:variable name="dx" select=".('x') - $loc-x"/>
                <xsl:variable name="dy" select=".('y') - $loc-y"/>
                <xsl:sequence select="$dx * $uxn + $dy * $uyn"/>
            </xsl:for-each>
        </xsl:variable>
        <!-\- Step 5: For "up", take the minimum positive projection; for "down", the maximum negative projection -\->
        <xsl:variable name="height-px"
            select="if ($direction='up')
            then min($projections[. ge 0])
            else abs(max($projections[. le 0]))"/>
        <!-\- Step 6: Always ensure non-negative, convert px to integer vu -\->
        <xsl:sequence select="if (exists($height-px)) then round($height-px div $rastrum('vu')) else 0"/>
    </xsl:function>-->
    
</xsl:stylesheet>