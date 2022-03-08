<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://wwww.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs math xd mei uuid"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 8, 2022</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This XSLT will operate on any XML file (including itself, and will generate a number of empty measures specified in the "count" parameter.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="count" select="500" as="xs:integer"/>
    <xsl:template match="/">
        
        <partOrScore xml:id="p{uuid:randomUUID()}" xmlns="http://www.music-encoding.org/ns/mei">
            <scoreDef xml:id="s{uuid:randomUUID()}">
                <staffGrp xml:id="s{uuid:randomUUID()}">
                    <staffDef n="1" lines="5" xml:id="s{uuid:randomUUID()}">
                        <label xml:id="s{uuid:randomUUID()}"></label>
                        <labelAbbr xml:id="s{uuid:randomUUID()}"></labelAbbr>
                    </staffDef>
                    <staffDef n="2" lines="5" xml:id="s{uuid:randomUUID()}">
                        <label xml:id="s{uuid:randomUUID()}"></label>
                        <labelAbbr xml:id="s{uuid:randomUUID()}"></labelAbbr>
                    </staffDef>
                </staffGrp>
            </scoreDef>
            <section xml:id="s{uuid:randomUUID()}">
                <xsl:for-each select="(1 to xs:integer($count))">
                    <xsl:variable name="i" select="position()" as="xs:integer"/>
                    <measure n="{$i}" label="{$i}" xml:id="m{uuid:randomUUID()}"/>
                </xsl:for-each>    
            </section>
        </partOrScore>
    </xsl:template>
    
</xsl:stylesheet>