<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:epub="http://www.idpf.org/2007/ops"
    xmlns:brl="http://www.daisy.org/z3986/2009/braille/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="http://my-functions"
    exclude-result-prefixes="xs brl">

    <xsl:param name="announcement" as="xs:string">'&lt;=</xsl:param>
    <xsl:param name="deannouncement" as="xs:string">'&lt;=</xsl:param>

    <xsl:output method="xml" encoding="utf-8" indent="no"/>

    <xsl:template match="text()[normalize-space(.)!='' and ancestor::*[my:is-prodnote(.)]]">
      <xsl:if test="not(preceding::text()[normalize-space(.)!=''][1][ancestor::*[my:is-prodnote(.)]])">
	<brl:literal><xsl:value-of select="$announcement"/></brl:literal>
      </xsl:if>
      <xsl:sequence select="."/>
      <xsl:if test="not(following::text()[normalize-space(.)!=''][1][ancestor::*[my:is-prodnote(.)]])">
	<brl:literal><xsl:value-of select="$deannouncement"/></brl:literal>
      </xsl:if>
    </xsl:template>

    <xsl:template match="*[my:is-prodnote(.)]">
      <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*">
      <xsl:copy>
	<xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|comment()|processing-instruction()">
      <xsl:sequence select="."/>
    </xsl:template>

    <xsl:function name="my:is-prodnote" as="xs:boolean">
      <xsl:param name="node" as="node()"/>
      <xsl:sequence select="$node/self::dtb:prodnote or
                            $node/self::html:aside[tokenize(@epub:type,'\s+')='z3998:production']"/>
    </xsl:function>
    
</xsl:stylesheet>
