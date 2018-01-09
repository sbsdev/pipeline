package org.daisy.dotify.impl.input;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Properties;

import org.daisy.dotify.api.tasks.AnnotatedFile;
import org.daisy.dotify.api.tasks.DefaultAnnotatedFile;
import org.daisy.dotify.api.tasks.InternalTaskException;
import org.daisy.dotify.api.tasks.ReadWriteTask;
import org.daisy.dotify.api.tasks.TaskOption;
import org.daisy.dotify.common.xml.XMLTools;
import org.daisy.dotify.common.xml.XMLToolsException;

/**
 * <p>Task that runs an XSLT conversion.</p>
 * <p>Input file type requirement: XML</p>
 * 
 * @author  Joel Hakansson
 * @version 4 maj 2009
 * @since 1.0
 */
public class XsltTask extends ReadWriteTask {
	private static final Logger logger = Logger.getLogger(XsltTask.class.getCanonicalName());
	final URL url;
	final Map<String, Object> options;
	List<TaskOption> uiOptions;
	
	/**
	 * Create a new XSLT task. Use system property javax.xml.transform.TransformerFactory
	 * to set factory implementation if needed.
	 * @param name task name
	 * @param url relative path to XSLT
	 * @param options XSLT parameters
	 */
	public XsltTask(String name, URL url, Map<String, Object> options) {
		this(name, url, options, null);
	}
	public XsltTask(String name, URL url, Map<String, Object> options, List<TaskOption> uiOptions) {
		super(name);
		this.url = url;
		this.options = options;
		this.uiOptions = uiOptions;
	}
	
	private List<TaskOption> buildOptions() {
		List<TaskOption> ret = new ArrayList<>();
		try {
			ByteArrayOutputStream os = new ByteArrayOutputStream();
			XMLTools.transform(url, os, this.getClass().getResource("resource-files/list-params.xsl"), new HashMap<String, Object>());
			Properties px = new Properties();
			px.loadFromXML(new ByteArrayInputStream(os.toByteArray()));
			for (Entry<Object, Object> entry : px.entrySet()) {
				ret.add(new TaskOption.Builder(entry.getKey().toString()).description(entry.getValue()+"").build());
			}
		} catch (XMLToolsException | IOException e) {
			logger.log(Level.FINE, "Failed to compile options for xslt: " + url, e);
		} 
		return ret;
	}

	@Override
	public AnnotatedFile execute(AnnotatedFile input, File output) throws InternalTaskException {
		try {
			XMLTools.transform(input.getFile(), output, url, options, new net.sf.saxon.TransformerFactoryImpl());
		} catch (XMLToolsException e) {
			throw new InternalTaskException("Error: ", e);
		}
		return new DefaultAnnotatedFile.Builder(output).extension("xslt").mediaType("application/xslt+xml").build();
	}

	@Override
	public void execute(File input, File output) throws InternalTaskException {
		execute(new DefaultAnnotatedFile.Builder(input).build(), output);
	}

	@Override
	public List<TaskOption> getOptions() {
		if (uiOptions==null) {
			this.uiOptions = buildOptions();
		}
		return uiOptions;
	}

}
