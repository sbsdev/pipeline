<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:brl="http://www.daisy.org/z3986/2009/braille/">
	
	<xsl:import href="http://www.daisy.org/pipeline/modules/nordic-epub3-dtbook-migrator/dtbook-to-epub3.xsl"/>
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/nordic-epub3-dtbook-migrator/epub3-to-dtbook.xsl"/>
	
	<xsl:template match="dtb:*" priority="1">
		<xsl:apply-imports/>
	</xsl:template>
	
	<xsl:template match="html:*" priority="1">
		<xsl:next-match/>
	</xsl:template>
	
	<xsl:template match="brl:*">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
