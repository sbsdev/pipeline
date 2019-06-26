<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                type="px:dtbook-to-daisy3.script" name="main"
                px:input-filesets="dtbook"
                px:output-filesets="daisy3 mp3"
                exclude-inline-prefixes="#all">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1 px:role="name">DTBook to DAISY 3</h1>
    <p px:role="desc">Converts multiple DTBooks to DAISY 3 format</p>
    <a px:role="homepage" href="http://daisy.github.io/pipeline/modules/dtbook-to-daisy3">
      Online documentation
    </a>
  </p:documentation>

  <p:input port="source" primary="true" px:media-type="application/x-dtbook+xml">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">DTBook file</h2>
      <p px:role="desc">The 2005-3 DTBook file to be transformed.</p>
    </p:documentation>
  </p:input>

  <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Status</h2>
      <p px:role="desc" xml:space="preserve">Whether or not the conversion was successful.

When text-to-speech is enabled, the conversion may output a (incomplete) DAISY 3 even if the text-to-speech process has errors.</p>
    </p:documentation>
    <p:pipe step="convert" port="validation-status"/>
  </p:output>

  <p:option name="publisher" required="false" px:type="string" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Publisher</h2>
      <p px:role="desc">The agency responsible for making the Digital
      Talking Book available. If left blank, it will be retrieved from
      the DTBook meta-data.</p>
    </p:documentation>
  </p:option>

  <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">DAISY 3</h2>
      <p px:role="desc">The resulting DAISY 3 publication.</p>
    </p:documentation>
  </p:option>

  <p:option name="tts-config" required="false" px:type="anyFileURI" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Text-To-Speech configuration file</h2>
      <p px:role="desc" xml:space="preserve">Configuration file for the Text-To-Speech.

[More details on the configuration file format](http://daisy.github.io/pipeline/modules/tts-common/doc/tts-config.html).</p>
    </p:documentation>
  </p:option>

  <p:option name="audio" required="false" px:type="boolean" select="'false'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Enable Text-To-Speech</h2>
      <p px:role="desc">Whether to use a speech synthesizer to produce audio files.</p>
    </p:documentation>
  </p:option>

  <p:option name="with-text" required="false" px:type="boolean" select="'true'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">With text</h2>
      <p px:role="desc">Includes DTBook in output, as opposed to audio only.</p>
    </p:documentation>
  </p:option>

  <!-- TODO: throw an error if both 'audio' and 'with-text' are false -->

  <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/tts-helpers/library.xpl"/>
  <p:import href="dtbook-to-daisy3.convert.xpl"/>

  <px:normalize-uri name="output-dir-uri">
    <p:with-option name="href" select="concat($output-dir,'/')"/>
  </px:normalize-uri>
  
  <px:dtbook-load name="load"/>

  <p:choose name="tts-config">
    <p:when test="$tts-config != ''">
      <p:output port="result"/>
      <p:load>
	<p:with-option name="href" select="$tts-config"/>
      </p:load>
    </p:when>
    <p:otherwise>
      <p:output port="result">
	<p:inline>
	  <d:config/>
	</p:inline>
      </p:output>
      <p:sink/>
    </p:otherwise>
  </p:choose>

  <px:dtbook-to-daisy3 name="convert" px:progress="1">
    <p:input port="fileset.in">
      <p:pipe step="load" port="fileset.out"/>
    </p:input>
    <p:input port="in-memory.in">
      <p:pipe step="load" port="in-memory.out"/>
    </p:input>
    <p:input port="tts-config">
      <p:pipe step="tts-config" port="result"/>
    </p:input>
    <p:with-option name="publisher" select="$publisher"/>
    <p:with-option name="output-fileset-base" select="/c:result/string()">
      <p:pipe step="output-dir-uri" port="normalized"/>
    </p:with-option>
    <p:with-option name="audio" select="$audio"/>
    <p:with-option name="audio-only" select="$with-text = 'false'"/>
  </px:dtbook-to-daisy3>

  <px:fileset-store name="store">
    <p:input port="fileset.in">
      <p:pipe port="fileset.out" step="convert"/>
    </p:input>
    <p:input port="in-memory.in">
      <p:pipe port="in-memory.out" step="convert"/>
    </p:input>
  </px:fileset-store>

  <px:rm-audio-files cx:depends-on="store">
    <p:input port="source">
      <p:pipe port="audio-map" step="convert"/>
    </p:input>
  </px:rm-audio-files>

</p:declare-step>
