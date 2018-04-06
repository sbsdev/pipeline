package org.daisy.dotify.common.splitter;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * Provides split point data
 * @author Joel Håkansson
 *
 * @param <T> the type of split point units
 */
public final class SplitPointDataList<T extends SplitPointUnit> implements SplitPointDataSource<T> {

	@SuppressWarnings("rawtypes")
	public static final SplitPointDataList EMPTY_LIST = new SplitPointDataList<>();
	
	@SuppressWarnings("rawtypes")
	private static final Supplements EMPTY_SUPPLEMENTS = new Supplements() {
		@Override
		public Object get(String id) {
			return null;
		}
	};
	
	private final List<T> units;
	private final Supplements<T> supplements;
	private final int offset;

	/**
	 * Creates a new instance with the specified units
	 * @param units the units
	 */
	@SafeVarargs
	public SplitPointDataList(T ... units) {
		this(Arrays.asList(units));
	}
	
	/**
	 * Creates a new instance with the specified units
	 * @param units the units
	 */
	public SplitPointDataList(List<T> units) {
		this(units, null);
	}
	
	/**
	 * Creates a new instance with no units
	 */
	public SplitPointDataList() {
		this(Collections.emptyList(), null);
	}
	
	@SuppressWarnings("unchecked")
	public static <T extends SplitPointUnit> SplitPointDataList<T> emptyList() {
		return (SplitPointDataList<T>)EMPTY_LIST;
	}
	
	@SuppressWarnings("unchecked")
	private static final <T extends SplitPointUnit> Supplements<T> emptySupplements() {
		return (Supplements<T>)EMPTY_SUPPLEMENTS;
	}
	
	/**
	 * Creates a new instance with the specified units and supplements
	 * @param units the units
	 * @param supplements the supplements
	 */
	public SplitPointDataList(List<T> units, Supplements<T> supplements) {
		this(units, supplements, 0);
	}

	private SplitPointDataList(List<T> units, Supplements<T> supplements, int offset) {
		this.units = units;
		this.offset = offset;
		if (supplements==null) {
			this.supplements = emptySupplements();
		} else {
			this.supplements = supplements;
		}
	}

	@Override
	public Supplements<T> getSupplements() {
		return supplements;
	}

	@Override
	public boolean isEmpty() {
		return units.size() == offset;
	}

	@Override
	public ListIterator iterator() {
		return new ListIterator();
	}

	public int getSize() {
		return units.size() - offset;
	}

	/**
	 * Gets the items before index.
	 * @param toIndex the index, exclusive
	 * @return returns a head list
	 * @throws IndexOutOfBoundsException if the index is beyond the end of the stream
	 */
	public List<T> head(int toIndex) {
		return this.units.subList(offset, offset + toIndex);
	}

	/**
	 * Gets a tail list.
	 * @param fromIndex the starting index, inclusive
	 * @return returns a new split point data source starting from fromIndex
	 * @throws IndexOutOfBoundsException if the index is beyond the end of the stream
	 */
	public SplitPointDataList<T> tail(int fromIndex) {
		return new SplitPointDataList<T>(units, supplements, offset + fromIndex);
	}

	public class ListIterator implements SplitPointDataSource.Iterator<T>, Cloneable {

		private int index = 0;

		@Override
		public boolean hasNext() {
			return units.size() <= offset + index;
		}

		// position is ignored
		@Override
		public T next(/*float position, */boolean last) throws NoSuchElementException /*, CantFitInOtherDimensionException*/ {
			if (units.size() <= offset + index) {
				return units.get(index++);
			} else {
				throw new NoSuchElementException();
			}
		}

		public void previous() {
			if (index >= 0) {
				index--;
			} else {
				throw new NoSuchElementException();
			}
		}

		@Override
		public SplitPointDataSource<T> iterable() {
			if (index == 0) {
				return SplitPointDataList.this;
			} else {
				return tail(index);
			}
		}

		@Override
		public ListIterator clone() {
			try {
				return (ListIterator)super.clone();
			} catch (CloneNotSupportedException e) {
				throw new InternalError("coding error");
			}
		}
	}
}
