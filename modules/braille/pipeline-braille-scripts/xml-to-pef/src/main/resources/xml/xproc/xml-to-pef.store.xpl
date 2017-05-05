<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:xml-to-pef.store" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:input port="source" primary="true">
        <p:documentation>PEF</p:documentation>
    </p:input>
    <p:input port="obfl" sequence="true"> <!-- sequence=false when include-obfl=true -->
        <p:documentation>OBFL</p:documentation>
    </p:input>
    
    <p:option name="pef-output-dir" select="''"/>
    <p:option name="brf-output-dir" select="''"/>
    <p:option name="preview-output-dir" select="''"/>
    
    <p:option name="name" required="true"/>
    <p:option name="include-preview" select="'false'"/>
    <p:option name="include-brf" select="'false'"/>
    <p:option name="include-obfl" select="'false'"/>
    <p:option name="ascii-file-format" select="''"/>
    <p:option name="ascii-table" select="''"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    
    <!-- ========= -->
    <!-- STORE PEF -->
    <!-- ========= -->
    <px:message>
        <p:with-option name="message" select="concat('[progress px:dtbook-to-pef.store ',(if ($include-obfl='true') then '90' else '100'),' pef:store] Storing PEF',(if ($include-brf='true') then ', BRF' else ''),(if ($include-preview='true') then ' and HTML preview' else ''))"/>
    </px:message>
    <pef:store name="pef-store">
        <p:with-option name="href" select="concat($pef-output-dir,'/',$name,'.pef')"/>
        <p:with-option name="preview-href" select="if ($include-preview='true' and $preview-output-dir!='')
                                                   then concat($preview-output-dir,'/',$name,'.pef.html')
                                                   else ''"/>
        <p:with-option name="brf-dir-href" select="if ($include-brf='true' and $brf-output-dir!='')
                                                   then $brf-output-dir
                                                   else ''"/>
        <p:with-option name="brf-name-pattern" select="concat($name,'_vol-{}')"/>
        <p:with-option name="brf-file-format" select="concat($ascii-file-format,'(locale:',(//pef:meta/dc:language,'und')[1],')')"/>
        <p:with-option name="brf-table" select="if ($ascii-table!='') then $ascii-table
                                                else concat('(locale:',(//pef:meta/dc:language,'und')[1],')')"/>
    </pef:store>
    
    <!-- ========== -->
    <!-- STORE OBFL -->
    <!-- ========== -->
    <p:identity>
        <p:input port="source">
            <p:pipe step="main" port="obfl"/>
        </p:input>
    </p:identity>
    <p:choose>
        <p:when test="$include-obfl='true'">
            <px:message message="[progress px:dtbook-to-pef.store 10 p:store] Storing OBFL"/>
            <p:store>
                <p:with-option name="href" select="concat($pef-output-dir,'/',$name,'.obfl')"/>
            </p:store>
        </p:when>
        <p:otherwise>
            <p:sink/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
