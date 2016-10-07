<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                exclude-result-prefixes="#all">
	
	<xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
	
	<xsl:param name="projectBaseDir"/>
	
	<xsl:template match="/*">
		<xsl:copy>
			<xsl:attribute name="xml:base" select="base-uri(.)"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="/*/@stylesheet">
		<xsl:variable name="stylesheet" select="pf:relativize-uri(resolve-uri(., base-uri(.)), $projectBaseDir)"/>
		<xsl:choose>
			<xsl:when test="$stylesheet='src/test/resources/block-translate.xsl'">
				<xsl:attribute name="{name()}"
				               select="pf:relativize-uri(
				                         resolve-uri(
				                           'src/test/resources/dtbook-block-translate-via-epub3.xsl',
				                           $projectBaseDir),
				                         base-uri(.))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">Error</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
