<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="x:odt-compare" name="main"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:x="http://www.daisy.org/ns/xprocspec"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="1.0"
                exclude-inline-prefixes="px pxi xsl">
    
    <!--
        TODO: move to odt-utils
    -->
    
    <p:input port="context" primary="false"/>
    <p:input port="expect" primary="false"/>
    <p:input port="parameters" kind="parameter" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:declare-step type="odt:compare-content" name="compare-content">
        
        <p:input port="source" primary="true"/>
        <p:input port="alternate"/>
        <p:output port="result" primary="false" sequence="false">
            <p:pipe step="compare" port="result"/>
        </p:output>
        
        <p:option name="fail-if-not-equal" select="'false'"/>
        
        <p:declare-step type="pxi:normalize">
            <p:input port="source"/>
            <p:output port="result"/>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:inline>
                        <xsl:stylesheet version="2.0">
                            <xsl:template match="@*|node()">
                                <xsl:copy>
                                    <xsl:apply-templates select="@*|node()"/>
                                </xsl:copy>
                            </xsl:template>
                            <xsl:template match="dc:date">
                                <xsl:copy>
                                    <xsl:text>...</xsl:text>
                                </xsl:copy>
                            </xsl:template>
                        </xsl:stylesheet>
                    </p:inline>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
            <p:delete match="/*/@xml:space"/>
            <p:string-replace match="text()" replace="normalize-space(.)"/>
        </p:declare-step>
        
        <pxi:normalize name="normalize-source">
            <p:input port="source">
                <p:pipe step="compare-content" port="source"/>
            </p:input>
        </pxi:normalize>
        
        <pxi:normalize name="normalize-alternate">
            <p:input port="source">
                <p:pipe step="compare-content" port="alternate"/>
            </p:input>
        </pxi:normalize>
        
        <p:compare name="compare">
            <p:input port="source">
                <p:pipe step="normalize-source" port="result"/>
            </p:input>
            <p:input port="alternate">
                <p:pipe step="normalize-alternate" port="result"/>
            </p:input>
            <p:with-option name="fail-if-not-equal" select="$fail-if-not-equal"/>
        </p:compare>
        
    </p:declare-step>
    
    <odt:compare-content fail-if-not-equal="false" name="compare">
        <p:input port="source">
            <p:pipe step="main" port="context"/>
        </p:input>
        <p:input port="alternate">
            <p:pipe step="main" port="expect"/>
        </p:input>
    </odt:compare-content>
    
    <p:rename match="/*" new-name="x:test-result">
        <p:input port="source">
            <p:pipe port="result" step="compare"/>
        </p:input>
    </p:rename>
    
    <p:add-attribute match="/*" attribute-name="result">
        <p:with-option name="attribute-value" select="if (string(/*)='true') then 'passed' else 'failed'">
            <p:pipe port="result" step="compare"/>
        </p:with-option>
    </p:add-attribute>
    
    <p:delete match="/*/node()" name="result"/>
    
    <p:choose>
        <p:when test="/*/@result='passed'">
            <p:identity/>
        </p:when>
        <p:otherwise>
            <p:wrap-sequence wrapper="x:expected" name="expected">
                <p:input port="source">
                    <p:pipe step="main" port="expect"/>
                </p:input>
            </p:wrap-sequence>
            <p:wrap-sequence wrapper="x:was" name="was">
                <p:input port="source">
                    <p:pipe step="main" port="context"/>
                </p:input>
            </p:wrap-sequence>
            <p:insert match="/*" position="last-child">
                <p:input port="source">
                    <p:pipe step="result" port="result"/>
                </p:input>
                <p:input port="insertion">
                    <p:pipe port="result" step="expected"/>
                    <p:pipe port="result" step="was"/>
                </p:input>
            </p:insert>
            <p:add-attribute match="/*/*" attribute-name="xml:space" attribute-value="preserve"/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
