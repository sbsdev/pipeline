package org.daisy.pipeline.braille.dotify.impl;

import java.net.URI;
import java.util.Iterator;
import java.util.Map;

import com.google.common.base.MoreObjects;
import com.google.common.base.MoreObjects.ToStringHelper;
import com.google.common.collect.ImmutableMap;

import static org.daisy.common.file.URIs.asURI;
import org.daisy.common.file.URLs;
import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logCreate;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.TransformProvider;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;

public interface DotifyOBFLTransform {
	
	@Component(
		name = "org.daisy.pipeline.braille.dotify.impl.DotifyOBFLTransform.Provider",
		service = {
			TransformProvider.class
		}
	)
	public class Provider extends AbstractTransformProvider<Transform> {
		
		private URI href;
		
		@Activate
		protected void activate(final Map<?,?> properties) {
			href = asURI(URLs.getResourceFromJAR("xml/transform/obfl-to-pef.xpl", DotifyOBFLTransform.class));
		}
		
		private final static Iterable<Transform> empty = Iterables.<Transform>empty();
		
		protected Iterable<Transform> _get(Query query) {
			try {
				MutableQuery q = mutableQuery(query);
				if (q.containsKey("formatter"))
					if (!"dotify".equals(q.removeOnly("formatter").getValue().get()))
						return empty;
				Iterator<Feature> input = q.get("input").iterator();
				while (input.hasNext())
					if ("obfl".equals(input.next().getValue().get())) {
						input.remove();
						for (Feature f : q.removeAll("output"))
							if (!("pef".equals(f.getValue().get()) || "braille".equals(f.getValue().get())))
								return empty;
						q.add("output", "braille");
						return Iterables.<Transform>of(
							logCreate((Transform)new TransformImpl(q.toString()))); }}
			catch (IllegalStateException e) {}
			return empty;
		}
		
		private class TransformImpl extends AbstractTransform {
			
			private final XProc xproc;
			
			private TransformImpl(String textTransformQuery) {
				xproc = new XProc(href, null, ImmutableMap.of("text-transform", textTransformQuery));
			}
			
			@Override
			public XProc asXProc() {
				return xproc;
			}
			
			@Override
			public ToStringHelper toStringHelper() {
				return MoreObjects.toStringHelper("o.d.p.b.dotify.impl.DotifyOBFLTransform$Provider$TransformImpl");
			}
		}
		
		@Override
		public ToStringHelper toStringHelper() {
			return MoreObjects.toStringHelper(DotifyOBFLTransform.Provider.class.getName());
		}
	}
}
