<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-to-ssml" version="1.0"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		exclude-inline-prefixes="#all"
		name="main">

    <p:documentation>
      <p>Specialization of the SSML generation for EPUB3</p>
    </p:documentation>

    <p:input port="fileset.in" sequence="false"/>
    <p:input port="content.in" primary="true" sequence="false"/>
    <p:input port="sentence-ids" sequence="false"/>
    <p:input port="config"/>

    <p:output port="result" primary="true" sequence="true">
      <p:pipe port="result" step="ssml-gen" />
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/text-to-ssml/library.xpl" />
    <p:import href="http://www.daisy.org/pipeline/modules/tts-helpers/library.xpl"/>

    <px:get-tts-lexicons name="user-lexicons">
      <p:input port="config">
	<p:pipe port="config" step="main"/>
      </p:input>
    </px:get-tts-lexicons>

    <px:text-to-ssml name="ssml-gen">
      <p:input port="fileset.in">
	<p:pipe port="fileset.in" step="main"/>
      </p:input>
      <p:input port="content.in">
	<p:pipe port="content.in" step="main"/>
      </p:input>
      <p:input port="sentence-ids">
	<p:pipe port="sentence-ids" step="main"/>
      </p:input>
      <p:input port="user-lexicons">
	<p:pipe port="result" step="user-lexicons"/>
      </p:input>
      <p:with-option name="word-element" select="'span'"/>
      <p:with-option name="word-attr" select="'role'"/>
      <p:with-option name="word-attr-val" select="'word'"/>
    </px:text-to-ssml>

    <px:message message="End SSML generation for EPUB3"/>
    <p:sink/>

</p:declare-step>
