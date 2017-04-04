<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:sbs="http://www.sbs.ch"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                type="sbs:dtbook-to-epub3-to-pef"
                name="main">
	
	<p:input port="source" primary="true"/>
	<p:input port="parameters" kind="parameter" primary="false"/>
	
	<!--
	    Stylesheets apply to EPUB3 but are resolved relative to DTBook
	-->
	<p:option name="stylesheet"/>
	
	<p:option name="pef-output-dir"/>
	<p:option name="brf-output-dir"/>
	<p:option name="preview-output-dir"/>
	<p:option name="temp-dir"/>
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
	
	<p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl"/>
	<p:import href="http://www.daisy.org/pipeline/modules/nordic-epub3-dtbook-migrator/library.xpl"/>
	<p:import href="epub3-to-pef.xpl"/>
	
	<px:tempdir>
		<p:with-option name="href" select="if ($temp-dir!='') then $temp-dir else $pef-output-dir"/>
	</px:tempdir>
	<p:group>
	<p:variable name="temp-dir" select="string(/c:result)"/>
	
	<px:dtbook-load name="dtbook">
		<p:input port="source">
			<p:pipe step="main" port="source"/>
		</p:input>
	</px:dtbook-load>
	
	<px:nordic-dtbook-to-html.step name="html"
	                               fail-on-error="true">
		<p:input port="fileset.in">
			<p:pipe step="dtbook" port="fileset.out"/>
		</p:input>
		<p:input port="in-memory.in">
			<p:pipe step="dtbook" port="in-memory.out"/>
		</p:input>
		<p:input port="xslt">
			<p:document href="dtbook-to-epub3.xsl"/>
		</p:input>
		<p:with-option name="temp-dir" select="concat($temp-dir,'dtbook-to-html/')"/>
	</px:nordic-dtbook-to-html.step>
	
	<px:nordic-html-to-epub3.step name="epub3"
	                              fail-on-error="true"
	                              compatibility-mode="true">
		<p:input port="fileset.in">
			<p:pipe step="html" port="fileset.out"/>
		</p:input>
		<p:input port="in-memory.in">
			<p:pipe step="html" port="in-memory.out"/>
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
		<p:with-option name="output-dir" select="concat($temp-dir,'epub3/')"/>
	</px:nordic-epub3-store.step>
	
	<px:fileset-filter media-types="application/epub+zip"/>
	
	<px:assert message="There must be exactly one EPUB in the fileset (was: $1)." error-code="NORDICDTBOOKEPUB021">
		<p:with-option name="test" select="count(/*/d:file)=1"/>
		<p:with-option name="param1" select="count(/*/d:file)"/>
	</px:assert>
	
	<px:move name="epub3-move" cx:depends-on="epub3-store">
		<p:with-option name="href" select="resolve-uri(/*/d:file/(@original-href,@href)[1],/*/*/base-uri(.))"/>
		<p:with-option name="target" select="concat($temp-dir,'epub3/',replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1'),'.epub')">
			<p:pipe step="main" port="source"/>
		</p:with-option>
	</px:move>
	
	<sbs:epub3-to-pef>
		<p:with-option name="epub" select="string(/c:result)">
			<p:pipe step="epub3-move" port="result"/>
		</p:with-option>
		<p:with-option name="pef-output-dir" select="$pef-output-dir"/>
		<p:with-option name="brf-output-dir" select="$brf-output-dir"/>
		<p:with-option name="preview-output-dir" select="$preview-output-dir"/>
		<p:with-option name="stylesheet" select="string-join(
		                                           for $s in tokenize($stylesheet,'\s+')[not(.='')] return resolve-uri($s,base-uri(/*)),
		                                           ' ')">
			<p:pipe step="main" port="source"/>
		</p:with-option>
		<p:with-option name="contraction-grade" select="$contraction-grade"/>
		<p:with-option name="ascii-file-format" select="$ascii-file-format"/>
		<p:with-option name="include-preview" select="$include-preview"/>
		<p:with-option name="include-brf" select="$include-brf"/>
		<p:with-option name="page-width" select="$page-width"/>
		<p:with-option name="page-height" select="$page-height"/>
		<p:with-option name="left-margin" select="$left-margin"/>
		<p:with-option name="duplex" select="$duplex"/>
		<p:with-option name="levels-in-footer" select="$levels-in-footer"/>
		<p:with-option name="main-document-language" select="$main-document-language"/>
		<p:with-option name="hyphenation" select="$hyphenation"/>
		<p:with-option name="line-spacing" select="$line-spacing"/>
		<p:with-option name="tab-width" select="$tab-width"/>
		<p:with-option name="capital-letters" select="$capital-letters"/>
		<p:with-option name="accented-letters" select="$accented-letters"/>
		<p:with-option name="polite-forms" select="$polite-forms"/>
		<p:with-option name="downshift-ordinal-numbers" select="$downshift-ordinal-numbers"/>
		<p:with-option name="include-captions" select="$include-captions"/>
		<p:with-option name="include-images" select="$include-images"/>
		<p:with-option name="include-image-groups" select="$include-image-groups"/>
		<p:with-option name="include-line-groups" select="$include-line-groups"/>
		<p:with-option name="text-level-formatting" select="$text-level-formatting"/>
		<p:with-option name="include-note-references" select="$include-note-references"/>
		<p:with-option name="include-production-notes" select="$include-production-notes"/>
		<p:with-option name="show-braille-page-numbers" select="$show-braille-page-numbers"/>
		<p:with-option name="show-print-page-numbers" select="$show-print-page-numbers"/>
		<p:with-option name="force-braille-page-break" select="$force-braille-page-break"/>
		<p:with-option name="toc-depth" select="$toc-depth"/>
		<p:with-option name="footnotes-placement" select="$footnotes-placement"/>
		<p:with-option name="colophon-metadata-placement" select="$colophon-metadata-placement"/>
		<p:with-option name="rear-cover-placement" select="$rear-cover-placement"/>
		<p:with-option name="number-of-sheets" select="$number-of-sheets"/>
		<p:with-option name="maximum-number-of-sheets" select="$maximum-number-of-sheets"/>
		<p:with-option name="minimum-number-of-sheets" select="$minimum-number-of-sheets"/>
		<p:with-option name="document-identifier" select="$document-identifier"/>
		<p:input port="parameters">
			<p:pipe step="main" port="parameters"/>
		</p:input>
		<p:with-option name="temp-dir" select="concat($temp-dir,'epub3-to-pef/')"/>
	</sbs:epub3-to-pef>
	
	</p:group>
	
</p:declare-step>
