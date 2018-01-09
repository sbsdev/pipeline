package org.daisy.braille.api.embosser;

import java.util.Collection;

import org.daisy.braille.api.factory.FactoryProperties;


/**
 * <p>
 * Provides an interface for an EmbosserCatalog service. The purpose of
 * this interface is to expose an implementation of an EmbosserCatalog
 * as an OSGi service.
 * </p>
 * 
 * <p>
 * To comply with this interface, an implementation must be thread safe and
 * address both the possibility that only a single instance is created and used
 * throughout and that new instances are created as desired.
 * </p>
 * 
 * @author Joel Håkansson
 */
public interface EmbosserCatalogService {

	public Embosser newEmbosser(String identifier);

	public Collection<FactoryProperties> list();

	public Collection<FactoryProperties> list(EmbosserFilter filter);

}
