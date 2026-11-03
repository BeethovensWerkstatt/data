<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:uuid="java:java.util.UUID" exclude-result-prefixes="xs math mei uuid" version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Dieses XSLT platziert alle <dynam> Elemente (außer Sforzandi) zwischen die Systeme. Diese Maßnahme ist als Vorarbeit gedacht und wird im Nachhinein händisch überarbeitet. -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>  
 
    <xsl:template match="mei:dynam[not(. = 'sf')]">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@place, @staff)"/>
            
            <xsl:attribute name="place" select="'between'"/>
            <xsl:attribute name="staff" select="'1 2'"/>
            
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
