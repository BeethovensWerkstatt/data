<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:bwu="https://www.beethovens-werkstatt.de/ns/utils"
    xmlns:bw="https://beethovens-werkstatt.de/ns/meiAdditions"
    xmlns:uuid="java:java.util.UUID"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    exclude-result-prefixes="xs math mei svg bwu bw uuid err"
    version="3.0">
    
    <xsl:variable name="path.in" select="document-uri(/)" as="xs:string"/>
    <xsl:variable name="out.path" select="$path.in => replace('/annotatedTranscripts/', '/modifiedAnnotatedTranscripts/')" as="xs:string"/>
    <xsl:variable name="sharps" select="['f','c','g','d','a','e','b']" as="xs:string+"/>
    <xsl:variable name="flats" select="['b','e','a','d','g','c','f']" as="xs:string+"/>
    
    <xsl:variable name="corresps" as="element(ref)*">
        <xsl:for-each select="//mei:staff[@corresp]">
            <xsl:variable name="staff.n" select="@n" as="xs:string"/>
            <xsl:for-each select="@corresp/tokenize(normalize-space(.), ' ')">
                <xsl:variable name="ref" select="." as="xs:string"/>
                <xsl:variable name="doc" select="substring-before($ref,'#')" as="xs:string"/>
                <xsl:variable name="id" select="substring-after($ref,'#')" as="xs:string"/>
                <xsl:variable name="url" select="resolve-uri($doc, $path.in)" as="xs:string"/>
                
                <xsl:try>
                    <xsl:variable name="elem" select="doc($url)/id($id)" as="element(mei:*)?"/>
                    <ref staff="{$staff.n}" link="{$ref}" name="{local-name($elem)}">
                        <xsl:copy-of select="$elem"/>
                    </ref>
                    <xsl:catch>
                        <xsl:message select="'Unable to retrieve elem ' || $ref || ', AT; ' || $path.in"/>
                    </xsl:catch>
                </xsl:try>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:if test="$path.in => contains('/annotatedTranscripts/')">
            <xsl:result-document href="{$out.path}">
                <xsl:apply-templates select="node()"/>
            </xsl:result-document>    
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mei:clef[ancestor::mei:staffDef]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="staff.n" select="ancestor::mei:staffDef/@n" as="xs:string"/>
            <xsl:variable name="ref.clef" select="$corresps/descendant-or-self::ref[@name = 'clef'][@staff = $staff.n]" as="element(ref)?"/>
            <xsl:if test="exists($ref.clef)">
                <xsl:attribute name="corresp" select="$ref.clef/@link"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:staffDef[ancestor::mei:scoreDef/mei:meterSig][@n]">
        <xsl:variable name="n" select="@n" as="xs:string"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:apply-templates select="ancestor::mei:scoreDef/mei:meterSig" mode="keep">
                <xsl:with-param name="staff" tunnel="yes" select="$n" as="xs:string"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:meterSig[parent::mei:scoreDef]"/>
    <!--<xsl:template match="mei:staff/@corresp"/>-->
    
    <xsl:template match="mei:meterSig" mode="keep">
        <xsl:param name="staff" tunnel="yes" as="xs:string"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="ref.clef" select="$corresps/descendant-or-self::ref[@name = 'meterSig'][@staff = $staff]" as="element(ref)?"/>
            <xsl:if test="exists($ref.clef)">
                <xsl:attribute name="corresp" select="$ref.clef/@link"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:keySig[not(mei:keyAccid)][ancestor::mei:scoreDef]">
        <xsl:variable name="staff.n" select="ancestor::mei:staffDef/@n" as="xs:string"/>
        <xsl:variable name="staff" select="following::mei:staff[@n = $staff.n][1]" as="element(mei:staff)"/>
        <xsl:variable name="corresps" as="element(ref)*">
            <xsl:for-each select="$corresps/descendant-or-self::ref[@staff = $staff.n][@name = 'accid']">
                <xsl:sort select="child::mei:*/@x" data-type="number" order="ascending"/>
                <xsl:sequence select="."/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="sig" select="@sig" as="xs:string"/>
        <xsl:variable name="dir" select="substring($sig,2)" as="xs:string"/>
        <xsl:variable name="count" select="substring($sig,1,1) cast as xs:integer" as="xs:integer"/>
        <xsl:if test="$count ne count($corresps) and count($corresps) ne 0">
            <xsl:message select="'spotted a mismatch (' || count($corresps) || ' corresps vs ' || $count || ' in keySig) at ' || tokenize($path.in,'/')[last()]"/>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@* except @sig"/>
            <xsl:apply-templates select="node()"/>    
            <xsl:for-each select="(1 to $count)">
                <xsl:variable name="i" select="."/>
                <xsl:variable name="pname" select="if ($dir = 's') then($sharps[$i]) else($flats[$i])" as="xs:string"/>
                <keyAccid xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:id" select="'k' || uuid:randomUUID()"/>
                    <xsl:attribute name="accid" select="$dir"/>
                    <xsl:attribute name="pname" select="$pname"/>
                    <xsl:if test="count($corresps) ge $i">
                        <xsl:attribute name="corresp" select="$corresps[$i]/descendant-or-self::ref/@link"/>
                    </xsl:if>
                </keyAccid>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:staff/@corresp"/>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>