<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="sbs:epub3-to-epub3" version="1.0"
                xmlns:sbs="http://www.sbs.ch"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Braille in EPUB 3 (SBS)</h1>
        <p px:role="desc">Transforms an EPUB 3 publication into an EPUB 3 publication with a braille rendition.</p>
    </p:documentation>
    
    <p:option name="source"/>
    
    <p:option name="contraction-grade" required="false" select="'0'">
      <p:pipeinfo>
        <px:data-type>
          <choice xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0">
            <value>0</value>
            <a:documentation xml:lang="de">Basisschrift</a:documentation>
            <value>1</value>
            <a:documentation xml:lang="de">Vollschrift</a:documentation>
            <value>2</value>
            <a:documentation xml:lang="de">Kurzschrift</a:documentation>
          </choice>
        </px:data-type>
      </p:pipeinfo>
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h2 px:role="name">Translation/formatting of text: Contraction grade</h2>
        <p px:role="desc">`Basisschrift` (uncontracted), `Vollschrift` (partly contracted) or `Kurzschrift` (fully contracted)</p>
      </p:documentation>
    </p:option>
    
    <p:option name="stylesheet" select="'http://www.sbs.ch/pipeline/modules/braille/default.scss'"/>
    <p:option name="apply-document-specific-stylesheets" select="'true'"/>
    <p:option name="set-default-rendition-to-braille"/>
    <p:option name="output-dir"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/epub3-to-epub3/library.xpl"/>
    
    <px:fileset-create name="target.base.fileset">
        <p:with-option name="base"
                       select="concat($output-dir,'/',replace(replace($source,'(\.epub|/mimetype)$',''),'^.*/([^/]+)$','$1'),'.epub!/')"/>
    </px:fileset-create>
    
    <px:epub3-to-epub3.load name="load">
        <p:with-option name="epub" select="$source"/>
        <p:input port="target-base">
            <p:pipe step="target.base.fileset" port="result"/>
        </p:input>
    </px:epub3-to-epub3.load>
    
    <px:epub3-to-epub3.convert content-media-types="application/xhtml+xml application/sbs-xhtml+xml"
                               name="convert">
        <p:input port="epub.in.fileset">
            <p:pipe step="load" port="fileset"/>
        </p:input>
        <p:input port="epub.in.in-memory">
            <p:pipe step="load" port="in-memory"/>
        </p:input>
        <p:with-option name="epub-base" select="base-uri(/*)">
            <p:pipe step="target.base.fileset" port="result"/>
        </p:with-option>
        <p:with-option name="braille-translator" select="concat('(translator:sbs)(grade:',$contraction-grade,')')"/>
        <p:with-option name="stylesheet" select="$stylesheet"/>
        <p:with-option name="apply-document-specific-stylesheets" select="$apply-document-specific-stylesheets"/>
        <p:with-option name="set-default-rendition-to-braille" select="$set-default-rendition-to-braille"/>
    </px:epub3-to-epub3.convert>
    
    <px:fileset-store>
        <p:input port="fileset.in">
            <p:pipe step="convert" port="epub.out.fileset"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe step="convert" port="epub.out.in-memory"/>
        </p:input>
    </px:fileset-store>
    
</p:declare-step>
