<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all">
	
	<xsl:include href="../../main/resources/xml/block-translate.xsl"/>
	
	<!--
	    Bypass identify-blocks for XSpec tests
	-->
	
	<xsl:template match="/*" priority="12">
		<xsl:variable name="wrapped">
			<_>
				<xsl:sequence select="."/>
			</_>
		</xsl:variable>
		<xsl:apply-templates select="$wrapped/_/*"/>
	</xsl:template>
	
	<xsl:template match="*" priority="11">
		<xsl:param name="source-style" as="element()*" tunnel="yes"/> <!-- css:property* -->
		<xsl:param name="result-style" as="element()*" tunnel="yes"> <!-- css:property* -->
			<!--
			    The default is also set in the root matcher of the "identify-blocks" mode in
			    abstract-block-translator.xsl, but needs to be repeated here for the XSpec tests.
			-->
			<xsl:call-template name="css:computed-properties">
				<xsl:with-param name="properties" select="$text-properties"/>
				<xsl:with-param name="context" select="$dummy-element"/>
				<xsl:with-param name="cascaded-properties" tunnel="yes" select="css:property('text-transform','none')"/>
			</xsl:call-template>
		</xsl:param>
		<xsl:next-match>
			<xsl:with-param name="source-style" tunnel="yes" select="$source-style"/>
			<xsl:with-param name="result-style" tunnel="yes" select="$result-style"/>
		</xsl:next-match>
	</xsl:template>
	
</xsl:stylesheet>
