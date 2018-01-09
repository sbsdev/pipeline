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

import java.nio.charset.Charset;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.daisy.braille.api.embosser.EightDotFallbackMethod;
import org.daisy.braille.api.factory.FactoryProperties;
import org.daisy.braille.api.table.BrailleConstants;
import org.daisy.braille.api.table.BrailleConverter;
import org.daisy.braille.api.table.Table;
import org.daisy.braille.api.table.TableProvider;
import org.daisy.braille.impl.table.EmbosserBrailleConverter;
import org.daisy.braille.impl.table.EmbosserTable;

import aQute.bnd.annotation.component.Component;

@Component
public class EmbosserTableProvider implements TableProvider {
	
	enum TableType implements FactoryProperties {
    //      EN_US,          // US computer braille, compatible with
                            // "Braillo USA 6 DOT 001.00"
            EN_GB("British", ""),          // US computer braille (lower case), compatible with
                            // "Braillo ENGLAND 6 DOT 044.00" which is identical to
                            // "Braillo USA 6 DOT 001.00"
            DA_DK("Danish", ""),
            DE_DE("German", ""),
            CS_CZ("Czech", ""),
            ES_ES("Spanish (classic)", "Classic Spanish braille table"),
            ES_ES_TABLE_2("Spanish (modern)", "Modern Spanish braille table"),
            IT_IT_FIRENZE("Italian", ""), 
            UNICODE_BRAILLE("Unicode braille", ""),
            MIT("US (MIT)", "Commonly used embosser table"),
            			// = EN_US (http://www.dotlessbraille.org/asciibrltable.htm)
            NABCC("US (NABCC)", "North American Braille Computer Code"),
            			// http://www.accessibility.org/~max/doc/2004-jica/html/node9.html
            NABCC_8DOT("US (NABCC 8 dot)", "North American Braille Computer Code (8 dot)")
            			// http://mielke.cc/brltty//doc/Manual-BRLTTY/English/BRLTTY-14.html
            ;
    		private final String name;
    		private final String desc;
    		private final String identifier;
    		TableType(String name, String desc) {
    			this.name = name;
    			this.desc = desc;
    			this.identifier = this.getClass().getCanonicalName() + "." + this.toString();
    		}
    		@Override
    		public String getIdentifier() {
    			return identifier;
    		}
    		@Override
    		public String getDisplayName() {
    			return name;
    		}
    		@Override
    		public String getDescription() {
    			return desc;
    		}
	};

	private final Map<String, FactoryProperties> tables;

	public EmbosserTableProvider() {
		tables = new HashMap<String, FactoryProperties>(); 
		//tables.add(new EmbosserTable("US", "Commonly used embosser table", TableType.EN_US, this));
		addTable(TableType.EN_GB);
		addTable(TableType.DA_DK);
		addTable(TableType.DE_DE);
		addTable(TableType.CS_CZ);
		addTable(TableType.ES_ES);
		addTable(TableType.ES_ES_TABLE_2);
		addTable(TableType.IT_IT_FIRENZE);
		addTable(TableType.UNICODE_BRAILLE);
                addTable(TableType.MIT);
                addTable(TableType.NABCC);
                addTable(TableType.NABCC_8DOT);
	}

	private void addTable(FactoryProperties t) {
		tables.put(t.getIdentifier(), t);
	}

	/**
	 * Get a new table instance based on the factory's current settings.
	 * 
	 * @param t
	 *            the type of table to return, this will override the factory's
	 *            default table type.
	 * @return returns a new table instance.
	 */
	public BrailleConverter newTable(TableType t) {
		return newFactory(t.getIdentifier()).newBrailleConverter();
	}

	public Table newFactory(String identifier) {
		FactoryProperties fp = tables.get(identifier);
		switch ((TableType)fp) {
		case EN_GB:
			return new EmbosserTable(TableType.EN_GB, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = 4584612763436332628L;

				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(
							new String(
									" a1b'k2l@cif/msp\"e3h9o6r^djg>ntq,*5<-u8v.%[$+x!&;:4\\0z7(_?w]#y)="),
							Charset.forName("UTF-8"), fallback, replacement, true);
				}};
		case DA_DK:
			return new EmbosserTable(TableType.DA_DK, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = 4359936542579972940L;

				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(
							new String(
									" a,b.k;l'cif/msp`e:h*o!r~djgæntq@å?ê-u(v\\îøë§xèç^û_ü)z\"à|ôwï#yùé"),
							Charset.forName("IBM850"), fallback, replacement, true);
				}};
		case DE_DE:
			return new EmbosserTable(TableType.DE_DE, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = -8433057756653813876L;

				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(
							new String(
									" a,b.k;l\"cif|msp!e:h*o+r>djg`ntq'1?2-u(v$3960x~&<5/8)z={_4w7#y}%"),
							Charset.forName("UTF-8"), fallback, replacement, true);
				}};
		case CS_CZ:
			return new EmbosserTable(TableType.CS_CZ, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = 5548455704716622935L;

				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(
							new String(
									" a,b.k;l'cifímsp~e:h*o!r^djgéntq§á?ě-u(v$čóňúxžý¤š+ť)z\"w|ďř/#yůľ"),
							Charset.forName("windows-1250"), fallback, replacement, true);
				}};
		case ES_ES:
			return new EmbosserTable(TableType.ES_ES, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = 8428536872667051999L;

				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(
							new String(
									" a,b.k;l'cif/msp@e:h}o+r^djg|ntq_1?2-u<v{3960x$&\"5*8>z=(%4w7#y)\\"),
							Charset.forName("UTF-8"), fallback, replacement, true);
				}};
		case ES_ES_TABLE_2:
			return new EmbosserTable(TableType.ES_ES_TABLE_2, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = 8190134366310806692L;

				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(
							new String(" a,b.k;l'cifímsp@e:h}o+r^djgÌntq_1?2-u<v{396óxé&\"5*8>z=á%4w7#yú\\"),
							Charset.forName("UTF-8"), fallback, replacement, false);
				}};
		case IT_IT_FIRENZE:
			return new EmbosserTable(TableType.IT_IT_FIRENZE, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = -7770742394778777549L;

				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(
							new String(
									" a,b'k;l\"cif/msp)e:h*o!r%djg&ntq(1?2-u<v#396^x\\@+5.8>z=[$4w7_y]0"),
							Charset.forName("UTF-8"), fallback, replacement, true);
				}};
		case UNICODE_BRAILLE:
			return new EmbosserTable(TableType.UNICODE_BRAILLE, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = 6394744029951505837L;

				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(BrailleConstants.BRAILLE_PATTERNS_256,
							Charset.forName("UTF-8"), fallback, replacement, true);
				}};
		case MIT:
			return new EmbosserTable(TableType.MIT, EightDotFallbackMethod.values()[0], '\u2800'){
            	/**
				 * 
				 */
				private static final long serialVersionUID = 6383725065146856776L;

				//	case EN_US:
				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(
							new String(
									" A1B'K2L@CIF/MSP\"E3H9O6R^DJG>NTQ,*5<-U8V.%[$+X!&;:4\\0Z7(_?W]#Y)="),
							Charset.forName("UTF-8"), fallback, replacement, true);
				}};
		case NABCC:
			return new EmbosserTable(TableType.NABCC, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = -1182152047005280796L;

				@Override
				public BrailleConverter newBrailleConverter() {
					return new EmbosserBrailleConverter(
							new String(
									" a1b'k2l`cif/msp\"e3h9o6r~djg>ntq,*5<-u8v.%{$+x!&;:4|0z7(_?w}#y)="),
							Charset.forName("UTF-8"), fallback, replacement, true);
				}};
		case NABCC_8DOT:
			return new EmbosserTable(TableType.NABCC_8DOT, EightDotFallbackMethod.values()[0], '\u2800'){

				/**
				 * 
				 */
				private static final long serialVersionUID = -1029298211693241561L;

				@Override
				public BrailleConverter newBrailleConverter() {
					char[] table = {(char)32,  (char)97,  (char)49,  (char)98,  (char)39,  (char)107, (char)50,  (char)108,
							(char)96,  (char)99,  (char)105, (char)102, (char)47,  (char)109, (char)115, (char)112,
							(char)34,  (char)101, (char)51,  (char)104, (char)57,  (char)111, (char)54,  (char)114,
							(char)126, (char)100, (char)106, (char)103, (char)62,  (char)110, (char)116, (char)113,
							(char)44,  (char)42,  (char)53,  (char)60,  (char)45,  (char)117, (char)56,  (char)118,
							(char)46,  (char)37,  (char)123, (char)36,  (char)43,  (char)120, (char)33,  (char)38,
							(char)59,  (char)58,  (char)52,  (char)124, (char)48,  (char)122, (char)55,  (char)40,
							(char)95,  (char)63,  (char)119, (char)125, (char)35,  (char)121, (char)41,  (char)61,
							(char)186, (char)65,  (char)185, (char)66,  (char)180, (char)75,  (char)178, (char)76,
							(char)64,  (char)67,  (char)73,  (char)70,  (char)247, (char)77,  (char)83,  (char)80,
							(char)168, (char)69,  (char)179, (char)72,  (char)167, (char)79,  (char)182, (char)82,
							(char)94,  (char)68,  (char)74,  (char)71,  (char)187, (char)78,  (char)84,  (char)81,
							(char)184, (char)215, (char)175, (char)171, (char)173, (char)85,  (char)174, (char)86,
							(char)183, (char)164, (char)91,  (char)162, (char)177, (char)88,  (char)161, (char)165,
							(char)181, (char)166, (char)172, (char)92,  (char)176, (char)90,  (char)169, (char)188,
							(char)127, (char)191, (char)87,  (char)93,  (char)163, (char)89,  (char)190, (char)189,
							(char)170, (char)129, (char)226, (char)130, (char)230, (char)139, (char)234, (char)140,
							(char)128, (char)131, (char)137, (char)134, (char)248, (char)141, (char)147, (char)144,
							(char)227, (char)133, (char)238, (char)136, (char)242, (char)143, (char)224, (char)146,
							(char)158, (char)132, (char)138, (char)135, (char)229, (char)142, (char)148, (char)145,
							(char)240, (char)225, (char)251, (char)233, (char)254, (char)149, (char)236, (char)150,
							(char)241, (char)237, (char)155, (char)253, (char)231, (char)152, (char)246, (char)228,
							(char)245, (char)250, (char)244, (char)156, (char)249, (char)154, (char)232, (char)239,
							(char)159, (char)243, (char)151, (char)157, (char)255, (char)153, (char)252, (char)235,
							(char)160, (char)1,   (char)194, (char)2,   (char)198, (char)11,  (char)202, (char)12,
							(char)0,   (char)3,   (char)9,   (char)6,   (char)216, (char)13,  (char)19,  (char)16,
							(char)195, (char)5,   (char)206, (char)8,   (char)210, (char)15,  (char)192, (char)18,
							(char)30,  (char)4,   (char)10,  (char)7,   (char)197, (char)14,  (char)20,  (char)17,
							(char)208, (char)193, (char)219, (char)201, (char)222, (char)21,  (char)204, (char)22,
							(char)209, (char)205, (char)27,  (char)221, (char)199, (char)24,  (char)214, (char)196,
							(char)213, (char)218, (char)212, (char)28,  (char)217, (char)26,  (char)200, (char)207,
							(char)31,  (char)211, (char)23,  (char)29,  (char)223, (char)25,  (char)220, (char)203 };
					StringBuffer sb = new StringBuffer();
		                        sb.append(table);
					return new EmbosserBrailleConverter(sb.toString(), Charset.forName("ISO-8859-1"), fallback, replacement, true);
				}};
		default:
			return null;
		}
	}

	@Override
	public Collection<FactoryProperties> list() {
		return Collections.unmodifiableCollection(tables.values());
	}

}
