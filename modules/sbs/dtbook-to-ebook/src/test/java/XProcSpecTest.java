import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.mavenBundle;
import static org.daisy.pipeline.pax.exam.Options.thisPlatform;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.Option;

import static org.ops4j.pax.exam.CoreOptions.composite;
import static org.ops4j.pax.exam.CoreOptions.options;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {

	@Override
	protected String[] testDependencies() {
		return new String[]{
			"org.daisy.pipeline.modules:nordic-epub3-dtbook-migrator:?",
			"org.daisy.pipeline.modules.braille:epub3-to-epub3:?",
			"org.daisy.pipeline.modules:dtbook-utils:?",
			"org.daisy.pipeline.modules:file-utils:?",
			"org.daisy.pipeline.modules:fileset-utils:?",
			
			// FIXME: depend on org.daisy.pipeline.modules.braille:mod-sbs instead
			"org.daisy.pipeline.modules.braille:liblouis-utils:?",
			"org.daisy.pipeline.modules.braille:liblouis-native:jar:" + thisPlatform() + ":?",
			"org.daisy.pipeline.modules.braille:liblouis-tables:?",
		};
	}
	
	@Override @Configuration
	public Option[] config() {
		return options(
			composite(super.config()),
			// FIXME: epubcheck needs older version of guava
			mavenBundle("com.google.guava:guava:14.0.1"),
			// FIXME: epubcheck needs older version of jing
			mavenBundle("org.daisy.libs:jing:20120724.0.0"));
	}
}
