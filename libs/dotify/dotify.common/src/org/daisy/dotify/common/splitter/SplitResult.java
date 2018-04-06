package org.daisy.dotify.common.splitter;

import java.util.List;

/**
 * Provides a split result.
 * @author Joel Håkansson
 *
 * @param <T> the type of units
 */
public interface SplitResult <T extends SplitPointUnit> {

	/**
	 * The head of the result.
	 * @return returns the head
	 */
	public List<T> head();

	/**
	 * The tail of the result.
	 * @return returns the tail
	 */
	public SplitPointDataSource<T> tail();
}
