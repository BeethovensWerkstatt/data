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
    
    <xsl:variable name="scaleFactor" select="3" as="xs:double"/>
    
    <xsl:variable name="root" select="/" as="node()"/>
    <xsl:variable name="page.width" select="xs:double($root//svg:svg/replace(@width,'px','')) * $scaleFactor" as="xs:double"/>
    <xsl:variable name="page.height" select="xs:double($root//svg:svg/replace(@height,'px','')) * $scaleFactor" as="xs:double"/>
    <!--<xsl:variable name="page.leftmar" select="tools:getCoordinates($root//@facs,'min')[1]" as="xs:double"/>
    <xsl:variable name="page.rightmar" select="round($page.width - tools:getCoordinates($root//@facs,'max')[1],5)" as="xs:double"/>-->
    <xsl:variable name="page.leftmar" select="0" as="xs:double"/>
    <xsl:variable name="page.rightmar" select="0" as="xs:double"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()" mode="mei"/>
        <xsl:message select="'page dimensions: width=' || $page.width || ', height=' || $page.height || ', lm=' || $page.leftmar || ' rm=' || $page.rightmar"/>
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
            <xsl:attribute name="ulx" select="tools:getCoordinates(@facs,'avg')[1]"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:staff[.//@facs]" mode="mei">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="uly" select="round($page.height - tools:getCoordinates(.//@facs,'min')[2],5)"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:system[.//@facs]" mode="mei">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="uly" select="round($page.height - tools:getCoordinates(.//@facs,'min')[2],5)"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:measure[.//@facs]" mode="mei">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="ulx" select="tools:getCoordinates(.//@facs,'min')[1]"/>
            <xsl:attribute name="lrx" select="tools:getCoordinates(.//@facs,'max')[1]"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:pages/@type" mode="mei">
        <xsl:attribute name="type" select="'transcription'"/>
    </xsl:template>
    
    <xsl:template match="mei:page" mode="mei">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="page.width" select="$page.width"/>
            <xsl:attribute name="page.height" select="$page.height"/>
            <xsl:attribute name="page.leftmar" select="$page.leftmar"/>
            <xsl:attribute name="page.rightmar" select="$page.rightmar"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:function name="tools:getCoordinates" as="xs:double+">
        <xsl:param name="shapes" as="xs:string*"/>
        <xsl:param name="which" as="xs:string"/><!-- allowed values: min, max, avg -->
        
        <xsl:variable name="shape.ids" select="tokenize(replace(normalize-space(string-join($shapes,' ')),'#',''),' ')" as="xs:string*"/>
        <xsl:variable name="shapes" as="node()*">
            <xsl:for-each select="$shape.ids">
                <xsl:variable name="current.shape.id" select="." as="xs:string"/>
                <xsl:sequence select="$root/key('path',$current.shape.id)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="boxes" as="node()*">
            <xsl:for-each select="$shapes">
                <xsl:variable name="M" select="substring-before(@d,'c')" as="xs:string"/>
                <xsl:variable name="x" select="substring(substring-before($M,','),2)" as="xs:string"/>
                <xsl:variable name="y" select="substring-after($M,',')" as="xs:string"/>
                <svg:circle cx="{$x}" cy="{$y}" r="0"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="x" as="xs:double">
            <xsl:choose>
                <xsl:when test="$which = 'avg'">
                    <xsl:value-of select="round(avg($boxes//xs:double(@cx)),5) * $scaleFactor"/>
                </xsl:when>
                <xsl:when test="$which = 'min'">
                    <xsl:value-of select="round(min($boxes//xs:double(@cx)),5) * $scaleFactor"/>
                </xsl:when>
                <xsl:when test="$which = 'max'">
                    <xsl:value-of select="round(max($boxes//xs:double(@cx)),5) * $scaleFactor"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="y" as="xs:double">
            <xsl:choose>
                <xsl:when test="$which = 'avg'">
                    <xsl:value-of select="round(avg($boxes//xs:double(@cy)),5) * $scaleFactor"/>
                </xsl:when>
                <xsl:when test="$which = 'min'">
                    <xsl:value-of select="round(min($boxes//xs:double(@cy)),5) * $scaleFactor"/>
                </xsl:when>
                <xsl:when test="$which = 'max'">
                    <xsl:value-of select="round(max($boxes//xs:double(@cy)),5) * $scaleFactor"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$x, $y"/>
    </xsl:function>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>