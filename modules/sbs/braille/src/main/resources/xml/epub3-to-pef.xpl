<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="sbs:epub3-to-pef" version="1.0"
                xmlns:sbs="http://www.sbs.ch"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:opf="http://www.idpf.org/2007/opf"
                exclude-inline-prefixes="#all"
                name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">EPUB 3 to PEF (SBS)</h1>
        <p px:role="desc">Transforms a EPUB 3 publication into a PEF.</p>
    </p:documentation>

    <p:option name="epub" required="true" px:type="anyFileURI" px:sequence="false" px:media-type="application/epub+zip application/oebps-package+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Input EPUB 3</h2>
            <p px:role="desc" xml:space="preserve">The EPUB you want to convert to braille. You may alternatively use the EPUB package document (the OPF-file) if your input is a unzipped/"exploded" version of an EPUB.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="pef-output-dir"/>
    <p:option name="brf-output-dir"/>
    <p:option name="preview-output-dir"/>
    <p:option name="temp-dir"/>
    
    <p:option name="stylesheet"/>
    <p:option name="apply-document-specific-stylesheets" px:type="boolean" select="'false'"/>
    <p:option name="contraction-grade"/>
    <p:option name="ascii-file-format"/>
    <p:option name="include-preview"/>
    <p:option name="include-brf"/>
    <p:option name="page-width"/>
    <p:option name="page-height"/>
    <p:option name="left-margin"/>
    <p:option name="duplex"/>
    <p:option name="levels-in-footer"/>
    <p:option name="main-document-language"/>
    <p:option name="hyphenation"/>
    <p:option name="line-spacing"/>
    <p:option name="tab-width"/>
    <p:option name="capital-letters"/>
    <p:option name="accented-letters"/>
    <p:option name="polite-forms"/>
    <p:option name="downshift-ordinal-numbers"/>
    <p:option name="include-captions"/>
    <p:option name="include-images"/>
    <p:option name="include-image-groups"/>
    <p:option name="include-line-groups"/>
    <p:option name="text-level-formatting"/>
    <p:option name="include-note-references"/>
    <p:option name="include-production-notes"/>
    <p:option name="show-braille-page-numbers"/>
    <p:option name="show-print-page-numbers"/>
    <p:option name="force-braille-page-break"/>
    <p:option name="toc-depth"/>
    <p:option name="footnotes-placement"/>
    <p:option name="colophon-metadata-placement"/>
    <p:option name="rear-cover-placement"/>
    <p:option name="number-of-sheets"/>
    <p:option name="maximum-number-of-sheets"/>
    <p:option name="minimum-number-of-sheets"/>
    <p:option name="document-identifier"/>

    <!-- for testing purposes -->
    <p:input port="parameters" kind="parameter" primary="false"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/epub3-to-pef/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    
    <p:in-scope-names name="in-scope-names"/>
    <px:merge-parameters>
        <p:input port="source">
            <p:pipe step="in-scope-names" port="result"/>
            <p:pipe step="main" port="parameters"/>
        </p:input>
    </px:merge-parameters>
    <px:delete-parameters parameter-names="stylesheet
                                           apply-document-specific-stylesheets
                                           ascii-file-format
                                           include-brf
                                           include-preview
                                           pef-output-dir
                                           brf-output-dir
                                           preview-output-dir
                                           temp-dir"/>
    <px:add-parameters>
        <p:with-param name="skip-margin-top-of-page" select="'true'"/>
    </px:add-parameters>
    <p:identity name="input-options"/>
    <p:sink/>
    
    <!-- =============== -->
    <!-- CREATE TEMP DIR -->
    <!-- =============== -->
    <px:tempdir name="temp-dir">
        <p:with-option name="href" select="if ($temp-dir!='') then $temp-dir else $pef-output-dir"/>
    </px:tempdir>
    
    <!-- =========== -->
    <!-- LOAD EPUB 3 -->
    <!-- =========== -->
    <px:message message="Loading EPUB"/>
    <px:epub3-to-pef.load name="load">
        <p:with-option name="epub" select="$epub"/>
        <p:with-option name="temp-dir" select="concat(string(/c:result),'load/')">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
    </px:epub3-to-pef.load>
    
    <!-- ============= -->
    <!-- EPUB 3 TO PEF -->
    <!-- ============= -->
    <p:identity>
        <p:input port="source">
            <p:pipe port="fileset.out" step="load"/>
        </p:input>
    </p:identity>
    <px:message message="Done loading EPUB, starting conversion to PEF"/>
    <px:epub3-to-pef.convert default-stylesheet="http://www.daisy.org/pipeline/modules/braille/epub3-to-pef/css/default.css"
                             name="convert">
        <p:with-option name="epub" select="$epub"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="load"/>
        </p:input>
        <p:with-option name="temp-dir" select="concat(string(/c:result),'convert/')">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
        <p:with-option name="stylesheet" select="string-join((
                                                   resolve-uri('group-starting-with-linenum.xsl'),
                                                   resolve-uri('handle-toc-and-running-line.xsl'),
                                                   resolve-uri('handle-dl.xsl'),
                                                   resolve-uri('handle-pageref.xsl'),
                                                   resolve-uri('insert-boilerplate.xsl'),
                                                   $stylesheet),' ')">
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
        <p:with-option name="apply-document-specific-stylesheets" select="$apply-document-specific-stylesheets"/>
        <p:with-option name="transform" select="concat('(formatter:dotify)(translator:sbs)(grade:',$contraction-grade,')')"/>
        <p:input port="parameters">
            <p:pipe port="result" step="input-options"/>
        </p:input>
    </px:epub3-to-pef.convert>
    <p:sink/>
    
    <!-- ========= -->
    <!-- STORE PEF -->
    <!-- ========= -->
    <p:identity>
        <p:input port="source">
            <p:pipe step="convert" port="in-memory.out"/>
        </p:input>
    </p:identity>
    <px:message message="Storing PEF"/>
    <p:delete match="/*/@xml:base"/>
    <px:epub3-to-pef.store>
        <p:with-option name="epub" select="$epub"/>
        <p:input port="opf">
            <p:pipe step="load" port="opf"/>
        </p:input>
        <p:with-option name="include-brf" select="$include-brf"/>
        <p:with-option name="include-preview" select="$include-preview"/>
        <p:with-option name="ascii-file-format" select="$ascii-file-format"/>
        <p:with-option name="pef-output-dir" select="$pef-output-dir"/>
        <p:with-option name="brf-output-dir" select="$brf-output-dir"/>
        <p:with-option name="preview-output-dir" select="$preview-output-dir"/>
    </px:epub3-to-pef.store>
    
    <!--
        store as single volume BRF (will overwrite PEF too)
    -->
    <p:identity>
        <p:input port="source">
            <p:pipe step="convert" port="in-memory.out"/>
        </p:input>
    </p:identity>
    <p:choose>
        <p:when test="$include-brf='true' and $brf-output-dir!='' and count(//pef:volume) &gt; 1">
            <p:variable name="name" select="if (ends-with(lower-case($epub),'.epub')) then replace($epub,'^.*/([^/]*)\.[^/\.]*$','$1')
                                           else (/opf:package/opf:metadata/dc:identifier[not(@refines)], 'unknown-identifier')[1]">
                <p:pipe step="load" port="opf"/>
            </p:variable>
            <pef:store>
                <p:with-option name="href" select="concat($pef-output-dir,'/',$name,'.pef')"/>
                <p:with-option name="brf-dir-href" select="$brf-output-dir"/>
                <p:with-option name="brf-name-pattern" select="$name"/>
                <p:with-option name="brf-single-volume-name" select="$name"/>
                <p:with-option name="brf-file-format" select="concat($ascii-file-format,'(locale:',(//pef:meta/dc:language,'und')[1],')')"/>
            </pef:store>
        </p:when>
        <p:otherwise>
            <p:sink/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
