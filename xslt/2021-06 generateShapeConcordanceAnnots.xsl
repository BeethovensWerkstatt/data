<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java.util.UUID"
    exclude-result-prefixes="xs math xd mei uuid"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 14, 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This XSLT tries to generate MEI annotations that reflect the relation of notes across multiple documents, and also in the text.xml file.
                It is supposed to operate in the context of the third module of Beethovens Werkstatt</xd:p>
            <xd:p>It needs to run on the text.xml file, and will automatically find all manifestation / document encodings. It will generate a list of annotations that 
                need to be copied into the _linking.xml file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:variable name="document.files" as="node()*">
        <xsl:variable name="file.path" select="document-uri(/)" as="xs:string"/>
        <xsl:if test="not(contains($file.path,'/edition/'))">
            <xsl:message terminate="yes" select="'[ERROR] This XSLT is supposed to run on a text.xml file, which should be stored inside an /edition/ folder. Processing terminated.'"/>
        </xsl:if>
        <xsl:variable name="documents.folder" select="substring-before($file.path,'/edition/') || '/manifestations?select=*.xml'" as="xs:string"/>
        <xsl:sequence select="collection($documents.folder)//mei:mei[.//mei:encodingDesc[@class = '#bw_module3_documentFile']]"/>        
    </xsl:variable>
    
    <xsl:variable name="shapes.per.doc" as="node()*">
        <xsl:for-each select="$document.files">
            <xsl:variable name="shape.refs" select="distinct-values(.//tokenize(normalize-space(@facs),' '))" as="xs:string*"/>
            <xsl:variable name="facs.elems" select=".//mei:*[@facs]" as="node()*"/>
            <doc id="{.//mei:manifestation/string(@xml:id)}" shapes="{count($shape.refs)}">
                <xsl:for-each select="$shape.refs">
                    <xsl:variable name="current.shape" select="." as="xs:string"/>
                    <xsl:variable name="elems" select="$facs.elems[$current.shape = tokenize(normalize-space(@facs),' ')]" as="node()+"/>
                    <xsl:if test="count($elems) gt 1">
                        <xsl:message select="'[INFO] Shape ' || $current.shape || ' used ' || count($elems) || ' times.'"/>
                    </xsl:if>
                    <shape ref="{$current.shape}" elems="{string-join($elems/concat('#',@xml:id),' ')}"/>
                </xsl:for-each>
            </doc>    
        </xsl:for-each>        
    </xsl:variable>
    
    <xsl:variable name="elements.with.facs" select="//mei:*[@facs][not(local-name() = ('staff','measure','layer'))][@xml:id][string-length(normalize-space(@facs)) gt 0]" as="node()*"/>
    
    <xsl:template match="/">
        <notesStmt xmlns="http://www.music-encoding.org/ns/mei">
            <head>Element Concordance</head>
            <xsl:for-each select="$elements.with.facs">
                <xsl:variable name="current.element" select="." as="node()"/>
                <xsl:variable name="svg.tokens" select="tokenize(normalize-space(@facs),' ')" as="xs:string*"/>
                
                <annot xml:id="a{uuid:randomUUID()}">
                    <xsl:attribute name="plist" select="'#' || $current.element/@xml:id"/>
                    <xsl:attribute name="type" select="local-name($current.element)"/>
                    <xsl:attribute name="class" select="'#bw_concordance_items'"/>
                    <xsl:variable name="source"/>
                    
                    <xsl:for-each select="$document.files">
                        
                        <xsl:variable name="current.doc" select="." as="node()"/>
                        <xsl:variable name="current.doc.siglum" select="$current.doc//mei:manifestation/@xml:id" as="xs:string"/>
                        
                        <xsl:variable name="doc.shapes.list" select="$shapes.per.doc/descendant-or-self::doc[@id = $current.doc.siglum]"/>
                        <xsl:variable name="current.shapes" select="for $token in $svg.tokens return $doc.shapes.list//shape[@ref = $token]" as="node()*"/>
                        
                        <xsl:variable name="element.refs" select="distinct-values($current.shapes/tokenize(normalize-space(@elems),' '))" as="xs:string*"/>
                        
                        <xsl:if test="count($element.refs) gt 0">
                            <relation rel="hasEmbodiment" label="{$current.doc.siglum}" target="{string-join($element.refs,' ')}"/>    
                        </xsl:if>
                    </xsl:for-each>
                </annot>
                
            </xsl:for-each>
        </notesStmt>
    </xsl:template>
    
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