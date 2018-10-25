<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    type="px:nordic-html-add-accessibility-css.step" name="main" version="1.0" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:cx="http://xmlcalabash.com/ns/extensions">

    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true">
        <p:empty/>
    </p:input>
    <p:output port="fileset.out" primary="true"/>

    <p:output port="in-memory.out" sequence="true">
      <p:pipe step="insert-css-link" port="result"/>
      
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>

    <px:fileset-load media-types="application/xhtml+xml" name="load-html">
      <p:input port="in-memory">
	<p:pipe port="in-memory.in" step="main"/>
      </p:input>
    </px:fileset-load>

    <p:insert match="/html:html/html:head" position="last-child" name="insert-css-link">
      <p:input port="insertion">
        <p:inline exclude-inline-prefixes="#all">
          <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="css/accessibility.css"/>
        </p:inline>
      </p:input>
    </p:insert>

    <p:group>
      <p:variable name="html-base" select="base-uri(/*)"/>
      <p:variable name="doc-base" select="base-uri(/)">
	<p:inline>
	  <irrelevant/>
	</p:inline>
      </p:variable>
  
      <px:mkdir name="mkdir">
	<p:with-option name="href" select="resolve-uri('css/fonts/opendyslexic/',$html-base)"/>
      </px:mkdir>

      <px:copy-resource name="dtbook-to-html.step.store1" cx:depends-on="mkdir">
	<p:with-option name="href" select="resolve-uri('../../../css/accessibility.css',$doc-base)"/>
	<p:with-option name="target"
		       select="resolve-uri('css/accessibility.css', $html-base)"/>
      </px:copy-resource>
      <px:copy-resource name="dtbook-to-html.step.store2" cx:depends-on="mkdir">
	<p:with-option name="href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexic-Regular.otf',$doc-base)"/>
	<p:with-option name="target"
		       select="resolve-uri('css/fonts/opendyslexic/OpenDyslexic-Regular.otf',
			       $html-base)"/>
      </px:copy-resource>
      <px:copy-resource name="dtbook-to-html.step.store3" cx:depends-on="mkdir">
	<p:with-option name="href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexic-Italic.otf',$doc-base)"/>
	<p:with-option name="target"
		       select="resolve-uri('css/fonts/opendyslexic/OpenDyslexic-Italic.otf',
			       $html-base)"/>
      </px:copy-resource>
      <px:copy-resource name="dtbook-to-html.step.store4" cx:depends-on="mkdir">
	<p:with-option name="href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexic-Bold.otf',$doc-base)"/>
	<p:with-option name="target"
		       select="resolve-uri('css/fonts/opendyslexic/OpenDyslexic-Bold.otf',
			       $html-base)"/>
      </px:copy-resource>
      <px:copy-resource name="dtbook-to-html.step.store5" cx:depends-on="mkdir">
	<p:with-option name="href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexic-BoldItalic.otf',$doc-base)"/>
	<p:with-option name="target"
		       select="resolve-uri('css/fonts/opendyslexic/OpenDyslexic-BoldItalic.otf',
			       $html-base)"/>
      </px:copy-resource>
      <px:copy-resource name="dtbook-to-html.step.store6" cx:depends-on="mkdir">
	<p:with-option name="href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexicMono-Regular.otf',$doc-base)"/>
	<p:with-option name="target"
		       select="resolve-uri('css/fonts/opendyslexic/OpenDyslexicMono-Regular.otf',
			       $html-base)"/>
      </px:copy-resource>
      <px:copy-resource name="dtbook-to-html.step.store7" cx:depends-on="mkdir">
	<p:with-option name="href" select="resolve-uri('../../../css/fonts/opendyslexic/LICENSE.txt',$doc-base)"/>
	<p:with-option name="target"
		       select="resolve-uri('css/fonts/opendyslexic/LICENSE.txt',
			       $html-base)"/>
      </px:copy-resource>
      <p:identity>
	<p:input port="source">
          <p:pipe port="result" step="dtbook-to-html.step.store1"/>
          <p:pipe port="result" step="dtbook-to-html.step.store2"/>
          <p:pipe port="result" step="dtbook-to-html.step.store3"/>
          <p:pipe port="result" step="dtbook-to-html.step.store4"/>
          <p:pipe port="result" step="dtbook-to-html.step.store5"/>
          <p:pipe port="result" step="dtbook-to-html.step.store6"/>
          <p:pipe port="result" step="dtbook-to-html.step.store7"/>
	</p:input>
      </p:identity>
    </p:group>
    <p:sink name="store-resources"/>
    
    <p:identity>
      <p:input port="source">
	<p:pipe port="fileset.in" step="main"/>
      </p:input>
    </p:identity>
    
    <px:fileset-add-entry media-type="text/css" href="css/accessibility.css"/>
    <px:fileset-add-entry media-type="application/x-font-opentype" href="css/fonts/opendyslexic/OpenDyslexic-Regular.otf"/>
    <px:fileset-add-entry media-type="application/x-font-opentype" href="css/fonts/opendyslexic/OpenDyslexic-Italic.otf"/>
    <px:fileset-add-entry media-type="application/x-font-opentype" href="css/fonts/opendyslexic/OpenDyslexic-Bold.otf"/>
    <px:fileset-add-entry media-type="application/x-font-opentype" href="css/fonts/opendyslexic/OpenDyslexic-BoldItalic.otf"/>
    <px:fileset-add-entry media-type="application/x-font-opentype" href="css/fonts/opendyslexic/OpenDyslexicMono-Regular.otf"/>
    <px:fileset-add-entry media-type="text/plain" href="css/fonts/opendyslexic/LICENSE.txt"/>

    <p:identity cx:depends-on="store-resources"/>    

  </p:declare-step>

