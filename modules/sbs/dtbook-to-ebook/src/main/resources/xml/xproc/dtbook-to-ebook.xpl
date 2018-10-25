<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-inline-prefixes="#all"
    type="sbs:dtbook-to-ebook" name="main" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook to E-Book (SBS)</h1>
        <p px:role="desc">Transforms a DTBook (DAISY 3 XML) document into an E-Book.</p>
    </p:documentation>

    <p:input port="source" primary="true" px:name="source" px:media-type="application/x-dtbook+xml">
        <p:documentation>
            <h2 px:role="name">source</h2>
            <p px:role="desc">Input DTBook.</p>
        </p:documentation>
    </p:input>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Directory for storing result files.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/nordic-epub3-dtbook-migrator/library.xpl"/>

    <!-- =============== -->
    <!-- CREATE TEMP DIR -->
    <!-- =============== -->

    <px:tempdir name="temp-dir">
      <p:with-option name="href" select="$output-dir"/>
    </px:tempdir>

    <p:group>
      <p:variable name="temp-dir" select="string(/c:result)">
        <p:pipe step="temp-dir" port="result"/>
      </p:variable>

      <!-- =========== -->
      <!-- LOAD DTBOOK -->
      <!-- =========== -->

      <px:dtbook-load name="dtbook">
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
      </px:dtbook-load>

      <px:fileset-load media-types="application/x-dtbook+xml">
	<p:input port="in-memory">
	  <p:pipe step="dtbook" port="in-memory.out"/>
	</p:input>
      </px:fileset-load>
	
      <!-- ===================== -->
      <!-- Clean the DTBook file -->
      <!-- ===================== -->

      <p:xslt name="filter-brl-contraction-hints">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/filterBrlContractionhints.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="filter-processing-instructions">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/filterProcessingInstructions.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="filter-toc">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/filterTOC.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="filter-comments">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/filterComments.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="filter-linenum-spans">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/filterLinenumSpans.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="add-empty-headers">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/addEmptyHeaders.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="add-boilerplate">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/addBoilerplate.xsl"/>
        </p:input>
      </p:xslt>

      <p:identity name="dtbook-xml-preprocessed"/>
      
      <!-- ======================= -->
      <!-- Convert DTBook to EPUB3 -->
      <!-- ======================= -->

      <!-- Invoke the nordic migrator here with the following changes: -->
      <!-- 1. Do not include the fonts -->
      <!-- 2. Use a different accessibility css -->
      <!-- 3. Include the elements needed for a good braille rendition -->

      <px:nordic-dtbook-to-html.step name="html"
	                             fail-on-error="true">
	<p:input port="fileset.in">
	  <p:pipe step="dtbook" port="fileset.out"/>
	</p:input>
	<p:input port="in-memory.in">
	  <p:pipe step="dtbook-xml-preprocessed" port="result"/>
	</p:input>
	<p:with-option name="temp-dir" select="concat($temp-dir,'dtbook-to-html/')"/>
      </px:nordic-dtbook-to-html.step>
      
      <px:fileset-load media-types="application/xhtml+xml" name="load-html">
	<p:input port="in-memory">
	  <p:pipe port="in-memory.out" step="html"/>
	</p:input>
      </px:fileset-load>

      <!-- Link to the CSS style sheet from the HTML. -->
      <p:insert match="/html:html/html:head" position="last-child" name="insert-css-link">
	<p:input port="insertion">
          <p:inline exclude-inline-prefixes="#all">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="css/accessibility.css"/>
          </p:inline>
	</p:input>
      </p:insert>

      <!-- Add the css -->
      <px:fileset-add-entry media-type="text/plain">
	<p:input port="source">
	  <p:pipe port="fileset.out" step="html"/>
	</p:input>
	<p:with-option name="href" select="resolve-uri('css/accessibility.css', base-uri(/))"/>
	<p:with-option name="original-href" select="resolve-uri('../../../css/accessibility.css', base-uri(/))">
	  <p:inline>
	    <irrelevant/>
	  </p:inline>
	</p:with-option>
      </px:fileset-add-entry>

      <px:nordic-html-to-epub3.step name="epub3"
	                            fail-on-error="true"
	                            compatibility-mode="true">
	<p:input port="in-memory.in">
	  <!-- for now the in-memory contains only the html document,
	       we're ignoring other stuff that it could contain -->
	  <p:pipe step="insert-css-link" port="result"/>
	</p:input>
	<p:with-option name="temp-dir" select="concat($temp-dir,'html-to-epub3/')"/>
      </px:nordic-html-to-epub3.step>
      
      <px:nordic-epub3-store.step name="epub3-store"
	                          fail-on-error="true">
	<p:input port="fileset.in">
	  <p:pipe step="epub3" port="fileset.out"/>
	</p:input>
	<p:input port="in-memory.in">
	  <p:pipe step="epub3" port="in-memory.out"/>
	</p:input>
	<p:with-option name="output-dir" select="concat($output-dir,'epub3/')"/>
      </px:nordic-epub3-store.step>
      <p:sink/>
	
      <!-- ================================ -->
      <!-- Add a Braille Rendition to EPUB3 -->
      <!-- ================================ -->

      <!-- =========== -->
      <!-- Store EPUB3 -->
      <!-- =========== -->

    </p:group>

  </p:declare-step>
