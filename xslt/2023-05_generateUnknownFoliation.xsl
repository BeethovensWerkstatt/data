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
            <xd:p><xd:b>Created on:</xd:b> May 8, 2023</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>Temporary XSLT that will generate unknownFoliation elements from surfaces, and prepare some metadata.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="mei:foliaDesc">
        <xsl:variable name="surfaces" select="//mei:surface" as="element(mei:surface)*"/>
        <xsl:variable name="foliumCount" select="round(count($surfaces) div 2) cast as xs:integer" as="xs:integer"/>
        <xsl:copy>
            <xsl:for-each select="1 to $foliumCount">
                <xsl:variable name="folium.pos" select="position()" as="xs:integer"/>
                <xsl:variable name="surface.recto.pos" select="$folium.pos * 2 - 1" as="xs:integer"/>
                <xsl:variable name="surface.verso.pos" select="$surface.recto.pos + 1" as="xs:integer"/>
                <unknownFoliation xmlns="http://www.music-encoding.org/ns/mei" 
                    xml:id="u{uuid:randomUUID()}"
                    recto="#{$surfaces[$surface.recto.pos]/@xml:id}"
                    verso="#{$surfaces[$surface.verso.pos]/@xml:id}"/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>