<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline type="pxi:block-translate" version="1.0"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
            xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
            xmlns:html="http://www.w3.org/1999/xhtml"
            exclude-inline-prefixes="#all">

	<p:option name="contraction-grade" required="true"/>
	<p:option name="text-transform-query-base" required="true"/>
	<p:option name="no-wrap" select="'false'"/>

	<p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>

	<css:parse-properties properties="display text-transform"/>
	
	<!-- ================== -->
	<!-- HANDLE DOWNGRADING -->
	<!-- ================== -->

	<p:xslt>
          <p:input port="stylesheet">
            <p:document href="handle-downgrading.xsl"/>
          </p:input>
          <p:input port="parameters">
            <p:empty/>
          </p:input>
	</p:xslt>

	<!-- =============== -->
	<!-- HANDLE PRODNOTE -->
	<!-- =============== -->

	<p:xslt>
          <p:input port="stylesheet">
            <p:document href="handle-prodnote.xsl"/>
          </p:input>
          <p:input port="parameters">
            <p:empty/>
          </p:input>
	</p:xslt>

	<!-- ========= -->
	<!-- TRANSLATE -->
	<!-- ========= -->

	<p:xslt initial-mode="identify-blocks">
		<p:input port="stylesheet">
			<p:document href="block-translate.xsl"/>
		</p:input>
		<p:with-param name="contraction-grade" select="$contraction-grade"/>
		<p:with-param name="text-transform-query-base" select="$text-transform-query-base"/>
		<p:with-param name="hyphenation" select="'true'"/>
		<p:with-param name="no-wrap" select="$no-wrap"/>
	</p:xslt>
	
	<!--
		This is to force the base URI of all elements to be the same, because for some reason some
		parts would otherwise get a different base URI.
	-->
	<p:group>
		<p:documentation>
			First make base URIs explicit using the p:add-xml-base step, then remove the
			attributes. Because simply deleting an attribute named xml:base with p:delete does not
			change the actual base URI of the element, we first change the value using
			p:add-attribute.
		</p:documentation>
		<p:add-xml-base/>
		<p:choose>
			<p:documentation>
				For EPUBs, only change the base URIs within each body element. This is needed to
				handle cross-references correctly.
			</p:documentation>
			<p:when test="/*/html:body or /_/*/html:body">
				<p:viewport match="/*/html:body | /_/*/html:body">
					<p:add-attribute match="*[@xml:base]" attribute-name="xml:base">
						<p:with-option name="attribute-value" select="/*/@xml:base"/>
					</p:add-attribute>
					<p:delete match="@xml:base"/>
				</p:viewport>
			</p:when>
			<p:otherwise>
				<p:add-attribute match="*[@xml:base]" attribute-name="xml:base">
					<p:with-option name="attribute-value" select="/*/@xml:base"/>
				</p:add-attribute>
				<p:delete match="@xml:base"/>
			</p:otherwise>
		</p:choose>
	</p:group>
	
</p:pipeline>
