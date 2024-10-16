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
            <xd:p>This XSLT will generate a source document. It operates on an XML-file that contains the basic structure of the desired document (as shown in the comment below).</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- Sample file: 
    
<doc siglum="A-Wn tralala" opus="Op.73">

    <monita count="6"/>  (when the desired document needs only sections like a revision list)
    
    ODER:
    
    <mdivs>
        <mdiv label="Allegro" measures="13">
            <parts>
                <part label="Piano" labelAbbr="Pno" staves="2"/>
                <part label="Violino Primo" labelAbbr="V1" staves="1"/>
                <part label="Violino Secondo" labelAbbr="V2" staves="1"/>    
            </parts>
        </mdiv>
        <mdiv label="Andante" measures="23">
            <parts>
                <part label="Piano" labelAbbr="Pno" staves="2"/>
                <part label="Violino Secondo" labelAbbr="V2" staves="1"/>    
            </parts>
        </mdiv>
        <mdiv label="Rondo" measures="5">
            <score>
                <part label="Piano" labelAbbr="Pno" staves="2"/>
                <part label="Violino Secondo" labelAbbr="V2" staves="1"/> 
            </score>
        </mdiv>
    </mdivs>
</doc>
    
    
    -->
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="doc" select="/doc" as="node()"/>
    <xsl:variable name="docLabel" select="$doc/string(@label)" as="xs:string"/>
    <xsl:variable name="docClasses" select="$doc/string(@class)" as="xs:string"/>
    <xsl:variable name="siglum" select="$doc/replace(@siglum,' ','_')" as="xs:string"/>
    <xsl:variable name="opus" select="$doc/string(@opus)" as="xs:string"/>
    
        <xsl:template match="/">
        <mei xmlns="http://www.music-encoding.org/ns/mei" xmlns:xi="http://www.w3.org/2001/XInclude" meiversion="5.0.0-dev" xml:id="x{uuid:randomUUID()}">
            <meiHead>
                <fileDesc>
                    <titleStmt>
                        <title><xsl:value-of select="$opus || ' ' || $siglum"/></title>
                        <title type="subordinate"><xsl:comment>post revisionem</xsl:comment></title>
                        <composer>
                            <persName xml:id="LvB" auth="GND" auth.uri="http://d-nb.info/gnd/" codedval="118508288">Ludwig van Beethoven</persName>
                        </composer>
                        <contributor>
                            <persName xml:id="unknown" auth="pbl" auth.uri="http://id.loc.gov/vocabulary/relators/">unknown publisher</persName>
                        </contributor>
                        <editor>
                            <corpName xml:id="BW" auth.uri="https://beethovens-werkstatt.de">Beethovens Werkstatt</corpName>
                        </editor>
                        <funder>
                            <corpName xml:id="AdW" auth.uri="http://www.adwmainz.de/">Akademie der Wissenschaften und der Literatur Mainz</corpName>
                        </funder>
                    </titleStmt>
                    <pubStmt/>
                    <seriesStmt>
                        <title xml:lang="de" level="s">Auf der Suche nach dem Werktext: Originalausgaben, variante Drucke und Beethovens Revisionsdokumente</title>
                        <identifier auth.uri="https://beethovens-werkstatt.de/modul-3/">rev</identifier>
                    </seriesStmt>
                </fileDesc>
                <encodingDesc class="#bw_module3_documentFile #bw_module3_staticExample"/>
                <manifestationList>
                    <manifestation xml:id="{$siglum}" label="{$docLabel}" class="{$docClasses}">
                        <physDesc>
                            <foliaDesc/>
                        </physDesc>
                        <physLoc>
                            <repository>
                                <identifier auth.uri="http://www.rism.info/" auth="RISM"><xsl:value-of select="substring-before($siglum,'_')"/></identifier>
                            </repository>
                            <identifier><xsl:value-of select="substring-after($siglum,'_')"/></identifier>
                        </physLoc>
                    </manifestation>
                </manifestationList>
                <revisionDesc>
                    <change n="1">
                        <respStmt>
                            <persName>BW</persName>
                        </respStmt>
                        <changeDesc>
                            <p>File generated by XSLT</p>
                        </changeDesc>
                        <date isodate="{substring(string(current-date()),1,10)}"/>
                    </change>
                </revisionDesc>
            </meiHead>
            <music>
                <facsimile xml:id="x{uuid:randomUUID()}"/>
                <body xml:id="x{uuid:randomUUID()}">
                    <xsl:for-each select="$doc//mdiv">
                        <xsl:variable name="mdiv" select="." as="element(mdiv)"/>
                        <mdiv n="{position()}" label="{$mdiv/string(@label)}" xml:id="x{uuid:randomUUID()}">
                            <xsl:if test="$mdiv/parts">
                                <parts xml:id="x{uuid:randomUUID()}">
                                    <xsl:for-each select="$mdiv/parts/part">
                                        <xsl:variable name="part" select="." as="element(part)"/>
                                        <xsl:variable name="partPos" select="position()" as="xs:integer"/>
                                        <part n="{$partPos}" label="{$part/@label}" xml:id="x{uuid:randomUUID()}">
                                            <xsl:variable name="labels" as="node()+">
                                                <label xml:id="x{uuid:randomUUID()}"><xsl:value-of select="$part/string(@label)"/></label>
                                                <labelAbbr xml:id="x{uuid:randomUUID()}"><xsl:value-of select="$part/string(@labelAbbr)"/></labelAbbr>
                                            </xsl:variable>
                                            <scoreDef xml:id="x{uuid:randomUUID()}">
                                                <staffGrp>
                                                    <xsl:if test="$part/xs:integer(@staves) gt 1">
                                                        <xsl:sequence select="$labels"/>
                                                    </xsl:if>
                                                    <xsl:for-each select="(1 to $part/xs:integer(@staves))">
                                                        <xsl:variable name="currentStaff" select="position()" as="xs:integer"/>
                                                        <staffDef n="{$currentStaff}" lines="5"><xsl:if test="$part/xs:integer(@staves) = 1"><xsl:sequence select="$labels"/></xsl:if></staffDef>
                                                    </xsl:for-each>
                                                </staffGrp>
                                            </scoreDef>
                                            <section xml:id="x{uuid:randomUUID()}">
                                                <xsl:for-each select="(1 to $mdiv/xs:integer(@measures))">
                                                    <xsl:variable name="i" select="position()" as="xs:integer"/>
                                                    <measure n="{$i}" label="{$i}" xml:id="m{uuid:randomUUID()}"/>
                                                </xsl:for-each>
                                            </section>
                                        </part>
                                    </xsl:for-each>
                                </parts>
                            </xsl:if>
                            <xsl:if test="$mdiv/score">
                                <score xml:id="x{uuid:randomUUID()}">
                                    <scoreDef xml:id="x{uuid:randomUUID()}">
                                        <staffGrp xml:id="x{uuid:randomUUID()}">
                                            <xsl:for-each select="$mdiv/score/part">
                                                <xsl:variable name="part" select="." as="element(part)"/>
                                                <xsl:variable name="partPos" select="position()" as="xs:integer"/>
                                                
                                                <xsl:variable name="baseN" select="xs:integer(round(sum(preceding-sibling::part/xs:integer(@staves))))" as="xs:integer"/>
                                                <xsl:variable name="labels" as="node()+">
                                                    <label xml:id="x{uuid:randomUUID()}"><xsl:value-of select="$part/string(@label)"/></label>
                                                    <labelAbbr xml:id="x{uuid:randomUUID()}"><xsl:value-of select="$part/string(@labelAbbr)"/></labelAbbr>
                                                </xsl:variable>
                                                
                                                <xsl:choose>
                                                    <xsl:when test="$part/xs:integer(@staves) gt 1">
                                                        <staffGrp xml:id="x{uuid:randomUUID()}">
                                                            <xsl:sequence select="$labels"/>
                                                            <xsl:for-each select="(1 to $part/xs:integer(@staves))">
                                                                <xsl:variable name="currentStaff" select="position()" as="xs:integer"/>
                                                                <staffDef n="{$baseN + $currentStaff}" lines="5"/>
                                                            </xsl:for-each>
                                                        </staffGrp>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <staffDef n="{$baseN + 1}" lines="5">
                                                            <xsl:sequence select="$labels"/>
                                                        </staffDef>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:for-each>
                                        </staffGrp>
                                    </scoreDef>
                                            
                                    <section xml:id="x{uuid:randomUUID()}">
                                        <xsl:for-each select="(1 to $mdiv/xs:integer(@measures))">
                                            <xsl:variable name="i" select="position()" as="xs:integer"/>
                                            <measure n="{$i}" label="{$i}" xml:id="m{uuid:randomUUID()}"/>
                                        </xsl:for-each>
                                    </section>
                                </score>
                            </xsl:if>
                        </mdiv>
                    </xsl:for-each>
                    <xsl:if test="$doc/monita">
                        <mdiv xml:id="x{uuid:randomUUID()}">
                            <scoreDef/>
                            <xsl:for-each select="(1 to xs:integer($doc/monita/@count))">
                                <section xml:id="x{uuid:randomUUID()}">
                                    <measure n="1" label="1" xml:id="x{uuid:randomUUID()}">
                                        <xsl:comment>Monitum <xsl:value-of select="position()"/> goes here</xsl:comment>
                                    </measure>
                                </section>
                            </xsl:for-each>
                        </mdiv>
                    </xsl:if>
                </body>
            </music>
        </mei>    
    </xsl:template>
    
    
    
</xsl:stylesheet>