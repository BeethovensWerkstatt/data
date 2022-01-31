<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs math xd mei uuid"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 31, 2022</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This stylesheet transforms tuplet brackets to slurs, for use in BW mod3 proofreading.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="no"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Start template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This adds a slur for every tuplet bracket.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:measure">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            
            <xsl:for-each select=".//mei:tuplet[@bracket.visible = 'true']">
                <xsl:variable name="first" select="(.//mei:note)[1]" as="element(mei:note)"/>
                <xsl:variable name="last" select="(.//mei:note)[last()]" as="element(mei:note)"/>
                <slur xmlns="http://www.music-encoding.org/ns/mei"
                    xml:id="s{uuid:randomUUID()}"
                    startid="#{$first/@xml:id}"
                    endid="#{$last/@xml:id}"
                    curvedir="{@bracket.place}"
                    staff="{ancestor::mei:staff/@n}"
                    color="red"/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This is converting all brackets to slurs, so brackets should not be shown anymore.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:tuplet/@bracket.visible">
        <xsl:attribute name="bracket.visible" select="'false'"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Non-visible brackets have no place…</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:tuplet/@bracket.place"/>
        
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>A simple, mode-sensitive copy-template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>