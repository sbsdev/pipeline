import javax.inject.Inject;

import java.io.File;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.daisy.dotify.api.text.Integer2TextFactoryMakerService;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;
import org.daisy.maven.xspec.TestResults;
import org.daisy.maven.xspec.XSpecRunner;

import org.daisy.pipeline.braille.common.BrailleTranslator.FromStyledTextToBraille;
import org.daisy.pipeline.braille.common.CSSStyledText;
import static org.daisy.pipeline.braille.common.Query.util.query;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.calabashConfigFile;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.logbackClassic;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.mavenBundle;
import static org.daisy.pipeline.pax.exam.Options.mavenBundlesWithDependencies;
import static org.daisy.pipeline.pax.exam.Options.pipelineModule;
import static org.daisy.pipeline.pax.exam.Options.thisBundle;
import static org.daisy.pipeline.pax.exam.Options.xprocspec;
import static org.daisy.pipeline.pax.exam.Options.xspec;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.junit.Test;
import org.junit.runner.RunWith;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemPackage;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class SBSTest {
	
	@Inject
	private XSpecRunner xspecRunner;
	
	@Inject
	private XProcSpecRunner xprocspecRunner;
	
	@Test
	public void runXSpecAndXProcSpec() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		File xspecTestsDir = new File(baseDir, "src/test/xspec");
		Map<String,File> xprocspecTests = new HashMap<String,File>();
		for (String test : new String[]{
			"test_translator",
			"test_dtbook-to-pef_prodnote",
			"test_dtbook-to-pef_downgrade",
			"test_dtbook-to-pef",
			"test_dtbook-to-pef_tables",
			"test_dtbook-to-pef_pagination",
			"test_dtbook-to-pef_titlepage",
			"test_dtbook-to-pef_print_page_numbers",
			"test_dtbook-to-pef_notes",
			"test_epub3-to-pef"
		    })
		    xprocspecTests.put(test, new File(baseDir, "src/test/xprocspec/" + test + ".xprocspec"));
		boolean xspecHasFocus = xspecRunner.hasFocus(xspecTestsDir);
		boolean xprocspecHasFocus = xprocspecRunner.hasFocus(xprocspecTests.values());
		List<AssertionError> errors = new ArrayList<AssertionError>();
		if (xspecHasFocus || !xprocspecHasFocus) {
			File xspecReportsDir = new File(baseDir, "target/surefire-reports");
			xspecReportsDir.mkdirs();
			TestResults result = xspecRunner.run(xspecTestsDir, xspecReportsDir);
			try {
				assertEquals("Number of XSpec failures and errors should be zero", 0L, result.getFailures() + result.getErrors()); }
			catch (AssertionError e) {
				errors.add(e); }}
		if (xprocspecHasFocus || !xspecHasFocus) {
			boolean success = xprocspecRunner.run(xprocspecTests,
			                                      new File(baseDir, "target/xprocspec-reports"),
			                                      new File(baseDir, "target/surefire-reports"),
			                                      new File(baseDir, "target/xprocspec"),
			                                      null,
			                                      new XProcSpecRunner.Reporter.DefaultReporter());
			try {
				assertTrue("XProcSpec tests should run with success", success); }
			catch (AssertionError e) {
				errors.add(e); }}
		for (AssertionError e : errors)
			throw e;
	}
	
	@Inject
	private Integer2TextFactoryMakerService int2textFactory;
	
	// @Test // XFAIL
	public void testInt2textFactory() throws Exception {
		assertEquals("zwölf", int2textFactory.newInteger2Text("de").intToText(12));
	}
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			calabashConfigFile(),
			domTraversalPackage(),
			felixDeclarativeServices(),
			systemPackage("javax.xml.stream;version=\"1.0.1\""),
			systemPackage("com.sun.org.apache.xml.internal.resolver"),
			systemPackage("com.sun.org.apache.xml.internal.resolver.tools"),
			thisBundle(),
			junitBundles(),
			mavenBundlesWithDependencies(
				brailleModule("common-utils"),
				brailleModule("css-utils"),
				brailleModule("pef-utils"),
				brailleModule("liblouis-utils"),
				brailleModule("liblouis-native").forThisPlatform(),
				brailleModule("libhyphen-core"),
				brailleModule("libhyphen-native").forThisPlatform(),
				mavenBundle("ch.sbs.pipeline:sbs-braille-tables:?"),
				mavenBundle("ch.sbs.pipeline:sbs-hyphenation-tables:?"),
				brailleModule("dotify-utils"),
				brailleModule("dotify-formatter"),
				brailleModule("dtbook-to-pef"),
				brailleModule("epub3-to-pef"),
				pipelineModule("common-utils"),
				pipelineModule("file-utils"),
				pipelineModule("fileset-utils"),
				// because of bug in lou_indexTables we need to include liblouis-tables even though
				// we're not using it (needed for include-brf)
				brailleModule("liblouis-tables"),
				// logging
				logbackClassic(),
				mavenBundle("org.slf4j:jul-to-slf4j:?"),
				mavenBundle("org.daisy.pipeline:logging-activator:?"),
				// xprocspec
				xprocspec(),
				mavenBundle("org.daisy.maven:xproc-engine-daisy-pipeline:?"),
				// xspec
				xspec(),
				mavenBundle("org.daisy.pipeline:saxon-adapter:?"))
		);
	}
	
	private Iterable<CSSStyledText> styledText(String... textAndStyle) {
		List<CSSStyledText> styledText = new ArrayList<CSSStyledText>();
		String text = null;
		boolean textSet = false;
		for (String s : textAndStyle) {
			if (textSet)
				styledText.add(new CSSStyledText(text, s));
			else
				text = s;
			textSet = !textSet; }
		if (textSet)
			throw new RuntimeException();
		return styledText;
	}
	
	private Iterable<CSSStyledText> text(String... text) {
		List<CSSStyledText> styledText = new ArrayList<CSSStyledText>();
		for (String t : text)
			styledText.add(new CSSStyledText(t, ""));
		return styledText;
	}
	
	private Iterable<String> braille(String... text) {
		return Arrays.asList(text);
	}
}
