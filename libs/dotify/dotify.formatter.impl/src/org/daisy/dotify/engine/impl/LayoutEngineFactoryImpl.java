package org.daisy.dotify.engine.impl;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.stream.XMLEventFactory;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.transform.TransformerFactory;
import javax.xml.xpath.XPathFactory;

import org.daisy.dotify.api.engine.FormatterEngine;
import org.daisy.dotify.api.engine.FormatterEngineFactoryService;
import org.daisy.dotify.api.formatter.FormatterConfiguration;
import org.daisy.dotify.api.formatter.FormatterFactory;
import org.daisy.dotify.api.obfl.ExpressionFactory;
import org.daisy.dotify.api.translator.MarkerProcessorFactoryMakerService;
import org.daisy.dotify.api.translator.TextBorderFactoryMakerService;
import org.daisy.dotify.api.writer.PagedMediaWriter;
import org.daisy.dotify.formatter.impl.FactoryManager;
import org.daisy.dotify.formatter.impl.SPIHelper;

import aQute.bnd.annotation.component.Component;
import aQute.bnd.annotation.component.Reference;

/**
 * Provides a layout engine factory.
 * @author Joel Håkansson
 */
@Component
public class LayoutEngineFactoryImpl implements FormatterEngineFactoryService {
	private FactoryManager factoryManager;

	/**
	 * Creates a new layout engine factory instance.
	 */
	public LayoutEngineFactoryImpl() {
		factoryManager = new FactoryManager();
	}
	
	private void setupFactoryManager() {
		//FIXME: all calls to newInstance below are OSGi violations that should be fixed.
		if (factoryManager.getTransformerFactory()==null) {
			factoryManager.setTransformerFactory(new net.sf.saxon.TransformerFactoryImpl());
		}
		if (factoryManager.getXpathFactory()==null) {
			factoryManager.setXpathFactory(XPathFactory.newInstance());
		}
		if (factoryManager.getDocumentBuilderFactory()==null) {
			factoryManager.setDocumentBuilderFactory(DocumentBuilderFactory.newInstance());
		}
		if (factoryManager.getXmlInputFactory()==null) {
			XMLInputFactory in = XMLInputFactory.newInstance();
			in.setProperty(XMLInputFactory.IS_COALESCING, Boolean.TRUE);
			in.setProperty(XMLInputFactory.IS_NAMESPACE_AWARE, Boolean.TRUE);
			in.setProperty(XMLInputFactory.SUPPORT_DTD, Boolean.FALSE);
			in.setProperty(XMLInputFactory.IS_SUPPORTING_EXTERNAL_ENTITIES, Boolean.FALSE);
			factoryManager.setXmlInputFactory(in);
		}
		if (factoryManager.getXmlOutputFactory()==null) {
			factoryManager.setXmlOutputFactory(XMLOutputFactory.newInstance());
		}
		if (factoryManager.getXmlEventFactory()==null) {
			factoryManager.setXmlEventFactory(XMLEventFactory.newInstance());
		}
	}

	@Override
	public LayoutEngineImpl newFormatterEngine(String locale, String mode, PagedMediaWriter writer) {
		setupFactoryManager();
		return new LayoutEngineImpl(locale, mode, writer, factoryManager);
	}

	@Override
	public FormatterEngine newFormatterEngine(FormatterConfiguration config, PagedMediaWriter writer) {
		setupFactoryManager();
		return new LayoutEngineImpl(config, writer, factoryManager);
	}

	// FIXME: not a service
	/**
	 * Sets a factory dependency.
	 * @param service the dependency
	 */
	@Reference
	public void setFormatterFactory(FormatterFactory service) {
		factoryManager.setFormatterFactory(service);
	}

	/**
	 * Removes a factory dependency.
	 * @param service the dependency to remove
	 */
	public void unsetFormatterFactory(FormatterFactory service) {
		factoryManager.setFormatterFactory(null);
	}

	/**
	 * Sets a factory dependency.
	 * @param service the dependency
	 */
	@Reference
	public void setMarkerProcessor(MarkerProcessorFactoryMakerService service) {
		factoryManager.setMarkerProcessorFactory(service);
	}

	/**
	 * Removes a factory dependency.
	 * @param service the dependency to remove
	 */
	public void unsetMarkerProcessor(MarkerProcessorFactoryMakerService service) {
		factoryManager.setMarkerProcessorFactory(null);
	}

	/**
	 * Sets a factory dependency.
	 * @param service the dependency
	 */
	@Reference
	public void setTextBorderFactoryMaker(TextBorderFactoryMakerService service) {
		factoryManager.setTextBorderFactory(service);
	}

	/**
	 * Removes a factory dependency.
	 * @param service the dependency to remove
	 */
	public void unsetTextBorderFactoryMaker(TextBorderFactoryMakerService service) {
		factoryManager.setTextBorderFactory(null);
	}

	/**
	 * Sets a factory dependency.
	 * @param service the dependency
	 */
	@Reference
	public void setExpressionFactory(ExpressionFactory service) {
		factoryManager.setExpressionFactory(service);
	}

	/**
	 * Removes a factory dependency.
	 * @param service the dependency to remove
	 */
	public void unsetExpressionFactory(ExpressionFactory service) {
		factoryManager.setExpressionFactory(null);
	}

	@Override
	public void setCreatedWithSPI() {
		setFormatterFactory(SPIHelper.getFormatterFactory());
		setMarkerProcessor(SPIHelper.getMarkerProcessorFactoryMaker());
		setTextBorderFactoryMaker(SPIHelper.getTextBorderFactoryMaker());
		setExpressionFactory(SPIHelper.getExpressionFactory());
		factoryManager.setTransformerFactory(TransformerFactory.newInstance());
	}

}
