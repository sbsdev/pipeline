<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
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

    <!--
        FIXME: rename to "status" (https://github.com/daisy/pipeline-framework/issues/121)
    -->
    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Status</h2>
            <p px:role="desc">Whether or not the conversion was successful.</p>
        </p:documentation>
    </p:output>
    
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/nordic-epub3-dtbook-migrator/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/epub3-to-epub3/epub3-to-epub3.xpl"/>

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

      <!-- We assume that if an image has a long description it will
           be inside a prodnote and that prodnote will be bundled with
           the image inside an imggroup. That means we do not have
           manually link the two elements using imgrefs. However as
	   the upstream off the shelf EPUB creation code in the
	   pipeline2 relies on imgrefs. For that reason we insert them
	   here.
	   We add an imageref to the first prodnote inside an image
	   group unless there are some existing elements within the
	   same imggroup that actually have an imgref already -->
      <p:xslt name="add-image-ids">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/addImageIds.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="add-image-refs">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/addImageRefs.xsl"/>
        </p:input>
      </p:xslt>

      <p:xslt name="add-image-description-boilerplate">
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xslt/addImageDescriptionBoilerplate.xsl"/>
        </p:input>
      </p:xslt>

      <px:message severity="INFO" message="DTBook preprocessing done"/>
      
      <p:identity name="dtbook-xml-preprocessed"/>

      <!-- ======================= -->
      <!-- Convert DTBook to EPUB3 -->
      <!-- ======================= -->

      <!-- Use the dtbook to html step from the nordic migrator -->
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

      <!-- Instead of adding fonts and the default accessibility css from the nordic
           migrator we include a simple accessibility css -->
      <px:fileset-load media-types="application/xhtml+xml" name="load-html">
	<p:input port="in-memory">
	  <p:pipe port="in-memory.out" step="html"/>
	</p:input>
      </px:fileset-load>

      <!-- Add a link to the CSS style sheet -->
      <p:insert match="/html:html/html:head" position="last-child" name="insert-css-link">
	<p:input port="insertion">
          <p:inline exclude-inline-prefixes="#all">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="css/accessibility.css"/>
          </p:inline>
	</p:input>
      </p:insert>

      <!-- Add the css file to the fileset -->
      <px:fileset-add-entry media-type="text/css">
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

      <px:message severity="INFO" message="Added accessibility CSS"/>
      
      <!-- Use the default html to epub3 converter from the nordic migrator -->
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
	<p:with-option name="output-dir" select="$output-dir"/>
      </px:nordic-epub3-store.step>
      
      <px:message severity="INFO" message="EPUB 3 created"/>
      
      <!-- ================================ -->
      <!-- Add a Braille Rendition to EPUB3 -->
      <!-- ================================ -->

      <!-- Disabled until the board figures out if we really want a Braille Rendition -->
      <!-- <px:epub3-to-epub3> -->
      <!--   <p:with-option name="source" select="//d:file[1]/resolve-uri(@href,base-uri(.))"> -->
      <!--     <p:pipe step="epub3-store" port="fileset.out"/> -->
      <!--   </p:with-option> -->
      <!--   <p:with-option name="output-dir" select="$output-dir"/> -->
      <!-- </px:epub3-to-epub3> -->

    </p:group>
    <p:identity name="result.fileset"/>
    <p:sink/>
    
    <p:identity name="status" cx:depends-on="result.fileset">
      <p:input port="source">
        <p:inline>
          <d:validation-status result="ok"/>
        </p:inline>
      </p:input>
    </p:identity>
    
  </p:declare-step>
