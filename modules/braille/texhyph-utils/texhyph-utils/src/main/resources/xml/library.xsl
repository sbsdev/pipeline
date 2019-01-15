<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    
    <!--
        Import this (dummy) library whenever one of the following functions is used:
        * tex:hyphenate
    -->
    
    <!--
        tex:hyphenate is implemented in Java: org.daisy.pipeline.braille.tex.saxon.impl.HyphenateDefinition
    -->
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            <p>Hyphenate a text string using texhyphj.</p>
        </desc>
    </doc>
    
</xsl:stylesheet>
