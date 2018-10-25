import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.thisPlatform;

public class SBSTest extends AbstractXSpecAndXProcSpecTest {

    @Override
    protected String[] testDependencies() {
	return new String[]{
	    "org.daisy.pipeline.modules:nordic-epub3-dtbook-migrator:?",
	    "org.daisy.pipeline.modules.braille:epub3-to-epub3:?",
	    "org.daisy.pipeline.modules:dtbook-utils:?",
	    "org.daisy.pipeline.modules:file-utils:?",
	    "org.daisy.pipeline.modules:fileset-utils:?",
	};
    }
}
