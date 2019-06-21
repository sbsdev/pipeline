<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    type="px:nordic-epub3-to-dtbook" name="main" version="1.0" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:pxp="http://exproc.org/proposed/steps" xpath-version="2.0"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:html="http://www.w3.org/1999/xhtml">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Nordic EPUB3 to DTBook</h1>
        <p px:role="desc">Transforms an EPUB3 publication into DTBook according to the nordic markup guidelines.</p>
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
    
    <p:option name="organization-specific-validation" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Organization-specific validation</h2>
            <p px:role="desc">Leave blank for the default validation schemas. Use 'nota' to validate using Nota-specific validation rules.</p>
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
            <h2 px:role="name">DTBook</h2>
            <p px:role="desc">Output directory for the DTBook.</p>
        </p:documentation>
    </p:option>

    <p:option name="discard-intermediary-html" required="false" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Discard intermediary HTML</h2>
            <p px:role="desc">Whether or not to include the intermediary HTML in the output (does not include external resources such as images). Set to false to include the HTML.</p>
        </p:documentation>
    </p:option>

    <p:option name="fail-on-error" required="false" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Stop processing on validation error</h2>
            <p px:role="desc">Whether or not to stop the conversion when a validation error occurs. Setting this to false may be useful for debugging or if the validation error is a minor one. The
                output is not guaranteed to be valid if this option is set to false.</p>
        </p:documentation>
    </p:option>

    <!-- option supporting convert to DTBook 1.1.0 -->
    <p:option name="dtbook2005" required="false" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">DTBook 2005</h2>
            <p px:role="desc">Whether or not to keep the DTBook 2005-3 output or downgrade to DTBook 1.1.0. Set to false to convert to DTBook 1.1.0.</p>
        </p:documentation>
    </p:option>

    <p:import href="step/epub3-validate.step.xpl"/>
    <p:import href="step/epub3-to-html.step.xpl"/>
    <p:import href="step/html-validate.step.xpl"/>
    <p:import href="step/html-store.step.xpl"/>
    <p:import href="step/html-to-dtbook.step.xpl"/>
    <p:import href="step/dtbook-validate.step.xpl"/>
    <p:import href="step/dtbook-store.step.xpl"/>
    <p:import href="step/format-html-report.xpl"/>
    <p:import href="step/fail-on-error-status.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>

    <px:message message="$1">
        <p:with-option name="param1" select="/*">
            <p:document href="../version-description.xml"/>
        </p:with-option>
    </px:message>
    
    <px:normalize-uri name="epub">
        <p:with-option name="href" select="resolve-uri($epub,static-base-uri())"/>
    </px:normalize-uri>
    <px:normalize-uri name="html-report">
        <p:with-option name="href" select="resolve-uri($html-report,static-base-uri())"/>
    </px:normalize-uri>
    <px:normalize-uri name="temp-dir">
        <p:with-option name="href" select="resolve-uri($temp-dir,static-base-uri())"/>
    </px:normalize-uri>
    <px:normalize-uri name="output-dir">
        <p:with-option name="href" select="resolve-uri($output-dir,static-base-uri())"/>
    </px:normalize-uri>
    <p:identity name="epub3-to-dtbook.nordic-version-message-and-variables"/>
    <p:sink/>

    <px:fileset-create cx:depends-on="epub3-to-dtbook.nordic-version-message-and-variables" name="epub3-to-dtbook.create-epub-fileset">
        <p:with-option name="base" select="replace(/*/text(),'[^/]+$','')">
            <p:pipe port="normalized" step="epub"/>
        </p:with-option>
    </px:fileset-create>
    <px:fileset-add-entry media-type="application/epub+zip" name="epub3-to-dtbook.add-epub-to-fileset">
        <p:with-option name="href" select="replace(/*/text(),'^.*/([^/]*)$','$1')">
            <p:pipe port="normalized" step="epub"/>
        </p:with-option>
    </px:fileset-add-entry>

    <px:message message="Validating EPUB"/>
    <px:nordic-epub3-validate.step name="epub3-to-dtbook.epub3-validate">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:with-option name="temp-dir" select="concat(/*/text(),'validate/')">
            <p:pipe port="normalized" step="temp-dir"/>
        </p:with-option>
        <p:with-option name="organization-specific-validation" select="$organization-specific-validation"/>
    </px:nordic-epub3-validate.step>

    <px:message message="Converting from EPUB to HTML"/>
    <px:nordic-epub3-to-html.step name="epub3-to-dtbook.epub3-to-html">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="epub3-to-dtbook.epub3-validate"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="report.out" step="epub3-to-dtbook.epub3-validate"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status.out" step="epub3-to-dtbook.epub3-validate"/>
        </p:input>
    </px:nordic-epub3-to-html.step>

    <px:message message="Validating HTML"/>
    <px:nordic-html-validate.step name="epub3-to-dtbook.html-validate" document-type="Nordic HTML (intermediary single-document)" check-images="false">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:with-option name="organization-specific-validation" select="$organization-specific-validation"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="epub3-to-dtbook.epub3-to-html"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="report.out" step="epub3-to-dtbook.epub3-to-html"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status.out" step="epub3-to-dtbook.epub3-to-html"/>
        </p:input>
    </px:nordic-html-validate.step>

    <p:group name="epub3-to-dtbook.html-move">
        <p:output port="fileset.out" primary="true"/>
        <p:output port="in-memory.out" sequence="true">
            <p:pipe port="in-memory.out" step="epub3-to-dtbook.html-move.inner"/>
        </p:output>
        <p:variable name="dirname" select="(//d:file[@media-type='application/x-dtbook+xml'], //d:file[@media-type='application/xhtml+xml'])[1]/replace(replace(@href,'.*/',''),'^(.+)\..*?$','$1')"/>
        <px:fileset-move name="epub3-to-dtbook.html-move.inner">
            <p:with-option name="new-base" select="concat(if (ends-with(/*/text(),'/')) then /*/text() else concat(/*/text(),'/'), $dirname, '/')">
                <p:pipe port="normalized" step="output-dir"/>
            </p:with-option>
            <p:input port="in-memory.in">
                <p:pipe port="in-memory.out" step="epub3-to-dtbook.html-validate"/>
            </p:input>
        </px:fileset-move>
    </p:group>

    <p:choose name="epub3-to-dtbook.choose-store-intermediary">
        <p:xpath-context>
            <p:pipe port="status.out" step="epub3-to-dtbook.html-validate"/>
        </p:xpath-context>
        <p:when test="$discard-intermediary-html='false' or (/*/@result='error' and $fail-on-error='true')">
            <px:message message="Storing intermediary HTML$1">
                <p:with-option name="param1" select="if ($discard-intermediary-html) then '' else ' (contains errors)'"/>
            </px:message>
            <px:nordic-html-store.step include-resources="false" name="epub3-to-dtbook.store-intermediary.html-store">
                <p:with-option name="fail-on-error" select="$fail-on-error"/>
                <p:input port="in-memory.in">
                    <p:pipe port="in-memory.out" step="epub3-to-dtbook.html-move"/>
                </p:input>
            </px:nordic-html-store.step>
            <p:filter name="epub3-to-dtbook.store-intermediary.blocking-store">
                <p:input port="source">
                    <p:pipe port="fileset.out" step="epub3-to-dtbook.html-move"/>
                </p:input>
                <p:with-option name="select" select="'/*'">
                    <!-- dynamically evaluated select expression connects to default connection thus forcing a dependency on px:nordic-html-store.step without using cx:depends-on. -->
                </p:with-option>
            </p:filter>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>

    <px:message message="Converting from HTML to DTBook"/>
    <px:nordic-html-to-dtbook.step name="epub3-to-dtbook.html-to-dtbook">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <!-- call with dtbook2005 option whether to convert to a DTBook 2005 or DTBook 1.1.0 -->
        <p:with-option name="dtbook2005" select="$dtbook2005"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="epub3-to-dtbook.html-move"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="report.out" step="epub3-to-dtbook.html-validate"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status.out" step="epub3-to-dtbook.html-validate"/>
        </p:input>
    </px:nordic-html-to-dtbook.step>
    
    <px:message message="Storing DTBook"/>
    <p:group name="epub3-to-dtbook.dtbook-move">
        <p:output port="fileset.out" primary="true"/>
        <p:output port="in-memory.out" sequence="true">
            <p:pipe port="in-memory.out" step="epub3-to-dtbook.dtbook-move.inner"/>
        </p:output>
        <p:variable name="dirname" select="(//d:file[@media-type='application/x-dtbook+xml'], //d:file[@media-type='application/xhtml+xml'])[1]/replace(replace(@href,'.*/',''),'^(.+)\..*?$','$1')"/>
        <px:fileset-move name="epub3-to-dtbook.dtbook-move.inner">
            <p:with-option name="new-base" select="concat(if (ends-with(/*/text(),'/')) then /*/text() else concat(/*/text(),'/'), $dirname, '/')">
                <p:pipe port="normalized" step="output-dir"/>
            </p:with-option>
            <p:input port="in-memory.in">
                <p:pipe port="in-memory.out" step="epub3-to-dtbook.html-to-dtbook"/>
            </p:input>
        </px:fileset-move>
    </p:group>
    <px:nordic-dtbook-store.step name="html-to-dtbook.dtbook-store">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="epub3-to-dtbook.dtbook-move"/>
        </p:input>
        <p:input port="report.in">
            <p:pipe port="report.out" step="epub3-to-dtbook.html-to-dtbook"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status.out" step="epub3-to-dtbook.html-to-dtbook"/>
        </p:input>
    </px:nordic-dtbook-store.step>

    <px:message message="Validating DTBook"/>
    <px:nordic-dtbook-validate.step name="epub3-to-dtbook.dtbook-validate" check-images="false">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <!-- call with dtbook2005 option whether to validate a DTBook 2005 or DTBook 1.1.0 -->
        <p:with-option name="dtbook2005" select="$dtbook2005"/>
        <p:with-option name="organization-specific-validation" select="$organization-specific-validation"/>
        <p:input port="report.in">
            <p:pipe port="report.out" step="html-to-dtbook.dtbook-store"/>
        </p:input>
        <p:input port="status.in">
            <p:pipe port="status.out" step="html-to-dtbook.dtbook-store"/>
        </p:input>
    </px:nordic-dtbook-validate.step>
    <p:sink/>

    <p:identity>
        <p:input port="source">
            <p:pipe port="report.out" step="epub3-to-dtbook.dtbook-validate"/>
        </p:input>
    </p:identity>
    <px:message message="Building report"/>
    <px:nordic-format-html-report name="epub3-to-dtbook.nordic-format-html-report"/>

    <p:store include-content-type="false" method="xhtml" omit-xml-declaration="false" name="epub3-to-dtbook.store-report" encoding="us-ascii">
        <p:with-option name="href" select="concat(/*/text(),if (ends-with(/*/text(),'/')) then '' else '/','report.xhtml')">
            <p:pipe port="normalized" step="html-report"/>
        </p:with-option>
    </p:store>
    <px:set-doctype doctype="&lt;!DOCTYPE html&gt;" name="epub3-to-dtbook.set-report-doctype">
        <p:with-option name="href" select="/*/text()">
            <p:pipe port="result" step="epub3-to-dtbook.store-report"/>
        </p:with-option>
    </px:set-doctype>
    <p:sink/>
    
    <px:nordic-fail-on-error-status name="status">
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
        <p:with-option name="output-dir" select="/*/text()">
            <p:pipe port="normalized" step="output-dir"/>
        </p:with-option>
        <p:input port="source">
            <p:pipe port="status.out" step="epub3-to-dtbook.dtbook-validate"/>
        </p:input>
    </px:nordic-fail-on-error-status>
    <p:sink/>

</p:declare-step>
