<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs math xd mei uuid"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 25, 2023</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSLT imports MEI files as annotated transcriptions into our data model. It requires proper files names.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:param name="basePath" select="'file:/Users/johannes/Repositories/BeethovensWerkstatt/data/data/sources/'" as="xs:string"/>
    <xsl:variable name="NotKPath" select="'Notirungsbuch_K/Notirungsbuch_K.xml'" as="xs:string"/>
    
    <xsl:variable name="NotK" select="doc($basePath || $NotKPath)//mei:mei" as="element(mei:mei)"/>
    
    <xsl:variable name="inputFile" select="/" as="node()"/>
    <xsl:variable name="inputFileName" select="tokenize(document-uri(/),'/')[last()]" as="xs:string"/>
    <xsl:variable name="pageN" select="xs:integer(substring(tokenize($inputFileName,'_')[2], 2))" as="xs:integer"/>
    <xsl:variable name="wzN" select="xs:integer(substring(tokenize($inputFileName,'_')[3], 3))" as="xs:integer"/>
    
    <xsl:variable name="NotKSurfaceIds" as="xs:string*">
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x2433e745-3d60-4043-9258-10ab1f1aeb47'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x57291b2b-71f2-40b4-b3a2-a4b4994ef961'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xe1e069ed-67a2-4a63-b4f1-c6b227242876'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xe0df306c-077d-49ea-8e0f-3e3440d50a5d'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xef927fa2-1f31-495f-83f9-9e00a850e003'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x717cfb28-9f73-4a31-a0ec-f6c781f772a5'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x6d6721df-b995-479b-a227-cf1bd05dfe7d'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xb14dce0a-0617-4be8-8272-522706548ae9'"/>
        
        <!-- 2 pages of D-BNba, BSk 21/69 -->
        <!-- 4 pages of D-BNba, MH 60 -->
        <!-- 2 pages of D-B, Grasnick 20b -->
        <xsl:value-of select="'D-BNba_BSk_21-69/D-BNba_BSk_21-69.xml#x731b0f02-032a-49d6-a417-d16500bea745'"/>
        <xsl:value-of select="'D-BNba_BSk_21-69/D-BNba_BSk_21-69.xml#xd174ea19-b7ae-48c8-aca1-ad6b5701f8b9'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x506637f0-9b11-4643-a220-9bbd77965bf7'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xf2f94a93-e5fe-4b94-9518-dcd35b27a88e'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x13167dbf-459c-4408-a8ee-df7c582e2255'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x69931b4f-66d0-4d26-9f4b-8a076f22a60c'"/>
        <xsl:value-of select="'D-B_Grasnick_20b/D-B_Grasnick_20b.xml#s611b7677-bc67-44cb-83ce-687a74cbbe49'"/>
        <xsl:value-of select="'D-B_Grasnick_20b/D-B_Grasnick_20b.xml#s386d6927-260e-4a44-ba8a-f664c34f6300'"/>
        
        <!-- 24 pages of D-BNba, MH 60 -->
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x5ac4fa83-c044-4c2b-858b-7a95888a5332'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x8933a040-58f0-4865-9be6-530eeb25157c'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x616c11a1-7377-48bd-a6d7-ec03ce718eb2'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x989f416b-6af5-4615-82da-09eed754b965'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x6e6bb355-b7bb-4d8f-b8ea-d23d9e9ae795'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xedf924c8-5e68-4508-bf57-5eee7904f096'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xcd55dabb-8f39-43a4-abbf-138c32f1f93b'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x7dcbd745-fe04-4731-8c56-7b6c6fd61ce9'"/>
        
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xf94dcffd-1999-4278-9711-5bdfb9e1ee85'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x1b0b15a1-cf03-491c-9fda-d15d4fbe5e66'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xc595ffad-c5c4-488b-ba92-45f4e5b4c450'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x73cd7cec-9873-4fd4-9f36-6d96e97ed881'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x50b7ec35-6d68-4ad7-91eb-59a315af7e0c'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x3ff8c2a2-81ef-40cc-8f3f-e135b610fe87'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x301c694b-9bea-4c50-8213-4a92143caeb4'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xca097347-c5ad-4863-8d7b-66f50c0550bf'"/>
        
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xac8888c6-90dc-4e7b-b704-c2f1be8c333d'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x58a60b82-2e9e-4adf-9415-6ca3063a1f29'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xaa2712a5-69c9-4a96-bc6c-84f326b61b4e'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x8ca2a944-2b00-4184-af2b-58e2bd33e205'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xa5c51527-c2ed-4565-91db-c6723d3a5d25'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x2433eb34-9ae9-44be-a41a-ff81446a672a'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xb2d5df6e-f52a-4021-b5b3-656d1e915c1f'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x9d3af3e9-b9bb-4392-b1e2-1978c50e0e44'"/>
        
        <!-- 2 pages of D-BNba, MH 60 -->
        <!-- 4 missing pages -->
        <!-- 2 pages of F-pn, Ff 12.756 -->
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#xbafcb5f6-d42e-4eed-b8c5-d4a93069400f'"/>
        <xsl:value-of select="'D-BNba_MH_60_Engelmann/D-BNba_MH_60_Engelmann.xml#x8a2db5b1-e555-424c-ab52-15c588abd75a'"/>
        <xsl:value-of select="'#t02ae4086-9a35-4361-af1d-af7045c56543'"/>
        <xsl:value-of select="'#t9f551fa1-8967-4aac-90ee-23ac79716c25'"/>
        <xsl:value-of select="'#td7c89c20-98d9-4d39-9f6f-a69574715dca'"/>
        <xsl:value-of select="'#ted5d9973-888f-43ac-8e6c-a826032073b9'"/>
        <xsl:value-of select="'F-Pn_Fonds_francais_12.756/F-Pn_Fonds_francais_12.756.xml#sbc1d28ab-f3b4-4b28-bfbb-eff71b44926d'"/>
        <xsl:value-of select="'F-Pn_Fonds_francais_12.756/F-Pn_Fonds_francais_12.756.xml#s10967407-7024-4c9e-b8b2-5522982cc265'"/>
        
        <!-- 8 pages of F-Pn, Ms. 96 -->
        <xsl:value-of select="'F-Pn_Ms_96/F-Pn_Ms_96.xml#s135bbdd5-17a1-4fa4-93e8-edd9570d2c1c'"/>
        <xsl:value-of select="'F-Pn_Ms_96/F-Pn_Ms_96.xml#s14ea2bc2-5406-4618-9754-0091b0c1a13f'"/>
        <xsl:value-of select="'F-Pn_Ms_96/F-Pn_Ms_96.xml#sd4d26df4-8997-4f6c-a26f-069241baa8bb'"/>
        <xsl:value-of select="'F-Pn_Ms_96/F-Pn_Ms_96.xml#s17f3fa15-d4a7-4167-b2dc-87530bc0922f'"/>
        <xsl:value-of select="'F-Pn_Ms_96/F-Pn_Ms_96.xml#s549e45a1-051e-465c-b973-048f5d3f65cf'"/>
        <xsl:value-of select="'F-Pn_Ms_96/F-Pn_Ms_96.xml#s49809936-9ab7-4f47-9fb6-d98c03f75703'"/>
        <xsl:value-of select="'F-Pn_Ms_96/F-Pn_Ms_96.xml#sa5355af8-fdd8-4f62-adb7-dfe777cf5b26'"/>
        <xsl:value-of select="'F-Pn_Ms_96/F-Pn_Ms_96.xml#s7437e117-4a2a-4e99-a09a-49e435ac2486'"/>
        
        <!-- 8 pages of D-B, Landsberg 8,1 -->
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s07669e68-2805-4d91-90a4-5636ecb5a327'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s482882fa-268d-4aa7-b61d-03c40add011b'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#sd4aa056d-b0f3-40ff-8437-811bbe334b0c'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#sba101e21-66fd-444c-8d19-6f1dc86e3ee1'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#sed995bd3-8b9d-4a9a-ad00-36f7cde7bb5a'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s33ab3ee0-155d-4e69-b5a5-5c36615a172b'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s2fb66137-b0c8-42a1-a33f-3b7e24d43d5f'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s29192417-92b0-417a-866a-4c491ef25f22'"/>
        
        <!-- 4 pages of D-B, Landsberg 8,1 -->
        <!-- 2 pages F-Pn, Ms. 57/2 -->
        <!-- 2 pages of D-B, Landsberg 8,1 -->
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s9833ac8c-ccb1-4fce-90e2-e19bd3099738'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s6ace5df9-3178-4f8d-a26d-19f9c388adc2'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s14d1e262-2821-4fa3-b763-2aba98804cb8'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s387832fe-c9d7-4d4b-8258-27ab055f913c'"/>
        <xsl:value-of select="'F-Pn_Ms_57/F-Pn_Ms_57.xml#s20df2be0-17c4-45d6-9924-eec1898ae075'"/>
        <xsl:value-of select="'F-Pn_Ms_57/F-Pn_Ms_57.xml#s91ca4a8e-856d-4cd0-91f1-8c43d4728c59'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s5a4e0315-8d55-4223-82ad-5fdccea32728'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#scd8c8537-26b0-4efb-86ed-42fbbf4acfb4'"/>
        
        <!-- 16 pages of D-B, Landsberg 8,1 -->
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s15b8e849-988f-4985-9d0e-b32b42461883'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#se6d50d9a-f779-413f-a09c-15f0e98494e0'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#sc2c82ebc-e460-4ed9-bb3a-91db2cc65021'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s5cff61dd-f8d2-4962-a4c9-3871f7e54101'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s1b35a94b-f578-41e1-bb78-9ec90046b5c9'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s4b95b470-069c-41a9-99e8-91347f81a5a3'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s71074e8b-0b76-4e8a-a539-816debef71e4'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#se98e6201-c288-4bdb-a617-d4799e0ee6ae'"/>
        
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#sc86443f1-8081-4cc9-a6e6-5d1842589730'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s5ca753e8-956f-4e25-b653-371c1fe65015'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#sbea9999f-8d86-46ec-b856-575e10e5b24c'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#sc7212032-1973-45d5-94ef-24a42e2904c8'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s479c9217-764e-4ce5-ad06-1b5e340aa4d6'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#sbf46e23c-d031-4d8d-b724-9ce27f86e682'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#sb9134010-835a-40f6-a800-b9c32a33de17'"/>
        <xsl:value-of select="'Landsberg_8-1/Landsberg_8-1.xml#s529b8ea8-602f-4d96-8ade-a16b801ca349'"/>
    </xsl:variable>
    
    <xsl:variable name="surfaceRef" select="$NotKSurfaceIds[$pageN]" as="xs:string"/>
    <xsl:variable name="sourceDocPath" select="if(starts-with($surfaceRef, '#')) then($NotKPath) else(substring-before($surfaceRef,'#'))" as="xs:string"/>
    <xsl:variable name="sourceName" select="substring-before($sourceDocPath, '/')" as="xs:string"/>
    
    <xsl:variable name="sourceDoc" select="doc($basePath || $sourceDocPath)" as="node()"/>
    
    <xsl:variable name="surfaceId" select="substring-after($surfaceRef,'#')" as="xs:string"/>
    <xsl:variable name="surface" select="$sourceDoc/id($surfaceId)" as="element(mei:surface)"/>
    <xsl:variable name="surfaceN" select="$surface/xs:integer(@n)" as="xs:integer"/>
    
    <xsl:variable name="genDescPage" select="$sourceDoc//mei:genDesc[@corresp = '#' || $surfaceId]" as="element(mei:genDesc)"/>
    <xsl:variable name="genDescWz" select="$genDescPage/mei:genDesc[$wzN]" as="element(mei:genDesc)"/>
    
    <xsl:variable name="outputPNum" select="'_p' || format-number($surfaceN, '000')" as="xs:string"/>
    <xsl:variable name="outputWzNum" select="'_wz' || format-number($wzN, '00')" as="xs:string"/>
    
    <xsl:variable name="resultPath" select="$basePath || $sourceName || '/annotatedTranscripts/' || $sourceName || $outputPNum || $outputWzNum || '_at.xml'" as="xs:string"/>
    <xd:doc>
        <xd:desc>
            <xd:p>Start template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:message select="'writing file ' || $resultPath"/>
        <xsl:result-document href="{$resultPath}" indent="yes" method="xml" exclude-result-prefixes="xlink">
            <xsl:processing-instruction name="xml-model">href="../../../../rng/bw_module4_complete.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
            <xsl:processing-instruction name="xml-model">href="../../../../rng/bw_module4_complete.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            <mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="6.0+beethovensWerkstatt" xml:id="a{uuid:randomUUID()}" xmlns:svg="http://www.w3.org/2000/svg">
                <xsl:variable name="step1">
                    <xsl:apply-templates select="$sourceDoc//mei:meiHead" mode="header"/>
                    <xsl:apply-templates select="$inputFile//mei:music" mode="body"/>
                </xsl:variable>
                <xsl:variable name="step2">
                    <xsl:apply-templates select="$step1" mode="cleanIds1"/>
                </xsl:variable>
                <xsl:apply-templates select="$step2" mode="cleanIds2"/>
            </mei>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="mei:manifestationList" mode="header"/>
    <xsl:template match="mei:revisionDesc" mode="header">
        <xsl:copy>
            <xsl:apply-templates select="$inputFile//mei:revisionDesc/(node() | @*)" mode="#current" exclude-result-prefixes="xlink"/>
            <change xmlns="http://www.music-encoding.org/ns/mei" xml:id="c{uuid:randomUUID()}" n="{count($inputFile//mei:change) + 1}" resp="#bw_jk" isodate="{substring(string(current-date()), 1, 10)}" xsl:exclude-result-prefixes="xlink">
                <changeDesc>
                    <p>Imported file into data structure using XSLT.</p>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:encodingDesc" mode="header">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="$inputFile//mei:appInfo" mode="#current" exclude-result-prefixes="xlink"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:source" mode="header">
        <xsl:copy>
            <xsl:attribute name="n" select="'1'"/>
            <xsl:attribute name="target" select="'../' || $sourceName || '.xml#' || $genDescWz/@xml:id"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="comment()[not(ancestor::mei:taxonomy)]" mode="header"/>
    <xsl:template match="mei:encodingDesc/@class" mode="header">
        <xsl:attribute name="class" select="'#bw_annotated_transcript #bw_module4'"/>
    </xsl:template>
    <xsl:template match="mei:category[@xml:id = 'bw_diplomatic_transcript']" mode="header">
        <xsl:next-match/>
        <category xmlns="http://www.music-encoding.org/ns/mei" xml:id="bw_annotated_transcript" class="#bw_transcription_type" xsl:exclude-result-prefixes="xlink"/>
    </xsl:template>
    <xsl:template match="mei:score" mode="body">
        <xsl:variable name="lt" as="xs:string">&lt;</xsl:variable>
        <xsl:variable name="gt" as="xs:string">&gt;</xsl:variable>
        <xsl:comment>
            <xsl:value-of select="$lt"/>drafts xml:id="s<xsl:value-of select="uuid:randomUUID()"/>"<xsl:value-of select="$gt"/>
                <xsl:value-of select="$lt"/>draft xml:id="d<xsl:value-of select="uuid:randomUUID()"/>" class="#bw_annotated_transcript"<xsl:value-of select="$gt"/>
                    move content of score here when finished with data cleanup
                <xsl:value-of select="$lt"/>/draft<xsl:value-of select="$gt"/>
            <xsl:value-of select="$lt"/>/drafts<xsl:value-of select="$gt"/>
        </xsl:comment>
        
        <xsl:copy>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:*[ancestor-or-self::mei:meiHead]" mode="cleanIds1">
        <xsl:choose>
            <xsl:when test="@xml:id and string-length(@xml:id) gt 8">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* except @xml:id" mode="#current"/>
                    <xsl:attribute name="xml:id" select="'x' || uuid:randomUUID()"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mei:*[ancestor-or-self::mei:music]" mode="cleanIds1">
        <xsl:choose>
            <xsl:when test="@xml:id and string-length(@xml:id) gt 8">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:attribute name="newId" select="'x' || uuid:randomUUID()"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@xml:id[parent::mei:*/@newId]" mode="cleanIds2">
        <xsl:attribute name="xml:id" select="parent::mei:*/@newId"/>
    </xsl:template>
    <xsl:template match="@startid[ancestor-or-self::mei:music]" mode="cleanIds2">
        <xsl:variable name="id" select="substring(., 2)" as="xs:string"/>
        <xsl:variable name="target" select="root()/id($id)" as="element()"/>
        <xsl:attribute name="startid" select="'#' || $target/@newId"/> 
    </xsl:template>
    <xsl:template match="@endid[ancestor-or-self::mei:music]" mode="cleanIds2">
        <xsl:variable name="id" select="substring(., 2)" as="xs:string"/>
        <xsl:variable name="target" select="root()/id($id)" as="element()"/>
        <xsl:attribute name="endid" select="'#' || $target/@newId"/> 
    </xsl:template>
    <xsl:template match="@newId" mode="cleanIds2"/>
    
    <!-- CLEAN UP SIBELIUS -->
    
    <xsl:template match="mei:scoreDef" mode="body">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@meter.count, @meter.unit, @meter.sym)" mode="#current"/>
            <meterSig xmlns="http://www.music-encoding.org/ns/mei" count="{@meter.count}" unit="{@meter.unit}">
                <xsl:if test="@meter.sym">
                    <xsl:attribute name="meter.sym" select="@meter.sym"/>
                </xsl:if>
            </meterSig>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:staffDef" mode="body">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@clef.line, @clef.shape, @key.mode, @key.sig)" mode="#current"/>
            <keySig xmlns="http://www.music-encoding.org/ns/mei" sig="{@key.sig}" mode="{@key.mode}"/>
            <clef xmlns="http://www.music-encoding.org/ns/mei" shape="{@clef.shape}" line="{@clef.line}"/>
            
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- remove comments auto-generated by Sibelius / sibmei -->
    <xsl:template match="comment()" priority="1" mode="body"/>
    
    
    
    <!--  -->
    <xsl:template match="mei:note[@artic]" mode="body">
        <xsl:copy>
            <xsl:apply-templates select="@* except @artic" mode="#current"/>
            <artic xmlns="http://www.music-encoding.org/ns/mei" artic="{@artic}"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:octave[@startid and @endid]" mode="body">
        <xsl:copy>
            <xsl:if test="@startid and @endid">
                <xsl:apply-templates select="@* except (@tstamp, @tstamp2)" mode="#current"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:tupletSpan[not(@endid)]" mode="body"/>
    <xsl:template match="mei:line">
        <xsl:copy>
            <xsl:attribute name="type" select="'unchecked'"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:slur" mode="body">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@startid and @endid">
                    <xsl:apply-templates select="@* except (@tstamp, @tstamp2)" mode="#current"/>
                </xsl:when>
                <xsl:when test="@startid">
                    <xsl:apply-templates select="@* except @tstamp" mode="#current"/>
                </xsl:when>
                <xsl:when test="@endid">
                    <xsl:apply-templates select="@* except @tstamp2" mode="#current"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*" mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:mRest[@visible='false']" mode="body">
        <xsl:element name="mSpace" xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="xml:id" select="'s' || uuid:randomUUID()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="//mei:instrDef" mode="body"/>
    <xsl:template match="//@color" mode="body"/>
    <xsl:template match="//@midi.bpm" mode="body"/>  
    <xsl:template match="//mei:pb" mode="body"/>
    <xsl:template match="//mei:sb" mode="body"/>
    <xsl:template match="//mei:rend" mode="body">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="//@ploc" mode="body"/>
    <xsl:template match="//@oloc" mode="body"/>
    <xsl:template match="//@dur.ppq" mode="body"/>
    <xsl:template match="//@dur.ges" mode="body"/>
    <xsl:template match="//@ppq" mode="body"/>
    <xsl:template match="//@pnum" mode="body"/>
    <xsl:template match="//@tstamp.ges" mode="body"/>
    <xsl:template match="//@tstamp.real" mode="body"/>
    
    <xsl:template match="//@vgrp" mode="body"/>
    <xsl:template match="//@val" mode="body"/>
    <xsl:template match="mei:pgHead" mode="body"/>
    <xsl:template match="mei:pgFoot" mode="body"/>
    <xsl:template match="mei:rend" mode="body"/>
    <xsl:template match="mei:verse[not(exists(descendant::mei:syl))]" mode="body"/>
    <xsl:template match="mei:note/@instr" mode="body"/>
    <xsl:template match="mei:chord/@instr" mode="body"/>
    <xsl:template match="mei:anchoredText" mode="body">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="mei:*/@ho" mode="body"/>
    <xsl:template match="mei:*/@vo" mode="body"/>
    <xsl:template match="mei:dynam/@vel" mode="body"/>
    <xsl:template match="mei:*/@page.leftmar" mode="body"/>
    <xsl:template match="mei:*/@page.rightmar" mode="body"/>
    <xsl:template match="mei:*/@page.topmar" mode="body"/>
    <xsl:template match="mei:*/@page.height" mode="body"/>
    <xsl:template match="mei:*/@page.botmar" mode="body"/>
    <xsl:template match="mei:*/@page.width" mode="body"/>
    <xsl:template match="mei:*/@spacing.staff" mode="body"/>
    <xsl:template match="mei:*/@text.name" mode="body"/>
    <xsl:template match="mei:*/@spacing.system" mode="body"/>
    <xsl:template match="mei:*/@vu.height" mode="body"/>
    <xsl:template match="mei:*/@vel" mode="body"/>
    <xsl:template match="mei:*/@lyric.name" mode="body"/>
    <xsl:template match="mei:*/@music.name" mode="body"/>
    <xsl:template match="mei:annot[@type='duration']" mode="body"/>
    
    
    <xsl:template match="@key.sig" mode="body">
    </xsl:template>
    <xsl:template match="mei:instrDef" mode="body"/>
    <xsl:template match="mei:scoreDef//mei:label" mode="body"/>
    <xsl:template match="mei:scoreDef//mei:labelAbbr" mode="body"/>
    <xsl:template match="mei:scoreDef/mei:staffGrp" mode="body">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="bar.thru" select="'true'"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Copy Template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>