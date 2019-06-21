<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:read-doctype-declaration" name="main" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:d="http://www.daisy.org/ns/pipeline/data" exclude-inline-prefixes="#all" version="1.0"
    xmlns:cx="http://xmlcalabash.com/ns/extensions">
    
    <!-- TODO: move this to pipeline 2 common-utils before the v1.10 release -->
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Example usage:</p>
        <pre xml:space="preserve">
            &lt;!-- provide a single document on the primary input port --&gt;
            &lt;px:read-doctype-declaration/&gt;
        </pre>
        <p>Example output:</p>
        <pre xml:space="preserve">
            &lt;c:result xmlns:c="http://www.w3.org/ns/xproc-step" has-doctype-declaration="true" name="HTML" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-declaration="&amp;lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"&amp;gt;"/&gt;
        </pre>
    </p:documentation>
    
    <p:option name="href" required="true"/>
    
    <p:output port="result"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    
    <px:file-xml-peek name="xml-peek">
        <p:with-option name="href" select="$href"/>
    </px:file-xml-peek>
    <p:sink/>
    <p:identity name="xml-prolog">
        <p:input port="source">
            <p:pipe step="xml-peek" port="prolog"/>
        </p:input>
    </p:identity>
    
    <p:choose>
        <p:when test="/*/c:doctype">
            <p:filter select="/*/c:doctype[1]"/>
            
            <p:rename match="/*" new-name="c:result"/>
            <p:rename match="/*/@public" new-name="doctype-public"/>
            <p:rename match="/*/@system" new-name="doctype-system"/>
            
            <p:add-attribute match="/*" attribute-name="doctype-declaration">
                <p:with-option name="attribute-value" select="/*/text()"/>
            </p:add-attribute>
            <p:add-attribute match="/*" attribute-name="has-doctype-declaration" attribute-value="true"/>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:inline exclude-inline-prefixes="#all">
                        <c:result has-doctype-declaration="false"/>
                    </p:inline>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
