<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:ns prefix="mei" uri="http://www.music-encoding.org/ns/mei"/>
    <sch:ns prefix="bw" uri="https://beethovens-werkstatt.de/ns/meiAdditions"/>
    
    <sch:let name="base.uri" value="base-uri(/)"/>
    
    <!-- <lb/> in DTs-->
    <sch:pattern id="check_lb">
        <sch:rule context="*:lb">
            <sch:assert test="namespace-uri() = 'http://www.music-encoding.org/ns/mei'" role="error">The line break is in the wrong namespace.</sch:assert>
            <sch:assert test="not(child::node())">A line break must not have content.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- <sb/> pb? in DTs -->
    
    <sch:pattern id="check_refs_in-AT">
        <sch:rule context="mei:section[ancestor::mei:score][not(preceding::mei:section)]">
            <sch:assert test="child::element()[1]/local-name() = 'pb'">The first child in the first section must be a pb.</sch:assert>
            <sch:assert test="child::element()[2]/local-name() = 'annot'">The second child in the first section must be an annot.</sch:assert>
            <sch:assert test="child::element()[2]/@class = '#bw_writingZoneBegin'">The annot must use @class = '#bw_writingZoneBegin'</sch:assert>
            <sch:assert test="child::element()[3]/local-name() = 'sb'">The third child in the first section must be a sb.</sch:assert>
        </sch:rule>
        </sch:pattern>
        
    
    
    
    <!-- <sb/> in ATs -->
    <sch:pattern id="check_pb_in_AT">
        <sch:rule context="mei:pb[not(ancestor::bw:draft)]">
            <sch:let name="source.uri" value="@corresp => substring-before('#')"/>
            <sch:let name="surface.id" value="@corresp => substring-after('#')"/>
            <sch:assert test="$source.uri => resolve-uri($base.uri) => doc-available()">The source document holding the surface is not available.</sch:assert>
            <sch:let name="source.doc" value="$source.uri => resolve-uri($base.uri) => doc()"/>
            <sch:assert test="$source.doc => exists()">There is no source doc at "<sch:value-of select="$source.uri"/>".</sch:assert>
            <sch:assert test="$source.doc//mei:surface[@xml:id = $surface.id]">There is no MEI surface with ID "<sch:value-of select="$surface.id"/>" in "<sch:value-of select="$source.uri"/>".</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="check_annot_in_AT">
        <sch:rule context="mei:annot[@class = '#bw_writingZoneBegin']">
            <sch:let name="pb" value="preceding-sibling::mei:pb[1]"/>
            <sch:let name="pb.surface.id" value="$pb/@corresp => substring-after('#')"/>
            
            <sch:let name="source.uri" value="@corresp => substring-before('#')"/>
            <sch:let name="genDescWz.id" value="@corresp => substring-after('#')"/>
            <sch:assert test="$source.uri => resolve-uri($base.uri) => doc-available()">The source document holding the genDesc is not available.</sch:assert>
            <sch:let name="source.doc" value="$source.uri => resolve-uri($base.uri) => doc()"/>
            <sch:let name="genDescWz" value="$source.doc//mei:genDesc[@xml:id = $genDescWz.id]"/>
            <sch:let name="genDescWzClasses" value="$genDescWz/@class => normalize-space() => tokenize(' ')"/>
            <sch:assert test="'#geneticOrder_writingZoneLevel' = $genDescWzClasses">The referenced genDesc does not have the right classes. Should be '#geneticOrder_writingZoneLevel', but is <sch:value-of select="$genDescWz/@classes"/>.</sch:assert>
            <sch:let name="genDescPage" value="$genDescWz/parent::mei:genDesc"/>
            <sch:let name="genDescPageSurfaceRef" value="$genDescPage/@corresp => substring-after('#')"/>
            <sch:assert test="$genDescPageSurfaceRef = $pb.surface.id">The referenced genDesc points to a different surfaceID than the pb element above. pb: "<sch:value-of select="$pb.surface.id"/>", genDesc: "<sch:value-of select="$genDescPageSurfaceRef"/>".</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="check_sb_in_AT">
        <sch:rule context="mei:sb">
            <sch:let name="AT.pb" value="preceding-sibling::mei:pb[1]"/>
            <sch:let name="AT.pb.surface.id" value="$AT.pb/@corresp => substring-after('#')"/>
            
            <!-- is this necessary? -->
            <sch:let name="annot" value="preceding-sibling::mei:annot[1]"/>
            
            <sch:let name="DT.uri" value="@corresp => substring-before('#')"/>
            <sch:let name="bw.system.id" value="@corresp => substring-after('#')"/>
            
            <sch:assert test="$DT.uri => resolve-uri($base.uri) => doc-available()">The diplomatic transcript is not available.</sch:assert>
            <sch:let name="DT.doc" value="$DT.uri => resolve-uri($base.uri) => doc()"/>
            <sch:let name="DT.system" value="$DT.doc//bw:system[@xml:id = $bw.system.id]"/>
            <sch:assert test="$DT.system => exists()">There is no system element with ID "<sch:value-of select="$bw.system.id"/>" in "<sch:value-of select="$DT.uri"/>".</sch:assert>
            
            <sch:let name="DT.pb" value="$DT.system/preceding-sibling::mei:pb[1]"/>
            <sch:let name="DT.pb.surface.id" value="$DT.pb/@target => substring-after('#')"/>
            <sch:assert test="$DT.pb.surface.id = $AT.pb.surface.id">DT has a different surface ID than AT. DT: "<sch:value-of select="$DT.pb.surface.id"/>", AT: "<sch:value-of select="$AT.pb.surface.id"/>".</sch:assert>       
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="check_staffDef_in_DT">
        <sch:rule context="mei:staffDef[ancestor::bw:system]">
            <sch:let name="rastrum.id" value="@decls => substring-after('#')"/>
            <sch:let name="source.uri" value="@decls => substring-before('#')"/>
            <sch:assert test="$source.uri => resolve-uri($base.uri) => doc-available()">The source document holding the rastrum is not available.</sch:assert>
            <sch:let name="source.doc" value="$source.uri => resolve-uri($base.uri) => doc()"/>
            <sch:let name="rastrum" value="$source.doc//mei:rastrum[@xml:id = $rastrum.id]"/>
            <sch:assert test="$rastrum => exists()">There is no rastrum with ID "<sch:value-of select="$rastrum.id"/>".</sch:assert>
            <sch:let name="layout" value="$rastrum/ancestor::mei:layout"/>
            <sch:let name="layout.id" value="$layout/@xml:id"/>
            
            <sch:let name="DT.pb" value="ancestor::bw:system/preceding-sibling::mei:pb[1]"/>
            <sch:let name="DT.pb.surface.id" value="$DT.pb/@target => substring-after('#')"/>
            
            <sch:let name="surface" value="$source.doc//mei:surface[@xml:id = $DT.pb.surface.id]"/>
            <sch:assert test="$surface => exists()">There is no surface with ID "<sch:value-of select="$DT.pb.surface.id"/>" in "<sch:value-of select="$source.uri"/>".</sch:assert>
            
            <sch:let name="surface.decls.layout.id" value="$surface/@decls => substring-after('#')"/>
            <sch:assert test="$surface.decls.layout.id = $layout.id">The rastrum referenced by "<sch:value-of select="$rastrum.id"/>" seems to be on a different page than referenced by "<sch:value-of select="$DT.pb.surface.id"/>". $layout.id: "<sch:value-of select="$layout.id"/>", $surface.decls.layout.id: "<sch:value-of select="$surface.decls.layout.id"/>".</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    
    
    <!--<sch:pattern id="check_source_available">
        <sch:rule context="tei:TEI">
            <sch:assert test="doc-available($mei.source.path)" role="error">The MEI Source file is not available at the expected location of <sch:value-of select="$mei.source.path"/></sch:assert>
        </sch:rule>
    </sch:pattern>-->
        
</sch:schema>
