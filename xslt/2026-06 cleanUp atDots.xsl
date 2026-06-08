<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:uuid="java:java.util.UUID" exclude-result-prefixes="xs math mei uuid" version="3.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="inPath" select="document-uri(/)" as="xs:string"/>

    <xsl:template match="/">
        <xsl:if test="contains($inPath, '/annotatedTranscripts/')">
            <xsl:variable name="outPath" select="replace($inPath, '/annotatedTranscripts/', '/annotatedTranscriptsNew/')" as="xs:string"/>
            <xsl:result-document href="{$outPath}">
                <xsl:apply-templates select="node()"/>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mei:*[@dots][local-name() = ('note', 'rest')]">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <xsl:variable name="dotCount" select="number(@dots) cast as xs:integer" as="xs:integer"/>
            <xsl:variable name="corresps" select="
                    if (@dot-corresp) then
                        (tokenize(normalize-space(@dot-corresp), ' '))
                    else
                        ()" as="xs:string*"/>
            <xsl:for-each select="(1 to $dotCount)">
                <xsl:variable name="i" select="position()" as="xs:integer"/>
                <dot xmlns="http://www.music-encoding.org/ns/mei" xml:id="d{uuid:randomUUID()}">
                    <xsl:if test="exists($corresps) and exists($corresps[$i])">
                        <xsl:attribute name="corresp" select="$corresps[$i]"/>
                    </xsl:if>
                </dot>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!--<xsl:template match="mei:bTrem/@dots"/>-->

    <!--<xsl:template match="mei:chord/@dots"/>-->
    <xsl:template match="mei:chord/@dot-corresp"/>

    <xsl:template match="mei:note/@dots"/>
    <xsl:template match="mei:note/@dot-corresp"/>

    <xsl:template match="mei:rest/@dots"/>
    <xsl:template match="mei:rest/@dot-corresp"/>

    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
