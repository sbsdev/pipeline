<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="sbs:xml-to-pef" version="1.0"
                xmlns:sbs="http://www.sbs.ch"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc">
    
    <!--
        options with defaults and documentation
    -->
    <p:option name="stylesheet" select="'http://www.sbs.ch/pipeline/modules/braille/default.scss'"/>
    
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
    
    <p:option name="ascii-file-format" select="'(id:&quot;ch.sbs.pipeline.braille.pef.impl.SBSFileFormat&quot;)'"/>
    
    <p:option name="page-width" select="'28'"/>
    <p:option name="page-height" select="'28'"/>
    <p:option name="document-identifier" select="''"/>
    
    <!--
        inherit defaults and documentation for other options
    -->
    <p:option name="pef-output-dir"/>
    <p:option name="brf-output-dir"/>
    <p:option name="preview-output-dir"/>
    <p:option name="temp-dir"/>
    <p:option name="include-preview"/>
    <p:option name="include-brf"/>
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
    
    <!--
        Do nothing; this script is only intended to be extended by other scripts
    -->
    <p:sink>
        <p:input port="source">
            <p:empty/>
        </p:input>
    </p:sink>
    
</p:declare-step>
