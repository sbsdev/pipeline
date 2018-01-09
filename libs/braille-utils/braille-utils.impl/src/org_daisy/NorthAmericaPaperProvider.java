/*
 * Braille Utils (C) 2010-2011 Daisy Consortium 
 * 
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 * 
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
package org_daisy;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;

import org.daisy.braille.api.paper.Length;
import org.daisy.braille.api.paper.Paper;
import org.daisy.braille.api.paper.PaperProvider;
import org.daisy.braille.api.paper.SheetPaper;

import aQute.bnd.annotation.component.Component;

@Component
public class NorthAmericaPaperProvider implements PaperProvider {
	public static final double INCH_IN_MM = 25.4;
	enum PaperSize {
		LETTER,
                LEGAL,
                JUNIOR_LEGAL,
                LEDGER,
                TABLOID,
		W11500THOU_X_H11INCH
	};

	private final Collection<Paper> papers;
	
	public NorthAmericaPaperProvider() {
		ArrayList<Paper> tmp = new ArrayList<Paper>();
		tmp.add(new SheetPaper("Letter", "8.5 inch x 11 inch", PaperSize.LETTER,
				Length.newInchValue(8.5), 
				Length.newInchValue(11)));
        tmp.add(new SheetPaper("Legal", " 8.5 inch x 14 inch", PaperSize.LEGAL, 
        		Length.newInchValue(8.5), 
        		Length.newInchValue(14)));
        tmp.add(new SheetPaper("Junior Legal", "8 inch x 5 inch", PaperSize.JUNIOR_LEGAL, 
        		Length.newInchValue(8), 
        		Length.newInchValue(5)));
        tmp.add(new SheetPaper("Ledger", "17 inch x 11 inch", PaperSize.LEDGER, 
        		Length.newInchValue(17),
        		Length.newInchValue(11)));
        tmp.add(new SheetPaper("Tabloid", "11 inch x 17 inch", PaperSize.TABLOID,
        		Length.newInchValue(11), 
        		Length.newInchValue(17)));
		tmp.add(new SheetPaper("11.5 inch x 11 inch", "11.5 inch wide, 11 inch high", PaperSize.W11500THOU_X_H11INCH, 
				Length.newInchValue(11.5),
				Length.newInchValue(11)));
		this.papers = Collections.unmodifiableCollection(tmp);
	}

	@Override
	public Collection<Paper> list() {
		return papers;
	}
}
