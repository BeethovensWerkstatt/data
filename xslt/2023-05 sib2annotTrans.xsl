<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs math xd mei uuid"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 3, 2023</xd:p>
            <xd:p><xd:b>Author:</xd:b>Kristin Herold, Johannes Kepper, Ran Mo, Agnes Seipelt, René Pauls</xd:p>
            <xd:p>This XSLT takes a writing-zone-based annotated transcript exported from Sibelius to MEI
                and cleans that MEI up for further use.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:variable name="file" select="/" as="node()"/>
    <xsl:variable name="fileName" select="tokenize(document-uri(), '/')[last()]"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="child::node()"/>
        
    </xsl:template>
    
    
    
    <xd:doc>
        <xd:p>Author:<xd:b>Kristin Herold, Johannes Kepper</xd:b></xd:p>
        <xd:desc> create revisionDesc-element </xd:desc>
    </xd:doc>
    <!-- todo: this template works only if there is no <revisionDesc> present -->
    <xsl:template match="mei:workList">
        <xsl:copy-of select="."/>
        <xsl:variable name="exportDate" as="xs:string">
            <xsl:variable name="raw" select="$file/id('sibelius')/substring-before(@isodate,'T')" as="xs:string"/>
            <xsl:variable name="tokens" select="tokenize($raw, '-')" as="xs:string*"/>
            <xsl:variable name="year" select="$tokens[1]" as="xs:string"/>
            <xsl:variable name="month" select="if(string-length($tokens[2]) = 1) then('0' || $tokens[2]) else($tokens[2])" as="xs:string"/>
            <xsl:variable name="day" select="if(string-length($tokens[3]) = 1) then('0' || $tokens[3]) else($tokens[3])" as="xs:string"/>
            <xsl:value-of select="$year || '-' || $month || '-' || $day"/>
        </xsl:variable>
        <revisionDesc xmlns="http://www.music-encoding.org/ns/mei">
            <change n="1" resp="#bw_sc" isodate="2023">
                <changeDesc>
                    <p>Original content transcribed using <ptr target="#sibelius"/>.</p>
                </changeDesc>
            </change>
            <change n="2" resp="#bw_" isodate="{$exportDate}">
                <changeDesc>
                    <p>Sibelius file exported to MEI using <ptr target="#sibmei"/>.</p>
                </changeDesc>
            </change>
            <change n="3" resp="#bw_rm" isodate="{substring(string(current-date()),1,10)}">
                <changeDesc>
                    <p>Cleaned up MEI file to match concept of annotated transcription, using <ptr target="#sib2annotTrans.xsl"/>.</p>
                </changeDesc>
            </change>
        </revisionDesc>
    </xsl:template>
    
    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <application xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id" select="'sib2annotTrans.xsl'"/>
                <xsl:attribute name="version" select="'2023-05-03'"/>
                <name>XSLT Transformation for Sibelius MEI to Annotated Transcriptions</name>
            </application>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:application//@isodate"/>
    
    <!-- TODO: adding this template will make it impossible to render with Verovio… -->
    <!--<xsl:template match="mei:score">
            <drafts xmlns="http://www.music-encoding.org/ns/mei">
                <draft>
                    <xsl:apply-templates select="node() | @*"/>
                </draft>
            </drafts>
        </xsl:template>-->
    
    <!-- TODO: use this in FacsEx to help with checking them? -->
    <xsl:template match="mei:space">
        <xsl:copy>
            <xsl:attribute name="type" select="'unchecked'"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:scoreDef">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@meter.count, @meter.unit, @meter.sym)"/>
            <meterSig xmlns="http://www.music-encoding.org/ns/mei" count="{@meter.count}" unit="{@meter.unit}">
                <xsl:if test="@meter.sym">
                    <xsl:attribute name="meter.sym" select="@meter.sym"/>
                </xsl:if>
            </meterSig>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:staffDef">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@clef.line, @clef.shape, @key.mode, @key.sig)"/>
            <keySig xmlns="http://www.music-encoding.org/ns/mei" sig="{@key.sig}" mode="{@key.mode}"/>
            <clef xmlns="http://www.music-encoding.org/ns/mei" shape="{@clef.shape}" line="{@clef.line}"/>
            
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- remove comments auto-generated by Sibelius / sibmei -->
    <xsl:template match="comment()"/>
    
    
    
    <!--  -->
    <xsl:template match="mei:note[@artic]">
        <xsl:copy>
            <xsl:apply-templates select="@* except @artic"/>
            <artic xmlns="http://www.music-encoding.org/ns/mei" artic="{@artic}"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:octave[@startid and @endid]">
        <xsl:copy>
            <xsl:if test="@startid and @endid">
                <xsl:apply-templates select="@* except (@tstamp, @tstamp2)"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:tupletSpan[not(@endid)]"/>
    <xsl:template match="mei:line">
        <xsl:copy>
            <xsl:attribute name="type" select="'unchecked'"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:slur">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@startid and @endid">
                    <xsl:apply-templates select="@* except (@tstamp, @tstamp2)"/>
                </xsl:when>
                <xsl:when test="@startid">
                    <xsl:apply-templates select="@* except @tstamp"/>
                </xsl:when>
                <xsl:when test="@endid">
                    <xsl:apply-templates select="@* except @tstamp2"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:mRest">
        <xsl:element name="mSpace" xmlns="http://www.music-encoding.org/ns/mei"/>
    </xsl:template>
    
    <xsl:template match="//mei:instrDef"/>
    <xsl:template match="//@color"/>
    <xsl:template match="//@midi.bpm"/>  
    <xsl:template match="//mei:pb"/>
    <xsl:template match="//mei:sb"/>
    <xsl:template match="//mei:rend">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="//@ploc"/>
    <xsl:template match="//@oloc"/>
    <xsl:template match="//@dur.ppq"/>
    <xsl:template match="//@dur.ges"/>
    <xsl:template match="//@ppq"/>
    <xsl:template match="//@pnum"/>
    <xsl:template match="//@tstamp.ges"/>
    <xsl:template match="//@tstamp.real"/>
    
    <xsl:template match="//@vgrp"/>
    <xsl:template match="//@val"/>
    <xsl:template match="mei:pgHead"/>
    <xsl:template match="mei:pgFoot"/>
    <xsl:template match="mei:rend"/>
    <xsl:template match="mei:verse[not(exists(descendant::mei:syl))]"/>
    <xsl:template match="mei:note/@instr"/>
    <xsl:template match="mei:chord/@instr"/>
    <xsl:template match="mei:anchoredText">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="mei:*/@ho"/>
    <xsl:template match="mei:*/@vo"/>
    <xsl:template match="mei:dynam/@vel"/>
    <xsl:template match="mei:*/@page.leftmar"/>
    <xsl:template match="mei:*/@page.rightmar"/>
    <xsl:template match="mei:*/@page.topmar"/>
    <xsl:template match="mei:*/@page.height"/>
    <xsl:template match="mei:*/@page.botmar"/>
    <xsl:template match="mei:*/@page.width"/>
    <xsl:template match="mei:*/@spacing.staff"/>
    <xsl:template match="mei:*/@text.name"/>
    <xsl:template match="mei:*/@spacing.system"/>
    <xsl:template match="mei:*/@vu.height"/>
    <xsl:template match="mei:*/@vel"/>
    <xsl:template match="mei:*/@lyric.name"/>
    <xsl:template match="mei:*/@music.name"/>
    <xsl:template match="mei:annot[@type='duration']"/>
    
    
    
    
    
    
    <xsl:template match="/">
        <xsl:result-document href="neu/{$fileName}">
            <xsl:apply-templates select="node()"/>
        </xsl:result-document>
    </xsl:template>
    
    
    <!-- copy templates -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    
</xsl:stylesheet>
