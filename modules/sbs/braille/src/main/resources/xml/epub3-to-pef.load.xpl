<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="sbs:epub3-to-pef.load" version="1.0"
                xmlns:sbs="http://www.sbs.ch"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-inline-prefixes="#all"
                name="main">
    
    <!--
        Supports EPUBs containing brl:* elements.
    -->
    
    <p:output port="fileset.out" primary="true">
        <p:pipe step="load" port="fileset.out"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe step="html" port="result"/>
    </p:output>
    <p:output port="opf">
        <p:pipe step="load" port="opf"/>
    </p:output>
    
    <p:option name="epub" required="true" px:media-type="application/epub+zip application/oebps-package+xml"/>
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/epub3-to-pef/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    
    <px:epub3-to-pef.load name="load">
        <p:with-option name="epub" select="$epub"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:epub3-to-pef.load>
    
    <p:add-attribute match="d:file[@media-type='application/xhtml+xml']"
                     attribute-name="media-type" attribute-value="application/sbs-xhtml+xml"/>
    
    <px:fileset-load media-types="application/sbs-xhtml+xml" name="html">
        <p:input port="in-memory">
            <!-- in-memory.out port of load step normally contains only the opf but could in theory
                 contain the html files (without the brl: prefixes) so we drop it -->
            <p:empty/>
        </p:input>
    </px:fileset-load>
    
</p:declare-step>
