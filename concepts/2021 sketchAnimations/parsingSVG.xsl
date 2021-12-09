<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:tools="no:where"
    exclude-result-prefixes="xs math xd mei svg tools"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 4, 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This seeks to parse SVG shapes associated with a given mei element, and determine it's position for rendering with Verovio. WIP.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- TODOs: 
        * scaleFactor as relation between physical size and svg size 
        * adjust unit (in Verovio options) to match the distance between two individual staff lines in mm (between 6 and 20)
    -->
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:key name="path" match="svg:path" use="@id"/>
    
    <xsl:variable name="scaleFactor" select="1" as="xs:double"/>
    
    <xsl:variable name="root" select="/" as="node()"/>
    <xsl:variable name="pix.width" select="xs:double($root//mei:graphic/@width)" as="xs:double"/>
    <xsl:variable name="pix.height" select="xs:double($root//mei:graphic/@height)" as="xs:double"/>
    <xsl:variable name="svg.page.width" select="xs:double($root//svg:svg/replace(@width,'px',''))" as="xs:double"/>
    <xsl:variable name="svg.page.height" select="xs:double($root//svg:svg/replace(@height,'px',''))" as="xs:double"/>
    <!--<xsl:variable name="page.leftmar" select="tools:getCoordinates($root//@facs,'min')[1]" as="xs:double"/>
    <xsl:variable name="page.rightmar" select="round($page.width - tools:getCoordinates($root//@facs,'max')[1],5)" as="xs:double"/>-->
    <xsl:variable name="page.leftmar" select="0" as="xs:double"/>
    <xsl:variable name="page.rightmar" select="0" as="xs:double"/>
    
    <xsl:variable name="svg2pixFactor" select="$pix.width div $svg.page.width" as="xs:double"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()" mode="mei"/>
        
        <!--<xsl:variable name="staff" select="//mei:staff[@xml:id='syawz38']" as="element(mei:staff)"/>
        <xsl:message select="$staff"/>
        
        <xsl:message select="'pix.width: ' || $pix.width || ', page.width: ' || $svg.page.width || ', factor: ' || $svg2pixFactor"/>
        <xsl:message select="tools:getCoordinates($staff/@facs)"/>
        
        <xsl:variable name="coords" select="tools:getCoordinates($staff/@facs)"/>
        
        <root>
        <svg ulx="{$coords[1]}" uly="{$coords[2]}" lrx="{$coords[5]}" lry="{$coords[6]}"/>    
            <rect ulx="{tools:getDimension($coords[1])}" uly="{tools:getDimension($coords[2])}" lrx="{tools:getDimension($coords[5])}" lry="{tools:getDimension($coords[6])}"/>
        </root>-->
        <xsl:message select="'page dimensions: width=' || $svg.page.width || ', height=' || $svg.page.height || ', lm=' || $page.leftmar || ' rm=' || $page.rightmar"/>
    </xsl:template>
    
    <!-- we don't want to copy that in -->
    <xsl:template match="svg:svg" mode="mei">
        <xsl:comment select="'TODO: skipped including SVG file here, adjust for production use!'"/>
    </xsl:template>
    
    <!--<xsl:template match="mei:*[@facs]" mode="mei">
        <xsl:copy>
            <xsl:if test="@xml:id = 'testNote'">
                <xsl:variable name="pos" select="tools:getCoordinates(@facs,'avg')" as="xs:double+"/>
                <xsl:message select="'Found it here with x=' || $pos[1] || ', y=' || $pos[2]"/>
            </xsl:if>
            
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>-->
    
    <xsl:template match="mei:note[@facs]" mode="mei">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:variable name="ulx" select="tools:getDimension(tools:getCoordinates(@facs)[3])"/>
            <xsl:message select="'note ' || @xml:id || ' x avg: ' || $ulx"></xsl:message>
            <xsl:attribute name="ulx" select="$ulx"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:staff[.//@facs]" mode="mei">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="uly" select="tools:getDimension($svg.page.height - tools:getCoordinates(.//@facs)[2])"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:system[.//@facs]" mode="mei">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="uly" select="tools:getDimension($svg.page.height - tools:getCoordinates(.//@facs)[2])"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:measure[.//@facs]" mode="mei">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="ulx" select="tools:getDimension(tools:getCoordinates(.//@facs)[1])"/>
            <xsl:attribute name="lrx" select="tools:getDimension(tools:getCoordinates(.//@facs)[5])"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:pages/@type" mode="mei">
        <xsl:attribute name="type" select="'transcription'"/>
    </xsl:template>
    
    <xsl:template match="mei:page" mode="mei">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="page.width" select="tools:getDimension($svg.page.width)"/>
            <xsl:attribute name="page.height" select="tools:getDimension($svg.page.height)"/>
            <xsl:attribute name="page.leftmar" select="tools:getDimension($page.leftmar)"/>
            <xsl:attribute name="page.rightmar" select="tools:getDimension($page.rightmar)"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:function name="tools:getCoordinates" as="xs:double+">
        <xsl:param name="shapes" as="xs:string*"/>
        
        <xsl:variable name="shape.ids" select="tokenize(replace(normalize-space(string-join($shapes,' ')),'#',''),' ')" as="xs:string*"/>
        <xsl:variable name="shape.nodes" as="node()*">
            <xsl:for-each select="$shape.ids">
                <xsl:variable name="current.shape.id" select="." as="xs:string"/>
                <xsl:sequence select="$root/key('path',$current.shape.id)"/>
            </xsl:for-each>
        </xsl:variable>
        <!--<xsl:message select="'parsing shapes ' || count($shapes)  || ', shape.nodes ' || count($shape.nodes)"/>
        <xsl:message select="$shape.ids"/>-->
        <xsl:variable name="boxes" as="element(svg:circle)*">
            <xsl:for-each select="$shape.nodes">
                <xsl:variable name="M" select="substring-before(@d,'c')" as="xs:string"/>
                <xsl:variable name="x" select="substring(substring-before($M,','),2)" as="xs:string"/>
                <xsl:variable name="y" select="substring-after($M,',')" as="xs:string"/>
                
                <xsl:variable name="enriched.d" select="replace(@d,'([McC])','|$1')" as="xs:string"/>
                <xsl:variable name="all.commands" select="tokenize($enriched.d,'\|')" as="xs:string*"/>
                
                <!--<xsl:message select="'. | @d | $enriched.d | $all.commands (' || count($all.commands) || ')'"/>
                <xsl:message select="."/>
                <xsl:message select="@d"/>
                <xsl:message select="$enriched.d"/>
                <xsl:message select="$all.commands"/>-->
                <xsl:variable name="points" as="element(svg:circle)*"/>
                
                <!--<xsl:variable name="processed.commands" select="fold-left($all.commands,$points,tools:getPoints)" as="element(svg:circle)*"/>-->
                
                <xsl:variable name="all.points" select="tools:getPoints($points,$all.commands)" as="element(svg:circle)*"/>
                
                <!--<xsl:message select="'commands: ' || count($all.commands) || ' | ' || count($all.points) || $all.points[1] || ' - ' || $all.points[last()] || ' % ' || $all.points[1]"/>
                <xsl:message select="'probs: ' || count($all.points//@cy[.=''])"/>
                <xsl:message select="$all.points[.//@cy='']"></xsl:message>
                <xsl:message select="'$all.points: '"/>
                <xsl:message select="$all.points"/>-->
                
                <!--<xsl:variable name="test" select="$all.commands[2]"/>
                <xsl:message select="tools:getPoints($points,$test)"/>-->
                <xsl:sequence select="$all.points"/>
                <!--<svg:circle cx="{$x}" cy="{$y}" r="0"/>-->
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="x.min" select="round(min($boxes//xs:double(@cx)) * $scaleFactor,5)" as="xs:double"/>
        <xsl:variable name="x.avg" select="round(avg($boxes//xs:double(@cx)) * $scaleFactor,5)" as="xs:double"/>
        <xsl:variable name="x.max" select="round(max($boxes//xs:double(@cx)) * $scaleFactor,5)" as="xs:double"/>
        
        <xsl:variable name="y.min" select="round(min($boxes//xs:double(@cy[.ne''])) * $scaleFactor,5)" as="xs:double"/>
        <xsl:variable name="y.avg" select="round(avg($boxes//xs:double(@cy)) * $scaleFactor,5)" as="xs:double"/>
        <xsl:variable name="y.max" select="round(max($boxes//xs:double(@cy)) * $scaleFactor,5)" as="xs:double"/>
        
        <xsl:message select="' x: ' || $x.min || '/' || $x.avg || '/' || $x.max || ', y: ' || $y.min || '/' || $y.avg || '/' || $y.max"/>
        <xsl:sequence select="$x.min, $y.min, $x.avg, $y.avg, $x.max, $y.max"/>
    </xsl:function>
    
    <xsl:function name="tools:getPoints" as="element(svg:circle)*">
        <xsl:param name="points" as="element(svg:circle)*"/>
        <xsl:param name="all.commands" as="xs:string*"/>
        
        <xsl:variable name="token" select="head($all.commands)" as="xs:string"/>
        
        <xsl:variable name="command" select="replace(normalize-space($token),'z','')" as="xs:string"/>
        <xsl:variable name="command.type" select="substring($command,1,1)" as="xs:string"/>
        <xsl:variable name="command.tokens" select="tokenize(substring($command,2,1) || replace(substring($command,3),'-',',-'),',')" as="xs:string*"/>
        
        <!--<xsl:message select="'command type: ' || $command.type"/>-->
        
        <xsl:variable name="new.points" as="element(svg:circle)*">
            <xsl:choose>
                <xsl:when test="$command.type = 'M'">
                    <svg:circle cx="{round(xs:double($command.tokens[1]) * $scaleFactor,5)}" cy="{round(xs:double($command.tokens[2]) * $scaleFactor,5)}" r="0"/>
                </xsl:when>
                <xsl:when test="$command.type = 'c'">
                    <!--<xsl:message select="'command.c: ' || string-join($command.tokens, ' | ')"/>-->
                    <xsl:variable name="current.pos" select="$points[last()]" as="element(svg:circle)"/>
                    <xsl:variable name="x.values" select="$command.tokens[position() mod 2 = 1]" as="xs:string+"/>
                    <xsl:variable name="y.values" select="$command.tokens[position() mod 2 = 0]" as="xs:string+"/>
                    
                    <xsl:for-each select="(1 to count($x.values))">
                        <xsl:variable name="i" select="." as="xs:integer"/>
                        <xsl:variable name="x" select="xs:double($x.values[$i])" as="xs:double"/>
                        <xsl:variable name="y" select="xs:double($y.values[$i])" as="xs:double"/>
                        <svg:circle cx="{round(($current.pos/xs:double(@cx) + $x) * $scaleFactor,5)}" cy="{round(($current.pos/xs:double(@cy) + $y) * $scaleFactor,5)}" r="1.{$i}"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$command.type = 'C'">
                    <xsl:for-each select="(1 to xs:integer(count($command.tokens) div 2))">
                        <xsl:variable name="i" select="." as="xs:integer"/>
                        <svg:circle cx="{round(xs:double($command.tokens[2 * $i - 1]) * $scaleFactor,5)}" cy="{round(xs:double($command.tokens[2 * $i]) * $scaleFactor,5)}" r="2"/>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="more.commands" select="tail($all.commands)" as="xs:string*"/>
        
        <xsl:choose>
            <xsl:when test="not(empty($more.commands))">
                <xsl:sequence select="$points, tools:getPoints($new.points,$more.commands)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$points, $new.points"/>
            </xsl:otherwise>
        </xsl:choose>
            
    </xsl:function>
    
    <xsl:function name="tools:getDimension" as="xs:double">
        <xsl:param name="svg.num" as="xs:double"/>
        <xsl:sequence select="round($svg.num * $svg2pixFactor,2)"/>
    </xsl:function>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>