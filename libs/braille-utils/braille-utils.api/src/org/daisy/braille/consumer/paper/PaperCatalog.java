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
package org.daisy.braille.consumer.paper;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import javax.imageio.spi.ServiceRegistry;

import org.daisy.braille.api.paper.Paper;
import org.daisy.braille.api.paper.PaperCatalogService;
import org.daisy.braille.api.paper.PaperFilter;
import org.daisy.braille.api.paper.PaperProvider;

import aQute.bnd.annotation.component.Component;
import aQute.bnd.annotation.component.Reference;

/**
 * Provides a catalog of Paper factories.
 * @author Joel Håkansson
 */
@Component
public class PaperCatalog implements PaperCatalogService {
	private final Map<String, Paper> map;
	
	/**
	 * Creates a new empty instance. This method is public because it is required by OSGi.
	 * In an SPI context, use newInstance()
	 */
	public PaperCatalog() {
		map = Collections.synchronizedMap(new HashMap<String, Paper>());
	}
	
	/**
	 * <p>
	 * Creates a new PaperCatalog and populates it using the SPI
	 * (java service provider interface).
	 * </p>
	 * 
	 * <p>
	 * In an OSGi context, an instance should be retrieved using the service
	 * registry. It will be registered under the PaperCatalogService
	 * interface.
	 * </p>
	 * 
	 * @return returns a new PaperCatalogCatalog
	 */
	public static PaperCatalog newInstance() {
		PaperCatalog ret = new PaperCatalog();
		Iterator<PaperProvider> i = ServiceRegistry.lookupProviders(PaperProvider.class);
		while (i.hasNext()) {
			PaperProvider provider = i.next();
			ret.addFactory(provider);
		}
		return ret;
	}
	
	@Reference(type = '*')
	public void addFactory(PaperProvider factory) {
		for (Paper paper : factory.list()) {
			map.put(paper.getIdentifier(), paper);
		}
	}

	// Unbind reference added automatically from addFactory annotation
	public void removeFactory(PaperProvider factory) {
		synchronized (map) {
			for (Paper paper : factory.list()) {
				map.remove(paper.getIdentifier());
			}
		}
	}

	@Override
	public Paper get(String identifier) {
		return map.get(identifier);
	}

	@Override
	public Collection<Paper> list() {
		return map.values();
	}

	@Override
	public Collection<Paper> list(PaperFilter filter) {
		Collection<Paper> ret = new ArrayList<>();
		for (Paper paper : map.values()) {
			if (filter.accept(paper)) {
				ret.add(paper);
			}
		}
		return ret;
	}
}
