import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest; 
 
import static org.daisy.pipeline.pax.exam.Options.mavenBundle;
 
import org.ops4j.pax.exam.Configuration; 
import static org.ops4j.pax.exam.CoreOptions.composite; 
import static org.ops4j.pax.exam.CoreOptions.options; 
import org.ops4j.pax.exam.Option; 
 
public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest { 
     
    @Override 
    protected String[] testDependencies() { 
        return new String[] { 
            pipelineModule("asciimath-utils"),
            pipelineModule("common-utils"),
            pipelineModule("dtbook-utils"),
            pipelineModule("dtbook-validator"),
            pipelineModule("epub3-nav-utils"),
            pipelineModule("epub3-ocf-utils"),
            pipelineModule("epub3-pub-utils"),
            pipelineModule("epubcheck-adapter"),
            pipelineModule("file-utils"),
            pipelineModule("fileset-utils"),
            pipelineModule("html-utils"),
            pipelineModule("mediatype-utils"),
            pipelineModule("validation-utils")
        }; 
    } 
     
    @Override @Configuration 
    public Option[] config() { 
        return options( 
			// FIXME: second version of guava needed for epubcheck-adapter
			mavenBundle("com.google.guava:guava:14.0.1"),
			// FIXME: epubcheck needs older version of jing
			mavenBundle("org.daisy.libs:jing:20120724.0.0"),
			composite(super.config()));
    } 
} 
