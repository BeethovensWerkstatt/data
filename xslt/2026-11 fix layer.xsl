<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:uuid="java:java.util.UUID" exclude-result-prefixes="xs math mei uuid" version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Dieses XSLT bringt die @n-Attribute aller <layer> Elemente, die durch den MuseScore Export falsch angelegt wurden, in eine sinnvolle Ordnung, beginnent mit n="1" -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mei:layer/@n">
        <xsl:attribute name="n">
            <xsl:value-of select="count(../preceding-sibling::mei:layer) + 1"/>
        </xsl:attribute>
    </xsl:template>
    
</xsl:stylesheet>
