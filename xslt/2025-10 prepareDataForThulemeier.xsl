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

    <!-- this file needs to run on Notirungsbuch_K.xml.  -->
    
    <xsl:include href="2025-09_utils/2025-09%20geometrics.xsl"/>
    
    <xsl:variable name="nk" select="/" as="node()"/>
    <xsl:variable name="path.in" select="document-uri(/)" as="xs:string"/>
    
    <xsl:variable name="source.folder" select="resolve-uri('..', $path.in)"/>
    
    <xsl:function name="mei:unfoldFolia" as="xs:string+">
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
    
    <xsl:variable name="source.docs.uris" as="xs:string*">
        <xsl:variable name="fileNamePattern" select="'?recurse=yes;select=*.xml'" as="xs:string"/>
        <xsl:variable name="all.docs" select="uri-collection($source.folder || $fileNamePattern)" as="xs:string*"/>
        <xsl:variable name="docs" select="$all.docs[not(contains(., 'Transcripts/')) and not(contains(., 'Notirungsbuch_K'))]" as="xs:string*"/>
        <xsl:sequence select="$docs"/>
    </xsl:variable>
    <xsl:variable name="source.docs" select="for $uri in $source.docs.uris return doc($uri)" as="node()+"/>
    
    <xsl:variable name="at.docs.uris" as="xs:string*">
        <xsl:variable name="fileNamePattern" select="'?recurse=yes;select=*_at.xml'" as="xs:string"/>
        <xsl:variable name="all.docs" select="uri-collection($source.folder || $fileNamePattern)" as="xs:string+"/>
        <xsl:variable name="docs" select="$all.docs[contains(., '/annotatedTranscripts/')]" as="xs:string+"/>
        <xsl:sequence select="$docs"/>
    </xsl:variable>
    <!--<xsl:variable name="at.docs" select="for $uri in $at.docs.uris return doc($uri)" as="node()+"/>-->
    
    <xsl:variable name="surfaces" select="$source.docs//mei:surface" as="element(mei:surface)+"/>
    <xsl:variable name="layouts" select="$source.docs//mei:layout" as="element(mei:layout)+"/>
    
    <xsl:variable name="NKpages" select="mei:unfoldFolia($nk//mei:foliaDesc/child::mei:*)" as="xs:string+"/>
    <!--<xsl:variable name="NKbaseLinks" as="xs:string*">
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
                    <xsl:value-of select="$source.folder || '/' || $docname || '/annotatedTranscripts/' || $docname || '_p' || $n || '_wz'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>-->
    
    <xsl:variable name="pages" as="node()*">
        <xsl:for-each select="$surfaces">
            <xsl:variable name="surface" select="." as="element(mei:surface)"/>
            <xsl:variable name="siglum" select="substring-before(tokenize(document-uri($surface/root()), '/')[last()], '.xml')" as="xs:string"/>
            <xsl:variable name="nk.folium" select="$nk//mei:foliaDesc//mei:*[some $att in @*/string(.) satisfies ends-with($att, '#' || $surface/@xml:id)]" as="node()?"/>
            <xsl:if test="$nk.folium">
                <xsl:variable name="mmWidth" select="xs:double($nk.folium/@width)" as="xs:double"/>
                <xsl:variable name="mmHeight" select="xs:double($nk.folium/@height)" as="xs:double"/>
                <xsl:variable name="pxWidth" select="bwu:getPxWidth($surface/mei:graphic[@type='facsimile']/@target)" as="xs:double"/>
                <xsl:variable name="scaleFactor" select="$pxWidth div $mmWidth" as="xs:double"/>
                
                <xsl:variable name="layoutId" select="$surface/@decls => substring(2)" as="xs:string"/>
                <xsl:variable name="rastrums" select="$layouts[@xml:id = $layoutId]//mei:rastrum" as="element(mei:rastrum)+"/>
                <xsl:variable name="xywh" select="$surface/mei:graphic[@type = 'facsimile']/@target => substring-after('xywh=') => substring-before('&amp;') => tokenize(',')" as="xs:string*"/>
                
                <page surfaceId="{$surface/@xml:id}"
                    n="{$surface/@n}"
                    scaleFactor="{round($scaleFactor * 1000) div 1000}"
                    svg="{$surface/mei:graphic[@type='shapes']/@target}"
                    siglum="{$siglum}"
                    width="{$mmWidth}"
                    height="{$mmHeight}"
                    pixOffX="{$xywh[1]}"
                    pixOffY="{$xywh[2]}"
                    rotate="{$surface/mei:graphic[@type='facsimile']/substring-after(@target,'rotate=')}">
                    <xsl:for-each select="$rastrums">
                        <staff xml:id="{@xml:id}" 
                            vu="{round(xs:double(@system.height) div 8 * 100) div 100}"
                            x="{@system.leftmar}"
                            yTop="{@system.topmar}"
                            yBottom="{(number(@system.topmar) + number(@system.height))}"
                            h="{@system.height}"
                            rotate="{@rotate}"/>
                    </xsl:for-each>
                </page>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="/">
        
        <xsl:for-each select="$pages">
            <xsl:variable name="current.page" select="." as="element(page)"/>
            <xsl:variable name="current.siglum" select="$current.page/@siglum" as="xs:string"/>
            <xsl:variable name="current.dir" select="$source.folder || $current.siglum" as="xs:string"/>
            <xsl:variable name="padded.pageN" select="format-number($current.page/number(@n), '000')" as="xs:string"/>
            <xsl:variable name="folder" select="$source.folder|| $current.siglum || '/annotatedTranscripts/'" as="xs:string"/>
            <xsl:variable name="fileNamePattern" select="'?select=' || $current.siglum || '_p' || $padded.pageN || '_wz*_at.xml'" as="xs:string"/>
            <xsl:variable name="svg" select="doc($current.dir || substring($current.page/@svg, 2))" as="node()?"/>
            <xsl:if test="not($svg)">
                <xsl:message select="'ERROR a: unable to retrieve SVG from ' || $current.dir || substring($current.page/@svg, 2)" terminate="yes"/>
            </xsl:if>
            <xsl:variable name="docs" select="collection($folder || $fileNamePattern)"/>
            <xsl:variable name="docPaths" select="uri-collection($folder || $fileNamePattern)"/>
            <xsl:message select="'Page ' || $padded.pageN || ' (' || $current.siglum || ', @n=' || $current.page/@n || '): ' || count($docs) || ' / ' || count($docPaths) || ', svg: ' || exists($svg)"/>
            
            <xsl:for-each select="$docPaths">
                <xsl:sort select="." data-type="text" order="ascending"/>
                <xsl:variable name="at.path" select="." as="xs:string"/>
                <xsl:variable name="at" select="doc($at.path)" as="node()+"/>
                <xsl:variable name="at.fileName" select="tokenize($at.path,'/')[last()]" as="xs:string"/>
                
                <xsl:variable name="linked.dts" select="distinct-values($at//mei:sb/substring-before(substring(@corresp, 3), '#'))" as="xs:string*"/>
                <xsl:variable name="linked.surfaces" select="distinct-values($at//mei:pb/@corresp)" as="xs:string*"/>
                <xsl:variable name="svgs" as="node()*">
                    <xsl:for-each select="$linked.surfaces">
                        <xsl:variable name="surfaceId" select="substring-after(.,'#')" as="xs:string"/>
                        <xsl:variable name="fullSurfaceLink" select="substring-before(.,'#')" as="xs:string"/>
                        <!--<xsl:message select="'     surfaceId: ' || $surfaceId || ', ' || exists($pages/descendant-or-self::page[@surfaceId = $surfaceId])"/>-->
                        <xsl:variable name="page" select="$pages/descendant-or-self::page[@surfaceId = $surfaceId]" as="element(page)?"/>
                        <xsl:choose>
                            <xsl:when test="exists($page)">
                                <xsl:variable name="fileNamePattern" select="'?recurse=yes;select=*' || substring($page/@svg, 7)" as="xs:string"/>
                                <!--<xsl:variable name="all.docs" select="uri-collection($source.folder || $fileNamePattern)" as="xs:string*"/>-->
                                <xsl:variable name="svg" select="uri-collection($source.folder || $fileNamePattern)" as="xs:string+"/>
                                <xsl:sequence select="doc($svg[1])"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message select="'need to retrieve from ' || $fullSurfaceLink"/>
                                <xsl:variable name="otherDoc" select="doc($current.dir || substring($fullSurfaceLink, 3))" as="node()+"/>
                                <xsl:variable name="surface" select="$otherDoc//mei:surface[@xml:id = $surfaceId]" as="element(mei:surface)"/>
                                <xsl:variable name="svgLink" select="$surface/mei:graphic[@type='shapes']/@target" as="xs:string"/>
                                <xsl:variable name="doc-uri" select="document-uri($surface/root())" as="xs:string"/>
                                <xsl:variable name="resolved" select="resolve-uri($svgLink, $doc-uri)" as="xs:string"/>
                                <xsl:variable name="svg" select="doc($resolved)" as="node()?"/>
                                <xsl:if test="not($svg)">
                                    <xsl:message select="'ERROR b: unable to retrieve SVG from ' || $resolved" terminate="yes"/>
                                </xsl:if>
                                <xsl:sequence select="$svg"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="modified.dts" as="node()*">
                    <xsl:choose>
                        <!--<xsl:when test="$at.fileName ne 'Landsberg_8-1_p009_wz01_at.xml'">
                            
                        </xsl:when>
                        --><xsl:when test="count($linked.dts) = 0">
                            <xsl:message select="'ERROR: ' || $at.fileName || ' has no valid //sb pointing to a diplomatic transcript'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="count($linked.dts) gt 1">
                                <xsl:message select="'More than one dt for ' || $at.fileName"/>
                            </xsl:if>
                            <xsl:for-each select="$linked.dts">
                                <xsl:sort select="." data-type="text" order="ascending"/>
                                <xsl:try>
                                    <xsl:variable name="dt.path" select="$current.dir || ." as="xs:string"/>
                                    <xsl:variable name="dt.fileName" select="tokenize($dt.path,'/')[last()]" as="xs:string"/>
                                    <xsl:variable name="dt" select="doc($dt.path)" as="node()+"/>
                                    <!--<xsl:message select="$at.fileName || ' – ' || $dt.fileName"/>-->
                                    
                                    <xsl:variable name="dt.new.path" select="$dt.path => replace('/diplomaticTranscripts/', '/modifiedDiplomaticTranscripts/')" as="xs:string"/>
                                    <output href="{$dt.new.path}">
                                        <xsl:apply-templates select="$dt/node()" mode="dt1">
                                            <xsl:with-param name="svg" select="$svgs" tunnel="yes" as="node()+"/>
                                            <xsl:with-param name="at" select="$at" tunnel="yes" as="node()"/>
                                            <xsl:with-param name="page" select="$current.page" tunnel="yes" as="node()"/>
                                        </xsl:apply-templates>
                                    </output>
                                    <xsl:catch>
                                        <xsl:variable name="dt.path" select="$current.dir || ." as="xs:string"/>
                                        <xsl:variable name="dt.fileName" select="tokenize($dt.path,'/')[last()]" as="xs:string"/>
                                        <xsl:message select="'ERROR: Failed to transform ' || $dt.fileName"/>
                                        <xsl:message select="'Description: ' || $err:description"/>
                                    </xsl:catch>
                                </xsl:try>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:for-each select="$modified.dts/descendant-or-self::output">
                    <xsl:variable name="dt.newPath" select="@href" as="xs:string"/>
                    <xsl:result-document href="{$dt.newPath}">
                        <xsl:apply-templates select="child::node()" mode="dt2"/>
                    </xsl:result-document>
                </xsl:for-each>
                
                <xsl:variable name="new.at.path" select="$at.path => replace('/annotatedTranscripts/', '/modifiedAnnotatedTranscripts/')" as="xs:string"/>
                <xsl:result-document href="{$new.at.path}">
                    <xsl:apply-templates select="$at" mode="at1">
                        <xsl:with-param name="dt" select="$modified.dts" tunnel="yes" as="node()+"/>
                    </xsl:apply-templates>
                </xsl:result-document>
                
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="mei:staff" mode="dt1">
        <xsl:param name="page" tunnel="yes" as="node()"/>
        
        <xsl:variable name="n" select="@n" as="xs:string"/>
        <xsl:variable name="def" select="preceding::mei:staffDef[@n = $n][1]" as="node()"/>
        <xsl:variable name="rastrumId" select="$def/@decls => substring-after('#')" as="xs:string"/>
        <xsl:variable name="staff" select="$pages//*:staff[@xml:id = $rastrumId]" as="node()?"/>
        <xsl:if test="not($staff)">
            <xsl:message select="'Searching ' || $rastrumId || ' (looking for event, starting from ' || @xml:id || ')'"/>
            <xsl:message select="$page" terminate="false"/>
        </xsl:if>
        
        <xsl:next-match>
            <xsl:with-param name="staff" select="$staff" tunnel="yes" as="node()"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="mei:*[@stem.dir][not(@stem.len)][@facs]" mode="dt1">
        <xsl:param name="svg" tunnel="yes" as="node()+"/>
        <xsl:param name="at" tunnel="yes" as="node()"/>
        <xsl:param name="page" tunnel="yes" as="element(page)"/>
        <xsl:param name="staff" tunnel="yes" as="element(staff)"/>
        
        <xsl:variable name="shapeIds" select="@facs => normalize-space() => tokenize(' ')" as="xs:string+"/>
        <xsl:variable name="shapes">
            <xsl:for-each select="$shapeIds">
                <xsl:variable name="id" select=". => substring-after('#')" as="xs:string"/>
                <xsl:variable name="shape" select="$svg//svg:path[@id = $id]" as="node()*"/>
                <xsl:if test="count($shape) gt 1">
                    <xsl:message select="$shape" terminate="yes"/>
                </xsl:if>
                <xsl:if test="not(exists($shape/@data-bbox))">
                    <xsl:message select="'error at ' || $id || ', svg has paths:' || count($svg//svg:path) || ', this one exists: ' || exists($shape) || ' first ID: ' || ($svg//svg:path)[1]/@id"/>
                    <xsl:message select="$shape" terminate="yes"/>
                </xsl:if>
                <xsl:variable name="xywh" select="$shape/@data-bbox => normalize-space() => tokenize(',')" as="xs:string+"/>
                <shape yTop="{$xywh[2]}" yBottom="{(number($xywh[2]) + number($xywh[4]))}" x1="{$xywh[1]}" x2="{(number($xywh[1]) + number($xywh[3]))}"/>
            </xsl:for-each>    
        </xsl:variable>
        <xsl:variable name="minY" select="$shapes//@yTop/xs:double(.) => min()" as="xs:double"/>
        <xsl:variable name="maxY" select="$shapes//@yBottom/xs:double(.) => max()" as="xs:double"/>
        <xsl:variable name="pixH" select="$maxY - $minY" as="xs:double"/>
        <xsl:variable name="vuH" select="round($pixH div $page/@scaleFactor/xs:double(.) div $staff/@vu/xs:double(.))" as="xs:double"/>
        
        <xsl:variable name="bboxX" select="$shapes//@x1/xs:double(.) => min()" as="xs:double"/>
        <xsl:variable name="bboxW" select="$shapes/descendant-or-self::*[@x1 and @x2]/sum(xs:double(@x1), xs:double(@x2)) => max()" as="xs:double"/>
        
        <xsl:variable name="bbox" select="map{'x':$bboxX, 'y':$minY, 'width': $bboxW, 'height': $pixH}" as="map(*)"/>
        <xsl:variable name="loc" as="xs:double">
            <xsl:choose>
                <xsl:when test="local-name() = 'note'">
                    <xsl:value-of select="xs:double(@loc)"/>
                </xsl:when>
                <xsl:when test="local-name() = 'chord' and @stem.dir = 'up'">
                    <xsl:value-of select="max(.//@loc/xs:double(.))"/>
                </xsl:when>
                <xsl:when test="local-name() = 'chord' and @stem.dir = 'down'">
                    <xsl:value-of select="min(.//@loc/xs:double(.))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="4"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="x" select="xs:double(@x)" as="xs:double"/>
        <xsl:variable name="direction" select="@stem.dir" as="xs:string"/>
        <xsl:variable name="rastrum" select="map{'x': $staff/xs:double(@x), 'y': $staff/xs:double(@yTop), 'rotate': $staff/xs:double(@rotate), 'vu': $staff/xs:double(@vu)}" as="map(*)"/>
        <xsl:variable name="page-rotate" select="$page/xs:double(@rotate)" as="xs:double"/>
        
        <!--<xsl:variable name="stem.len" select="bwu:feature-height-vu($bbox, $loc, $x, $direction, $rastrum, $page-rotate)" as="xs:integer"/>-->
        
        <xsl:variable name="y" select="$staff/xs:double(@yBottom) - ($staff/xs:double(@vu) * $loc)" as="xs:double"/>
        
        <!--<xsl:message select="'$x:' || $x || ' | $y:' || $y || ' | $staff/@x:' || $staff/xs:double(@x) || ' | $staff/@y:' || $staff/xs:double(@yTop) || ' | $staff/@rotate:' || $staff/xs:double(@rotate) * -1"/>-->
        <xsl:variable name="rotatedByRastrum" select="bwu:rotate-and-translate($x, $y, $staff/xs:double(@x), $staff/xs:double(@yTop), $staff/xs:double(@rotate) * -1)" as="map(*)"/>
        <!--<xsl:message select="'rotatedByRastrum ( x:' || $rotatedByRastrum?x || ', y:' || $rotatedByRastrum?y || ')'"/>-->
        <xsl:variable name="rotatedByPage" select="bwu:rotate-and-translate($rotatedByRastrum?x, $rotatedByRastrum?y, ($page/xs:double(@width) div 2), ($page/xs:double(@height) div 2), $page/xs:double(@rotate))" as="map(*)"/>
        <!--<xsl:message select="'rotatedByPage ( x:' || $rotatedByPage?x || ', y:' || $rotatedByPage?y || ')'"/>-->
        <xsl:variable name="xOnPage" select="$rotatedByPage?x * $page/xs:double(@scaleFactor) + $page/xs:double(@pixOffX)" as="xs:double"/>
        <xsl:variable name="yOnPage" select="$rotatedByPage?y * $page/xs:double(@scaleFactor) + $page/xs:double(@pixOffY)" as="xs:double"/>
        <!--<xsl:message select="'$minY:' || $minY || ', $yOnPage:' || $yOnPage || ', $maxY:' || $maxY"/>-->
        
        <xsl:variable name="heightPx" select="if($direction = 'up') then($yOnPage - $minY) else($maxY - $yOnPage)" as="xs:double"/>
        <!--<xsl:message select="'$heightPx:' || $heightPx"/>-->
        
        <xsl:variable name="heightMm" select="$heightPx div $page/xs:double(@scaleFactor)" as="xs:double"/>
        <xsl:variable name="heightVu" select="max((round($heightMm div $staff/xs:double(@vu)), 1))" as="xs:double"/>
        <!--<xsl:message select="'$heightMm:' || $heightMm"/>
        <xsl:message select="'$heightVu:' || $heightVu"/>
        <xsl:message select="'–'"/>-->
        
        <!--<xsl:message select="$shapes"/>-->
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="stem.len" select="$heightVu"/>
            <!--<xsl:attribute name="stem.len2" select="$vuH"/>-->
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:beamSpan" mode="dt1">
        <xsl:param name="svg" tunnel="yes" as="node()+"/>
        <xsl:param name="page" tunnel="yes" as="element(page)"/>
        
        <xsl:variable name="beamSpanId" select="@xml:id" as="xs:string"/>
        <xsl:variable name="staffN" select="@staff" as="xs:string"/>
        <xsl:variable name="def" select="preceding::mei:staffDef[@n = $staffN][1]" as="element(mei:staffDef)"/>
        <xsl:variable name="rastrumId" select="$def/@decls => substring-after('#')" as="xs:string"/>
        <xsl:variable name="staff" select="$pages//staff[@xml:id = $rastrumId]" as="node()?"/>
        <xsl:if test="not($staff)">
            <xsl:message select="'Searching ' || $rastrumId || ' (looking for controlevent)'"/>
            <xsl:message select="$page" terminate="yes"/>
        </xsl:if>
        
        <xsl:variable name="shapes" select="@facs => normalize-space() => tokenize(' ')" as="xs:string+"/>
        <!--<xsl:if test="$beamSpanId = 'ddd9aa4d9-b239-4841-89b3-d3ea80db9b6e'">
            <xsl:message select="'facs (' || count($shapes) || '): ' || @facs"/>
        </xsl:if>-->
        <xsl:for-each select="$shapes">
            <xsl:variable name="shapeRef" select="." as="xs:string"/>
            <xsl:variable name="shape.id" select=". => substring-after('#')" as="xs:string"/>
            <xsl:variable name="shape" select="$svg//svg:path[@id = $shape.id]" as="element(svg:path)"/>
            <xsl:variable name="xywh" select="$shape/@data-bbox => tokenize(',')" as="xs:string+"/>
            
            <xsl:variable name="llxPx" select="xs:double($xywh[1]) - $page/xs:double(@pixOffX)" as="xs:double"/>
            <xsl:variable name="llyPx" select="xs:double($xywh[2]) + xs:double($xywh[4]) - $page/xs:double(@pixOffY)" as="xs:double"/>
            <xsl:variable name="urxPx" select="xs:double($xywh[1]) + xs:double($xywh[3]) - $page/xs:double(@pixOffX)" as="xs:double"/>
            <xsl:variable name="uryPx" select="xs:double($xywh[2]) - $page/xs:double(@pixOffY)" as="xs:double"/>
            
            <xsl:variable name="llRotatedByPage" select="bwu:rotate-and-translate($llxPx, $llyPx, ($page/xs:double(@width) div 2), ($page/xs:double(@height) div 2), $page/xs:double(@rotate) * -1)" as="map(*)"/>
            <xsl:variable name="urRotatedByPage" select="bwu:rotate-and-translate($urxPx, $uryPx, ($page/xs:double(@width) div 2), ($page/xs:double(@height) div 2), $page/xs:double(@rotate) * -1)" as="map(*)"/>
            
            <xsl:variable name="llRotatedByRastrum" select="bwu:rotate-and-translate($llRotatedByPage?x, $llRotatedByPage?y, $staff/xs:double(@x), $staff/xs:double(@yTop), $staff/xs:double(@rotate))" as="map(*)"/>
            <xsl:variable name="urRotatedByRastrum" select="bwu:rotate-and-translate($urRotatedByPage?x, $urRotatedByPage?y, $staff/xs:double(@x), $staff/xs:double(@yTop), $staff/xs:double(@rotate))" as="map(*)"/>
            
            <xsl:variable name="llScaled" select="map{'x': $llRotatedByRastrum?x div $page/xs:double(@scaleFactor), 'y':  $llRotatedByRastrum?y div $page/xs:double(@scaleFactor)}" as="map(*)"/>
            <xsl:variable name="urScaled" select="map{'x': $urRotatedByRastrum?x div $page/xs:double(@scaleFactor), 'y':  $urRotatedByRastrum?y div $page/xs:double(@scaleFactor)}" as="map(*)"/>
            
            <xsl:variable name="llxMm" select="round(($llScaled?x - $staff/xs:double(@system.leftmar))*10) div 10" as="xs:double?"/>
            
            <xsl:variable name="ll" select="map{'x': round(($llScaled?x - $staff/xs:double(@x))*10) div 10, 'y': round(($llScaled?y - $staff/xs:double(@yTop))*10) div 10}" as="map(*)"/>
            <xsl:variable name="ur" select="map{'x': round(($urScaled?x - $staff/xs:double(@x))*10) div 10, 'y': round(($urScaled?y - $staff/xs:double(@yTop))*10) div 10}" as="map(*)"/>
            
            <line xmlns="http://www.music-encoding.org/ns/mei"
                xml:id="b{uuid:randomUUID()}"
                func="beam"
                staff="{$staffN}"
                x="{$ll?x}" y="{$ll?y}"
                x2="{$ur?x}" y2="{$ur?y}"
                facs="{$shapeRef}"
                oldId="{$beamSpanId}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="@oldId" mode="dt2"/>
    
    <xsl:template match="mei:beam/@corresp" mode="at1">
        <xsl:param name="dt" tunnel="yes" as="node()+"/>
        <xsl:variable name="refs" select=". => normalize-space() => tokenize(' ')" as="xs:string*"/>
        <xsl:variable name="fixed.refs" as="xs:string*">
            <xsl:for-each select="$refs">
                <xsl:variable name="path" select=". => substring-before('#')" as="xs:string"/>
                <xsl:variable name="id" select=". => substring-after('#')" as="xs:string"/>
                <xsl:variable name="dt.lines" select="$dt//mei:line[@oldId = $id]" as="node()*"/>
                <xsl:choose>
                    <xsl:when test="count($dt.lines) gt 0">
                        <xsl:for-each select="$dt.lines">
                            <xsl:sequence select="$path || '#' || @xml:id"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$path || '#' || $id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:attribute name="corresp" select="string-join($fixed.refs, ' ')"/>
    </xsl:template>
    
    <!-- move misplaced dir etc. to the right place -->
    <xsl:template match="mei:section" mode="dt1">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <xsl:apply-templates select=".//mei:layer//mei:*[@staff]" mode="dt2"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:layer//mei:*[@staff]" mode="dt1"/>
    
    <!-- fix dur on notes etc. -->
    <xsl:template match="@dur" mode="dt1">
        <xsl:param name="at" tunnel="yes" as="node()+"/>
        <xsl:if test="xs:double(.) gt 4">
            <!-- a flag attribute can only be necessary for 8th notes or shorter -->
            <xsl:variable name="e" select="parent::element()" as="element()"/>
            <xsl:variable name="e.ref" select="'#' || $e/@xml:id" as="xs:string"/>
            
            <xsl:variable name="beamedRefs" select="$at//mei:beam//mei:*[@dur]/tokenize(normalize-space(@corresp),' ')" as="xs:string*"/>
            <xsl:variable name="beamed" select="some $ref in $beamedRefs satisfies ends-with($ref, $e.ref)" as="xs:boolean"/>
            
            <xsl:choose>
                <xsl:when test="$beamed">
                    <xsl:attribute name="bw:stem.flags" select="0"/>
                    <!--<xsl:message select="'setting flags to zero because of beam'"/>-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="dur" select="xs:double(.)" as="xs:double"/>
                    <xsl:variable name="flags" select="round(math:log($dur) div math:log(2)) - 2" as="xs:double"/>
                    <xsl:attribute name="bw:stem.flags" select="$flags"/>
                    <!--<xsl:message select="'setting flags to ' || $flags || ' for dur=' || $dur"/>-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>