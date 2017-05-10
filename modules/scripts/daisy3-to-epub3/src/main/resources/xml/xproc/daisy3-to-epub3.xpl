<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal/daisy3-to-epub3"
    px:input-filesets="daisy3"
    px:output-filesets="epub3"
    type="px:daisy3-to-epub3" version="1.0" name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DAISY 3 to EPUB 3</h1>
        <p px:role="desc">Transforms a DAISY 3 publication into an EPUB 3 publication.</p>
        <dl px:role="author maintainer">
            <dt>Name:</dt>
            <dd px:role="name">Romain Deltour</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:rdeltour@gmail.com">rdeltout@gmail.com</a></dd>
            <dt>Organization:</dt>
            <dd px:role="organization">DAISY</dd>
        </dl>
        <p><a px:role="homepage" href="http://daisy.github.io/pipeline/modules/daisy3-to-epub3"
                >Online documentation</a></p>
    </p:documentation>


    <!--=========================================================================-->
    <!-- STEP SIGNATURE                                                          -->
    <!--=========================================================================-->

    <p:input port="source" primary="true" sequence="false" px:media-type="application/oebps-package+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">OPF</h2>
            <p px:role="desc">The package file of the input DTB.</p>
        </p:documentation>
    </p:input>

    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">EPUB</h2>
            <p px:role="desc">The produced EPUB.</p>
        </p:documentation>
    </p:option>
    <p:option name="temp-dir" required="true" px:output="temp" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Temporary directory</h2>
            <p px:role="desc">Directory used for temporary files.</p>
        </p:documentation>
    </p:option>
    <p:option name="mediaoverlays" required="false" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Include Media Overlays</h2>
            <p px:role="desc">Whether or not to include media overlays and associated audio files
                (true or false).</p>
        </p:documentation>
    </p:option>
    <p:option name="assert-valid" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Assert validity</h2>
            <p px:role="desc">Whether to stop processing and raise an error on validation issues.</p>
        </p:documentation>
    </p:option>
    <!--<p:option name="compatibility-mode" required="false" select="'true'" px:type="boolean">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Compatibility Mode</h2>
            <p px:role="desc">Whether or not to include NCX-file, OPF guide element and ASCII
                filenames (true or false).</p>
        </p:documentation>
    </p:option>-->


    <!--=========================================================================-->
    <!-- IMPORTS                                                                 -->
    <!--=========================================================================-->

    <p:import
        href="http://www.daisy.org/pipeline/modules/epub3-ocf-utils/library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml"><p px:role="desc">For putting it all
                into a ZIP container.</p></p:documentation>
    </p:import>
    <p:import
        href="http://www.daisy.org/pipeline/modules/epub3-pub-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/daisy3-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/library.xpl"/>
    <p:import href="../internal/ncx-to-nav.xpl"/>
    <p:import href="../internal/dtbook-to-html.xpl"/>
    <p:import href="../internal/list-audio-clips.xpl"/>


    <!--=========================================================================-->
    <!-- GLOBAL VARIABLES                                                        -->
    <!--=========================================================================-->
    <!--FIXME check options-->
    <p:variable name="output-dir-checked" select="resolve-uri(replace($output-dir,'(.+?)/?$','$1/'))"/>
    <p:variable name="temp-dir-checked" select="resolve-uri(replace($temp-dir,'(.+?)/?$','$1/'))"/>
    <p:variable name="epub-dir" select="concat($temp-dir-checked,'epub/')"/>
    <p:variable name="content-dir" select="concat($temp-dir-checked,'epub/EPUB/')"/>
    <p:variable name="epub-file" select="concat($output-dir-checked,'result.epub')"/>
    <p:variable name="type" xmlns:opf="http://openebook.org/namespaces/oeb-package/1.0/"
        select="for $daisy-type in /opf:package/opf:metadata/opf:x-metadata/opf:meta[@name='dtb:multimediaType']/@content
                return
                    if ($daisy-type=('audioFullText','audioPartText','textPartAudio')) then 'text+mo'
                    else if ($daisy-type='textNCX') then 'text'
                    else ''"/>


    <!--=========================================================================-->
    <!-- LOAD THE DAISY 3 FILESET                                                -->
    <!--=========================================================================-->
    <px:daisy3-load name="load"/>
    <px:fileset-load media-types="application/smil" name="smils">
        <p:input port="fileset">
            <p:pipe port="fileset.out" step="load"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.out" step="load"/>
        </p:input>
    </px:fileset-load>
    <px:fileset-load media-types="application/x-dtbook+xml" name="dtbooks">
        <p:input port="fileset">
            <p:pipe port="fileset.out" step="load"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.out" step="load"/>
        </p:input>
    </px:fileset-load>
    <px:fileset-load media-types="application/x-dtbncx+xml" name="ncx">
        <p:input port="fileset">
            <p:pipe port="fileset.out" step="load"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory.out" step="load"/>
        </p:input>
    </px:fileset-load>

    <!--=========================================================================-->
    <!-- CHECK THE DTB TYPE                                                      -->
    <!--=========================================================================-->

    <!--TODO fail if DTB type is not supported (e.g. audio-only books) -->


    <!--=========================================================================-->
    <!-- CREATE A MAP OF CONTENT IDs TO AUDIO FRAGMENTS                          -->
    <!--=========================================================================-->

    <!--TODO conditionally, if the MO option is set-->
    <p:choose name="audio-clips">
        <p:when test="$mediaoverlays and $type='text+mo'">
            <p:output port="fileset.out" primary="true"/>
            <p:output port="audio-clips" sequence="true">
                <p:pipe port="audio-clips" step="audio-clips.inner"/>
            </p:output>
            <pxi:list-audio-clips name="audio-clips.inner">
                <p:input port="fileset.in">
                    <p:pipe port="fileset.out" step="load"/>
                </p:input>
                <p:input port="dtbooks">
                    <p:pipe port="result" step="dtbooks"/>
                </p:input>
                <p:input port="smils">
                    <p:pipe port="result" step="smils"/>
                </p:input>
                <p:with-option name="content-dir" select="$content-dir"/>
            </pxi:list-audio-clips>
        </p:when>
        <p:otherwise>
            <p:output port="fileset.out" primary="true"/>
            <p:output port="audio-clips" sequence="true">
                <p:empty/>
            </p:output>
            <p:identity>
                <p:input port="source"><p:empty/></p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:sink/>

    <!--=========================================================================-->
    <!-- CONVERT DTBOOK TO XHTML                                                 -->
    <!--=========================================================================-->

    <pxi:dtbook-to-html name="content-docs">
        <p:input port="fileset.in">
            <p:pipe port="fileset.out" step="load"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="result" step="dtbooks"/>
        </p:input>
        <p:with-option name="output-dir" select="$content-dir"/>
        <p:with-option name="assert-valid" select="$assert-valid"/>
    </pxi:dtbook-to-html>
    <p:sink/>

    <!--=========================================================================-->
    <!-- CONVERT NCX TO NAVIGATION DOCUMENT                                      -->
    <!--=========================================================================-->
    <pxi:ncx-to-nav name="nav-doc">
        <p:input port="source">
            <p:pipe port="result" step="ncx"/>
        </p:input>
        <p:input port="smils">
            <p:pipe port="result" step="smils"/>
        </p:input>
        <p:input port="dtbooks">
            <p:pipe port="result" step="dtbooks"/>
        </p:input>
        <p:input port="htmls">
            <p:pipe port="in-memory.out" step="content-docs"/>
        </p:input>
        <p:with-option name="result-uri" select="concat($content-dir,'nav.xhtml')"/>
        <!--TODO make sure that the name is unused-->
    </pxi:ncx-to-nav>
    <p:sink/>

    <!--=========================================================================-->
    <!-- GENERATE MEDIA OVERLAYS                                                 -->
    <!--=========================================================================-->

    <!--TODO conditionally, if the MO option is set-->
    <p:choose name="media-overlays">
        <p:when test="$mediaoverlays and $type='text+mo'">
            <p:output port="fileset.out" primary="true"/>
            <p:output port="in-memory.out" sequence="true">
                <p:pipe port="in-memory.out" step="media-overlays.inner"/>
            </p:output>
            <px:create-mediaoverlays name="media-overlays.inner">
                <p:input port="content-docs">
                    <p:pipe port="in-memory.out" step="content-docs"/>
                </p:input>
                <p:input port="audio-map">
                    <p:pipe port="audio-clips" step="audio-clips"/>
                </p:input>
                <p:with-option name="content-dir" select="$content-dir"/>
            </px:create-mediaoverlays>
        </p:when>
        <p:otherwise>
            <p:output port="fileset.out" primary="true"/>
            <p:output port="in-memory.out" sequence="true">
                <p:empty/>
            </p:output>
            <p:identity>
                <p:input port="source"><p:empty/></p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:sink/>

    <!--=========================================================================-->
    <!-- METADATA                                                                -->
    <!--=========================================================================-->

    <p:documentation>Extract metadata from the DAISY 3 OPF document</p:documentation>
    <p:group name="metadata">
        <p:output port="result"/>
        <p:xslt>
            <p:input port="source">
                <p:pipe port="source" step="main"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../internal/opf-to-metadata.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:sink/>


    <!--=========================================================================-->
    <!-- CREATE THE PACKAGE DOCUMENT                                             -->
    <!--=========================================================================-->

    <p:group name="package-doc">
        <p:output port="fileset.out" primary="true"/>
        <p:output port="in-memory.out">
            <p:pipe port="result" step="package-doc.create"/>
        </p:output>

        <p:variable name="opf-uri" select="concat($content-dir,'package.opf')"/>

        <px:fileset-join name="package-doc.join-filesets">
            <p:input port="source">
                <p:pipe port="fileset.out" step="content-docs"/>
                <p:pipe port="fileset.out" step="nav-doc"/>
                <p:pipe port="fileset.out" step="media-overlays"/>
                <p:pipe port="fileset.out" step="audio-clips"/>
            </p:input>
        </px:fileset-join>
        <p:sink/>

        <px:epub3-pub-create-package-doc name="package-doc.create">
            <p:input port="spine-filesets">
                <p:pipe port="fileset.out" step="content-docs"/>
            </p:input>
            <p:input port="publication-resources">
                <p:pipe port="result" step="package-doc.join-filesets"/>
            </p:input>
            <p:input port="metadata">
                <p:pipe port="result" step="metadata"/>
            </p:input>
            <p:input port="content-docs">
                <p:pipe port="in-memory.out" step="nav-doc"/>
                <p:pipe port="in-memory.out" step="content-docs"/>
            </p:input>
            <p:input port="mediaoverlays">
                <p:pipe port="in-memory.out" step="media-overlays"/>
            </p:input>
            <p:with-option name="result-uri" select="$opf-uri"/>
            <p:with-option name="compatibility-mode" select="'false'"/>
            <!--TODO configurability for other META-INF files ?-->
        </px:epub3-pub-create-package-doc>

        <px:fileset-add-entry media-type="application/oebps-package+xml">
            <p:input port="source">
                <p:pipe port="result" step="package-doc.join-filesets"/>
            </p:input>
            <p:with-option name="href" select="$opf-uri"/>
        </px:fileset-add-entry>

        <px:message message="Package Document Created."/>
    </p:group>
    <p:sink/>

    <!--=========================================================================-->
    <!-- FINALIZE AND STORE THE CONTAINER                                        -->
    <!--=========================================================================-->

    <p:group name="finalize">
        <p:output port="fileset.out" primary="true">
            <p:pipe port="result" step="finalize.ocf"/>
        </p:output>
        <p:output port="in-memory.out" sequence="true">
            <p:pipe port="result" step="finalize.in-memory"/>
        </p:output>

        <px:fileset-create name="fileset.with-epub-base">
            <p:with-option name="base" select="$epub-dir"/>
        </px:fileset-create>
        <px:fileset-join name="fileset.without-ocf">
            <p:input port="source">
                <p:pipe port="result" step="fileset.with-epub-base"/>
                <p:pipe port="fileset.out" step="package-doc"/>
            </p:input>
        </px:fileset-join>
        <p:sink/>
        <px:epub3-ocf-finalize name="finalize.ocf">
            <p:input port="source">
                <p:pipe port="result" step="fileset.without-ocf"/>
            </p:input>
        </px:epub3-ocf-finalize>

        <p:identity name="finalize.in-memory">
            <p:input port="source">
                <p:pipe port="in-memory.out" step="nav-doc"/>
                <p:pipe port="in-memory.out" step="content-docs"/>
                <p:pipe port="in-memory.out" step="package-doc"/>
                <p:pipe port="in-memory.out" step="media-overlays"/>
                <p:pipe port="in-memory.out" step="finalize.ocf"/>
            </p:input>
        </p:identity>
        <p:sink/>
    </p:group>

    <px:epub3-store>
        <p:with-option name="href" select="$epub-file"/>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.out" step="finalize"/>
        </p:input>
    </px:epub3-store>


</p:declare-step>
