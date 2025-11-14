<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs math tei mei uuid"
    version="3.0">
    
    <xsl:variable name="path.in" select="document-uri(/)" as="xs:string"/>
    <xsl:variable name="base.dir" select="$path.in => tokenize('/')" as="xs:string+"/>
    <xsl:variable name="folders" select="count($base.dir) - 1" as="xs:integer"/>
    
    <xsl:variable name="current.dir" select="$base.dir[position() le $folders] => string-join('/')" as="xs:string"/>
    
    <xsl:variable name="NKfile" select="doc('/Users/johannes/Repositories/BeethovensWerkstatt/data/data/sources/Notirungsbuch_K/Notirungsbuch_K.xml')" as="node()"/>
    <xsl:function name="mei:unfoldFolia" as="xs:string*">
        <xsl:param name="folia" as="element()+"/>
        <xsl:for-each select="$folia">
            <xsl:variable name="current" select="."/>
            <xsl:choose>
                <xsl:when test="local-name($current) = 'bifolium'">
                    <xsl:sequence select="$current/@outer.recto"/>
                    <xsl:sequence select="$current/@inner.verso"/>
                    <xsl:if test="$current/child::mei:*">
                        <xsl:sequence select="mei:unfoldFolia(child::mei:*)"/>    
                    </xsl:if>
                    <xsl:sequence select="$current/@inner.recto"/>
                    <xsl:sequence select="$current/@outer.verso"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$current/@recto"/>
                    <xsl:sequence select="$current/@verso"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    <xsl:variable name="surfaces" as="element(mei:surface)*">
        <xsl:sequence select="doc('/Users/johannes/Repositories/BeethovensWerkstatt/data/data/sources/D-B_Grasnick_20b/D-B_Grasnick_20b.xml')//mei:surface"/>
        <xsl:sequence select="doc('/Users/johannes/Repositories/BeethovensWerkstatt/data/data/sources/D-BNba_BSk_21-69/D-BNba_BSk_21-69.xml')//mei:surface"/>
        <xsl:sequence select="doc('/Users/johannes/Repositories/BeethovensWerkstatt/data/data/sources/D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml')//mei:surface"/>
        <xsl:sequence select="doc('/Users/johannes/Repositories/BeethovensWerkstatt/data/data/sources/F-Pn_Fonds_francais_12.756/F-Pn_Fonds_francais_12.756.xml')//mei:surface"/>
        <xsl:sequence select="doc('/Users/johannes/Repositories/BeethovensWerkstatt/data/data/sources/F-Pn_Ms_57/F-Pn_Ms_57.xml')//mei:surface"/>
        <xsl:sequence select="doc('/Users/johannes/Repositories/BeethovensWerkstatt/data/data/sources/F-Pn_Ms_96/F-Pn_Ms_96.xml')//mei:surface"/>
        <xsl:sequence select="doc('/Users/johannes/Repositories/BeethovensWerkstatt/data/data/sources/Landsberg_8-1/Landsberg_8-1.xml')//mei:surface"/>
    </xsl:variable>
    
    <xsl:variable name="NKpages" select="mei:unfoldFolia($NKfile//mei:foliaDesc/child::mei:*)" as="xs:string+"/>
    <xsl:variable name="NKbaseLinks" as="xs:string*">
        <xsl:for-each select="$NKpages">
            <xsl:variable name="current" select="." as="xs:string"/>
            <xsl:choose>
                <xsl:when test="$current => starts-with('#')">
                    <xsl:value-of select="'invalid'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="docname" select="tokenize($current, '/')[3]" as="xs:string"/>
                    <xsl:variable name="surfaceId" select="$current => substring-after('#')" as="xs:string"/>
                    <xsl:variable name="surface" select="$surfaces[@xml:id = $surfaceId]" as="element(mei:surface)"/>
                    <xsl:variable name="n" select="$surface/@n => format-integer('0000')" as="xs:string"/>
                    <xsl:value-of select="'../../sources/' || $docname || '/annotatedTranscripts/' || $docname || '_p' || $n || '_wz'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:message select="'NK pages: ' || count($NKpages)"/>
        <xsl:message select="$NKbaseLinks"/>
        
        <xsl:for-each select="//tei:row">
            <xsl:variable name="page" select="./tei:cell[@n = '1']/text() => normalize-space()" as="xs:string"/>
            <xsl:variable name="padded.page" select="if(string-length($page) = 1) then('0' || $page) else($page)" as="xs:string"/>
            <xsl:variable name="wz" select="./tei:cell[@n = '2']/text() => normalize-space() => replace('WZ', '')" as="xs:string"/>
            <xsl:variable name="padded.wz" select="if(string-length($wz) = 1) then('0' || $wz) else($wz)" as="xs:string"/>
            <xsl:variable name="work.raw" select="./tei:cell[@n = '3']/text() => normalize-space()" as="xs:string"/>
            <xsl:variable name="relation" select="./tei:cell[@n = '4']/text() => normalize-space()" as="xs:string"/>
            <xsl:variable name="link" select="./tei:cell[@n = '5']/text() => normalize-space()" as="xs:string"/>
            
            <xsl:variable name="annot.id" select="'x' || uuid:randomUUID()" as="xs:string"/>
            
            <xsl:variable name="nk.position" select="'NK' || $padded.page || '-' || $padded.wz" as="xs:string"/>
            <xsl:variable name="file.name" select="$current.dir || '/links/NK/' || $nk.position || '_' || $annot.id || '.xml'" as="xs:string"/>
            
            <xsl:variable name="relation.id" select="'r' || uuid:randomUUID()" as="xs:string"/>
            
            <xsl:variable name="target" as="xs:string">
                <xsl:choose>
                    <xsl:when test="$link => contains('range(') => not()">
                        <xsl:value-of select="$link"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="prefix" select="$link => substring-before('range(')" as="xs:string"/>
                        <xsl:variable name="range.start" select="$link => substring-after('range(') => substring-before(',')" as="xs:string"/>
                        <xsl:variable name="range.end" select="$link => substring-after($range.start || ',') => substring-before(')')" as="xs:string"/>
                        <xsl:variable name="tick" as="xs:string">'</xsl:variable>
                        <xsl:value-of select="$prefix || 'range(' || $tick || $range.start || $tick || ',' || $tick || $range.end || $tick || ')'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="plistBase" select="$NKbaseLinks[xs:integer($page)]" as="xs:string"/>
            <xsl:variable name="plist" select="$plistBase || format-integer(xs:integer($wz), '00') || '_at.xml'" as="xs:string"/>
            <xsl:variable name="workName" select="if(starts-with($link,'Op.120.xml#')) then('../../works/Op.120/Op.120_work.xml#') else('../../works/Op.125/Op.125_work.xml#')" as="xs:string"/>
            <xsl:variable name="final.target" select="$workName || substring-after($target, '#')" as="xs:string"/>
            
            <xsl:message select="'writing file to ' || $file.name"/>
            <xsl:result-document href="{$file.name}" indent="yes" method="xml">
                <annot xmlns="http://www.music-encoding.org/ns/mei"
                    xml:id="{$annot.id}" resp="#bw" isodate="2025">
                    <xsl:comment select="$nk.position => replace('-', '/') || ' –> ' || $work.raw"/>
                    <relation
                        xml:id="{$relation.id}"
                        plist="{$plist}"
                        target="{$final.target}"
                        rel="{$relation}"/>
                    <p/>
                </annot>
            </xsl:result-document>
        </xsl:for-each>    
    </xsl:template>
    
</xsl:stylesheet>