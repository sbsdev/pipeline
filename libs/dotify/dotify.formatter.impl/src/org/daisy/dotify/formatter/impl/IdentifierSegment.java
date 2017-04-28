package org.daisy.dotify.formatter.impl;

class IdentifierSegment implements Segment {
	
	private final String name;
	
	public IdentifierSegment(String name) {
		this.name = name;
	}

	@Override
	public SegmentType getSegmentType() {
		return SegmentType.Identifier;
	}

	public String getName() {
		return name;
	}
}
