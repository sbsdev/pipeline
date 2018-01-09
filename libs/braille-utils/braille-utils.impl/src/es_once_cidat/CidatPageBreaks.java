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
package es_once_cidat;

import org.daisy.braille.impl.embosser.PageBreaks;

/**
 *
 * @author Bert Frees
 */
public class CidatPageBreaks implements PageBreaks {

    public static enum Type { IMPACTO_TRANSPARENT,
                              PORTATHIEL_TRANSPARENT
    };
    private final String newpage;

    public CidatPageBreaks(Type type) {

        switch (type) {
            case PORTATHIEL_TRANSPARENT:
                newpage = "\u00c7";
                break;
            case IMPACTO_TRANSPARENT:
                newpage = "\u001b\u000c";
                break;
            default:
                newpage = "";
                break;
        }
    }

    @Override
    public String getString() {
        return newpage;
    }
}
