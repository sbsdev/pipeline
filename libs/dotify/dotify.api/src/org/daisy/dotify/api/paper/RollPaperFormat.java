package org.daisy.dotify.api.paper;


/**
 * Provides a paper format for paper in rolls.
 * @author Joel Håkansson
 */
public class RollPaperFormat extends AbstractPageFormat {
	private final Length across, along;

	/**
	 * Creates a new roll paper format
	 * @param paper the roll paper to use
	 * @param length the cut-length
	 */
	public RollPaperFormat(RollPaper paper, Length length) {
		this.across = paper.getLengthAcrossFeed();
		this.along = length;
	}

	/**
	 * Creates a new roll paper format
	 * @param acrossPaperFeed the height of the roll
	 * @param alongPaperFeed the cut-length
	 */
	public RollPaperFormat(Length acrossPaperFeed, Length alongPaperFeed) {
		this.across = acrossPaperFeed;
		this.along = alongPaperFeed;
	}

	/**
	 * Gets the length of the paper perpendicular to the direction of the paper feed
	 * @return returns the length.
	 */
	public Length getLengthAcrossFeed() {
		return across;
	}

	/**
	 * Gets the length of the paper along the direction of the paper feed
	 * @return returns the length.
	 */
	public Length getLengthAlongFeed() {
		return along;
	}

	@Override
	public Type getPageFormatType() {
		return Type.ROLL;
	}

	@Override
	public RollPaperFormat asRollPaperFormat() {
		return this;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "RollPaperFormat [across=" + across + ", along=" + along + "]";
	}

}
