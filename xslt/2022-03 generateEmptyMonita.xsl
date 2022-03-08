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
            <xd:p>This XSLT will generate empty monita, to be inserted into multiple files. All links are properly prepared.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        
        <xsl:variable name="textAnnot" select="uuid:randomUUID()" as="xs:string"/>
        <xsl:variable name="originAnnot" select="uuid:randomUUID()" as="xs:string"/>
        <xsl:variable name="revisionAnnot" select="uuid:randomUUID()" as="xs:string"/>
        <xsl:variable name="revisionMetamark" select="uuid:randomUUID()" as="xs:string"/>
        <xsl:variable name="targetAnnot" select="uuid:randomUUID()" as="xs:string"/>
        
        <monitumData xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:text>
                
            </xsl:text>
            <xsl:comment>Text.xml. 
                (Remove relations when a given document is missing)</xsl:comment>
            <annot 
                xml:id="{$textAnnot}"
                class="#bw_monitum_effect"
                staff="X">
                <relation rel="succeeding" target="#{$originAnnot}"/>
                <relation rel="preceding" target="#{$targetAnnot}"/>
                <relation rel="original" target="#{$revisionAnnot}"/>
                <relation rel="constituent" target="#{$revisionMetamark}"/>
            </annot>
            <xsl:text>
                
            </xsl:text>
            
            <xsl:comment>Ausgangsdokument:</xsl:comment>
            <annot
                xml:id="{$originAnnot}"
                class="#bw_monitum_context"
                staff="X">
                <annot xml:id="{uuid:randomUUID()}" class="#bw_monitum_comment"><p/></annot>
            </annot>
            <xsl:text>
                
            </xsl:text>
            
            <xsl:comment>Revisionsdokument:
                #bw_classification_korrektur
                #bw_classification_variante
                #bw_classification_textpraezisierung
                #bw_classification_schriftbildliche_verbesserung
                #bw_classification_paratextliche_eingriffe
                
                #bw_textoperation_einfuegung
                #bw_textoperation_tilgung
                #bw_textoperation_ersetzung
                #bw_textoperation_umstellung
                
                #bw_object_dynamic
                #bw_object_pitch
                #bw_object_bogensetzung
                #bw_object_rhythm
                #bw_object_ornament
                #bw_object_octave
                #bw_object_pedal
                #bw_object_articulation
                #bw_object_clef
                #bw_object_arpeggio
                #bw_object_rest
                #bw_object_fingering
                
                #bw_kontext_korrekt
                #bw_kontext_unvollstaendig
                #bw_kontext_korrumpiert
            </xsl:comment>
            <metaMark
                xml:id="{$revisionMetamark}"
                class="#bw_monitum XX"
                function="revision"
                state="#postRevision"/>
            
            <annot
                xml:id="{$revisionAnnot}"
                class="#bw_monitum_context"
                staff="X">
                <annot xml:id="{uuid:randomUUID()}" class="#bw_monitum_comment"><p/></annot>
            </annot>
            <xsl:text>
                
            </xsl:text>
            
            <xsl:comment>Zieldokument:
                #bw_fully_implemented
                #bw_partially_implemented
                #bw_not_implemented
            </xsl:comment>
            <annot
                xml:id="{$targetAnnot}"
                class="#bw_monitum_context #bw_monitum_fully_implemented"
                staff="X">
                <annot xml:id="{uuid:randomUUID()}" class="#bw_monitum_comment"><p/></annot>
            </annot>
        </monitumData>
    </xsl:template>
    
</xsl:stylesheet>