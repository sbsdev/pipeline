package org.daisy.dotify.common.splitter;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.daisy.dotify.common.collection.SplitList;
import org.daisy.dotify.common.splitter.SplitPointSpecification.Type;


/**
 * Breaks units into results. All allowed break points are supplied with the input.
 * 
 * @author Joel Håkansson
 *
 * @param <T> the type of split point units
 */
public class SplitPointHandler<T extends SplitPointUnit> {
	private final List<T> EMPTY_LIST = Collections.emptyList();
	private final SplitPointDataSource<T> EMPTY_DATA_SOURCE = null;
	private final SplitPointCost<T> defaultCost = new SplitPointCost<T>() {
		@Override
		public double getCost(T unit, int index, int breakpoint) {
			// 1. the smaller the result, the higher the cost
			// 2. breakable units are always preferred over forced ones
			return (unit.isBreakable()?1:2)*breakpoint-index;
		}
	};
	
	/**
	 * Splits the data at, or before, the supplied breakPoint according to the rules
	 * in the data. If force is used, rules may be broken to achieve a result.
	 * @param breakPoint the split point
	 * @param units the data
	 * @param <T> the type of split point units
	 * @return returns a split point result
	 */
	@SafeVarargs
	public static <T extends SplitPointUnit> SplitPoint<T> split(float breakPoint, T ... units) {
		SplitPointHandler<T> splitter = new SplitPointHandler<>();
		return splitter.split(breakPoint, new SplitPointDataList<T>(units), splitter.defaultCost);
	}

	/**
	 * Splits the data at, or before, the supplied breakPoint according to the rules
	 * in the data. If force is used, rules may be broken to achieve a result.
	 * @param breakPoint the split point
	 * @param units the data
	 * @param options the split options
	 * @param <T> the type of split point units
	 * @return returns a split point result
	 */
	public static <T extends SplitPointUnit> SplitPoint<T> split(float breakPoint, List<T> units, SplitOption ... options) {
		SplitPointHandler<T> splitter = new SplitPointHandler<>();
		return splitter.split(breakPoint, new SplitPointDataList<T>(units), splitter.defaultCost, options);
	}
	
	/**
	 * Splits the data at, or before, the supplied breakPoint according to the rules
	 * in the data. If force is used, rules may be broken to achieve a result.
	 * @param breakPoint the split point
	 * @param units the data
	 * @param cost the cost function used when determining the optimal <i>forced</i> split point. In other words,
	 * 		 the cost function is only used if there are no breakable units available.
	 * @param options the split options
	 * @param <T> the type of split point units
	 * @return returns a split point result
	 */
	public static <T extends SplitPointUnit> SplitPoint<T> split(float breakPoint, List<T> units, SplitPointCost<T> cost, SplitOption ... options) {
		SplitPointHandler<T> splitter = new SplitPointHandler<>();
		return splitter.split(breakPoint, new SplitPointDataList<T>(units), cost, options);
	}

	/**
	 * Splits the data at, or before, the supplied breakPoint according to the rules
	 * in the data. If force is used, rules may be broken to achieve a result.
	 *
	 * The resulting tail is guaranteed to be of the same type as the input data.
	 *
	 * @param breakPoint the split point
	 * @param data the data to split
	 * @param options the split options
	 * @return returns a split point result
	 */
	public SplitPoint<T> split(float breakPoint, SplitPointDataSource<T> data, SplitOption ... options) {
		return split(breakPoint, data, defaultCost, options);
	}

	/**
	 * Splits the data at, or before, the supplied breakPoint according to the rules
	 * in the data. If force is used, rules may be broken to achieve a result.
	 *
	 * The resulting tail is guaranteed to be of the same type as the input data, and the
	 * cost function is guaranteed to be called with objects of that type.
	 *
	 * @param breakPoint the split point
	 * @param data the data to split
	 * @param cost the cost function used when determining the optimal <i>forced</i> split point. In other words,
	 * 		 the cost function is only used if there are no breakable units available.
	 * @param options the split options
	 * @return returns a split point result
	 * @throws IllegalArgumentException if cost is null
	 */
	public SplitPoint<T> split(float breakPoint, SplitPointDataSource<T> data, SplitPointCost<T> cost, SplitOption ... options) {
		SplitPointSpecification spec = find(breakPoint, data, cost, options);
		if (cost==null) {
			throw new IllegalArgumentException("Null cost not allowed.");
		}
		return split(spec, data);
	}
	
	// FIXME: in theory we don't need the two phases "find" and "split"
	
	/**
	 * <p>Splits the data according to the supplied specification. A specification can be created by using 
	 * {@link #find(float, SplitPointDataSource, SplitPointCost, SplitOption...)} on the data source.</p>
	 * <p>No data is beyond the specified split point is produced using this method.</p>
	 *
	 * The resulting tail is guaranteed to be of the same type as the input data.
	 *
	 * @param spec the specification
	 * @param data the data
	 * @return returns a split point result
	 */
	public SplitPoint<T> split(SplitPointSpecification spec, SplitPointDataSource<T> data) {
		if (spec.getType()==Type.EMPTY) {
			return new SplitPoint<>(EMPTY_LIST, EMPTY_LIST, EMPTY_DATA_SOURCE, EMPTY_LIST, false);
		} else if (spec.getType()==Type.NONE) {
			return new SplitPoint<>(EMPTY_LIST, EMPTY_LIST, data, EMPTY_LIST, false);
		} else if (spec.getType()==Type.ALL) {
			TrimStep<T> trimmed = new TrimStep<>(data.getSupplements());
			SplitPointDataSource<T> tail = findCollapse(data, trimmed);
			List<T> head = trimmed.getResult();
			List<T> discarded = trimmed.getDiscarded();
			if (spec.shouldTrimTrailing()) {
				SplitList<T> split = trimTrailing(head);
				head = split.getFirstPart();
				discarded.addAll(split.getSecondPart());
			}
			return new SplitPoint<>(head, trimmed.getSupplements(), tail, discarded, false);
		} else if (spec.getType()==Type.INDEX) {
			TrimStep<T> trimmed = new TrimStep<T>(data.getSupplements()) {
					int count = 0;
					@Override
					public void addUnit(T unit) {
						super.addUnit(unit);
						count++;
					}
					@Override
					public void addDiscarded(T unit) {
						super.addDiscarded(unit);
						count++;
					}
					@Override
					public boolean overflows(T buffer) {
						return count + 1 > spec.getIndex();
					}
					@Override
					public T getNext(SplitPointDataSource.Iterator<T> data) {
						return data.next(count + 1 == spec.getIndex());
					}
				};
			SplitPointDataSource<T> tail = findCollapse(data, trimmed);
			List<T> head = trimmed.getResult();
			List<T> discarded = trimmed.getDiscarded();
			if (spec.shouldTrimTrailing()) {
				SplitList<T> split = trimTrailing(head);
				head = split.getFirstPart();
				discarded.addAll(split.getSecondPart());
			}
			return new SplitPoint<>(head, trimmed.getSupplements(), tail, discarded, spec.isHard());
		} else {
			throw new IllegalArgumentException();
		}
	}

	/**
	 * Finds a split point at, or before, the supplied breakPoint according to the rules
	 * in the data. If force is used, rules may be broken to achieve a result.
	 *
	 * @param breakPoint the split point
	 * @param data the data to split
	 * @param options the split options
	 * @return returns a split point specification
	 */
	public SplitPointSpecification find(float breakPoint, SplitPointDataSource<T> data, SplitOption ... options) {
		return find(breakPoint, data, defaultCost, options);
	}

	/**
	 * Finds a split point at, or before, the supplied breakPoint according to the rules
	 * in the data. If force is used, rules may be broken to achieve a result.
	 *
	 * The cost function is guaranteed to be called with objects of the same type as the
	 * input data.
	 *
	 * @param breakPoint the split point
	 * @param data the data to split
	 * @param cost the cost function used when determining the optimal <i>forced</i> split point. In other words,
	 * 		 the cost function is only used if there are no breakable units available.
	 * @param options the split options
	 * @return returns a split point specification
	 */
	public SplitPointSpecification find(float breakPoint, SplitPointDataSource<T> data, SplitPointCost<T> cost, SplitOption ... options) {
		SplitOptions opts = SplitOptions.parse(options);
		if (cost==null) {
			throw new IllegalArgumentException("Null cost not allowed.");
		}
		if (data.isEmpty()) {
			// pretty simple...
			return SplitPointSpecification.empty();
		} else if (breakPoint<=0) {
			return SplitPointSpecification.none();
		} else if (fits(data, breakPoint, opts.useLastUnitSize)) {
			return SplitPointSpecification.all();
		} else {
			final int limit; {
				SizeStep<T> collect = new SizeStep<>(breakPoint, data.getSupplements(), opts.useLastUnitSize);
				SplitPointDataSource<T> tail = findCollapse(data, collect);
				// If no units are returned here it's because even the first unit doesn't fit.
				// Therefore, force will not help.
				if (collect.getTotalCount() == 0) {
					return SplitPointSpecification.none();
				}
				limit  = collect.getTotalCount() + forwardSkippable(tail);
				// check next unit to see if it can be removed.
				// if (!data.hasElementAt(strPos+1)) { // last unit?
				// 	return SplitPointSpecification.all();
				// }
			}
			final BreakPointScannerResult result = new BreakPointScannerResult();
			result.bestBreakable = -1;
			result.bestSplitPoint = limit;
			findCollapse(data, new StepForward<T>() {
				double currentCost = Double.MAX_VALUE;
				double currentBreakableCost = Double.MAX_VALUE;
				int index = 0;
				void computeCost(T unit) {
					// Note that order of collapsable units may be changed
					double c = cost.getCost(unit, index, limit);
					if (c < currentCost) { // this should always be true for the first unit
						result.bestSplitPoint = index;
						currentCost = c;
					}
					if (c < currentBreakableCost && unit.isBreakable()) {
						result.bestBreakable = index;
						currentBreakableCost = c;
					}
					index++;
				}
				public void addUnit(T unit) {
					computeCost(unit);
				}
				public void addDiscarded(T unit) {
					computeCost(unit);
				}
				public boolean overflows(T buffer) {
					return index + 1 > limit;
				}
			});
			boolean hard = false;
			int tailStart;
			if (result.bestBreakable != result.bestSplitPoint) { // no breakable found, break hard
				if (opts.useForce) {
					hard = true;
					tailStart = result.bestSplitPoint + 1;
				} else {
					tailStart = 0;
				}
			} else {
				tailStart = result.bestBreakable + 1;
			}
			return new SplitPointSpecification(tailStart, hard, opts.trimTrailing);
		}
	}
	
	private static class SplitOptions {
		boolean useForce = false;
		boolean trimTrailing = true;
		boolean useLastUnitSize = true;
		static SplitOptions parse(SplitOption ... opts) {
			SplitOptions result = new SplitOptions();
			for (SplitOption option : opts) {
				if (option==StandardSplitOption.ALLOW_FORCE) {
					result.useForce = true;
				} else if (option==StandardSplitOption.RETAIN_TRAILING) {
					result.trimTrailing = false;
				} else if (option==StandardSplitOption.NO_LAST_UNIT_SIZE) {
					result.useLastUnitSize = false; 
				} else if (option == null) {
                   //no-op
				} else {
					throw new UnsupportedOperationException("'" + option +
                    "' is not a recognized split option");
				}
			}
			return result;
		}
	}
	
	/**
	 * Trims leading skippable units in the supplied list. The result is backed by the
	 * original list. 
	 * 
	 * @param in the list to trim
	 * @param <T> the type of split list
	 * @return the list split in two parts, one with the leading skippable units, one with
	 * the remainder
	 */
	public static <T extends SplitPointUnit> SplitList<T> trimLeading(List<T> in) {
		int i;
		for (i = 0; i<in.size(); i++) {
			if (!in.get(i).isSkippable()) {
				break;
			}
		}
		return SplitList.split(in, i);
	}

	/**
	 * Trims leading skippable units in the supplied data source. The result is backed by the
	 * original data source.
	 * 
	 * @param in the list to trim
	 * @param <T> the type of split list
	 * @return a split point, the leading skippable units are placed in {@link SplitPoint#getDiscarded()}, the
	 * remainder are placed in {@link SplitPoint#getTail()}
	 */
	public static <T extends SplitPointUnit> SplitPoint<T> trimLeading(SplitPointDataSource<T> in/*, float position*/) {
		return skipLeading(in, findLeading(in /*, position*/) /*, position*/);
	}
	
	/**
	 * Skips leading units in the supplied list. The result is backed by the original data source.
	 * No data is beyond index is produced using this method.  
	 * @param in the list to trim
	 * @param index the index of the split point
	 * @param <T> the type of object
	 * @return a split point, the leading units are placed in {@link SplitPoint#getDiscarded()}, the
	 * remainder are placed in {@link SplitPoint#getTail()}
	 */
	public static <T extends SplitPointUnit> SplitPoint<T> skipLeading(SplitPointDataSource<T> in, int index/*, float position*/) {
		List<T> skipped = new ArrayList<>();
		SplitPointDataSource.Iterator<T> it = in.iterator();
		while (skipped.size() < index) {
			skipped.add(it.next(/*position,*/false));
		}
		return new SplitPoint<>(null, null, it.iterable(), skipped, false);
	}
	
	/**
	 * Finds leading skippable units in the supplied data source.
	 * @param in the data source to search
	 * @param <T> the type of object
	 * @return returns the index of the first non-skippable unit
	 */
	public static <T extends SplitPointUnit> int findLeading(SplitPointDataSource<T> in/*, float position*/) {
		int i = 0;
		for (SplitPointDataSource.Iterator<T> it = in.iterator(); it.hasNext();) {
			T unit = it.next(/*position,*/false);
			if (!unit.isSkippable()) {
				break;
			}
			i++;
		}
		return i;
	}

	static <T extends SplitPointUnit> T maxSize(T u1, T u2) {
		return (u1.getUnitSize()>=u2.getUnitSize()?u1:u2); 
	}
	
	static <T extends SplitPointUnit> SplitList<T> trimTrailing(List<T> in) {
		int i;
		for (i = in.size()-1; i>=0; i--) {
			if (!in.get(i).isSkippable()) {
				break;
			}
		}
		return SplitList.split(in, i+1);
	}

	/**
	 * Finds the last unit that fits into the given space
	 *
	 * Returns a data source containing the units that do not fit in the space. It is
	 * guaranteed to be of the same type as the input data.
	 *
	 * @param data the input data source
	 * @param collect destination of the units that fit into the given space
	 * @return returns the index for the last unit
	 */
	static <T extends SplitPointUnit> SplitPointDataSource<T> findCollapse(SplitPointDataSource<T> data, StepForward<T> collect) {
		T maxCollapsable = null;
		for (SplitPointDataSource.Iterator<T> it = data.iterator(); it.hasNext();) {
			T c = collect.getNext(it);
			if (c.isCollapsible()) {
				if (maxCollapsable!=null) {
					if (maxCollapsable.collapsesWith(c)) {
						if (maxSize(maxCollapsable, c)==c) {
							//new one is now max, add the previous to collapsed
							collect.addDiscarded(maxCollapsable);
							maxCollapsable = c;
						} else {
							//old one is max, add the new one to collapsed
							collect.addDiscarded(c);
						}
					} else {
						collect.addUnit(maxCollapsable);
						maxCollapsable = c;
					}
				} else {
					maxCollapsable = c;
				}
				if (collect.overflows(maxCollapsable)) {
					return data;
				}
			} else {
				if (maxCollapsable!=null) {
					collect.addUnit(maxCollapsable);
					maxCollapsable = null;
				}
				if (collect.overflows(c)) {
					return data;
				}
				collect.addUnit(c);
			}
			data = it.iterable();
		}
		if (maxCollapsable!=null) {
			collect.addUnit(maxCollapsable);
			maxCollapsable = null;
		}
		return data; // empty
	}

	static int forwardSkippable(SplitPointDataSource<? extends SplitPointUnit> data) {
		int skipped = 0;
		for (SplitPointDataSource.Iterator<? extends SplitPointUnit> it = data.iterator(); it.hasNext();) {
			SplitPointUnit c = it.next(/*0,*/false);
			if (c.isBreakable()) {
				break;
			} else if (c.isSkippable()) {
				skipped++;
				continue;
			} else {
				return 0;
			}
		}
		return skipped;
	}

	private static class BreakPointScannerResult {
		int bestBreakable;
		int bestSplitPoint;
	}
	
	/**
	 * Returns true if the total size is less than or equal to the limit, false otherwise.
	 * 
	 * @param data the units
	 * @param limit the maximum width that is relevant to calculate
	 * @return returns the size 
	 */
	static <T extends SplitPointUnit> boolean fits(SplitPointDataSource<T> data, float limit, boolean useLastUnitSize) {
		return totalSize(data, limit, useLastUnitSize)<=limit;
	}
	/**
	 * If the total size is less than the limit, the size is returned, otherwise a value greater
	 * than or equal to the limit is returned.
	 * 
	 * @param data the units
	 * @param limit the maximum width that is relevant to calculate
	 * @return returns the size 
	 */
	static <T extends SplitPointUnit> float totalSize(SplitPointDataSource<T> data, float limit, boolean useLastUnitSize) {
		float ret = 0;
		Set<String> ids = new HashSet<>();
		Supplements<T> map = data.getSupplements();
		boolean hasSupplements = false;
		// we check up to the limit and beyond by one element, to make sure that we check enough units
		for (SplitPointDataSource.Iterator<T> it = data.iterator(); it.hasNext() && ret <= limit;) {
			T unit = it.next(/*ret, */false);
			List<String> suppIds = unit.getSupplementaryIDs();
			if (suppIds!=null) {
				for (String id : suppIds) {
					if (ids.add(id)) { //id didn't already exist in the list
						T item = map.get(id);
						if (item!=null) {
							if (!hasSupplements) {
								hasSupplements = true;
								ret += map.getOverhead();
							}
							ret += item.getUnitSize();
						}
					}
				}
			}
			//last unit?
			if (useLastUnitSize && !it.hasNext()) {
				ret += unit.getLastUnitSize();
			} else {
				ret += unit.getUnitSize();
			}
		}
		return ret;
	}

}
