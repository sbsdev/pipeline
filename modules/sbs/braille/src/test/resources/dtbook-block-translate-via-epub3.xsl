<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:brl="http://www.daisy.org/z3986/2009/braille/"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:this="dtbook-block-translate-via-epub3.xsl"
                exclude-result-prefixes="#all">
	
	<!--
	    Three stylesheets are combined here. Each stylesheet is used for a different step in the
	    transformation. xsl:apply-imports is used as a trick to not let the stylesheets interfere
	    with each other.
	    
	    A proper solution would use a different mode for each stylesheet.
	-->
	
	<xsl:import href="epub3-dtbook-migrator.xsl"/>
	
	<!-- @Override -->
	<xsl:variable name="normalize-space-in-h" select="false()"/>
	
	<!-- @Override -->
	<xsl:variable name="generate-ids" select="false()"/>
	
	<!-- @Override -->
	<xsl:variable name="transform-longdesc-to" select="'imgref'"/>
	
	<!-- @Override -->
	<xsl:template name="f:attrs" xmlns:f="http://www.daisy.org/pipeline/modules/nordic-epub3-dtbook-migrator/dtbook-to-epub3.xsl">
		<xsl:call-template name="f:coreattrs"/>
		<xsl:call-template name="f:i18n"/>
		<xsl:copy-of select="@brl:*"/>
	</xsl:template>
	
	<!-- @Override -->
	<xsl:template name="f:attrs" xmlns:f="http://www.daisy.org/pipeline/modules/nordic-epub3-dtbook-migrator/epub3-to-dtbook.xsl">
		<xsl:call-template name="f:coreattrs"/>
		<xsl:call-template name="f:i18n"/>
		<xsl:copy-of select="@brl:*"/>
	</xsl:template>
	
	<xsl:include href="block-translate.xsl"/>
	
	<xsl:template match="@*|node()" priority="1000">
		<xsl:param name="this:mode" as="xs:string" tunnel="yes" select="'#default'"/>
		<xsl:choose>
			<xsl:when test="$this:mode=('dtbook-to-epub3','epub3-to-dtbook')">
				<xsl:apply-imports/>
			</xsl:when>
			<xsl:when test="$this:mode='block-translate'">
				<xsl:next-match/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="epub3">
					<xsl:apply-templates mode="dtbook-to-epub3" select="."/>
				</xsl:variable>
				<xsl:variable name="translated-epub3">
					<xsl:apply-templates mode="block-translate" select="$epub3"/>
				</xsl:variable>
				<xsl:variable name="translated-dtbook">
					<xsl:apply-templates mode="epub3-to-dtbook" select="$translated-epub3"/>
				</xsl:variable>
				<xsl:sequence select="$translated-dtbook/node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template mode="dtbook-to-epub3" match="dtb:*|dtb:*/@*|dtb:*/text()|brl:*">
		<xsl:apply-templates select=".">
			<xsl:with-param name="this:mode" select="'dtbook-to-epub3'" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template mode="block-translate" match="html:*|html:*/@*|text()|brl:*|css:block">
		<xsl:apply-templates select=".">
			<xsl:with-param name="this:mode" select="'block-translate'" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template mode="epub3-to-dtbook" match="html:*|html:*/@*|html:*/text()|brl:*">
		<xsl:apply-templates select=".">
			<xsl:with-param name="this:mode" select="'epub3-to-dtbook'" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template mode="dtbook-to-epub3 block-translate epub3-to-dtbook" match="*">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:apply-templates mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
