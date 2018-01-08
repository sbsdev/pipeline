/*
 * Braille Utils (C) 2010-2011 Daisy Consortium 
 * 
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 * 
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
package org.daisy.braille.consumer.embosser;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Logger;

import javax.imageio.spi.ServiceRegistry;

import org.daisy.braille.api.embosser.Embosser;
import org.daisy.braille.api.embosser.EmbosserCatalogService;
import org.daisy.braille.api.embosser.EmbosserFilter;
import org.daisy.braille.api.embosser.EmbosserProvider;
import org.daisy.braille.api.factory.FactoryCatalog;
import org.daisy.braille.api.factory.FactoryProperties;

import aQute.bnd.annotation.component.Component;
import aQute.bnd.annotation.component.Reference;

/**
 * Provides a catalog of Embosser factories.
 * @author Joel Håkansson
 */
//TODO: use EmbosserService instead of Embosser and enable OSGi support
@Component
public class EmbosserCatalog implements FactoryCatalog<Embosser>, EmbosserCatalogService {
	private final List<EmbosserProvider> providers;
	private final Map<String, EmbosserProvider> map;
	private final Logger logger;
	
	/**
	 * Creates a new empty instance. This method is public because it is required by OSGi.
	 * In an SPI context, use newInstance()
	 */
	public EmbosserCatalog() {
		logger = Logger.getLogger(this.getClass().getCanonicalName());
		providers = new CopyOnWriteArrayList<>();
		map = Collections.synchronizedMap(new HashMap<String, EmbosserProvider>());
	}
	
	/**
	 * <p>
	 * Creates a new EmbosserCatalog and populates it using the SPI
	 * (java service provider interface).
	 * </p>
	 * 
	 * <p>
	 * In an OSGi context, an instance should be retrieved using the service
	 * registry. It will be registered under the EmbosserCatalogService
	 * interface.
	 * </p>
	 * 
	 * @return returns a new EmbosserCatalog
	 */
	public static EmbosserCatalog newInstance() {
		EmbosserCatalog ret = new EmbosserCatalog();
		Iterator<EmbosserProvider> i = ServiceRegistry.lookupProviders(EmbosserProvider.class);
		while (i.hasNext()) {
			EmbosserProvider ep = i.next();
			ep.setCreatedWithSPI();
			ret.addFactory(ep);
		}
		return ret;
	}
	
	@Reference(type = '*')
	public void addFactory(EmbosserProvider factory) {
		logger.finer("Adding factory: " + factory);
		providers.add(factory);
	}

	// Unbind reference added automatically from addFactory annotation
	public void removeFactory(EmbosserProvider factory) {
		// this is to avoid adding items to the cache that were removed while
		// iterating
		synchronized (map) {
			providers.remove(factory);
			map.clear();
		}
	}
	
        @Override
	public Embosser get(String identifier) {
		if (identifier==null) {
			return null;
		}
		EmbosserProvider template = map.get(identifier);
		if (template==null) {
			// this is to avoid adding items to the cache that were removed
			// while iterating
			synchronized (map) {
				for (EmbosserProvider p : providers) {
					for (FactoryProperties fp : p.list()) {
						if (fp.getIdentifier().equals(identifier)) {
							logger.fine("Found a factory for " + identifier + " (" + p.getClass() + ")");
							map.put(fp.getIdentifier(), p);
							template = p;
							break;
						}						
					}
				}
			}
		}
		if (template!=null) {
			return template.newFactory(identifier);
		} else {
			return null;
		}
	}
	
        @Override
	public Embosser newEmbosser(String identifier) {
		return get(identifier);
	}
	
        @Override
	public Collection<FactoryProperties> list() {
		Collection<FactoryProperties> ret = new ArrayList<>();
		for (EmbosserProvider p : providers) {
			ret.addAll(p.list());
		}
		return ret;
	}
	
        @Override
	public Collection<FactoryProperties> list(EmbosserFilter filter) {
		Collection<FactoryProperties> ret = new ArrayList<>();
		for (FactoryProperties fp : list()) {
			if (filter.accept(fp)) {
				ret.add(fp);
			}
		}
		return ret;
	}
}
