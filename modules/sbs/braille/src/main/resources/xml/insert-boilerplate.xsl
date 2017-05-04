<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:brl="http://www.daisy.org/z3986/2009/braille/"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:epub="http://www.idpf.org/2007/ops"
    xmlns:f="http://my-functions"
    exclude-result-prefixes="xs">

  <xsl:output indent="yes"/>

  <xsl:param name="contraction-grade" select="'0'"/>
  <xsl:param name="generate-titlepage" select="'true'"/>

  <xsl:variable name="namespace" as="xs:string" select="namespace-uri(/*)"/>

  <xsl:variable name="series">
    <xsl:choose>
      <xsl:when test="//(dtb:meta|html:meta)[@name='prod:series']/@content='PPP'">rucksack</xsl:when>
      <xsl:when test="//(dtb:meta|html:meta)[@name='prod:series']/@content='SJW'">sjw</xsl:when>
      <xsl:otherwise>standard</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="series-number"
		select="//(dtb:meta|html:meta)[@name='prod:seriesNumber']/@content"/>

  <xsl:template match="dtb:frontmatter/dtb:docauthor">
    <xsl:next-match/>
    <xsl:if test="$generate-titlepage='true'">
      <xsl:call-template name="add-information-based-from-metadata"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[f:has-epub-type(.,'frontmatter')]">
    <xsl:next-match/>
    <xsl:if test="$generate-titlepage='true'
		  and html:header//html:p[f:has-epub-type(.,'z3998:author')]">
      <xsl:call-template name="add-information-based-from-metadata"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="node()" mode="#all">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="add-information-based-from-metadata">
    <xsl:element name="{if (self::dtb:*) then 'level1' else local-name()}" namespace="{$namespace}">
      <xsl:sequence select="@epub:type"/>
      <xsl:attribute name="id" select="'cover-recto'"/>

      <!-- Authors -->
      <xsl:element name="p" namespace="{$namespace}">
	<xsl:attribute name="id" select="'cover-author'"/>
        <xsl:sequence select="//dtb:docauthor/node()|
			      //html:header//html:p[f:has-epub-type(.,'z3998:author')][1]/node()"/>
      </xsl:element>

      <!-- Title -->
      <xsl:element name="p" namespace="{$namespace}">
      <xsl:attribute name="id" select="'cover-title'"/>
        <xsl:sequence select="//dtb:doctitle/node()|
			      //html:header//html:h1[f:has-epub-type(.,'fulltitle')][1]/node()"/>
      </xsl:element>

      <!-- Series -->
      <xsl:if test="$series = 'sjw'">
	<xsl:element name="p" namespace="{$namespace}">
	  <xsl:attribute name="class" select="'series-sjw'"/>
	  <xsl:text>SJW-Heft NR.</xsl:text>
	  <xsl:value-of select="$series-number"/>
	</xsl:element>
      </xsl:if>

      <!-- Volumes -->
      <!-- How many Volumes -->
      <xsl:element name="p" namespace="{$namespace}">
	<xsl:attribute name="class" select="'how-many-volumes'"/>
      </xsl:element>

      <!-- Current Volume -->
      <xsl:element name="p" namespace="{$namespace}">
	<xsl:attribute name="class" select="'which-volume'"/>
	<!-- FIXME: if there are more than 12 volumes we want just the -->
	<!-- number but downshifted as with ordinals -->
      </xsl:element>
      
      <!-- Make sure Rucksack series and publisher blurb are flush with the bottom of the page -->
      <xsl:element name="div" namespace="{$namespace}">
	<xsl:attribute name="class" select="'flush-bottom'"/>
	<!-- Series -->
	<xsl:if test="$series = 'rucksack'">
	  
	  <xsl:element name="p" namespace="{$namespace}">
	    <xsl:attribute name="class" select="'series-ppp'"/>
	    <xsl:text>Rucksackbuch Nr.</xsl:text>
	    <xsl:value-of select="$series-number"/>
	  </xsl:element>
	</xsl:if>

	<!-- Publisher -->
	<xsl:element name="p" namespace="{$namespace}">
	  <xsl:attribute name="class" select="'publisher'"/>
	  <xsl:element name="abbr" namespace="{$namespace}">SBS</xsl:element>
	  <xsl:choose>
	    <xsl:when test="$contraction-grade = '0'">
	      <xsl:text> Schweiz. Bibliothek</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Für Blinde, Seh- und</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Lesebehinderte</xsl:text>
	    </xsl:when>
	    <xsl:when test="$contraction-grade = '1'">
	      <xsl:text> Schweizerische Bibliothek</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Für Blinde, Seh- und</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Lesebehinderte</xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:text> Schweizerische Bibliothek</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Für Blinde, Seh- und Lesebehinderte</xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:element>
      </xsl:element>

    </xsl:element>
    <xsl:element name="{if (self::dtb:*) then 'level1' else local-name()}" namespace="{$namespace}">
      <xsl:sequence select="@epub:type"/>
      <xsl:attribute name="id" select="'cover-verso'"/>
      <xsl:choose>
	<xsl:when test="$series = 'sjw'">
	  <xsl:element name="p" namespace="{$namespace}">
	    <xsl:attribute name="id" select="'sjw-blurb'"/>
	    <xsl:text>Brailleausgabe mit </xsl:text>
	    <xsl:element name="span" namespace="{$namespace}">
	      <xsl:attribute name="style" select="'hyphens:manual'"/>
	      <xsl:text>freund­licher</xsl:text>
	    </xsl:element>
	    <xsl:text> Genehmigung des </xsl:text>
	    <xsl:element name="abbr" namespace="{$namespace}">SJW</xsl:element>
	    <xsl:text> Schweizerischen Jugendschriftenwerks, Zürich. Wir danken dem </xsl:text>
	    <xsl:element name="abbr" namespace="{$namespace}">SJW</xsl:element>
	    <xsl:text>-Verlag für die Bereitstellung der Daten.</xsl:text>
	  </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:element name="p" namespace="{$namespace}">
	    <xsl:attribute name="id" select="'copyright-blurb'"/>
	    <xsl:text>Dieses Braillebuch ist die ausschließlich für die Nutzung durch Seh- und
	    Lesebehinderte Menschen bestimmte zugängliche Version eines urheberrechtlich geschützten
	    Werks. </xsl:text>
	    <brl:v-form>Sie</brl:v-form>
	    <xsl:text> können es im Rahmen des Urheberrechts persönlich nutzen, dürfen es aber nicht
	    weiter verbreiten oder öffentlich zugänglich machen.</xsl:text>
	  </xsl:element>
	</xsl:otherwise>
      </xsl:choose>

      <!-- Make sure Rucksack series and publisher blurb are flush with the bottom of the page -->
      <xsl:element name="div" namespace="{$namespace}">
	<xsl:attribute name="class" select="'flush-bottom'"/>
	<!-- Series -->
	<xsl:if test="$series = 'rucksack'">
	  <xsl:element name="p" namespace="{$namespace}">
	    <xsl:attribute name="class" select="'series-ppp'"/>
	    <xsl:text>Rucksackbuch Nr.</xsl:text>
	    <xsl:value-of select="$series-number"/>
	  </xsl:element>
	</xsl:if>

	<!-- Publisher long -->
	<xsl:element name="p" namespace="{$namespace}">
	  <xsl:attribute name="class" select="'publisher'"/>
	  <xsl:text>Verlag, Satz und Druck</xsl:text>
	  <xsl:element name="br" namespace="{$namespace}"/>
	  <xsl:element name="abbr" namespace="{$namespace}">SBS</xsl:element>
	  <xsl:choose>
	    <xsl:when test="$contraction-grade = '0'">
	      <xsl:text> Schweiz. Bibliothek</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Für Blinde, Seh- und</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Lesebehinderte, Zürich</xsl:text>
	    </xsl:when>
	    <xsl:when test="$contraction-grade = '1'">
	      <xsl:text> Schweizerische Bibliothek</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Für Blinde, Seh- und</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Lesebehinderte, Zürich</xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:text> Schweizerische Bibliothek</xsl:text>
	      <xsl:element name="br" namespace="{$namespace}"/>
	      <xsl:text> Für Blinde, Seh- und Lesebehinderte, Zürich</xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:element name="br" namespace="{$namespace}"/>
	  <brl:computer>www.sbs.ch</brl:computer>
	</xsl:element>
      </xsl:element>

      <xsl:variable name="date" select="//(dtb:meta|html:meta)[lower-case(@name)='dc:date']/@content"/>
      <xsl:element name="p" namespace="{$namespace}">
	<xsl:attribute name="id" select="'cover-year'"/>
	<xsl:element name="abbr" namespace="{$namespace}">SBS</xsl:element>
	<xsl:text> </xsl:text>
	<xsl:value-of select="format-date($date, '[Y]')"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:function name="f:has-epub-type" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:sequence select="$type=tokenize($element/@epub:type,' ')"/>
  </xsl:function>

</xsl:stylesheet>
