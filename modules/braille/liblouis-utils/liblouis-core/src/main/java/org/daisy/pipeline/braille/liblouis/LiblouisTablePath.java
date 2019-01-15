package org.daisy.pipeline.braille.liblouis;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

import com.google.common.base.Function;
import static com.google.common.collect.Iterables.transform;

import org.daisy.pipeline.braille.common.BundledResourcePath;

import org.osgi.service.component.ComponentContext;

public class LiblouisTablePath extends BundledResourcePath {
	
	private static final String MANIFEST = "manifest";
	
	@Override
	protected void activate(ComponentContext context, Map<?,?> properties) throws Exception {
		if (properties.get(UNPACK) != null)
			throw new IllegalArgumentException(UNPACK + " property not supported");
		if (properties.get(MANIFEST) != null)
			throw new IllegalArgumentException(MANIFEST + " property not supported");
		Map<Object,Object> props = new HashMap<Object,Object>(properties);
		props.put(BundledResourcePath.UNPACK, true);
		super.activate(context, props);
	}
	
	public Iterable<URI> listTableFiles() {
		return transform(
			listResources(),
			new Function<URI,URI>() {
				public URI apply(URI resource) {
					return getIdentifier().resolve(resource); }});
	}
}
