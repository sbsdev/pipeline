<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@style">
        <xsl:variable name="style" as="element()*" select="css:parse-stylesheet(.)"/> <!-- css:rule*-->
        <xsl:variable name="extract-styles" as="element()*"
                      select="$style/self::css:rule[@selector[not(contains(.,'(')
                                                                  or .='&amp;::list-item'
                                                                  or .='&amp;::list-header')]]"/> <!-- css:rule*-->
        <xsl:if test="exists($style except $extract-styles)">
            <xsl:sequence select="css:style-attribute(css:serialize-stylesheet($style except $extract-styles))"/>
        </xsl:if>
        <xsl:apply-templates select="$extract-styles"/>
    </xsl:template>
    
    <xsl:template match="css:rule">
        <xsl:attribute name="css:{replace(replace(replace(@selector, '^(@|&amp;::|&amp;:)' , ''  ),
                                                                     '^-'                  , '_' ),
                                                                     ' +'                  , '-' )}"
                       select="@style"/>
    </xsl:template>
    
    <!--
        Suppress warning messages "The source document is in no namespace, but the template rules
        all expect elements in a namespace" (see https://github.com/daisy/pipeline-mod-braille/issues/38)
    -->
    <xsl:template match="/phony">
        <xsl:next-match/>
    </xsl:template>
    
</xsl:stylesheet>
