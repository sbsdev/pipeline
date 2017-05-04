<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:brl="http://www.daisy.org/z3986/2009/braille/"
                xmlns:f="http://www.daisy.org/pipeline/modules/nordic-epub3-dtbook-migrator/dtbook-to-epub3.xsl"
                xmlns="http://www.w3.org/1999/xhtml">
	
	<xsl:import href="http://www.daisy.org/pipeline/modules/nordic-epub3-dtbook-migrator/dtbook-to-epub3.xsl"/>
	
	<!-- @Override -->
	<xsl:variable name="generate-ids" select="false()"/>
	
	<!-- @Override -->
	<xsl:variable name="supported-list-types" select="('ol','ul','pl')"/>
	
	<!-- @Override -->
	<xsl:variable name="parse-list-marker" select="false()"/>
	
	<!-- @Override -->
	<xsl:variable name="add-tbody" select="false()"/>
	
	<!-- @Override -->
	<xsl:template name="f:attrs">
		<xsl:call-template name="f:coreattrs"/>
		<xsl:call-template name="f:i18n"/>
		<xsl:copy-of select="@brl:*"/>
	</xsl:template>
	
	<xsl:template match="brl:*">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="brl:volume">
		<br class="braille-volume-break"/>
	</xsl:template>
	
	<xsl:template match="brl:volume[@brl:grade]">
		<br class="braille-volume-break-grade-{@brl:grade}"/>
	</xsl:template>
	
</xsl:stylesheet>
