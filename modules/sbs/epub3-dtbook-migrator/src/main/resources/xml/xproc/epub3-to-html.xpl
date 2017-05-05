<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    type="px:nordic-epub3-to-html" name="main" version="1.0" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:pxp="http://exproc.org/proposed/steps" xpath-version="2.0"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:html="http://www.w3.org/1999/xhtml">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Nordic EPUB3 to HTML5</h1>
        <p px:role="desc">Transforms an EPUB3 publication into HTML5 according to the nordic markup guidelines.</p>
    </p:documentation>

    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Validation status</h1>
            <p px:role="desc">Validation status (http://code.google.com/p/daisy-pipeline/wiki/ValidationStatusXML).</p>
        </p:documentation>
        <p:pipe port="result" step="status"/>
    </p:output>

    <p:option name="html-report" required="true" px:output="result" px:type="anyDirURI" px:media-type="application/vnd.pipeline.report+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">HTML Report</h1>
            <p px:role="desc">An HTML-formatted version of the validation report.</p>
        </p:documentation>
    </p:option>

    <p:option name="epub" required="true" px:type="anyFileURI" px:media-type="application/epub+zip">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">EPUB3 Publication</h2>
            <p px:role="desc">EPUB3 Publication marked up according to the nordic markup guidelines.</p>
        </p:documentation>
    </p:option>

    <p:option name="temp-dir" required="true" px:output="temp" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Temporary directory</h2>
            <p px:role="desc">Temporary directory for use by the script.</p>
        </p:documentation>
    </p:option>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">HTML</h2>
            <p px:role="desc">Output directory for the HTML.</p>
        </p:documentation>
    </p:option>

    <p:option name="fail-on-error" required="false" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Stop processing on validation error</h2>
            <p px:role="desc">Whether or not to stop the conversion when a validation error occurs. Setting this to false may be useful for debugging or if the validation error is a minor one. The
                output is not guaranteed to be valid if this option is set to false.</p>
        </p:documentation>
    </p:option>

    <p:import href="step/epub3-validate.step.xpl"/>
    <p:import href="step/epub3-to-html.step.xpl"/>
    <p:import href="step/html-validate.step.xpl"/>
    <p:import href="step/html-store.step.xpl"/>
    <p:import href="step/format-html-report.xpl"/>
    <p:import href="step/fail-on-error-status.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>

    <p:variable name="epub-href" select="resolve-uri($epub,static-base-uri())"/>

    <px:message message="$1" name="epub3-to-html.nordic-version-message">
        <p:with-option name="param1" select="/*">
            <p:document href="../version-description.xml"/>
        </p:with-option>
    </px:message>

    <px:fileset-create cx:depends-on="epub3-to-html.nordic-version-message" name="epub3-to-html.create-epub-fileset">
        <p:with-option name="base" select="replace($epub-href,'[^/]+$','')"/>
    </px:fileset-create>
    <px:fileset-add-entry media-type="application/epub+zip" name="epub3-to-html.add-epub-to-fileset">
        <p:with-option name="href" select="replace($epub-href,'^.*/([^/]*)$','$1')"/>
    </px:fileset-add-entry>
    <px:message message="Validating EPUB"/>
    <px:nordic-epub3-validate.step name="epub3-to-html.epub3-validate">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:with-option name="temp-dir" select="concat($temp-dir,'validate/')"/>
    </px:nordic-epub3-validate.step>

    <px:message message="Converting from EPUB to HTML"/>
    <px:nordic-epub3-to-html.step name="epub3-to-html.epub3-to-html">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="epub3-to-html.epub3-validate"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="report.out" step="epub3-to-html.epub3-validate"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status.out" step="epub3-to-html.epub3-validate"/>
        </p:input>
    </px:nordic-epub3-to-html.step>

    <px:message message="Storing HTML"/>
    <px:fileset-move name="epub3-to-html.html-move">
        <p:with-option name="new-base"
            select="concat(if (ends-with($output-dir,'/')) then $output-dir else concat($output-dir,'/'), substring-before(replace(/*/d:file[@media-type='application/xhtml+xml'][1]/@href,'^.*/',''),'.'), '/')"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="epub3-to-html.epub3-to-html"/>
        </p:input>
    </px:fileset-move>
    <px:nordic-html-store.step name="epub3-to-html.html-store">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="epub3-to-html.html-move"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="report.out" step="epub3-to-html.epub3-to-html"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status.out" step="epub3-to-html.epub3-to-html"/>
        </p:input>
    </px:nordic-html-store.step>

    <px:message message="Validating HTML"/>
    <px:nordic-html-validate.step name="epub3-to-html.html-validate" document-type="Nordic HTML (single-document)" check-images="false">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="epub3-to-html.html-store"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="report.out" step="epub3-to-html.html-store"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status.out" step="epub3-to-html.html-store"/>
        </p:input>
    </px:nordic-html-validate.step>
    <p:sink/>

    <p:identity>
        <p:input port="source">
            <p:pipe port="report.out" step="epub3-to-html.html-validate"/>
        </p:input>
    </p:identity>
    <px:message message="Building report"/>
    <px:nordic-format-html-report name="epub3-to-html.nordic-format-html-report"/>

    <p:store include-content-type="false" method="xhtml" omit-xml-declaration="false" name="epub3-to-html.store-report">
        <p:with-option name="href" select="concat($html-report,if (ends-with($html-report,'/')) then '' else '/','report.xhtml')"/>
    </p:store>
    <px:set-doctype doctype="&lt;!DOCTYPE html&gt;" name="epub3-to-html.set-report-doctype">
        <p:with-option name="href" select="/*/text()">
            <p:pipe port="result" step="epub3-to-html.store-report"/>
        </p:with-option>
    </px:set-doctype>
    <p:sink/>
    
    <px:nordic-fail-on-error-status name="status">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:input port="source">
            <p:pipe port="status.out" step="epub3-to-html.html-validate"/>
        </p:input>
    </px:nordic-fail-on-error-status>
    <p:sink/>

</p:declare-step>
