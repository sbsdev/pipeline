<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
    exclude-inline-prefixes="#all"
    type="sbs:dtbook-to-ebook" name="dtbook-to-ebook" version="1.0">

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

    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-odt/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/odt-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>

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
          <p:pipe step="dtbook-to-odt" port="source"/>
        </p:input>
      </px:dtbook-load>

      <!-- ====================== -->
      <!-- Clean the DTBook file -->
      <!-- ====================== -->

      <p:xslt name="filter-brl-contraction-hints">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="filterBrlContractionhints.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="filter-processing-instructions">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="filterProcessingInstructions.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="filter-toc">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="filterTOC.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="filter-comments">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="filterComments.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="filter-linenum-spans">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="filterLinenumSpans.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="add-empty-headers">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="addEmptyHeaders.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="add-boilerplate">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="addBoilerplate.xsl"/>
        </p:input>
      </p:xslt>

      <!-- ======================= -->
      <!-- Convert DTBook to EPUB3 -->
      <!-- ======================= -->

      <!-- Invoke the nordic migrator here with the following changes: -->
      <!-- 1. Do not include the fonts -->
      <!-- 2. Use a different accessibility css -->
      <!-- 3. Include the elements needed for a good braille rendition -->

      <px:nordic-dtbook-to-epub3 name="dtbook-to-epub3">
        <p:input port="content.xsl">
          <p:document href="content-sbs.xsl"/>
        </p:input>
        <p:input port="fileset.in">
          <p:pipe step="dtbook" port="fileset.out"/>
        </p:input>
        <p:input port="in-memory.in">
          <p:pipe step="dtbook" port="in-memory.out"/>
        </p:input>
        <p:with-option name="temp-dir" select="$temp-dir">
          <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
      </px:nordic-dtbook-to-epub3>

      <!-- ================================ -->
      <!-- Add a Braille Rendition to EPUB3 -->
      <!-- ================================ -->

      <!-- =========== -->
      <!-- Store EPUB3 -->
      <!-- =========== -->

    </p:group>

  </p:declare-step>
