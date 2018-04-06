package org.daisy.dotify.common.splitter;

import java.util.NoSuchElementException;

/**
 * Provides split point data source. Data provided by via this interface
 * is expected to be immutable. The interface is designed to work with
 * data sources of unknown size. Access to the interfaces methods should
 * be done with care to limit unnecessary computation in the data source.
 * 
 * @author Joel Håkansson
 *
 * @param <T> the type of split point units
 */
public interface SplitPointDataSource<T extends SplitPointUnit> {

	/**
	 * Gets the split point data source supplements.
	 * @return the supplements
	 */
	public Supplements<T> getSupplements();
	
	public boolean isEmpty();
	
	public Iterator<T> iterator();
	
	public interface Iterator<T extends SplitPointUnit> {
		
		/**
		 * Returns true if the data source has more items. Note that this  method
		 * can return false, even if {@link #getSupplements()} is non-empty.
		 * @return returns true if the data source has more items, false otherwise
		 */
		public boolean hasNext();

		/*
		 * Gets the next item, given a target position. The SplitPointDataSource
		 * may refuse to return an item if it can't be fit in a dimension not
		 * controlled by the caller, in which case it should throw a
		 * CantFitInOtherDimensionException. The SplitPointDataSource must not
		 * interfere with the breaking in the "first dimension", i.e. the
		 * dimension represented by the provided "position" argument.
		 *
		 * @param position the target position
		 * @throws CantFitInOtherDimensionException if a next item can not be
		 *         produced in a way that it fits the other dimensions
		 */

		// FIXME: do we need to cover the case of two subsequent breaks? (empty page)
		// FIXME: make break explicit with a dedicated method?
		/**
		 * Gets the next item.
		 *
		 * @param last whether the item will be the last one before a break
		 * @return returns the next item
		 * @throws NoSuchElementException if there are no items left
		 */
		public T next(/*float position,*/ boolean last) throws NoSuchElementException;//, CantFitInOtherDimensionException;

		// needs to be called at most once in a row (similar to peek)
		// FIXME: isn't it more efficient to handle this on caller side?
		// because caller knows beforehand if it might be needed or not
		// public void previous();

		// alternative: return dummy unit with the same properties as the next unit, but don't
		// advance in the source the dummy only implements isBreakable(), isSkippable() and
		// isCollapsible()
		// public T nextProperties() throws NoSuchElementException;

		// /**
		//  * Gets a deep copy.
		//  *
		//  * The copy is guaranteed to be of the same type.
		//  *
		//  * @return the copy
		//  */
		// public Iterator<T> clone();

		/**
		 * Returns a SplitPointDataSource from this iterator object.
		 *
		 * The result is guaranteed to be of the same type as the SplitPointDataSource
		 * that supplied this iterator. The operation does not change the state of this
		 * object.
		 */
		public SplitPointDataSource<T> iterable();

	}
}
