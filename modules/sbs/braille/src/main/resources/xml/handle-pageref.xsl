<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:f="http://my-functions"
                exclude-result-prefixes="#all">
    
    <!-- <xsl:include href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xsl"/> -->

    <!--
        temporary implementation of pf:warn (will be in http://www.daisy.org/pipeline/modules/braille/common-utils/library.xsl soon)
    -->
    <xsl:template name="pf:warn">
        <xsl:param name="msg"/>
        <xsl:message select="$msg"/>
    </xsl:template>
    
    <xsl:template match="dtb:a/@class[.='pageref']|
                         html:a/@class[.='pageref']">
        <xsl:variable name="href" select="parent::*/@href"/>
        <xsl:variable name="id" select="replace($href,'^.*#','')"/>
        <xsl:choose>
            <xsl:when test="//(dtb:frontmatter|*[f:has-epub-type(.,'frontmatter')])
                            //*[@id=$id]">
                <xsl:call-template name="pf:warn">
                    <xsl:with-param name="msg">
                      <xsl:text>pageref link points to element in frontmater (</xsl:text>
                      <xsl:value-of select="$href"/>
                      <xsl:text>). Ignoring because frontmatter pages are not numbered.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:attribute name="class" select="'pageref pageref-frontmatter'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="f:has-epub-type" as="xs:boolean">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:sequence select="$type=tokenize($element/@epub:type,' ')"/>
    </xsl:function>
    
</xsl:stylesheet>
