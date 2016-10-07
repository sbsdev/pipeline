<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.daisy.org/ns/xprocspec"
                xmlns:sbs="http://www.sbs.ch"
                exclude-result-prefixes="#all">
	
	<xsl:template match="/*">
		<xsl:copy>
			<xsl:namespace name="sbs" select="'http://www.sbs.ch'"/>
			<xsl:attribute name="xml:base" select="base-uri(.)"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
		<xsl:if test="not(@script)">
			<xsl:message terminate="yes">Error</xsl:message>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="/*/@script">
		<xsl:choose>
			<xsl:when test=".='http://www.sbs.ch/pipeline/modules/braille/dtbook-to-pef.xpl'">
				<xsl:attribute name="{name()}"
				               select="'http://www.sbs.ch/pipeline/modules/braille/internal/dtbook-to-epub3-to-pef.xpl'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">Error</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:variable name="sbs:dtbook-to-pef" as="xs:QName" select="QName('http://www.sbs.ch','dtbook-to-pef')"/>
	
	<xsl:template match="x:call/@step">
		<xsl:variable name="step" as="xs:QName" select="resolve-QName(string(.), parent::*)"/>
		<xsl:choose>
			<xsl:when test="$step=$sbs:dtbook-to-pef">
				<xsl:attribute name="step" select="'sbs:dtbook-to-epub3-to-pef'"/>
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
