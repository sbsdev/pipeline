package org.daisy.pipeline.braille.pef.impl;

import java.util.ArrayList;
import java.util.List;

import com.google.common.base.Optional;

import org.daisy.braille.api.factory.FactoryProperties;
import org.daisy.braille.api.table.Table;

import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

// Note that although the name suggests it, this class doesn't use instances
// of the TableCatalog interface. It uses instances of the more low-level
// org.daisy.braille.api.table.TableProvider directly. The name was chosen
// because it more or less provides the same functionality as a TableCatalog,
// except that it's based on the query syntax instead of ID's.
@Component(
	name = "org.daisy.pipeline.braille.pef.impl.BrailleUtilsTableCatalog",
	service = { TableProvider.class }
)
public class BrailleUtilsTableCatalog implements TableProvider {
	
	public Iterable<Table> get(Query query) {
		MutableQuery q = mutableQuery(query);
		if (q.containsKey("id")) {
			String id = q.removeOnly("id").getValue().get();
			if (q.isEmpty())
				return get(id); }
		return empty;
	}
	
	private Iterable<Table> get(String id) {
		for (org.daisy.braille.api.table.TableProvider p : providers)
			for (FactoryProperties fp : p.list())
				if (fp.getIdentifier().equals(id))
					return Optional.fromNullable(p.newFactory(id)).asSet();
		return empty;
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
	
	private final List<org.daisy.braille.api.table.TableProvider> providers
	= new ArrayList<org.daisy.braille.api.table.TableProvider>();
	
	@Reference(
		name = "TableProvider",
		unbind = "removeTableProvider",
		service = org.daisy.braille.api.table.TableProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	public void addTableProvider(org.daisy.braille.api.table.TableProvider provider) {
		providers.add(provider);
	}
	
	public void removeTableProvider(org.daisy.braille.api.table.TableProvider provider) {
		providers.remove(provider);
	}
}
