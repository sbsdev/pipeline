<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/2011/obfl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:_xsl="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:re="regex-utils"
                exclude-result-prefixes="#all"
                version="2.0" >
    
    <xsl:namespace-alias stylesheet-prefix="_xsl" result-prefix="xsl"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xsl"/>
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:param name="braille-translator-query" as="xs:string" required="yes"/> <!-- unused -->
    <xsl:param name="page-counters" as="xs:string" required="yes"/>
    <xsl:param name="volume-transition" as="xs:string" required="no" select="''"/>
    
    <xsl:variable name="sections" select="collection()[position() &lt; last()]"/>
    <xsl:variable name="page-and-volume-styles" select="collection()[position()=last()]/*/*"/>
    <xsl:variable name="page-counter-names" as="xs:string*" select="tokenize($page-counters,' ')"/>
    
    <xsl:variable name="volume-transition-rule" as="element()?">
        <xsl:if test="not($volume-transition='')">
            <xsl:sequence select="css:deep-parse-stylesheet(concat('@-obfl-volume-transition { ',$volume-transition,' }'))"/>
        </xsl:if>
    </xsl:variable>
    
    <!-- ====================== -->
    <!-- Page and volume styles -->
    <!-- ====================== -->
    
    <xsl:variable name="volume-stylesheets" as="element()*">
        <xsl:variable name="volume-stylesheets" as="element()*">
            <xsl:sequence select="$page-and-volume-styles[@selector='@volume']"/>
            <xsl:if test="not($page-and-volume-styles[@selector='@volume'])">
                <css:rule selector="@volume"/>
            </xsl:if>
        </xsl:variable>
        <xsl:apply-templates mode="serialize-page-styles" select="$volume-stylesheets"/>
    </xsl:variable>
    
    <xsl:template mode="serialize-page-styles" match="*[.//css:rule[@selector='@page']]">
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:apply-templates mode="#current" select="*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template mode="serialize-page-styles" match="css:rule[@selector='@page' and not(@style)]">
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:attribute name="style" select="css:serialize-stylesheet(*)"/>
            <xsl:sequence select="*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template mode="serialize-page-styles" match="*">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:variable name="page-stylesheets" as="element()*">
        <css:rule selector="@page" style=""/>
        <xsl:sequence select="$page-and-volume-styles[@selector='@page']"/>
        <xsl:for-each select="$volume-stylesheets">
            <xsl:sequence select="(.|*[matches(@selector,'^&amp;:')])
                                  /*[@selector=('@begin','@end')]
                                  /css:rule[@selector='@page']"/>
        </xsl:for-each>
    </xsl:variable>
    
    <!--
        Based on a sequence of @volume rules, return a sequence of "use-when" expressions for which
        each volume is quaranteed to match exactly one of them. Should in theory not be needed
        because volume templates are matched in the order they appear.
    -->
    <xsl:function name="obfl:volume-stylesheets-use-when" as="xs:string*">
        <xsl:param name="stylesheets" as="element()*"/>
        <xsl:for-each select="$stylesheets">
            <xsl:variable name="i" select="position()"/>
            <xsl:choose>
                <xsl:when test="@selector='@volume'">
                    <xsl:sequence select="obfl:not(obfl:or($stylesheets[position()&lt;$i or @selector[not(.='@volume')]]
                                                                       /obfl:volume-stylesheets-use-when(.)))"/>
                </xsl:when>
                <xsl:when test="@selector='&amp;:only'">
                    <xsl:sequence select="'(= $volumes 1)'"/>
                </xsl:when>
                <xsl:when test="@selector='&amp;:first'">
                    <xsl:sequence select="obfl:and((
                                            '(= $volume 1)',
                                            obfl:not(obfl:or($stylesheets[(position()&lt;$i and @selector[not(.='@volume')])
                                                                          or @selector[.='&amp;:only']]
                                                                         /obfl:volume-stylesheets-use-when(.)))))"/>
                </xsl:when>
                <xsl:when test="@selector='&amp;:last'">
                    <xsl:sequence select="obfl:and((
                                            '(= $volume $volumes)',
                                            obfl:not(obfl:or($stylesheets[(position()&lt;$i and @selector[not(.='@volume')])
                                                                          or @selector[.='&amp;:only']]
                                                                         /obfl:volume-stylesheets-use-when(.)))))"/>
                </xsl:when>
                <xsl:when test="matches(@selector,'^&amp;:nth\([1-9][0-9]*\)$')">
                    <xsl:sequence select="obfl:and((
                                            concat('(= $volume ',substring(@selector,7)),
                                            obfl:not(obfl:or($stylesheets[(position()&lt;$i and @selector[not(.='@volume')])
                                                                          or @selector[.='&amp;:only']]
                                                                         /obfl:volume-stylesheets-use-when(.)))))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="'nil'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <!-- ===== -->
    <!-- Flows -->
    <!-- ===== -->
    
    <!--
        The flows that correspond to a obfl:collection
    -->
    <xsl:variable name="collection-flows" as="xs:string*">
        <xsl:for-each select="$page-stylesheets">
            <xsl:sequence select="css:parse-content-list(
                                    css:rule[@selector='@footnotes'][1]
                                    /css:property[@name='content'][1]/@value,())
                                  /self::css:flow[@from and (not(@scope) or @scope='page')]/@from"/>
        </xsl:for-each>
        <xsl:for-each select="$volume-stylesheets">
            <xsl:for-each select="(.|*[matches(@selector,'^&amp;:')])
                                  /*[@selector=('@begin','@end')]">
                <xsl:variable name="volume-area-content" as="element()*"
                              select="css:parse-content-list(
                                        (if (css:property) then . else *[not(@selector)])
                                        /css:property[@name='content'][1]/@value,())"/>
                <xsl:sequence select="$volume-area-content/self::css:flow[@from and @scope='volume']/@from"/>
                <xsl:for-each select="distinct-values(
                                        $volume-area-content/self::css:flow[@from][(@scope,'document')[1]='document']/@from)">
                    <xsl:variable name="flow" as="xs:string" select="."/>
                    <xsl:sequence select="$sections/*[@css:flow=$flow]
                                          /css:box[@type='block' and @css:_obfl-list-of-references]
                                          //css:custom-func[@name='-obfl-collection' and @arg1 and not(@arg2)]/@arg1"/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- ================== -->
    <!-- xml-data renderers -->
    <!-- ================== -->
    
    <xsl:function name="pxi:renderer-to-string" as="xs:string">
        <xsl:param name="elem" as="element()"/>
        <xsl:sequence select="string-join($elem/child::*/(@css:_obfl-scenario-cost,'none')[1],' ')"/>
    </xsl:function>
    
    <xsl:variable name="renderers" as="xs:string*"
                  select="distinct-values(collection()//css:box[@type='block'][@css:_obfl-scenarios]/pxi:renderer-to-string(.))"/>
    
    <xsl:function name="pxi:renderer-name" as="xs:string">
        <xsl:param name="renderer"/> <!-- element()|xs:string -->
        <xsl:choose>
            <xsl:when test="$renderer instance of xs:string">
                <xsl:sequence select="concat('renderer_',index-of($renderers,$renderer))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="pxi:renderer-name(pxi:renderer-to-string($renderer))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:variable name="_OBFL_SCENARIO_COST_RE" select="concat('none|(',$css:INTEGER_RE,')|-obfl-evaluate\((',$css:STRING_RE,')\)')"/>
    <xsl:variable name="_OBFL_SCENARIO_COST_RE_integer" select="1"/>
    <xsl:variable name="_OBFL_SCENARIO_COST_RE_eval" select="$_OBFL_SCENARIO_COST_RE_integer + $css:INTEGER_RE_groups + 1"/>
    
    <xsl:function name="pxi:parse-scenario-cost" as="xs:string">
        <xsl:param name="cost-attr" as="attribute()?"/>
        <xsl:analyze-string select="($cost-attr/string(),'none')[1]" regex="^{$_OBFL_SCENARIO_COST_RE}$">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test=".='none'">
                        <xsl:sequence select="'0'"/>
                    </xsl:when>
                    <xsl:when test="regex-group($_OBFL_SCENARIO_COST_RE_integer)!=''">
                        <xsl:sequence select="regex-group($_OBFL_SCENARIO_COST_RE_integer)"/>
                    </xsl:when>
                    <xsl:when test="regex-group($_OBFL_SCENARIO_COST_RE_eval)!=''">
                        <xsl:sequence select="substring(regex-group($_OBFL_SCENARIO_COST_RE_eval),
                                                        2, string-length(regex-group($_OBFL_SCENARIO_COST_RE_eval))-2)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:call-template name="coding-error">
                    <xsl:with-param name="context" select="$cost-attr"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:key name="renderer" match="css:box[@type='block'][@css:_obfl-scenarios]" use="pxi:renderer-to-string(.)"/>
    
    <xsl:template name="renderers">
        <xml-processor name="take-nth">
            <!--
                FIXME: without the "bogus" attributes, Dotify currently does not preserve the in
                scope namespace declarations
            -->
            <_xsl:stylesheet version="2.0"
                             d:bogus=""
                             xs:bogus="">
                <_xsl:param name="n" as="xs:integer"/>
                <_xsl:template match="/">
                    <_xsl:sequence select="/*/d:scenario[position()=$n]"/>
                </_xsl:template>
            </_xsl:stylesheet>
        </xml-processor>
        <xsl:for-each select="$renderers">
            <xsl:variable name="renderer" as="xs:string" select="."/>
            <renderer name="{pxi:renderer-name($renderer)}">
                <xsl:for-each select="(collection()/key('renderer',$renderer))[1]/child::*">
                    <!--
                        revert order because in case of equal costs Dotify selects the last scenario
                        while CSS expects the first to be selected
                    -->
                    <xsl:sort select="position()" data-type="number" order="descending"/>
                    <rendering-scenario processor="take-nth" cost="{pxi:parse-scenario-cost(@css:_obfl-scenario-cost)}">
                        <parameter name="n" value="{last()-position()+1}"/>
                    </rendering-scenario>
                </xsl:for-each>
            </renderer>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ===== -->
    <!-- Start -->
    <!-- ===== -->
    
    <xsl:variable name="initial-text-transform" as="xs:string" select="'none'"/>
    <xsl:variable name="initial-hyphens" as="xs:string" select="'manual'"/>
    <xsl:variable name="initial-word-spacing" as="xs:integer" select="1"/>
    
    <!-- count the total number of text nodes with braille content so that we get a good estimate of the progress -->
    <xsl:variable name="progress-total" select="count(collection()//text()[matches(.,concat('[',
                                                '⠀⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟',
                                                '⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿',
                                                '⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟',
                                                '⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿',
                                                '⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟',
                                                '⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿',
                                                '⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟',
                                                '⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿',
                                                ']'))])"/>
    
    <xsl:template name="start">
        <xsl:call-template name="pf:progress">
            <xsl:with-param name="progress" select="concat('1/',$progress-total)"/>
        </xsl:call-template>
        <obfl version="2011-1" xml:lang="und">
            <xsl:variable name="translate" as="xs:string" select="if ($initial-text-transform='none') then 'pre-translated-text-css' else ''"/>
            <xsl:variable name="hyphenate" as="xs:string" select="string($initial-hyphens='auto')"/>
            <xsl:attribute name="hyphenate" select="$hyphenate"/>
            <xsl:if test="$translate!=''">
                <xsl:attribute name="translate" select="$translate"/>
            </xsl:if>
            <xsl:call-template name="_start">
                <xsl:with-param name="text-transform" tunnel="yes" select="$initial-text-transform"/>
                <xsl:with-param name="hyphens" tunnel="yes" select="$initial-hyphens"/>
                <xsl:with-param name="word-spacing" tunnel="yes" select="$initial-word-spacing"/>
            </xsl:call-template>
        </obfl>
    </xsl:template>
    
    <xsl:template name="_start">
        <xsl:param name="word-spacing" as="xs:integer" tunnel="yes"/>
            <xsl:sequence select="$page-stylesheets"/>
            <xsl:if test="count($volume-stylesheets)&gt;1">
                <xsl:call-template name="pf:warn">
                    <xsl:with-param name="msg">Documents with more than one volume style are not supported.</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="not(exists($volume-stylesheets))">
                <xsl:call-template name="pf:warn">
                    <xsl:with-param name="msg">Document does not have an associated volume style.</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="collection()//*/@css:_obfl-scenarios">
                <xsl:call-template name="renderers"/>
            </xsl:if>
            <xsl:if test="$volume-stylesheets[1]/*">
                <xsl:variable name="volume-stylesheets" as="element()*"
                              select="$volume-stylesheets[1]/(.|*[matches(@selector,'^&amp;:')])"/>
                <xsl:variable name="volume-stylesheets-use-when" as="xs:string*"
                              select="if (count($volume-stylesheets)=1)
                                      then ('t')
                                      else obfl:volume-stylesheets-use-when($volume-stylesheets)"/>
                <xsl:if test="not(obfl:or($volume-stylesheets-use-when)='nil')">
                    <xsl:variable name="no-upper-limit" select="'1000'"/>
                    <xsl:for-each select="$volume-stylesheets">
                        <xsl:variable name="i" select="position()"/>
                        <xsl:variable name="use-when" as="xs:string" select="$volume-stylesheets-use-when[$i]"/>
                        <xsl:if test="not($use-when='nil')">
                            <xsl:variable name="properties" as="element()*"
                                          select="if (css:property) then * else *[not(@selector)]/css:property"/>
                            <xsl:variable name="volume-area-rules" as="element()*" select="*[@selector=('@begin','@end')]"/>
                            <!--
                                page style to use in @begin and @end areas when no page property specified
                            -->
                            <xsl:variable name="default-page-style" as="xs:string" select="($sections/*[not(@css:flow)])[1]/string(@css:page)"/>
                            <volume-template sheets-in-volume-max="{($properties[@name='max-length' and css:is-valid(.)]/string(@value),$no-upper-limit)[1]}">
                                <xsl:if test="not($use-when='t')">
                                    <xsl:attribute name="use-when" select="$use-when"/>
                                </xsl:if>
                                <xsl:for-each select="('@begin','@end')">
                                    <xsl:variable name="volume-area" select="."/>
                                    <xsl:variable name="volume-area-style" as="element()*"
                                                  select="$volume-area-rules[@selector=$volume-area][1]/*"/>
                                    <xsl:variable name="volume-area-page-style" as="xs:string?"
                                                  select="$volume-area-style[@selector='@page']/@style"/>
                                    <xsl:variable name="volume-area-properties" as="element()*"
                                                  select="if ($volume-area-style/self::css:property)
                                                          then $volume-area-style
                                                          else $volume-area-style[not(@selector)]/css:property"/>
                                    <xsl:variable name="pending-text-transform" as="xs:string?" select="$volume-area-properties[@name='text-transform']/@value"/>
                                    <xsl:variable name="pending-hyphens" as="xs:string?" select="$volume-area-properties[@name='hyphens']/@value"/>
                                    <xsl:variable name="word-spacing" as="xs:integer" select="($volume-area-properties[@name='word-spacing']/@value,$word-spacing)[1]"/>
                                    <xsl:variable name="white-space" as="xs:string?" select="$volume-area-properties[@name='white-space']/@value"/>
                                    <xsl:variable name="volume-area-content" as="element()*"> <!-- css:_|obfl:list-of-references -->
                                        <xsl:apply-templates mode="css:eval-volume-area-content-list"
                                                             select="css:parse-content-list($volume-area-properties[@name='content'][1]/@value,())"/>
                                    </xsl:variable>
                                    <xsl:variable name="space" as="xs:string" select="('pre','post')[index-of(('@begin','@end'),$volume-area)]"/>
                                    <xsl:variable name="default-page-counter-name" as="xs:string" select="concat($space,'-page')"/>
                                    <xsl:if test="$volume-area-properties[@name=('counter-increment','counter-reset')]">
                                        <xsl:message terminate="yes">
                                            <xsl:apply-templates mode="css:serialize"
                                                                 select="$volume-area-properties[@name=('counter-increment','counter-reset')][1]"/>
                                            <xsl:text>: counter-reset and counter-increment not supported in </xsl:text>
                                            <xsl:value-of select="$volume-area"/>
                                        </xsl:message>
                                    </xsl:if>
                                    <xsl:variable name="volume-area-counter-set" as="element()*"
                                                  select="css:parse-counter-set(
                                                            ($volume-area-properties[@name='counter-set']/@value,$default-page-counter-name)[1]
                                                            ,0)"/>
                                    <xsl:if test="$volume-area-content">
                                        <xsl:element name="{$space}-content">
                                            <xsl:variable name="default-page-style" as="xs:string" select="($volume-area-page-style,$default-page-style)[1]"/>
                                            <xsl:for-each-group select="$volume-area-content" group-starting-with="css:_[@css:counter-set]">
                                                <xsl:for-each-group select="current-group()" group-adjacent="(self::css:_/@css:page/string(),$default-page-style)[1]">
                                                    <xsl:variable name="page-style" select="current-grouping-key()"/>
                                                    <xsl:variable name="page-style" as="element()" select="$page-stylesheets[@style=$page-style][1]"/>
                                                    <xsl:variable name="page-properties" as="element()*"
                                                                  select="(if ($page-style/css:property)
                                                                           then $page-style/css:property
                                                                           else $page-style/*[not(@selector)]/css:property)"/>
                                                    <xsl:variable name="counter-increment" as="element()"
                                                                  select="css:parse-counter-set(
                                                                            ($page-properties[@name='counter-increment']/@value,$default-page-counter-name)[1],
                                                                            1)[last()]"/>
                                                    <xsl:variable name="page-number-counter" as="attribute()?">
                                                        <xsl:if test="not($counter-increment/@name=$default-page-counter-name)">
                                                            <xsl:attribute name="page-number-counter" select="$counter-increment/@name"/>
                                                        </xsl:if>
                                                    </xsl:variable>
                                                            <xsl:variable name="counter-set" as="element()*"
                                                                          select="current-group()[1]/@css:counter-set/css:parse-counter-set(.,0)"/>
                                                            <xsl:if test="$counter-set[not(@name=$counter-increment/@name)]">
                                                                <xsl:message terminate="yes">
                                                                    <xsl:apply-templates mode="css:serialize" select="$counter-set[not(@name=$counter-increment/@name)][1]"/>
                                                                    <xsl:text>: only the active page counter (</xsl:text>
                                                                    <xsl:value-of select="$counter-increment/@name"/>
                                                                    <xsl:text>) may be manipulated</xsl:text>
                                                                </xsl:message>
                                                            </xsl:if>
                                                            <xsl:variable name="counter-set" as="element()?" select="$counter-set[last()]"/>
                                                            <xsl:variable name="initial-page-number" as="attribute()?">
                                                                <xsl:if test="$counter-set">
                                                                    <xsl:if test="(xs:integer($counter-set/@value) mod 2)=0">
                                                                        <xsl:message terminate="yes">
                                                                            <xsl:apply-templates mode="css:serialize" select="$counter-set"/>
                                                                            <xsl:text>: page counter may not be set to an even value</xsl:text>
                                                                        </xsl:message>
                                                                    </xsl:if>
                                                                    <xsl:attribute name="initial-page-number" select="$counter-set/@value"/>
                                                                </xsl:if>
                                                            </xsl:variable>
                                                            <xsl:apply-templates mode="assert-nil-attr"
                                                                                 select="current-group()/self::css:_/(@* except (@css:flow|@css:page|@css:counter-set))"/>
                                                            <xsl:variable name="current-group" as="element()*"
                                                                          select="for $e in current-group() return if ($e/self::css:_) then $e/* else $e"/>
                                                            <xsl:variable name="first-toc" as="element()?"
                                                                          select="($current-group/self::css:box[@type='block' and @css:_obfl-toc])[1]"/>
                                                            <xsl:choose>
                                                                <xsl:when test="not($first-toc)">
                                                                    <xsl:variable name="sequence" as="element()*">
                                                                        <xsl:call-template name="apply-templates-within-post-or-pre-content-sequence">
                                                                            <xsl:with-param name="select" select="$current-group"/>
                                                                            <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                                                                            <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                                                                            <xsl:with-param name="word-spacing" tunnel="yes" select="$word-spacing"/>
                                                                            <xsl:with-param name="white-space" tunnel="yes" select="$white-space"/>
                                                                        </xsl:call-template>
                                                                    </xsl:variable>
                                                                    <xsl:element name="{if ($sequence/self::obfl:list-of-references) then 'dynamic-sequence' else 'sequence'}">
                                                                        <xsl:attribute name="css:page" select="$page-style/@style"/>
                                                                        <xsl:sequence select="$page-number-counter|$initial-page-number"/>
                                                                        <xsl:sequence select="$sequence"/>
                                                                    </xsl:element>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:variable name="before-first-toc" as="element()*">
                                                                        <xsl:for-each-group select="$current-group"
                                                                                            group-starting-with="css:box[@type='block' and @css:_obfl-toc]">
                                                                            <xsl:if test="position()=1
                                                                                          and not(current-group()/self::css:box[@type='block' and @css:_obfl-toc])">
                                                                                <xsl:call-template name="apply-templates-within-post-or-pre-content-sequence">
                                                                                    <xsl:with-param name="select" select="current-group()"/>
                                                                                    <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                                                                                    <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                                                                                    <xsl:with-param name="word-spacing" tunnel="yes" select="$word-spacing"/>
                                                                                    <xsl:with-param name="white-space" tunnel="yes" select="$white-space"/>
                                                                                </xsl:call-template>
                                                                            </xsl:if>
                                                                        </xsl:for-each-group>
                                                                    </xsl:variable>
                                                                    <xsl:for-each-group select="$current-group"
                                                                                        group-starting-with="css:box[@type='block' and @css:_obfl-toc]">
                                                                        <xsl:variable name="toc" as="element()?"
                                                                                      select="current-group()/self::css:box[@type='block' and @css:_obfl-toc]"/>
                                                                        <xsl:if test="exists($toc)">
                                                                            <xsl:variable name="toc-name" select="generate-id($toc)"/>
                                                                            <xsl:variable name="toc-range" as="xs:string"
                                                                                          select="($toc/@css:_obfl-toc-range,'document')[1]"/>
                                                                            <xsl:variable name="on-toc-start" as="element()*"
                                                                                          select="$sections/*[@css:flow=concat('-obfl-on-toc-start/',
                                                                                                                               $toc/@css:_obfl-on-toc-start)]/*"/>
                                                                            <xsl:variable name="on-volume-start" as="element()*"
                                                                                          select="if ($toc-range='document' and $toc/@css:_obfl-on-volume-start)
                                                                                                  then $sections/*[@css:flow=concat('-obfl-on-volume-start/',
                                                                                                                                    $toc/@css:_obfl-on-volume-start)]/*
                                                                                                  else ()"/>
                                                                            <xsl:variable name="on-volume-end" as="element()*"
                                                                                          select="if ($toc-range='document' and $toc/@css:_obfl-on-volume-end)
                                                                                                  then $sections/*[@css:flow=concat('-obfl-on-volume-end/',
                                                                                                                                    $toc/@css:_obfl-on-volume-end)]/*
                                                                                                  else ()"/>
                                                                            <xsl:variable name="on-toc-end" as="element()*"
                                                                                          select="($sections/*[@css:flow=concat('-obfl-on-toc-end/',
                                                                                                                                $toc/@css:_obfl-on-toc-end)]/*)"/>
                                                                            <xsl:variable name="before-toc" as="element()*" select="if (position()=2) then $before-first-toc else ()"/>
                                                                            <xsl:variable name="after-toc" as="element()*">
                                                                                <xsl:call-template name="apply-templates-within-post-or-pre-content-sequence">
                                                                                    <xsl:with-param name="select" select="current-group()[not(self::css:box[@type='block' and @css:_obfl-toc])]"/>
                                                                                    <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                                                                                    <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                                                                                    <xsl:with-param name="word-spacing" tunnel="yes" select="$word-spacing"/>
                                                                                    <xsl:with-param name="white-space" tunnel="yes" select="$white-space"/>
                                                                                </xsl:call-template>
                                                                            </xsl:variable>
                                                                            <xsl:if test="exists($before-toc) and not($toc-range='document')
                                                                                          or $before-toc/self::obfl:list-of-references">
                                                                                <xsl:element name="{if ($before-toc/self::obfl:list-of-references) then 'dynamic-sequence' else 'sequence'}">
                                                                                    <xsl:attribute name="css:page" select="$page-style/@style"/>
                                                                                    <xsl:sequence select="$page-number-counter|$initial-page-number"/>
                                                                                    <xsl:sequence select="$before-toc"/>
                                                                                </xsl:element>
                                                                            </xsl:if>
                                                                            <toc-sequence css:page="{$page-style/@style}" range="{$toc-range}" toc="{$toc-name}">
                                                                                <xsl:if test="position()=1
                                                                                              or (exists($before-toc) and $toc-range='document' and not($before-toc/self::obfl:list-of-references))">
                                                                                    <xsl:sequence select="$initial-page-number"/>
                                                                                </xsl:if>
                                                                                <xsl:sequence select="$page-number-counter"/>
                                                                                <!--
                                                                                    Inserting table-of-contents here as child of toc-sequence. Will be moved to the
                                                                                    right place (child of obfl) later.
                                                                                -->
                                                                                <table-of-contents name="{$toc-name}">
                                                                                    <xsl:apply-templates mode="table-of-contents" select="$toc">
                                                                                        <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                                                                                        <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                                                                                        <xsl:with-param name="word-spacing" tunnel="yes" select="$word-spacing"/>
                                                                                        <xsl:with-param name="white-space" tunnel="yes" select="$white-space"/>
                                                                                    </xsl:apply-templates>
                                                                                </table-of-contents>
                                                                                <xsl:if test="(exists($before-toc) and $toc-range='document' and not($before-toc/self::obfl:list-of-references))
                                                                                              or exists($on-toc-start)
                                                                                              or $toc/@css:page-break-before='always'">
                                                                                    <on-toc-start>
                                                                                        <xsl:if test="$toc-range='document' and not($before-toc/self::obfl:list-of-references)">
                                                                                            <xsl:sequence select="$before-toc"/>
                                                                                        </xsl:if>
                                                                                        <xsl:if test="$toc/@css:page-break-before='always'">
                                                                                            <block break-before="page"/>
                                                                                        </xsl:if>
                                                                                        <xsl:apply-templates mode="sequence" select="$on-toc-start">
                                                                                            <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                                                                                            <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                                                                                            <xsl:with-param name="word-spacing" tunnel="yes" select="$word-spacing"/>
                                                                                            <xsl:with-param name="white-space" tunnel="yes" select="$white-space"/>
                                                                                            <xsl:with-param name="top-of-page" tunnel="yes" select="true()"/> <!-- toc-sequence always starts on new sheet -->
                                                                                        </xsl:apply-templates>
                                                                                    </on-toc-start>
                                                                                </xsl:if>
                                                                                <xsl:if test="exists($on-volume-start)">
                                                                                    <on-volume-start>
                                                                                        <xsl:apply-templates mode="sequence" select="$on-volume-start">
                                                                                            <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                                                                                            <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                                                                                            <xsl:with-param name="word-spacing" tunnel="yes" select="$word-spacing"/>
                                                                                            <xsl:with-param name="white-space" tunnel="yes" select="$white-space"/>
                                                                                        </xsl:apply-templates>
                                                                                    </on-volume-start>
                                                                                </xsl:if>
                                                                                <xsl:if test="exists($on-volume-end)">
                                                                                    <on-volume-end>
                                                                                        <xsl:apply-templates mode="sequence" select="$on-volume-end">
                                                                                            <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                                                                                            <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                                                                                            <xsl:with-param name="word-spacing" tunnel="yes" select="$word-spacing"/>
                                                                                            <xsl:with-param name="white-space" tunnel="yes" select="$white-space"/>
                                                                                        </xsl:apply-templates>
                                                                                    </on-volume-end>
                                                                                </xsl:if>
                                                                                <xsl:if test="exists($on-toc-end) or (exists($after-toc) and not($after-toc/self::obfl:list-of-references))">
                                                                                    <on-toc-end>
                                                                                        <xsl:apply-templates mode="sequence" select="$on-toc-end">
                                                                                            <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                                                                                            <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                                                                                            <xsl:with-param name="word-spacing" tunnel="yes" select="$word-spacing"/>
                                                                                            <xsl:with-param name="white-space" tunnel="yes" select="$white-space"/>
                                                                                        </xsl:apply-templates>
                                                                                        <xsl:if test="not($after-toc/self::obfl:list-of-references)">
                                                                                            <xsl:sequence select="$after-toc"/>
                                                                                        </xsl:if>
                                                                                    </on-toc-end>
                                                                                </xsl:if>
                                                                            </toc-sequence>
                                                                            <xsl:if test="$after-toc/self::obfl:list-of-references">
                                                                                <xsl:element name="{if ($after-toc/self::obfl:list-of-references) then 'dynamic-sequence' else 'sequence'}">
                                                                                    <xsl:attribute name="css:page" select="$page-style/@style"/>
                                                                                    <xsl:sequence select="$after-toc"/>
                                                                                </xsl:element>
                                                                            </xsl:if>
                                                                        </xsl:if>
                                                                    </xsl:for-each-group>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:for-each-group>
                                                    </xsl:for-each-group>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:for-each>
                            </volume-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:if>
            <!--
                Note that a volume-keep-priority attribute is not needed to prefer volume breaking
                before a block over inside a block, but for now we have the conditional anyway.
            -->
            <xsl:if test="exists($volume-transition-rule) or $sections//@css:volume-break-inside">
                <volume-transition range="sheet">
                    <xsl:for-each select="$volume-transition-rule/css:rule[matches(@selector,'@(sequence|any)-(interrupted|resumed)')
                                                                           and css:property[@name='content']]">
                        <xsl:variable name="sequence-interrupted-resumed-content" as="xs:string" select="css:property[@name='content'][1]/@value"/>
                        <xsl:variable name="pending-text-transform" as="xs:string?" select="css:property[@name='text-transform']/@value"/>
                        <xsl:variable name="pending-hyphens" as="xs:string?" select="css:property[@name='hyphens']/@value"/>
                        <xsl:variable name="word-spacing" as="xs:integer" select="(css:property[@name='word-spacing']/@value,$word-spacing)[1]"/>
                        <xsl:variable name="white-space" as="xs:string?" select="css:property[@name='white-space']/@value"/>
                        <xsl:variable name="sequence-interrupted-resumed-content" as="element()*"> <!-- (css:_|css:box)* -->
                            <xsl:apply-templates mode="css:eval-sequence-interrupted-resumed-content-list"
                                                 select="css:parse-content-list($sequence-interrupted-resumed-content,())"/>
                        </xsl:variable>
                        <xsl:apply-templates mode="assert-nil-attr"
                                             select="$sequence-interrupted-resumed-content/self::css:_/(@* except @css:flow)"/>
                        <xsl:variable name="sequence-interrupted-resumed-content" as="element()*"> <!-- css:box* -->
                            <xsl:sequence select="for $e in $sequence-interrupted-resumed-content return if ($e/self::css:_) then $e/* else $e"/>
                        </xsl:variable>
                        <xsl:variable name="sequence-interrupted-resumed-content" as="element()*"> <!-- css:box[@type='block']* -->
                            <xsl:call-template name="make-anonymous-block-boxes">
                                <xsl:with-param name="boxes" select="$sequence-interrupted-resumed-content"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="sequence" as="element()*"> <!-- block* -->
                            <xsl:apply-templates mode="sequence-interrupted-resumed" select="$sequence-interrupted-resumed-content">
                                <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                                <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                                <xsl:with-param name="word-spacing" tunnel="yes" select="$word-spacing"/>
                                <xsl:with-param name="white-space" tunnel="yes" select="$white-space"/>
                            </xsl:apply-templates>
                        </xsl:variable>
                        <xsl:if test="$sequence">
                            <xsl:element name="{substring-after(@selector,'@')}">
                                <xsl:sequence select="$sequence"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </volume-transition>
            </xsl:if>
            <xsl:apply-templates mode="assert-nil" select="$sections/*[not(self::css:_)]"/>
            <xsl:for-each select="$sections/css:_[@css:flow=$collection-flows]">
                <xsl:variable name="flow" as="xs:string" select="@css:flow"/>
                <collection name="{$flow}">
                    <xsl:for-each select="*">
                        <xsl:if test="@css:anchor='NULL'">
                            <xsl:call-template name="pf:warn">
                                <xsl:with-param name="msg">Flowed element does not have anchor in normal flow</xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <!--
                            We don't explicitly check that two items do not end up having the same
                            ID, which would trigger a "Identifier is not unique" error in
                            Dotify. Until this happens in practice I just assume that it can not
                            happen.
                        -->
                        <item id="{@css:anchor}">
                            <xsl:apply-templates mode="item" select="."/>
                        </item>
                    </xsl:for-each>
                </collection>
                <xsl:if test="$sections/css:_[@css:flow[not(.=$collection-flows)]]/*/@css:_obfl-use-when-collection-not-empty=$flow">
                    <collection name="meta/{$flow}">
                        <xsl:for-each select="*[1]">
                            <!--
                                giving this dummy item the same ID as the first item of the real collection seems to work
                            -->
                            <item id="{@css:anchor}">
                                <block/>
                            </item>
                        </xsl:for-each>
                    </collection>
                </xsl:if>
            </xsl:for-each>
            <!--
                FIXME: duplication
            -->
            <xsl:variable name="default-page-style-uses-explicit-counter-page" as="xs:boolean"
                          select="some $p in $page-stylesheets[@style=($sections/*[not(@css:flow)])[1]/string(@css:page)][1]
                                  satisfies
                                    (if ($p/css:property)
                                     then $p/css:property
                                     else $p/*[not(@selector)]/css:property)
                                    [@name='counter-increment']
                                    [css:parse-counter-set(@value,1)[@name='page']]"/>
            <xsl:variable name="some-volume-areas-use-counter-page" as="xs:boolean"
                          select="some $a in (for $v in $volume-stylesheets
                                              return $v/(.|*[matches(@selector,'^&amp;:')])
                                                     /*[@selector=('@begin','@end')])
                                  satisfies
                                    if (not($a/*[@selector='@page']))
                                    then $default-page-style-uses-explicit-counter-page
                                    else some $p in $a/*[@selector='@page']
                                         satisfies
                                           (if ($p/css:property)
                                            then $p/css:property
                                            else $p/*[not(@selector)]/css:property)
                                           [@name='counter-increment']
                                           [css:parse-counter-set(@value,1)[@name='page']]"/>
            <xsl:for-each-group select="$sections/css:_[not(@css:flow)]" group-starting-with="*[@css:counter-set]">
                <xsl:variable name="first-sequence" as="xs:boolean" select="position()=1"/>
                <xsl:for-each-group select="current-group()" group-adjacent="string(@css:page)">
                    <xsl:variable name="first-sequence" as="xs:boolean" select="$first-sequence and position()=1"/>
                    <xsl:variable name="page-style" select="current-grouping-key()"/>
                    <xsl:variable name="page-style" as="element()" select="$page-stylesheets[@style=$page-style][1]"/>
                    <xsl:variable name="page-properties" as="element()*"
                                  select="(if ($page-style/css:property)
                                           then $page-style/css:property
                                           else $page-style/*[not(@selector)]/css:property)"/>
                    <xsl:variable name="counter-increment" as="element()"
                                  select="css:parse-counter-set(
                                            ($page-properties[@name='counter-increment']/@value,'page')[1],
                                            1)[last()]"/>
                    <xsl:variable name="page-number-counter" as="attribute()?">
                        <xsl:if test="not($counter-increment/@name='page')
                                      or $some-volume-areas-use-counter-page">
                            <xsl:attribute name="page-number-counter" select="$counter-increment/@name"/>
                        </xsl:if>
                    </xsl:variable>
                            <xsl:for-each-group select="current-group()" group-starting-with="css:_[*/@css:volume-break-before='always']">
                                <xsl:variable name="first-sequence" as="xs:boolean" select="$first-sequence and position()=1"/>
                                <sequence css:page="{$page-style/@style}">
                                    <xsl:variable name="counter-set" as="element()*"
                                                  select="current-group()[1]/@css:counter-set/css:parse-counter-set(.,0)"/>
                                    <xsl:if test="$counter-set[not(@name=$counter-increment/@name)]">
                                        <xsl:message terminate="yes">
                                            <xsl:apply-templates mode="css:serialize" select="$counter-set[not(@name=$counter-increment/@name)][1]"/>
                                            <xsl:text>: only the active page counter (</xsl:text>
                                            <xsl:value-of select="$counter-increment/@name"/>
                                            <xsl:text>) may be manipulated</xsl:text>
                                        </xsl:message>
                                    </xsl:if>
                                    <xsl:variable name="counter-set" as="element()?" select="$counter-set[last()]"/>
                                    <xsl:if test="$counter-set">
                                        <xsl:if test="(xs:integer($counter-set/@value) mod 2)=0">
                                            <xsl:message terminate="yes">
                                                <xsl:apply-templates mode="css:serialize" select="$counter-set"/>
                                                <xsl:text>: page counter may not be set to an even value</xsl:text>
                                            </xsl:message>
                                        </xsl:if>
                                        <xsl:attribute name="initial-page-number" select="$counter-set/@value"/>
                                    </xsl:if>
                                    <xsl:sequence select="$page-number-counter"/>
                                    <xsl:apply-templates mode="sequence-attr"
                                                         select="current-group()[1]/(@* except (@css:page|@css:volume|@css:string-entry|@css:counter-set))"/>
                                    <xsl:apply-templates mode="sequence-attr"
                                                         select="current-group()[1]/*/@css:volume-break-before[.='always']">
                                        <xsl:with-param name="first-sequence" tunnel="yes" select="$first-sequence"/>
                                    </xsl:apply-templates>
                                    <xsl:apply-templates mode="sequence"
                                                         select="current-group()[1]/(@css:string-entry|*)">
                                        <xsl:with-param name="top-of-page" tunnel="yes" select="true()"/> <!-- sequence starts on new sheet -->
                                    </xsl:apply-templates>
                                    <xsl:apply-templates mode="assert-nil-attr"
                                                         select="current-group()[position()&gt;1]/(@* except (@css:page|@css:volume|@css:string-entry))"/>
                                    <xsl:apply-templates mode="sequence"
                                                         select="current-group()[position()&gt;1]/*"/>
                                </sequence>
                            </xsl:for-each-group>
                </xsl:for-each-group>
            </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="apply-templates-within-post-or-pre-content-sequence">
        <xsl:param name="select" as="element()*" required="yes"/> <!-- (css:box|obfl:list-of-references)* -->
        <xsl:for-each-group select="$select" group-adjacent="boolean(self::obfl:list-of-references or
                                                                     self::css:box[@type='block' and @css:_obfl-list-of-references])">
            <xsl:variable name="first" as="xs:boolean" select="position()=1"/>
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:for-each select="current-group()">
                        <xsl:choose>
                            <xsl:when test="self::obfl:list-of-references">
                                <xsl:sequence select="."/>
                            </xsl:when>
                            <xsl:otherwise> <!-- css:box[@type='block' and @css:_obfl-list-of-references] -->
                                <xsl:variable name="collection" as="element()*">
                                    <xsl:apply-templates mode="display-obfl-list-of-references" select="."/>
                                </xsl:variable>
                                <xsl:if test="not(count($collection)=1)">
                                    <xsl:message terminate="yes">
                                      <xsl:text>The 'content' property on an element with 'display: -obfl-list-of-references' </xsl:text>
                                      <xsl:text>must consist of exactly one -obfl-collection().</xsl:text>
                                    </xsl:message>
                                </xsl:if>
                                <xsl:variable name="self" as="element()" select="."/>
                                <xsl:variable name="on-volume-start" as="element()*"
                                              select="if (@css:_obfl-on-volume-start)
                                                      then $sections/*[@css:flow=concat('-obfl-on-volume-start/',
                                                                                        $self/@css:_obfl-on-volume-start)]/*
                                                      else ()"/>
                                <xsl:variable name="on-volume-end" as="element()*"
                                              select="if (@css:_obfl-on-volume-end)
                                                      then $sections/*[@css:flow=concat('-obfl-on-volume-end/',
                                                                                        $self/@css:_obfl-on-volume-end)]/*
                                                      else ()"/>
                                <list-of-references collection="{$collection/@arg1}" range="document">
                                    <xsl:if test="exists($on-volume-start)">
                                        <on-volume-start>
                                            <xsl:for-each select="$on-volume-start">
                                                <xsl:apply-templates mode="sequence" select="."/>
                                            </xsl:for-each>
                                        </on-volume-start>
                                    </xsl:if>
                                    <xsl:if test="exists($on-volume-end)">
                                        <on-volume-end>
                                            <xsl:for-each select="$on-volume-end">
                                                <xsl:apply-templates mode="sequence" select="."/>
                                            </xsl:for-each>
                                        </on-volume-end>
                                    </xsl:if>
                                </list-of-references>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise> <!-- css:box -->
                    <xsl:variable name="block-boxes" as="element()*"> <!-- css:box[@type='block']* -->
                        <xsl:call-template name="make-anonymous-block-boxes">
                            <xsl:with-param name="boxes" select="current-group()"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:for-each-group select="$block-boxes" group-adjacent="(@css:_obfl-use-when-collection-not-empty,'normal')[1]">
                        <xsl:variable name="first" as="xs:boolean" select="$first and position()=1"/>
                        <xsl:variable name="flow" as="xs:string" select="current-grouping-key()"/>
                        <xsl:choose>
                            <xsl:when test="not($flow='normal')">
                                <xsl:if test="$flow=$collection-flows">
                                    <list-of-references collection="meta/{$flow}" range="document">
                                        <on-collection-start>
                                            <xsl:for-each select="current-group()">
                                                <xsl:apply-templates mode="sequence" select=".">
                                                    <xsl:with-param name="top-of-page" tunnel="yes" select="$first and position()=1"/>
                                                </xsl:apply-templates>
                                            </xsl:for-each>
                                        </on-collection-start>
                                    </list-of-references>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="current-group()">
                                    <xsl:apply-templates mode="sequence" select=".">
                                        <xsl:with-param name="top-of-page" tunnel="yes" select="$first and position()=1"/>
                                    </xsl:apply-templates>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="make-anonymous-block-boxes" as="element()*"> <!-- css:box[@type='block']* -->
        <xsl:param name="boxes" as="element()*" required="yes"/> <!-- css:box* -->
        <xsl:for-each-group select="$boxes" group-adjacent="boolean(self::css:box[@type='block'])">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:sequence select="current-group()"/>
                </xsl:when>
                <xsl:otherwise>
                    <css:box type="block">
                        <xsl:sequence select="current-group()"/>
                    </css:box>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template mode="display-obfl-list-of-references"
                  match="/css:_
                         /css:box[@type='block' and @css:_obfl-list-of-references]">
        <xsl:apply-templates mode="assert-nil-attr" select="@* except (@type|
                                                                       @css:_obfl-list-of-references|
                                                                       @css:_obfl-on-volume-start|
                                                                       @css:_obfl-on-volume-end)"/>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template mode="display-obfl-list-of-references"
                  match="css:box[@type='inline']">
        <xsl:apply-templates mode="#current" select="@* except @type"/>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template mode="display-obfl-list-of-references"
                  match="css:custom-func[@name='-obfl-collection' and @arg1 and not(@arg2)]">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template mode="display-obfl-list-of-references"
                  match="@*|node()">
      <xsl:message terminate="yes">
          <xsl:text>Coding error: unexpected </xsl:text>
          <xsl:value-of select="pxi:get-path(.)"/>
          <xsl:text> inside element with 'display: -obfl-list-of-references'</xsl:text>
        </xsl:message>
    </xsl:template>
    
    <!-- ======== -->
    <!-- Sequence -->
    <!-- ======== -->
    
    <xsl:template mode="sequence
                        sequence-interrupted-resumed"
                  match="/css:_/@css:string-entry">
        <block>
            <xsl:apply-templates mode="css:parse-string-entry" select="css:parse-string-set(.)"/>
        </block>
    </xsl:template>
    
    <xsl:template mode="css:parse-string-entry"
                  match="css:string-set">
        <xsl:variable name="value" as="xs:string*">
            <xsl:apply-templates mode="css:eval-string-set" select="css:parse-content-list(@value, ())"/>
        </xsl:variable>
        <marker class="{@name}/entry" value="{replace(string-join($value,''),'^\s+|\s+$','')}"/>
    </xsl:template>
    
    <!-- ===== -->
    <!-- Boxes -->
    <!-- ===== -->
    
    <xsl:template mode="block-attr span-attr td-attr table-attr assert-nil-attr"
                  match="css:box/@part"/>
    
    <xsl:template mode="block-attr span-attr td-attr table-attr toc-entry-attr assert-nil-attr"
                  match="css:box/@name|
                         css:box/css:_/@name|
                         css:_/css:_/@name"/>
    
    <!-- =========== -->
    <!-- Block boxes -->
    <!-- =========== -->
    
    <xsl:template mode="sequence item td sequence-interrupted-resumed"
                  match="css:box[@type='block']">
        <xsl:apply-templates mode="block" select="."/>
    </xsl:template>
    
    <xsl:template mode="table-of-contents"
                  match="css:box[@type='block']">
        <xsl:apply-templates mode="toc-entry" select="."/>
    </xsl:template>
    
    <!--
        block or toc-entry element depending on context
    -->
    <xsl:template priority="0.8"
                  mode="block"
                  match="css:box[@type='block']">
        <block>
            <xsl:next-match/>
        </block>
    </xsl:template>
    <xsl:template priority="0.8"
                  mode="toc-entry"
                  match="css:box[@type='block']">
        <!--
            Automatically compute the toc-entry's ref-id by searching for target-counter(),
            target-text() and target-string() values within the current block, descendant blocks,
            following blocks or preceding blocks (in that order). It is currently not possible to
            define the ref-id directly in CSS which means a table-of-contents can not be constructed
            if no references are used for rendering content (such as braille page numbers or print
            page numbers).
        -->
        <!--
            TODO: warning when not all references in a block point to the same element
            TODO: warning when a block has no references or descendant blocks with references
        -->
        <xsl:variable name="descendant-refs" as="attribute()*"
                      select="((descendant::css:box)/@css:anchor
                               |(descendant::css:string)/@target
                               |(descendant::css:counter)/@target)"/>
        <xsl:variable name="following-refs" as="attribute()*"
                      select="((following::css:box)/@css:anchor
                               |(following::css:string)/@target
                               |(following::css:counter)/@target)"/>
        <xsl:variable name="preceding-refs" as="attribute()*"
                      select="(preceding::css:box/@css:anchor
                               |preceding::css:string/@target
                               |preceding::css:counter/@target)"/>
        <xsl:choose>
            <xsl:when test="exists($descendant-refs[some $id in string(.) satisfies $sections/*[not(@css:flow)]//*[@css:id=$id]])">
                <xsl:variable name="ref-id" as="xs:string"
                              select="$descendant-refs[some $id in string(.) satisfies $sections/*[not(@css:flow)]//*[@css:id=$id]][1]"/>
                <toc-entry ref-id="{$ref-id}">
                    <xsl:next-match>
                        <xsl:with-param name="toc-entry-ref-id" select="$ref-id" tunnel="yes"/>
                    </xsl:next-match>
                </toc-entry>
            </xsl:when>
            <xsl:when test="exists($descendant-refs)">
                <!--
                    if the entry references an element in a named flow, we assume that element is
                    part of the volume begin or end area, and is therefore omitted from the table of
                    contents
                -->
            </xsl:when>
            <xsl:when test="exists($following-refs[some $id in string(.) satisfies $sections/*[not(@css:flow)]//*[@css:id=$id]])">
                <xsl:variable name="ref-id" as="xs:string"
                              select="$following-refs[some $id in string(.) satisfies $sections/*[not(@css:flow)]//*[@css:id=$id]][1]"/>
                <toc-entry ref-id="{$ref-id}">
                    <xsl:next-match>
                        <xsl:with-param name="toc-entry-ref-id" select="$ref-id" tunnel="yes"/>
                    </xsl:next-match>
                </toc-entry>
            </xsl:when>
            <xsl:when test="exists($preceding-refs[some $id in string(.) satisfies $sections/*[not(@css:flow)]//*[@css:id=$id]])">
                <xsl:variable name="ref-id" as="xs:string"
                              select="$preceding-refs[some $id in string(.) satisfies $sections/*[not(@css:flow)]//*[@css:id=$id]][last()]"/>
                <toc-entry ref-id="{$ref-id}">
                    <xsl:next-match>
                        <xsl:with-param name="toc-entry-ref-id" select="$ref-id" tunnel="yes"/>
                    </xsl:next-match>
                </toc-entry>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="pf:warn">
                    <xsl:with-param name="msg">
                        An element with display: -obfl-toc must have at least one descendant
                        target-counter(), target-string() or target-text() value (that references an
                        element that does not participate in a named flow).
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        wrap content in additional block or toc-entry element (depending on context) when
        page-break-before is combined with padding-top and string-set
    -->
    <xsl:template priority="0.73"
                  mode="block"
                  match="css:box[@type='block'][@css:page-break-before]">
          <xsl:apply-templates mode="block-attr" select="@css:page-break-before"/>
          <xsl:next-match/>
    </xsl:template>
    <xsl:template priority="0.72"
                  mode="block"
                  match="css:box[@type='block'][@css:page-break-before]">
        <xsl:variable name="first-inline" as="element()?" select="(descendant::css:box[@type='inline'])[1]"/>
        <xsl:variable name="string-set-on-first-inline" as="attribute()*"
                      select="$first-inline/@css:string-set|
                              $first-inline/css:_[not(preceding-sibling::*) and
                                                  not(preceding-sibling::text()[not(matches(string(),'^[\s&#x2800;]*$'))])]
                                           //@css:string-set"/>
        <xsl:choose>
            <xsl:when test="$string-set-on-first-inline
                            and (descendant-or-self::css:box[@type='block'] intersect $first-inline/ancestor::*)/@css:padding-top
                            and not((descendant::css:box[@type='block'] intersect $first-inline/ancestor::*)/@css:page-break-before)">
                <xsl:apply-templates mode="marker" select="$string-set-on-first-inline"/>
                <block>
                    <xsl:next-match>
                        <xsl:with-param name="string-set-handled" tunnel="yes" select="$string-set-on-first-inline"/>
                    </xsl:next-match>
                </block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template priority="0.72"
                  mode="toc-entry"
                  match="css:box[@type='block'][@css:page-break-before]">
        <xsl:param name="toc-entry-ref-id" as="xs:string" tunnel="yes"/>
        <xsl:variable name="first-inline" as="element()?" select="(descendant::css:box[@type='inline'])[1]"/>
        <xsl:variable name="string-set-on-first-inline" as="attribute()*"
                      select="$first-inline/@css:string-set|
                              $first-inline/css:_[not(preceding-sibling::*) and
                                                  not(preceding-sibling::text()[not(matches(string(),'^[\s&#x2800;]*$'))])]
                                           //@css:string-set"/>
        <xsl:choose>
            <xsl:when test="$string-set-on-first-inline
                            and (descendant-or-self::css:box[@type='block'] intersect $first-inline/ancestor::*)/@css:padding-top
                            and not((descendant::css:box[@type='block'] intersect $first-inline/ancestor::*)/@css:page-break-before)">
                <xsl:apply-templates mode="marker" select="$string-set-on-first-inline"/>
                <toc-entry ref-id="{$toc-entry-ref-id}">
                    <xsl:next-match>
                        <xsl:with-param name="string-set-handled" tunnel="yes" select="$string-set-on-first-inline"/>
                    </xsl:next-match>
                </toc-entry>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template priority="0.7" mode="marker" match="@css:string-set">
        <xsl:param name="string-set-handled" as="attribute()*" tunnel="yes" select="()"/>
        <xsl:if test="not(. intersect $string-set-handled)">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    
    <!--
        wrap content in additional block or toc-entry element (depending on context) when
        line-height > 1 is combined with top/bottom margin or border
    -->
    <xsl:template priority="0.61"
                  mode="block"
                  match="css:box[@type='block']
                                [@css:line-height
                                 and (@css:margin-top or @css:margin-top-skip-if-top-of-page or @css:margin-bottom or
                                      @css:border-top-pattern or @css:border-bottom-pattern)]">
        <block>
            <xsl:next-match/>
        </block>
    </xsl:template>
    <xsl:template priority="0.61"
                  mode="toc-entry"
                  match="css:box[@type='block']
                                [@css:line-height
                                 and (@css:margin-top or @css:margin-top-skip-if-top-of-page or @css:margin-bottom or
                                      @css:border-top-pattern or @css:border-bottom-pattern)]">
        <xsl:param name="toc-entry-ref-id" as="xs:string" tunnel="yes"/>
        <toc-entry ref-id="{$toc-entry-ref-id}">
            <xsl:next-match/>
        </toc-entry>
    </xsl:template>
    
    <!--
        attributes that apply on inner block if content is wrapped in additional block
    -->
    <xsl:template priority="0.6"
                  mode="block toc-entry"
                  match="css:box[@type='block']
                                [not(@css:line-height
                                     and (@css:margin-top or @css:margin-top-skip-if-top-of-page or @css:margin-bottom or
                                          @css:border-top-pattern or @css:border-bottom-pattern))]">
        <xsl:apply-templates mode="block-attr"
                             select="@css:line-height|@css:text-align|@css:text-indent|@page-break-inside"/>
        <xsl:next-match/>
        <xsl:apply-templates mode="anchor" select="@css:id"/>
    </xsl:template>
    <xsl:template priority="0.6"
                  mode="block toc-entry"
                  match="css:box[@type='block']
                                [@css:line-height
                                 and (@css:margin-top or @css:margin-top-skip-if-top-of-page or @css:margin-bottom or
                                      @css:border-top-pattern or @css:border-bottom-pattern)]">
        <xsl:apply-templates mode="block-attr"
                             select="@css:line-height|@css:text-align|@css:text-indent|@page-break-inside"/>
        <!--
            repeat orphans/widows (why?)
        -->
        <xsl:apply-templates mode="block-attr" select="@css:orphans|@css:widows"/>
        <xsl:next-match/>
        <xsl:apply-templates mode="anchor" select="@css:id"/>
    </xsl:template>
    
    <xsl:template priority="0.59"
                  mode="block toc-entry"
                  match="css:box[@type='block']">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!--
        Rendering scenarios
    -->
    <xsl:template priority="0.591"
                  mode="block"
                  match="css:box[@type='block'][@css:_obfl-scenarios]">
        <xml-data renderer="{pxi:renderer-name(.)}">
            <d:scenarios>
                <xsl:apply-templates mode="xml-data"/>
            </d:scenarios>
        </xml-data>
    </xsl:template>
    
    <xsl:template mode="xml-data"
                  match="css:box[@type=('block','table')][@css:_obfl-scenario]">
        <d:scenario>
            <xsl:apply-templates mode="block" select="."/>
        </d:scenario>
    </xsl:template>
    
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:_obfl-scenarios|
                         css:box[@type='block'][@css:_obfl-scenarios]/css:box[@type=('block','table')]/@css:_obfl-scenario|
                         css:box[@type='block'][@css:_obfl-scenarios]/css:box[@type=('block','table')]/@css:_obfl-scenario-cost"/>
    
    <xsl:template priority="0.7"
                  mode="toc-entry"
                  match="css:box[@type='block']">
        <xsl:apply-templates mode="assert-nil-attr" select="@css:_obfl-scenarios"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        attributes translate, hyphenate
    -->
    <xsl:template priority="0.71"
                  mode="block toc-entry"
                  match="css:box[@type='block']"
                  name="insert-text-attributes-and-next-match">
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:param name="pending-text-transform-inline" as="xs:string?" tunnel="yes" select="()"/>
        <xsl:param name="pending-hyphens-inline" as="xs:string?" tunnel="yes" select="()"/>
        <xsl:variable name="new-text-transform" as="xs:string?">
            <xsl:apply-templates mode="css:text-transform" select="."/>
        </xsl:variable>
        <xsl:variable name="new-hyphens" as="xs:string?">
            <xsl:apply-templates mode="css:hyphens" select="."/>
        </xsl:variable>
        <xsl:call-template name="obfl:translate">
            <xsl:with-param name="new-text-transform" select="$new-text-transform"/>
        </xsl:call-template>
        <xsl:call-template name="obfl:hyphenate">
            <xsl:with-param name="new-hyphens" select="$new-hyphens"/>
        </xsl:call-template>
        <xsl:next-match>
            <xsl:with-param name="text-transform" tunnel="yes" select="($new-text-transform,$text-transform)[1]"/>
            <xsl:with-param name="hyphens" tunnel="yes" select="($new-hyphens,$hyphens)[1]"/>
            <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform-inline"/>
            <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens-inline"/>
        </xsl:next-match>
    </xsl:template>
    
    <!--
        all other attributes
    -->
    <xsl:template priority="0.7"
                  mode="block toc-entry"
                  match="css:box[@type='block']">
        <xsl:apply-templates mode="block-attr"
                             select="@* except (@type|
                                                @css:text-transform|@css:hyphens|
                                                @css:line-height|@css:text-align|@css:text-indent|@page-break-inside|
                                                @css:page-break-before)"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!-- ====== -->
    <!-- Tables -->
    <!-- ====== -->
    
    <xsl:template priority="0.6"
                  mode="sequence block"
                  match="css:box[@type='table']">
        <table>
            <xsl:call-template name="insert-text-attributes-and-next-match"/>
        </table>
    </xsl:template>
    
    <xsl:template mode="sequence block"
                  match="css:box[@type='table']">
        <xsl:apply-templates mode="table-attr" select="@* except (@type|@css:render-table-by|
                                                                  @css:text-transform|@css:hyphens)"/>
        <xsl:if test="@css:render-table-by and not(@css:render-table-by='column')">
            <xsl:call-template name="pf:warn">
                <xsl:with-param name="msg">
                    'render-table-by' property with a value other than 'column' is not supported on
                    elements with 'display: table'.
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="@css:render-table-by='column'">
                <xsl:for-each-group select="css:box[@type='table-cell']" group-by="@css:table-column">
                    <xsl:sort select="xs:integer(current-grouping-key())"/>
                    <tr>
                        <xsl:for-each select="current-group()">
                            <xsl:sort select="if (@css:table-header-group) then 1 else
                                              if (@css:table-row-group) then 2 else
                                              if (@css:table-footer-group) then 3 else ()"/>
                            <xsl:sort select="xs:integer((@css:table-header-group,@css:table-row-group,@css:table-footer-group)[1])"/>
                            <xsl:sort select="xs:integer(@css:table-row)"/>
                            <xsl:apply-templates mode="tr" select="."/>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="header-cells" as="element()*" select="css:box[@type='table-cell' and @css:table-header-group]"/>
                <xsl:variable name="body-cells" as="element()*" select="css:box[@type='table-cell' and @css:table-row-group]"/>
                <xsl:variable name="footer-cells" as="element()*" select="css:box[@type='table-cell' and @css:table-footer-group]"/>
                <xsl:variable name="header" as="element()*">
                    <xsl:for-each-group select="$header-cells" group-by="@css:table-row">
                        <xsl:sort select="xs:integer(current-grouping-key())"/>
                        <tr>
                            <xsl:for-each select="current-group()">
                                <xsl:sort select="xs:integer(@css:table-column)"/>
                                <xsl:apply-templates mode="tr" select="."/>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each-group>
                </xsl:variable>
                <xsl:variable name="body" as="element()*">
                    <xsl:for-each-group select="$body-cells" group-by="@css:table-row-group">
                        <xsl:sort select="xs:integer(current-grouping-key())"/>
                        <xsl:for-each-group select="current-group()" group-by="@css:table-row">
                            <xsl:sort select="xs:integer(current-grouping-key())"/>
                            <tr>
                                <xsl:for-each select="current-group()">
                                    <xsl:sort select="xs:integer(@css:table-column)"/>
                                    <xsl:apply-templates mode="tr" select="."/>
                                </xsl:for-each>
                            </tr>
                        </xsl:for-each-group>
                    </xsl:for-each-group>
                </xsl:variable>
                <xsl:variable name="footer" as="element()*">
                    <xsl:for-each-group select="$footer-cells" group-by="@css:table-row">
                        <xsl:sort select="xs:integer(current-grouping-key())"/>
                        <tr>
                            <xsl:for-each select="current-group()">
                                <xsl:sort select="xs:integer(@css:table-column)"/>
                                <xsl:apply-templates mode="tr" select="."/>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each-group>
                </xsl:variable>
                <xsl:apply-templates mode="table" select="node() except ($header-cells|$body-cells|$footer-cells)"/>
                <xsl:choose>
                    <xsl:when test="exists($header)">
                        <thead>
                            <xsl:sequence select="$header"/>
                        </thead>
                        <tbody>
                            <xsl:sequence select="$body"/>
                            <xsl:sequence select="$footer"/>
                        </tbody>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$body"/>
                        <xsl:sequence select="$footer"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template priority="0.6"
                  mode="tr"
                  match="css:box[@type='table-cell']">
        <td>
            <xsl:call-template name="insert-text-attributes-and-next-match"/>
        </td>
    </xsl:template>
    
    <xsl:template mode="tr"
                  match="css:box[@type='table-cell']">
        <xsl:if test="@css:table-row-span">
            <xsl:attribute name="{if (parent::*/@css:render-table-by='column') then 'col-span' else 'row-span'}"
                           select="@css:table-row-span"/>
        </xsl:if>
        <xsl:if test="@css:table-column-span">
            <xsl:attribute name="{if (parent::*/@css:render-table-by='column') then 'row-span' else 'col-span'}"
                           select="@css:table-column-span"/>
        </xsl:if>
        <xsl:apply-templates mode="td-attr"
                             select="@* except (@type|
                                                @css:text-transform|@css:hyphens|
                                                @css:table-header-group|
                                                @css:table-row-group|
                                                @css:table-footer-group|
                                                @css:table-row|
                                                @css:table-column|
                                                @css:table-row-span|
                                                @css:table-column-span)"/>
        <xsl:apply-templates mode="td"/>
    </xsl:template>
    
    <xsl:template mode="td"
                  match="css:box[@type='table']">
        <xsl:call-template name="pf:error">
            <xsl:with-param name="msg">Nested tables not supported.</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- ============ -->
    <!-- Inline boxes -->
    <!-- ============ -->
    
    <xsl:template mode="block td toc-entry"
                  match="css:box[@type='inline']">
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:param name="pending-text-transform" as="xs:string?" tunnel="yes" select="()"/>
        <xsl:param name="pending-hyphens" as="xs:string?" tunnel="yes" select="()"/>
        <xsl:variable name="pending-text-transform" as="xs:string?"
                      select="(@css:text-transform/string(),$pending-text-transform)[1]"/>
        <xsl:variable name="pending-hyphens" as="xs:string?"
                      select="(@css:hyphens/string(),$pending-hyphens)[1]"/>
        <xsl:apply-templates mode="marker" select="@css:string-set|@css:_obfl-marker"/>
        <xsl:apply-templates mode="assert-nil-attr"
                             select="@* except (@type|
                                                @css:id|
                                                @css:string-set|
                                                @css:_obfl-marker|
                                                @css:text-transform|@css:hyphens)"/>
        <xsl:apply-templates mode="#current" select="@css:id"/>
        <xsl:for-each-group select="node()" group-adjacent="boolean(
                                                              self::css:box[@type='inline'] or
                                                              self::css:custom-func[@name='-obfl-evaluate'] or
                                                              self::css:counter[@target][@name=$page-counter-names] or
                                                              self::css:leader)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:apply-templates mode="#current" select="current-group()">
                        <xsl:with-param name="pending-text-transform" tunnel="yes" select="$pending-text-transform"/>
                        <xsl:with-param name="pending-hyphens" tunnel="yes" select="$pending-hyphens"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="every $n in current-group() satisfies
                                $n/self::text() and matches(string($n),'^[ \t\n\r&#x2800;&#x00AD;&#x200B;]*$')">
                    <xsl:value-of select="."/>
                </xsl:when>
                <!--
                    FIXME: this is a hack to avoid ending up with spans around <br/> elements, but
                    this should be fixed either in the pre-translator or in the Dotify white space
                    normalizer.
                -->
                <xsl:when test="every $n in current-group() satisfies
                                matches(string($n),'^[\s&#x2800;]*$')
                                and not($n/descendant-or-self::css:string|
                                        $n/descendant-or-self::css:counter|
                                        $n/descendant-or-self::css:leader|
                                        $n/descendant-or-self::css:custom-func)">
                    <xsl:apply-templates mode="#current" select="current-group()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="new-text-transform" as="xs:string" select="($pending-text-transform,$text-transform)[1]"/>
                    <xsl:variable name="new-hyphens" as="xs:string" select="($pending-hyphens,$hyphens)[1]"/>
                    <xsl:variable name="attrs" as="attribute()*">
                        <xsl:call-template name="obfl:translate">
                            <xsl:with-param name="new-text-transform" select="$new-text-transform"/>
                        </xsl:call-template>
                        <xsl:call-template name="obfl:hyphenate">
                            <xsl:with-param name="new-hyphens" select="$new-hyphens"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="exists($attrs)">
                            <span>
                                <xsl:sequence select="$attrs"/>
                                <xsl:apply-templates mode="span" select="current-group()">
                                    <xsl:with-param name="pending-text-transform" tunnel="yes" select="()"/>
                                    <xsl:with-param name="pending-hyphens" tunnel="yes" select="()"/>
                                    <xsl:with-param name="text-transform" tunnel="yes" select="$new-text-transform"/>
                                    <xsl:with-param name="hyphens" tunnel="yes" select="$new-hyphens"/>
                                </xsl:apply-templates>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates mode="#current" select="current-group()">
                                <xsl:with-param name="pending-text-transform" tunnel="yes" select="()"/>
                                <xsl:with-param name="pending-hyphens" tunnel="yes" select="()"/>
                                <xsl:with-param name="text-transform" tunnel="yes" select="$new-text-transform"/>
                                <xsl:with-param name="hyphens" tunnel="yes" select="$new-hyphens"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
        <xsl:apply-templates mode="anchor" select="@css:id"/>
    </xsl:template>
    
    <!-- ===================== -->
    <!-- Other inline elements -->
    <!-- ===================== -->
    
    <xsl:template mode="block span td table toc-entry"
                  match="css:box/css:_|
                         css:_/css:_">
        <xsl:apply-templates mode="assert-nil-attr" select="@* except (@css:id|@css:string-set|@css:_obfl-marker)"/>
        <xsl:apply-templates mode="#current" select="@css:id"/>
        <xsl:apply-templates mode="marker" select="@css:string-set|@css:_obfl-marker"/>
        <xsl:apply-templates mode="#current"/>
        <xsl:apply-templates mode="anchor" select="@css:id"/>
    </xsl:template>
    
    <xsl:template priority="2"
                  mode="block span toc-entry"
                  match="css:_/text()">
        <xsl:call-template name="coding-error"/>
    </xsl:template>
    
    <!-- =============== -->
    <!-- Text attributes -->
    <!-- =============== -->
    
    <xsl:template mode="css:text-transform" match="css:box" as="xs:string?">
        <xsl:param name="pending-text-transform" as="xs:string?" tunnel="yes" select="()"/>
        <xsl:sequence select="(@css:text-transform/string(),$pending-text-transform)[1]"/>
    </xsl:template>
    
    <xsl:template mode="css:hyphens" match="css:box" as="xs:string?">
        <xsl:param name="pending-hyphens" as="xs:string?" tunnel="yes" select="()"/>
        <xsl:sequence select="(@css:hyphens/string(),$pending-hyphens)[1]"/>
    </xsl:template>
    
    <xsl:template name="obfl:hyphenate" as="attribute()?"> <!-- @hyphenate? -->
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:param name="new-hyphens" as="xs:string?"/>
        <!--
            'hyphens:auto' corresponds with 'hyphenate="true"'. 'hyphens:manual' corresponds with
            'hyphenate="false"'. For 'hyphens:none' all SHY and ZWSP characters are removed from the
            text.
        -->
        <xsl:choose>
            <xsl:when test="not(exists($new-hyphens))"/>
            <xsl:when test="$new-hyphens='auto' and not($hyphens='auto')">
                <xsl:attribute name="hyphenate" select="'true'"/>
            </xsl:when>
            <xsl:when test="not($new-hyphens='auto') and $hyphens='auto'">
                <xsl:attribute name="hyphenate" select="'false'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="obfl:translate" as="attribute()?"> <!-- @translate? -->
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="new-text-transform" as="xs:string?"/>
        <!--
            'text-transform:auto' corresponds with 'translate=""'. 'text-transform:none' corresponds
            with 'translate="pre-translated-text-css"'. Other values of text-transform are handled
            through style elements and text-style attributes.
        -->
        <xsl:choose>
            <xsl:when test="not(exists($new-text-transform))"/>
            <xsl:when test="$new-text-transform='none' and not($text-transform='none')">
                <xsl:attribute name="translate" select="'pre-translated-text-css'"/>
            </xsl:when>
            <xsl:when test="not($new-text-transform='none') and $text-transform='none'">
                <xsl:attribute name="translate" select="''"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template priority="1"
                  mode="block span td table toc-entry"
                  match="css:box[@css:word-spacing]">
        <xsl:next-match>
            <xsl:with-param name="word-spacing" tunnel="yes" select="xs:integer(@css:word-spacing)"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template mode="block-attr span-attr td-attr table-attr toc-entry-attr assert-nil-attr"
                  match="css:box/@css:word-spacing"/>
    
    <xsl:template priority="1.01"
                  mode="block span td table toc-entry"
                  match="css:box[@css:white-space]|
                         css:string[@name][@css:white-space]|
                         css:counter[@target][@name=$page-counter-names][@css:white-space]|
                         css:custom-func[@name='-obfl-evaluate'][@css:white-space]">
        <xsl:next-match>
            <xsl:with-param name="white-space" tunnel="yes" select="@css:white-space"/>
        </xsl:next-match>
    </xsl:template>
    
    <!-- ================ -->
    <!-- Other attributes -->
    <!-- ================ -->
    
    <xsl:template priority="0.6"
                  mode="block-attr toc-entry-attr"
                  match="/css:_/*/@css:_obfl-toc|
                         /css:_/*[@css:_obfl-toc]/@css:page-break-before[.='always']|
                         /css:_/*[@css:_obfl-toc]/@css:_obfl-toc-range|
                         /css:_/*[@css:_obfl-toc]/@css:_obfl-on-toc-start|
                         /css:_/*[@css:_obfl-toc]/@css:_obfl-on-volume-start|
                         /css:_/*[@css:_obfl-toc]/@css:_obfl-on-volume-end|
                         /css:_/*[@css:_obfl-toc]/@css:_obfl-on-toc-end"/>
    
    <xsl:template mode="block-attr table-attr toc-entry-attr"
                  match="css:box[@type=('block','table')]/@css:margin-left|
                         css:box[@type=('block','table')]/@css:margin-right|
                         css:box[@type=('block','table')]/@css:margin-top|
                         css:box[@type=('block','table')]/@css:margin-bottom|
                         css:box[@type=('block','table')]/@css:padding-left|
                         css:box[@type=('block','table')]/@css:padding-right|
                         css:box[@type=('block','table')]/@css:padding-top|
                         css:box[@type=('block','table')]/@css:padding-bottom">
        <xsl:attribute name="{local-name()}" select="format-number(xs:integer(number(.)), '0')"/>
    </xsl:template>
    
    <xsl:template mode="block-attr table-attr toc-entry-attr"
                  match="css:box[@type='block']/@css:margin-top-skip-if-top-of-page">
        <xsl:param name="top-of-page" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:if test="not($top-of-page)">
            <xsl:attribute name="margin-top" select="format-number(xs:integer(number(.)), '0')"/>
        </xsl:if>
    </xsl:template>
    
    <!--
        combine margin and padding on table cells
    -->
    <xsl:template mode="td-attr"
                  match="css:box[@type='table-cell' and not(@css:padding-left)]/@css:margin-left|
                         css:box[@type='table-cell' and not(@css:padding-right)]/@css:margin-right|
                         css:box[@type='table-cell' and not(@css:padding-top)]/@css:margin-top|
                         css:box[@type='table-cell' and not(@css:padding-bottom)]/@css:margin-bottom">
        <xsl:attribute name="{replace(local-name(),'margin','padding')}"
                       select="format-number(xs:integer(number(.)), '0')"/>
    </xsl:template>
    
    <xsl:template mode="td-attr"
                  match="css:box[@type='table-cell']/@css:padding-left|
                         css:box[@type='table-cell']/@css:padding-right|
                         css:box[@type='table-cell']/@css:padding-top|
                         css:box[@type='table-cell']/@css:padding-bottom">
        <xsl:variable name="padding" as="xs:integer" select="xs:integer(number(.))"/>
        <xsl:variable name="margin-name" as="xs:string" select="replace(local-name(),'padding','margin')"/>
        <xsl:variable name="margin" as="xs:integer" select="xs:integer(number((parent::*/@css:*[local-name()=$margin-name],0)[1]))"/>
        <xsl:attribute name="{local-name()}" select="format-number($padding + $margin, '0')"/>
    </xsl:template>
    
    <xsl:template mode="block-attr table-attr toc-entry-attr"
                  match="css:box[@type=('block','table')]/@css:line-height">
        <xsl:variable name="rounded" as="xs:double" select="number(css:round-line-height(.))"/>
        <xsl:choose>
            <xsl:when test="$rounded=1"/>
            <xsl:when test="$rounded &lt; 1">
                <xsl:message select="concat('line-height smaller than 1 not supported: ', .)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="row-spacing" select="format-number($rounded, '0.00')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        handle negative text-indent
    -->
    <xsl:template priority="0.6"
                  mode="block-attr table-attr td-attr toc-entry-attr"
                  match="css:box[@type=('block','table-cell')
                                 and not(child::css:box[@type='block'])
                                 and not(@css:border-top-pattern|@css:border-bottom-pattern|@css:border-left-pattern)
                                 and @css:text-indent]
                         /@css:margin-left"/>
    
    <xsl:template priority="0.6"
                  mode="block-attr table-attr td-attr toc-entry-attr"
                  match="css:box[@type=('block','table-cell')
                                 and not(child::css:box[@type='block'])
                                 and @css:text-indent]
                         /@css:padding-left"/>
    
    <xsl:template priority="0.6"
                  mode="block-attr table-attr td-attr toc-entry-attr"
                  match="css:box[@type=('block','table-cell')
                                 and not(child::css:box[@type='block'])]
                         /@css:text-indent">
        <xsl:variable name="text-indent" as="xs:integer" select="xs:integer(number(.))"/>
        <xsl:variable name="padding-left" as="xs:integer" select="(parent::*/@css:padding-left/xs:integer(number(.)),0)[1]"/>
        <xsl:choose>
            <xsl:when test="parent::*/(@css:border-top-pattern|@css:border-bottom-pattern|@css:border-left-pattern)">
                <xsl:if test="parent::*[@name or not(preceding-sibling::css:box)]">
                    <xsl:attribute name="first-line-indent" select="format-number($padding-left + $text-indent, '0')"/>
                </xsl:if>
                <xsl:if test="$padding-left &gt; 0">
                    <xsl:attribute name="text-indent" select="format-number($padding-left, '0')"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="margin-left" as="xs:integer" select="(parent::*/@css:margin-left/xs:integer(number(.)),0)[1]"/>
                <xsl:if test="parent::*[@name or not(preceding-sibling::css:box)]">
                    <xsl:attribute name="first-line-indent" select="format-number($margin-left + $padding-left + $text-indent, '0')"/>
                </xsl:if>
                <xsl:if test="$margin-left + $padding-left &gt; 0">
                    <xsl:attribute name="text-indent" select="format-number($margin-left + $padding-left, '0')"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template mode="block-attr table-attr td-attr toc-entry-attr"
                  match="css:box[@type=('block','table-cell')]/@css:text-indent"/>
    
    <xsl:template mode="block-attr table-attr td-attr toc-entry-attr"
                  match="css:box[@type=('block','table-cell')]/@css:text-align">
        <xsl:attribute name="align" select="."/>
    </xsl:template>
    
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:_obfl-vertical-position">
        <xsl:attribute name="vertical-position" select="."/>
    </xsl:template>
    
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:_obfl-vertical-align">
        <xsl:attribute name="vertical-align" select="."/>
    </xsl:template>
    
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:page-break-before[.='always']">
        <xsl:attribute name="break-before" select="'page'"/>
    </xsl:template>
    
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:page-break-before[.='right']">
        <xsl:attribute name="break-before" select="'sheet'"/>
    </xsl:template>
    
    <!--
        FIXME: 'left' not supported, treating as 'always'
    -->
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:page-break-before[.='left']">
        <xsl:call-template name="pf:warn">
            <xsl:with-param name="msg">{}:{} not supported yet. Treating like "always".</xsl:with-param>
            <xsl:with-param name="args" select="(local-name(),
                                                 .)"/>
        </xsl:call-template>
        <xsl:attribute name="break-before" select="'page'"/>
    </xsl:template>
    
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:page-break-after[.='avoid']">
        <xsl:attribute name="keep-with-next" select="'1'"/>
        <!--
            keep-with-next="1" requires that keep="page". This gives it a slighly different meaning
            than "page-break-after: avoid", but it will do.
        -->
        <xsl:if test="not(parent::*/@css:page-break-inside[.='avoid'])">
            <xsl:attribute name="keep" select="'page'"/>
        </xsl:if>
    </xsl:template>
    
    <!--
        page-break-after:always|right becomes break-before="page|sheet" on next block unless there is no next block
    -->
    <xsl:template priority="1"
                  mode="block"
                  match="css:box[@type='block'][not(parent::css:box) and not(following-sibling::*)][@css:page-break-after[.='always']]">
        <xsl:next-match/>
        <block break-before="page"/>
    </xsl:template>
    <xsl:template mode="block-attr"
                  match="css:box[@type='block'][not(parent::css:box) and not(following-sibling::*)]/@css:page-break-after[.='always']"/>
    <xsl:template priority="1"
                  mode="block"
                  match="css:box[@type='block'][not(parent::css:box) and not(following-sibling::*)][@css:page-break-after[.='right']]">
        <xsl:next-match/>
        <block break-before="sheet"/>
    </xsl:template>
    <xsl:template mode="block-attr"
                  match="css:box[@type='block'][not(parent::css:box) and not(following-sibling::*)]/@css:page-break-after[.='right']"/>
    
    <!--
        FIXME: 'left' not supported
    -->
    <xsl:template mode="block-attr"
                  match="css:box[@type='block'][not(parent::css:box) and not(following-sibling::*)]/@css:page-break-after[.='left']"/>
    
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:page-break-inside[.='avoid']">
        <xsl:attribute name="keep" select="'page'"/>
    </xsl:template>
    
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:orphans|
                         css:box[@type='block']/@css:widows">
        <xsl:attribute name="{local-name()}" select="."/>
    </xsl:template>
    
    <xsl:template mode="sequence-attr"
                  match="css:box[@type='block'][not(parent::css:box) and not(preceding-sibling::*)]/@css:volume-break-before[.='always']">
        <xsl:param name="first-sequence" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:if test="not($first-sequence)">
            <xsl:attribute name="break-before" select="'volume'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="block-attr table-attr"
                  match="css:box[@type='block'][not(parent::css:box) and not(preceding-sibling::*)]/@css:volume-break-before[.='always']"/>
    
    <xsl:variable name="_OBFL_KEEP_FN_RE">-obfl-keep\(\s*([1-9])\s*\)</xsl:variable>
    <xsl:variable name="_OBFL_KEEP_FN_RE_priority" select="1"/>
    
    <xsl:template mode="block-attr table-attr"
                  match="css:box[@type='block']/@css:volume-break-inside">
        <xsl:variable name="this" select="."/>
        <xsl:analyze-string select="." regex="^{$_OBFL_KEEP_FN_RE}$">
            <xsl:matching-substring>
                <xsl:attribute name="volume-keep-priority" select="regex-group($_OBFL_KEEP_FN_RE_priority)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:call-template name="coding-error">
                    <xsl:with-param name="context" select="$this"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template mode="block-attr"
                  match="css:box[@type='block']/@css:_obfl-keep-with-previous-sheets|
                         css:box[@type='block']/@css:_obfl-keep-with-next-sheets">
        <xsl:attribute name="{replace(local-name(),'^_obfl-','')}" select="format-number(xs:integer(.), '0')"/>
    </xsl:template>
    
    <xsl:template mode="toc-entry-attr"
                  match="css:box[@type='block']/@css:_obfl-vertical-position|
                         css:box[@type='block']/@css:_obfl-vertical-align|
                         css:box[@type='block' and not(@css:_obfl-toc)]/@css:page-break-before|
                         css:box[@type='block']/@css:page-break-after|
                         css:box[@type='block']/@css:page-break-inside|
                         css:box[@type='block']/@css:orphans|
                         css:box[@type='block']/@css:widows">
        <xsl:call-template name="pf:warn">
            <xsl:with-param name="msg">Property {} not supported inside an element with display: -obfl-toc</xsl:with-param>
            <xsl:with-param name="args" select="replace(local-name(),'^_','-')"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template priority="1.1"
                  mode="block-attr"
                  match="css:box[@type='table-cell']//css:box[@type='block']/@css:_obfl-vertical-position|
                         css:box[@type='table-cell']//css:box[@type='block']/@css:_obfl-vertical-align|
                         css:box[@type='table-cell']//css:box[@type='block']/@css:page-break-before|
                         css:box[@type='table-cell']//css:box[@type='block']/@css:page-break-after|
                         css:box[@type='table-cell']//css:box[@type='block']/@css:page-break-inside|
                         css:box[@type='table-cell']//css:box[@type='block']/@css:orphans|
                         css:box[@type='table-cell']//css:box[@type='block']/@css:widows">
        <xsl:call-template name="pf:warn">
            <xsl:with-param name="msg">Property {} not supported inside table cell elements</xsl:with-param>
            <xsl:with-param name="args" select="replace(local-name(),'^_','-')"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template mode="block-attr table-attr td-attr toc-entry-attr"
                  match="css:box[@type=('block','table','table-cell')]/@css:border-left-pattern|
                         css:box[@type=('block','table','table-cell')]/@css:border-right-pattern">
        <xsl:variable name="name" select="replace(local-name(),'-pattern$','')"/>
        <xsl:choose>
            <xsl:when test=".=('⠇','⠿','⠸')">
                <xsl:attribute name="{$name}-style" select="'solid'"/>
                <xsl:choose>
                    <xsl:when test=".='⠿'">
                        <xsl:attribute name="{$name}-width" select="'2'"/>
                    </xsl:when>
                    <xsl:when test=".='⠇'">
                        <xsl:attribute name="{$name}-align"
                                       select="if (local-name()='border-left-pattern') then 'outer' else 'inner'"/>
                    </xsl:when>
                    <xsl:when test=".='⠸'">
                        <xsl:attribute name="{$name}-align"
                                       select="if (local-name()='border-right-pattern') then 'outer' else 'inner'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="pf:warn">
                    <xsl:with-param name="msg">{}:{} not supported yet</xsl:with-param>
                    <xsl:with-param name="args" select="(local-name(),
                                                         .)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template mode="block-attr table-attr td-attr toc-entry-attr"
                  match="css:box[@type=('block','table','table-cell')]/@css:border-top-pattern|
                         css:box[@type=('block','table','table-cell')]/@css:border-bottom-pattern">
        <xsl:variable name="name" select="replace(local-name(),'-pattern$','')"/>
        <xsl:choose>
            <xsl:when test=".=('⠉','⠛','⠒','⠿','⠶','⠤')">
                <xsl:attribute name="{$name}-style" select="'solid'"/>
                <xsl:choose>
                    <xsl:when test=".=('⠛','⠶')">
                        <xsl:attribute name="{$name}-width" select="'2'"/>
                    </xsl:when>
                    <xsl:when test=".='⠿'">
                        <xsl:attribute name="{$name}-width" select="'3'"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test=".=('⠉','⠛')">
                        <xsl:attribute name="{$name}-align"
                                       select="if (local-name()='border-top-pattern') then 'outer' else 'inner'"/>
                    </xsl:when>
                    <xsl:when test=".=('⠶','⠤')">
                        <xsl:attribute name="{$name}-align"
                                       select="if (local-name()='border-top-pattern') then 'inner' else 'outer'"/>
                    </xsl:when>
                    <xsl:when test=".='⠒'">
                        <xsl:attribute name="{$name}-align"
                                       select="'center'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="pf:warn">
                    <xsl:with-param name="msg">{}:{} not supported yet</xsl:with-param>
                    <xsl:with-param name="args" select="(replace(local-name(),'^_','-'),
                                                         .)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template mode="block-attr table-attr td-attr toc-entry-attr"
                  match="css:box[@type='block']/@css:_obfl-underline">
        <xsl:attribute name="underline-pattern" select="."/>
    </xsl:template>
    
    <xsl:template mode="block-attr assert-nil-attr"
                  match="@css:_obfl-use-when-collection-not-empty[.='normal']"/>
    
    <xsl:template mode="block-attr assert-nil-attr"
                  match="/css:_[@css:flow[not(.=$collection-flows)]]/*/@css:_obfl-use-when-collection-not-empty"/>
    
    <!-- ==================== -->
    <!-- More inline elements -->
    <!-- ==================== -->
    
    <!--
        string() and target-string()
    -->
    <xsl:template mode="block span toc-entry"
                  match="css:string[@name]">
        <xsl:param name="white-space" as="xs:string?" tunnel="yes" select="()"/>
        <xsl:if test="@scope">
            <xsl:call-template name="pf:warn">
                <xsl:with-param name="msg">string({}, {}): second argument not supported</xsl:with-param>
                <xsl:with-param name="args" select="(@name,
                                                     @scope)"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$white-space[not(.='normal')]">
            <xsl:call-template name="pf:warn">
                <xsl:with-param name="msg">white-space:{} could not be applied to {}({})</xsl:with-param>
                <xsl:with-param name="args" select="($white-space,
                                                     if (@target) then 'target-string' else 'string',
                                                     @name)"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="target" as="xs:string?" select="if (@target) then @target else ()"/>
        <xsl:variable name="target" as="element()?" select="if ($target)
                                                            then $sections//*[@css:id=$target][1]
                                                                 /(descendant-or-self::css:box|following::css:box)[@type='inline'][1]
                                                            else ."/>
        <xsl:if test="$target">
            <xsl:apply-templates mode="css:eval-string" select="css:string(@name, $target)"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="css:eval-string"
                  match="css:string[@value]">
        <xsl:variable name="evaluated" as="xs:string">
            <xsl:apply-templates mode="css:eval" select="."/>
        </xsl:variable>
        <xsl:call-template name="text">
            <xsl:with-param name="text" select="$evaluated"/>
        </xsl:call-template>
    </xsl:template>
    
    <!--
        target-counter(page)
    -->
    <xsl:template mode="block toc-entry"
                  priority="1"
                  match="css:counter[@target][@name=$page-counter-names]">
        <xsl:variable name="target" as="xs:string" select="@target"/>
        <xsl:variable name="target" as="element()*" select="$sections//*[@css:id=$target]"/>
        <xsl:choose>
            <xsl:when test="count($target)=0">
                <!-- can not happen: these references should already have been removed in css:label-targets -->
                <xsl:message terminate="yes">coding error</xsl:message>
            </xsl:when>
            <xsl:when test="count($target)&gt;1">
                <!-- can happen -->
                <xsl:message>
                    <xsl:text>Ignoring '</xsl:text>
                    <xsl:apply-templates mode="css:serialize" select="."/>
                    <xsl:text>': there are multiple elements with the ID '</xsl:text>
                    <xsl:value-of select="(@original-target,@target)[1]"/>
                    <xsl:text>'.</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="target" as="element()" select="$target[1]"/>
                <!--
                    FIXME: compute target-page-counter-name (how?) and when this doesn't match @name
                    raise a warning if @name is "page" or raise an error otherwise
                -->
                <xsl:choose>
                    <xsl:when test="$target/ancestor::*/@css:flow[not(.='normal')]">
                        <xsl:message>
                            <xsl:text>Ignoring '</xsl:text>
                            <xsl:apply-templates mode="css:serialize" select="."/>
                            <xsl:text>': referencing element in named flow.</xsl:text>
                        </xsl:message>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:next-match/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template mode="block toc-entry"
                  match="css:counter[@target][@name=$page-counter-names]">
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:param name="pending-text-transform" as="xs:string?" tunnel="yes"/>
        <xsl:param name="pending-hyphens" as="xs:string?" tunnel="yes"/>
        <xsl:param name="white-space" as="xs:string?" tunnel="yes" select="()"/>
        <xsl:if test="($pending-text-transform[not(.='none')] and $text-transform='none')
                      or ($pending-hyphens[not(.='auto')] and $hyphens='auto')">
            <xsl:message terminate="yes">Coding error</xsl:message>
        </xsl:if>
        <xsl:variable name="text-transform" as="xs:string" select="($pending-text-transform,$text-transform)[1]"/>
        <xsl:variable name="hyphens" as="xs:string" select="($pending-hyphens,$hyphens)[1]"/>
        <xsl:variable name="style" as="xs:string*">
            <xsl:variable name="text-transform" as="xs:string*">
                <xsl:if test="matches(@style,re:exact($css:SYMBOLS_FN_RE))">
                    <xsl:sequence select="'-dotify-counter'"/>
                </xsl:if>
                <!--
                    Dotify always uses default mode for page-number (bug?)
                -->
                <xsl:if test="not($text-transform='auto' or ($text-transform='none' and matches(@style,re:exact($css:SYMBOLS_FN_RE))))">
                    <xsl:sequence select="$text-transform"/>
                </xsl:if>
            </xsl:variable>
            <xsl:if test="exists($text-transform)">
                <xsl:sequence select="concat('text-transform: ',string-join($text-transform,' '))"/>
            </xsl:if>
            <xsl:if test="$hyphens='none'">
                <xsl:sequence select="concat('hyphens: ',$hyphens)"/>
            </xsl:if>
            <xsl:if test="$white-space[not(.='normal')]">
                <xsl:sequence select="concat('white-space:',$white-space)"/>
            </xsl:if>
            <xsl:if test="matches(@style,re:exact($css:SYMBOLS_FN_RE))">
                <xsl:sequence select="concat('-dotify-counter-style: ',@style)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="page-number" as="element()">
            <page-number ref-id="{@target}"
                         number-format="{if (@style=('roman', 'upper-roman', 'lower-roman', 'upper-alpha', 'lower-alpha'))
                                         then @style else 'default'}"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($style)">
                <style name="{string-join($style,'; ')}">
                    <xsl:sequence select="$page-number"/>
                </style>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$page-number"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        set text-transform to "auto" on block with descendant -target-counter(page) with
        text-transform ≠ "auto" (because page-number can not be contained within span)
    -->
    <xsl:template priority="1"
                  mode="css:text-transform"
                  as="xs:string?"
                  match="css:box[@type='block']
                           [css:box[@type='inline']
                              //css:counter[@target][@name=$page-counter-names]
                                  /ancestor::css:box[@type='inline']
                                  /@css:text-transform
                                     [last()]
                                     [not(.='none')]]">
        <xsl:param name="specified-value" as="xs:boolean" select="false()"/>
        <xsl:choose>
            <xsl:when test="$specified-value">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'auto'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template priority="1"
                  mode="block"
                  match="css:box[@type='block']
                           [css:box[@type='inline']
                              //css:counter[@target][@name=$page-counter-names]
                                  /ancestor::css:box[@type='inline']
                                  /@css:text-transform
                                     [last()]
                                     [not(.='none')]]">
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:variable name="specified-text-transform" as="xs:string?">
            <xsl:apply-templates mode="css:text-transform" select=".">
                <xsl:with-param name="specified-value" select="true()"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:next-match>
            <!--
                for child css:box[@type='inline'] matcher (FIXME: what about child text nodes?)
            -->
            <xsl:with-param name="pending-text-transform-inline" tunnel="yes" select="($specified-text-transform,$text-transform)[1]"/>
        </xsl:next-match>
    </xsl:template>
    
    <!--
        leader()
    -->
    <xsl:template mode="block td toc-entry"
                  match="css:leader">
        <xsl:if test="@position[not(matches(.,re:exact($css:POSITIVE_NUMBER_RE)))]">
            <!--
                Percentages not supported because they are relative to the box width, but
                css:adjust-boxes changes the box dimensions
            -->
            <xsl:message terminate="yes">
                <xsl:apply-templates mode="css:serialize" select="."/>
                <xsl:text>: percentage not supported</xsl:text>
            </xsl:message>
        </xsl:if>
        <leader pattern="{@pattern}" position="{(@position,'100%')[1]}" align="{(@alignment,'right')[1]}"/>
    </xsl:template>
    
    <!--
        -obfl-evaluate
    -->
    <xsl:template priority="1"
                  mode="block"
                  match="css:custom-func[@name='-obfl-evaluate'][matches(@arg1,$css:STRING_RE) and not (@arg2)]">
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:param name="pending-text-transform" as="xs:string?" tunnel="yes"/>
        <xsl:param name="pending-hyphens" as="xs:string?" tunnel="yes"/>
        <xsl:param name="white-space" as="xs:string?" tunnel="yes" select="()"/>
        <xsl:if test="($pending-text-transform[not(.='none')] and $text-transform='none')
                      or ($pending-hyphens[not(.='auto')] and $hyphens='auto')">
            <xsl:message terminate="yes">Coding error</xsl:message>
        </xsl:if>
        <xsl:variable name="text-transform" as="xs:string" select="($pending-text-transform,$text-transform)[1]"/>
        <xsl:variable name="hyphens" as="xs:string" select="($pending-hyphens,$hyphens)[1]"/>
        <xsl:variable name="style" as="xs:string*">
            <xsl:if test="not($text-transform=('auto','none'))">
                <xsl:sequence select="concat('text-transform: ',$text-transform)"/>
            </xsl:if>
            <xsl:if test="$hyphens='none'">
                <xsl:sequence select="concat('hyphens: ',$hyphens)"/>
            </xsl:if>
            <xsl:if test="$white-space[not(.='normal')]">
                <xsl:sequence select="concat('white-space: ',$white-space)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="expression" as="xs:string" select="css:parse-string(@arg1)/@value"/>
        <xsl:choose>
            <xsl:when test="exists($style)">
                <style name="{string-join($style,'; ')}">
                    <evaluate expression="{$expression}"/>
                </style>
            </xsl:when>
            <xsl:otherwise>
                <evaluate expression="{$expression}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template mode="block span"
                  match="css:custom-func[@name='-obfl-evaluate'][@arg2]">
        <xsl:call-template name="pf:warn">
            <xsl:with-param name="msg">-obfl-evaluate() function requires exactly one string argument</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!--
        set text-transform to "auto" on block with descendant -obfl-evaluate() with text-transform ≠
        "auto" (because evaluate can not be contained within span)
    -->
    <xsl:template priority="1"
                  mode="css:text-transform"
                  as="xs:string?"
                  match="css:box[@type='block']
                           [css:box[@type='inline']
                              //css:custom-func
                                  [@name='-obfl-evaluate']
                                  [matches(@arg1,$css:STRING_RE) and not (@arg2)]
                                  /ancestor::css:box[@type='inline']
                                  /@css:text-transform
                                     [last()]
                                     [not(.='none')]]">
        <xsl:param name="specified-value" as="xs:boolean" select="false()"/>
        <xsl:choose>
            <xsl:when test="$specified-value">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'auto'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template priority="1"
                  mode="block"
                  match="css:box[@type='block']
                           [css:box[@type='inline']
                              //css:custom-func
                                  [@name='-obfl-evaluate']
                                  [matches(@arg1,$css:STRING_RE) and not (@arg2)]
                                  /ancestor::css:box[@type='inline']
                                  /@css:text-transform
                                     [last()]
                                     [not(.='none')]]">
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:variable name="specified-text-transform" as="xs:string?">
            <xsl:apply-templates mode="css:text-transform" select=".">
                <xsl:with-param name="specified-value" select="true()"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:next-match>
            <!--
                for child css:box[@type='inline'] matcher (FIXME: what about child text nodes?)
            -->
            <xsl:with-param name="pending-text-transform-inline" tunnel="yes" select="($specified-text-transform,$text-transform)[1]"/>
        </xsl:next-match>
    </xsl:template>
    
    <!-- =============== -->
    <!-- IDs and anchors -->
    <!-- =============== -->
    
    <xsl:variable name="page-number-references" as="xs:string*"
                  select="$sections//css:counter[@name='page']/@target"/>
    
    <xsl:variable name="toc-entry-references" as="xs:string*"
                  select="$sections//css:box[@type='block' and @css:_obfl-toc]
                          /((descendant::css:counter)/@target|
                            (descendant::css:string)/@target|
                            (descendant::css:box)/@css:anchor)"/>
    
    <xsl:template mode="block-attr toc-entry-attr span-attr"
                  match="css:box[@type='block']/@css:id|
                         css:box[@type='inline']/@css:id|
                         css:box[@type='inline']/css:_/@css:id">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="not(ancestor::*/@css:flow[not(.='normal')]) and $id=($page-number-references,$toc-entry-references)">
            <xsl:attribute name="id" select="$id"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="block td toc-entry"
                  match="css:box[@type='inline']/@css:id|
                         css:box[@type='inline']/css:_/@css:id">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="not(ancestor::*/@css:flow[not(.='normal')]) and $id=($page-number-references,$toc-entry-references)">
            <span id="{$id}"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="anchor"
                  match="css:box/@css:id|
                         css:box[@type='inline']/css:_/@css:id">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="$sections/*[@css:flow=$collection-flows]/*/@css:anchor=$id">
            <anchor item="{$id}"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="block-attr span-attr toc-entry-attr assert-nil-attr"
                  match="css:box/@css:anchor"/>
    
    <!-- ======= -->
    <!-- Markers -->
    <!-- ======= -->
    
    <!--
        wrap markers at the start of a block in an additional block (in order to support page-start
        and page-start-except-last)
    -->
    <xsl:template priority="0.6"
                  mode="marker"
                  match="css:box[@type='block']/css:box[@type='inline'][not(preceding-sibling::css:box)]/@css:string-set|
                         css:box[@type='block']/css:box[@type='inline'][not(preceding-sibling::css:box) and
                                                                        not(@css:id and
                                                                            not(ancestor::*/@css:flow[not(.='normal')]) and
                                                                            @css:id=($page-number-references,$toc-entry-references))]
                         /css:_[not(preceding-sibling::*) and
                                not(preceding-sibling::text()[not(matches(string(),'^[\s&#x2800;]*$'))])]
                         //@css:string-set">
        <block>
            <xsl:next-match/>
        </block>
    </xsl:template>
    
    <xsl:template mode="marker"
                  match="css:box[@type='inline']/@css:string-set|
                         css:box[@type='inline']/css:_/@css:string-set|
                         css:_/css:_/@css:string-set">
        <xsl:for-each select="css:parse-string-set(.)">
            <xsl:variable name="value" as="xs:string*">
                <xsl:apply-templates mode="css:eval-string-set" select="css:parse-content-list(@value, ())"/>
            </xsl:variable>
            <marker class="{@name}/prev"/>
            <marker class="{@name}" value="{replace(string-join($value,''),'^\s+|\s+$','')}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template mode="css:eval-string-set"
                  as="xs:string"
                  match="css:string[@value]">
        <xsl:sequence select="string(@value)"/>
    </xsl:template>
    
    <xsl:template mode="marker"
                  match="css:box/@css:_obfl-marker|
                         css:box/css:_/@css:_obfl-marker|
                         css:_/css:_/@css:_obfl-marker">
        <xsl:for-each select="tokenize(.,' ')">
            <marker class="indicator/{.}" value="x"/>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ========================== -->
    <!-- -obfl- prefixed attributes -->
    <!-- ========================== -->
    
    <xsl:template mode="table-attr"
                  match="css:box[@type='table']/@css:_obfl-table-col-spacing|
                         css:box[@type='table']/@css:_obfl-table-row-spacing|
                         css:box[@type='table']/@css:_obfl-preferred-empty-space">
        <xsl:attribute name="{replace(local-name(),'^_obfl-','')}" select="format-number(xs:integer(.), '0')"/>
    </xsl:template>
    
    <!-- ==== -->
    <!-- Text -->
    <!-- ==== -->
    
    <xsl:template mode="block span td toc-entry"
                  match="text()">
        <xsl:call-template name="text">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template mode="block span td toc-entry"
                  match="css:white-space">
        <xsl:apply-templates mode="#current">
            <xsl:with-param name="white-space" tunnel="yes" select="'pre-wrap'"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!--
        FIXME: only if within block and no sibling blocks
    -->
    <xsl:template name="text">
        <xsl:param name="text" as="xs:string" required="yes"/>
        <xsl:param name="text-transform" as="xs:string" tunnel="yes"/>
        <xsl:param name="hyphens" as="xs:string" tunnel="yes"/>
        <xsl:param name="word-spacing" as="xs:integer" tunnel="yes"/>
        <xsl:param name="white-space" as="xs:string?" tunnel="yes" select="()"/>
        
        <xsl:call-template name="pf:progress">
            <xsl:with-param name="progress" select="concat('1/',$progress-total)"/>
        </xsl:call-template>

        <xsl:choose>
            <xsl:when test="$white-space=('pre-wrap','pre-line') and matches($text,'\n')">
                <xsl:analyze-string select="$text" regex="\n">
                    <xsl:matching-substring>
                        <xsl:text>&#x200B;</xsl:text> <!-- to make sure there are no leading br elements in a block because those would be ignored -->
                        <br/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:call-template name="text">
                            <xsl:with-param name="text" select="."/>
                        </xsl:call-template>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="text" as="xs:string">
                    <xsl:choose>
                        <!--
                            For 'hyphens:none' all SHY and ZWSP characters are removed from the text in advance.
                            FIXME: handle this with a style element
                        -->
                        <xsl:when test="$hyphens='none'">
                            <xsl:sequence select="replace($text,'[&#x00AD;&#x200B;]','')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$text"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="text" as="xs:string*">
                    <xsl:choose>
                        <!--
                            When 'white-space: pre-wrap', replace spaces with NBSP and add ZWSP to
                            make the string breakable between words.
                            FIXME: handle this with a style element?
                        -->
                        <xsl:when test="$white-space='pre-wrap'">
                            <xsl:analyze-string select="$text" regex="[ \t\n\r&#x2800;]+">
                                <xsl:matching-substring>
                                    <xsl:value-of select="concat(replace(.,'.','&#x00A0;'),'&#x200B;')"/>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="translate($text,'&#x2800;',' ')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="text" as="xs:string" select="string-join($text)"/>
                <xsl:variable name="style" as="xs:string*">
                    <!--
                        text-transform values 'none' and 'auto' are handled through the translate attribute.
                    -->
                    <xsl:if test="not($text-transform=('none','auto'))">
                        <xsl:sequence select="concat('text-transform: ',$text-transform)"/>
                    </xsl:if>
                    <xsl:if test="not($word-spacing=1)">
                        <xsl:sequence select="concat('word-spacing: ',format-number($word-spacing, '0'))"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="not(exists($style))">
                        <xsl:value-of select="$text"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <style name="{string-join($style,'; ')}">
                            <xsl:value-of select="$text"/>
                        </style>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- === -->
    <!-- ... -->
    <!-- === -->
    
    <xsl:template priority="0.1"
                  mode="block-attr toc-entry-attr"
                  match="css:box[@type='block']/@css:_obfl-toc">
        <xsl:call-template name="pf:warn">
            <xsl:with-param name="msg">display: -obfl-toc only allowed on elements that are flowed into @begin or @end area.</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template mode="block-attr span-attr"
                  match="@css:_obfl-on-toc-start|
                         @css:_obfl-on-toc-end">
        <xsl:call-template name="pf:warn">
            <xsl:with-param name="msg">::{} pseudo-element only allowed on elements with display: -obfl-toc.</xsl:with-param>
            <xsl:with-param name="args" select="replace(local-name(),'^_','-')"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template mode="block-attr span-attr"
                  match="@css:_obfl-on-volume-start|
                         @css:_obfl-on-volume-end">
        <xsl:message select="concat(
                               '::',replace(local-name(),'^_','-'),
                               ' pseudo-element only allowed on elements with display: -obfl-toc or -obfl-list-of-references.')"/>
    </xsl:template>
    
    <xsl:template priority="-10"
                  mode="#default sequence item table-of-contents block span table tr td toc-entry assert-nil
                        sequence-attr item-attr table-of-contents-attr block-attr span-attr
                        table-attr tr-attr td-attr toc-entry-attr assert-nil-attr
                        marker sequence-interrupted-resumed"
                  match="@*|node()">
        <xsl:call-template name="coding-error"/>
    </xsl:template>
    
    <xsl:template name="coding-error">
        <xsl:param name="context" select="."/> <!-- element()|text()|attribute() -->
        <xsl:call-template name="pf:error">
            <xsl:with-param name="msg">
                <xsl:text>Coding error: unexpected </xsl:text>
                <xsl:value-of select="pxi:get-path($context)"/>
                <xsl:if test="$context/self::text()">
                    <xsl:text> ("</xsl:text>
                    <xsl:value-of select="replace(
                                            if (string-length($context)&gt;10) then concat(substring($context,1,10),'...') else string($context),
                                            '\n','\\n')"/>
                    <xsl:text>")</xsl:text>
                </xsl:if>
                <xsl:text> (mode was </xsl:text>
                <xsl:apply-templates select="$pxi:print-mode" mode="#current"/>
                <xsl:text>)</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:function name="pxi:get-path" as="xs:string">
        <xsl:param name="x"/> <!-- element()|text()|attribute() -->
        <xsl:variable name="name" as="xs:string"
                      select="if ($x/self::css:box[@name])
                              then $x/@name
                              else if ($x/self::text())
                              then 'text()'
                              else name($x)"/>
        <xsl:sequence select="if ($x/self::attribute())
                              then concat(pxi:get-path($x/parent::*),'/@',$name)
                              else if ($x/parent::*)
                              then concat(pxi:get-path($x/parent::*),'/',$name,'[',(count($x/preceding-sibling::*)+1),']')
                              else concat('/',$name)"/>
    </xsl:function>
    
    <xsl:variable name="pxi:print-mode"><pxi:print-mode/></xsl:variable>
    <xsl:template match="pxi:print-mode">#default</xsl:template>
    <xsl:template match="pxi:print-mode" mode="sequence">sequence</xsl:template>
    <xsl:template match="pxi:print-mode" mode="item">item</xsl:template>
    <xsl:template match="pxi:print-mode" mode="table-of-contents">table-of-contents</xsl:template>
    <xsl:template match="pxi:print-mode" mode="block">block</xsl:template>
    <xsl:template match="pxi:print-mode" mode="span">span</xsl:template>
    <xsl:template match="pxi:print-mode" mode="table">table</xsl:template>
    <xsl:template match="pxi:print-mode" mode="tr">tr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="td">td</xsl:template>
    <xsl:template match="pxi:print-mode" mode="toc-entry">toc-entry</xsl:template>
    <xsl:template match="pxi:print-mode" mode="assert-nil">assert-nil</xsl:template>
    <xsl:template match="pxi:print-mode" mode="sequence-attr">sequence-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="item-attr">item-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="table-of-contents-attr">table-of-contents-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="block-attr">block-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="span-attr">span-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="table-attr">table-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="tr-attr">tr-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="td-attr">td-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="toc-entry-attr">toc-entry-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="assert-nil-attr">assert-nil-attr</xsl:template>
    <xsl:template match="pxi:print-mode" mode="marker">marker</xsl:template>
    <xsl:template match="pxi:print-mode" mode="xml-data">xml-data</xsl:template>
    <xsl:template match="pxi:print-mode" mode="sequence-interrupted-resumed">sequence-interrupted-resumed</xsl:template>
    <xsl:template match="pxi:print-mode" mode="#all" priority="-1">?</xsl:template>
    
    <!-- =========== -->
    <!-- Volume area -->
    <!-- =========== -->
    
    <xsl:template mode="css:eval-volume-area-content-list
                        css:eval-sequence-interrupted-resumed-content-list"
                  match="css:string[@value]">
        <css:box type="inline">
            <xsl:value-of select="@value"/>
        </css:box>
    </xsl:template>
    
    <!--
        default scope within volume area is 'document'
    -->
    <xsl:template mode="css:eval-volume-area-content-list
                        css:eval-sequence-interrupted-resumed-content-list"
                  match="css:flow[@from and (not(@scope) or @scope='document')]">
        <xsl:variable name="flow" as="xs:string" select="@from"/>
        <xsl:sequence select="$sections/*[@css:flow=$flow]"/>
    </xsl:template>
    
    <xsl:template mode="css:eval-volume-area-content-list"
                  match="css:flow[@from=$collection-flows and @scope='volume']">
        <list-of-references collection="{@from}" range="volume"/>
    </xsl:template>
    
    <xsl:template mode="css:eval-volume-area-content-list
                        css:eval-sequence-interrupted-resumed-content-list"
                  match="css:attr|
                         css:content[@target]|
                         css:content[not(@target)]|
                         css:string[@name][not(@target)]|
                         css:counter[not(@target)]|
                         css:text[@target]|
                         css:string[@name][@target]|
                         css:counter[@target]|
                         css:leader">
        <xsl:call-template name="pf:warn">
            <xsl:with-param name="msg">{}{}() function not supported in volume area or volume transition</xsl:with-param>
            <xsl:with-param name="args" select="(if (@target) then 'target-' else '',
                                                 local-name())"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template mode="css:eval-volume-area-content-list"
                  match="css:custom-func[@name='-obfl-evaluate']">
        <xsl:call-template name="pf:warn">
            <xsl:with-param name="msg">-obfl-evaluate() function not supported in volume area</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template mode="css:eval-sequence-interrupted-resumed-content-list"
                  match="css:custom-func[@name='-obfl-evaluate']">
        <css:box type="inline">
            <xsl:sequence select="."/>
        </css:box>
    </xsl:template>
    
    <xsl:template mode="css:eval-volume-area-content-list
                        css:eval-sequence-interrupted-resumed-content-list"
                  match="*">
        <xsl:call-template name="pf:error">
            <xsl:with-param name="msg">Coding error</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- ======================== -->
    <!-- OBFL evaluation language -->
    <!-- ======================== -->
    
    <xsl:function name="obfl:not" as="xs:string">
        <xsl:param name="sexpr" as="xs:string"/>
        <xsl:sequence select="if ($sexpr='nil') then 't'
                              else if ($sexpr='t') then 'nil'
                              else concat('(! ',$sexpr,')')"/>
    </xsl:function>
    
    <xsl:function name="obfl:and" as="xs:string">
        <xsl:param name="sexprs" as="xs:string*"/>
        <xsl:variable name="sexprs2" as="xs:string*" select="distinct-values($sexprs)[not(.='t')]"/>
        <xsl:sequence select="if (not(exists($sexprs2))) then 't'
                              else if ('nil'=$sexprs2) then 'nil'
                              else if (count($sexprs2)=1) then $sexprs2[1]
                              else concat('(&amp; ',string-join($sexprs2,' '),')')"/>
    </xsl:function>
    
    <xsl:function name="obfl:or" as="xs:string">
        <xsl:param name="sexprs" as="xs:string*"/>
        <xsl:variable name="sexprs2" as="xs:string*" select="distinct-values($sexprs)[not(.='nil')]"/>
        <xsl:sequence select="if (not(exists($sexprs2))) then 'nil'
                              else if ('t'=$sexprs2) then 't'
                              else if (count($sexprs2)=1) then $sexprs2[1]
                              else concat('(| ',string-join($sexprs2,' '),')')"/>
    </xsl:function>

</xsl:stylesheet>
