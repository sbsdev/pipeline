<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-from-dir-list" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:err="http://www.w3.org/ns/xproc-error"
  xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="err px">
  
  <p:input port="source"/>
  <p:output port="result"/>
  
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="../xslt/fileset-from-dir-list.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
</p:declare-step>
