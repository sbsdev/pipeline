package org.daisy.dotify.formatter.impl.search;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;

import org.daisy.dotify.api.formatter.Marker;
import org.daisy.dotify.api.formatter.MarkerReferenceField;
import org.daisy.dotify.formatter.impl.datatype.VolumeKeepPriority;

public class CrossReferenceHandler implements Cloneable {
	private LookupHandler<String, Integer> pageRefs;
	private LookupHandler<String, Integer> volumeRefs;
	private LookupHandler<Integer, Iterable<AnchorData>> anchorRefs;
	private LookupHandler<String, Integer> variables;
	private LookupHandler<SheetIdentity, Boolean> breakable;
	private LookupHandler<BlockAddress, Integer> rowCount;
    private LookupHandler<BlockAddress, List<String>> groupAnchors;
    private LookupHandler<BlockAddress, List<Marker>> groupMarkers;
    private LookupHandler<BlockAddress, List<String>> groupIdentifiers;
	private LookupHandler<PageId, TransitionProperties> transitionProperties;
	private HashMap<Integer, Overhead> volumeOverhead;
    private HashMap<String, Integer> counters;
	private SearchInfo searchInfo;
	private static final String VOLUMES_KEY = "volumes";
	private static final String SHEETS_IN_VOLUME = "sheets-in-volume-";
	private static final String SHEETS_IN_DOCUMENT = "sheets-in-document";
	private static final String PAGES_IN_VOLUME = "pages-in-volume-";
	private static final String PAGES_IN_DOCUMENT = "pages-in-document";
    protected HashSet<String> pageIds;
	private final Runnable setDirty;
	
	/**
	 * @param setDirty called if some information has been changed since last use
	 */
	public CrossReferenceHandler(Runnable setDirty) {
		this.pageRefs = new LookupHandler<>(setDirty);
		this.volumeRefs = new LookupHandler<>(setDirty);
		this.anchorRefs = new LookupHandler<>(setDirty);
		this.variables = new LookupHandler<>(setDirty);
		this.breakable = new LookupHandler<>(setDirty);
		//TODO: fix dirty flag for anchors/markers
		Runnable nop = () -> {};
		this.rowCount = new LookupHandler<>(nop);
        this.groupAnchors = new LookupHandler<>(nop);
        this.groupMarkers = new LookupHandler<>(nop);
        this.groupIdentifiers = new LookupHandler<>(setDirty);
		this.transitionProperties = new LookupHandler<>(setDirty);
		this.volumeOverhead = new HashMap<>();
		this.counters = new HashMap<>();
		this.searchInfo = new SearchInfo(setDirty);
        this.pageIds = new HashSet<>();
        this.setDirty = setDirty;
	}
	
	/**
	 * Gets the volume for the specified identifier.
	 * @param refid the identifier to get the volume for
	 * @return returns the volume number, one-based
	 */
	public Integer getVolumeNumber(String refid) {
		return volumeRefs.get(refid);
	}
	
	/**
	 * Gets the page number for the specified identifier.
	 * @param refid the identifier to get the page for
	 * @return returns the page number, one-based
	 */
	public Integer getPageNumber(String refid) {
		return pageRefs.get(refid);
	}
	
	public Iterable<AnchorData> getAnchorData(int volume) {
		return anchorRefs.get(volume);
	}
	
	private void setPagesInVolume(int volume, int value) {
		//TODO: use this method
		variables.put(PAGES_IN_VOLUME+volume, value);
	}
	
	private void setPagesInDocument(int value) {
		//TODO: use this method
		variables.put(PAGES_IN_DOCUMENT, value);
	}
	
	public Overhead getOverhead(int volumeNumber) {
		if (volumeNumber<1) {
			throw new IndexOutOfBoundsException("Volume must be greater than or equal to 1");
		}
		if (volumeOverhead.get(volumeNumber)==null) {
			volumeOverhead.put(volumeNumber, new Overhead(0, 0));
			setDirty.run();
		}
		return volumeOverhead.get(volumeNumber);
	}
	
	public Integer getPageNumberOffset(String key) {
		return counters.get(key);
	}

	/**
	 * Gets the number of volumes.
	 * @return returns the number of volumes
	 */
	public int getVolumeCount() {
		return variables.get(VOLUMES_KEY, 1);
	}
	
	public int getSheetsInVolume(int volume) {
		return variables.get(SHEETS_IN_VOLUME+volume, 0);
	}

	public int getSheetsInDocument() {
		return variables.get(SHEETS_IN_DOCUMENT, 0);
	}
	
	public int getPagesInVolume(int volume) {
		return variables.get(PAGES_IN_VOLUME+volume, 0);
	}

	public int getPagesInDocument() {
		return variables.get(PAGES_IN_DOCUMENT, 0);
	}
	
	public boolean getBreakable(SheetIdentity ident) {
		return breakable.get(ident, true);
	}
	
	public TransitionProperties getTransitionProperties(PageId id) {
		return transitionProperties.get(id, TransitionProperties.empty());
	}

	public List<String> getGroupAnchors(BlockAddress blockId) {
		return groupAnchors.get(blockId, Collections.emptyList());
	}

	public List<Marker> getGroupMarkers(BlockAddress blockId) {
		return groupMarkers.get(blockId, Collections.emptyList());
	}
	
	public List<String> getGroupIdentifiers(BlockAddress blockId) {
		return groupIdentifiers.get(blockId, Collections.emptyList());
	}
	
	public int getRowCount(BlockAddress blockId) {
		return rowCount.get(blockId, Integer.MAX_VALUE);
	}
	
	/**
	 * <p>Finds a marker value starting from the page with the supplied id.</p>
	 * <p>To find markers, the following methods must be used to register
	 * data needed by this method:</p>
	 * <ul><li>{@link #keepPageDetails(PageDetails)}</li>
	 * <li>{@link #commitPageDetails()}</li>
	 * <li>{@link #setSequenceScope(DocumentSpace, int, int, int)}</li>
	 * <li>{@link #setVolumeScope(int, int, int)}</li></ul>
	 * @param id the page id of the page where the search originates.
	 * 			Note that this page is not necessarily the first page
	 * 			searched (depending on the value of 
	 * 			{@link MarkerReferenceField#getOffset()}).
	 * @param spec the search specification
	 * @return returns the marker value, or an empty string if not found
	 */
	public String findMarker(PageId id, MarkerReferenceField spec) {
		return searchInfo.findStartAndMarker(id, spec);
	}

	public Optional<PageDetails> findNextPageInSequence(PageId id) {
		return searchInfo.findNextPageInSequence(id);
	}

	// public void resetLookupHandlers() {
	// 	pageRefs.reset();
	// 	volumeRefs.reset();
	// 	anchorRefs.reset();
	// 	variables.reset();
	// 	breakable.reset();
	// 	transitionProperties.reset();
	// 	rowCount.reset();
	// 	groupAnchors.reset();
	// 	groupMarkers.reset();
	// }

	// FIXME: move counters to a separate object (similar to PageStruct)
	public void resetCounters() {
		counters.clear();
	}
	
	public Builder builder() {
		return new Builder(this);
	}
	
	@SuppressWarnings("unchecked")
	private CrossReferenceHandler(CrossReferenceHandler template) {
		pageRefs = template.pageRefs.clone();
		volumeRefs = template.volumeRefs.clone();
		anchorRefs = template.anchorRefs.clone();
		variables = template.variables.clone();
		breakable = template.breakable.clone();
		rowCount = template.rowCount.clone();
		groupAnchors = template.groupAnchors.clone();
		groupMarkers = template.groupMarkers.clone();
		groupIdentifiers = template.groupIdentifiers.clone();
		transitionProperties = template.transitionProperties.clone();
		volumeOverhead = (HashMap<Integer, Overhead>)template.volumeOverhead.clone();
		counters = (HashMap<String, Integer>)template.counters.clone();
		searchInfo = template.searchInfo.clone();
		pageIds = (HashSet<String>)template.pageIds.clone();
		setDirty = template.setDirty;
	}

	public static class Builder extends CrossReferenceHandler {

		private Builder(CrossReferenceHandler template) {
			super(template);
		}

		public CrossReferenceHandler build() {
			return new Builder(this);
		}

		public Builder setVolumeNumber(String refid, int volume) {
			volumeRefs.put(refid, volume);
			return this;
		}

		public Builder setPageNumber(String refid, int page) {
			if (!pageIds.add(refid)) {
				throw new IllegalArgumentException("Identifier not unique: " + refid);
			}
			pageRefs.put(refid, page);
			return this;
		}

		public Builder setAnchorData(int volume, Iterable<AnchorData> data) {
			anchorRefs.put(volume, data);
			return this;
		}

		public Builder setVolumeCount(int volumes) {
			variables.put(VOLUMES_KEY, volumes);
			return this;
		}

		public Builder setSheetsInVolume(int volume, int value) {
			variables.put(SHEETS_IN_VOLUME+volume, value);
			return this;
		}

		public Builder setSheetsInDocument(int value) {
			variables.put(SHEETS_IN_DOCUMENT, value);
			return this;
		}

		// public void keepBreakable(SheetIdentity ident, boolean value) {
		// 	breakable.keep(ident, value);
		// }
	
		// public void commitBreakable() {
		// 	breakable.commit();
		// }
	
		public Builder setBreakable(SheetIdentity ident, boolean value) {
			breakable.put(ident, value);
			return this;
		}

		// public void keepTransitionProperties(PageId id, TransitionProperties value) {
		// 	transitionProperties.keep(id, value);
		// }
	
		// public void commitTransitionProperties() {
		// 	transitionProperties.commit();
		// }
	
		public Builder setTransitionProperties(PageId id, TransitionProperties value) {
			transitionProperties.put(id, value);
			return this;
		}

		public Builder setRowCount(BlockAddress blockId, int value) {
			rowCount.put(blockId, value);
			return this;
		}

		public Builder trimPageDetails() {
			//FIXME: implement
			return this;
		}

		public Builder setGroupAnchors(BlockAddress blockId, List<String> anchors) {
			groupAnchors.put(blockId, anchors.isEmpty() ? Collections.emptyList() : new ArrayList<>(anchors));
			return this;
		}

		public Builder setGroupMarkers(BlockAddress blockId, List<Marker> markers) {
			groupMarkers.put(blockId, markers.isEmpty() ? Collections.emptyList() : new ArrayList<>(markers));
			return this;
		}

		public Builder setGroupIdentifiers(BlockAddress blockId, List<String> identifiers) {
			groupIdentifiers.put(blockId, identifiers.isEmpty() ? Collections.emptyList() : new ArrayList<>(identifiers));
			return this;
		}

		public Builder setOverhead(int volumeNumber, Overhead overhead) {
			volumeOverhead.put(volumeNumber, overhead);
			return this;
		}

		public Builder setPageNumberOffset(String key, Integer value) {
			counters.put(key, value);
			return this;
		}
		
		// public Builder keepPageDetails(PageDetails value) {
		// 	searchInfo.keepPageDetails(value);
		// 	return this;
		// }
	
		// public Builder commitPageDetails() {
		// 	searchInfo.commitPageDetails();
		// 	return this;
		// }
		
		public Builder setPageDetails(PageDetails value) {
			searchInfo.setPageDetails(value);
			return this;
		}
		
		/**
		 * Sets the sequence scope for the purpose of finding markers in a specific sequence.
		 * @param space the document space
		 * @param sequenceNumber the sequence number
		 * @param fromIndex the start index
		 * @param toIndex the end index
		 */
		public Builder setSequenceScope(DocumentSpace space, int sequenceNumber, int fromIndex, int toIndex) {
			searchInfo.setSequenceScope(space, sequenceNumber, fromIndex, toIndex);
			return this;
		}

		/**
		 * Sets the volume scope for the purpose of finding markers in a specific volume.
		 * @param volumeNumber the volume number
		 * @param fromIndex the start index
		 * @param toIndex the end index
		 */
		public Builder setVolumeScope(int volumeNumber, int fromIndex, int toIndex) {
			searchInfo.setVolumeScope(volumeNumber, fromIndex, toIndex);
			return this;
		}

		public Builder resetUniqueChecks() {
			pageIds = new HashSet<>();
			return this;
		}
	}
}
