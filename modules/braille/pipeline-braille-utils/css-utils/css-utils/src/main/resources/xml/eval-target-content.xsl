<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:content[@target]">
        <xsl:variable name="target" select="@target"/>
        <xsl:apply-templates select="//*[@css:id=$target][1]/child::node()" mode="copy">
            <xsl:with-param name="anchor" select="$target"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*" mode="copy">
        <xsl:param name="anchor" as="xs:string" required="yes"/>
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:if test="not(@css:anchor)">
                <xsl:attribute name="css:anchor" select="$anchor"/>
            </xsl:if>
            <xsl:sequence select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="copy">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="css:after|
                         css:before|
                         css:duplicate|
                         css:alternate|
                         css:footnote-call" mode="copy"/>
    
    <!--
        Suppress warning messages "The source document is in no namespace, but the template rules
        all expect elements in a namespace" (see https://github.com/daisy/pipeline-mod-braille/issues/38)
    -->
    <xsl:template match="/phony">
        <xsl:next-match/>
    </xsl:template>
    
</xsl:stylesheet>
