[![Build Status](https://travis-ci.org/brailleapps/dotify.formatter.impl.svg?branch=master)](https://travis-ci.org/brailleapps/dotify.formatter.impl)
[![Type](https://img.shields.io/badge/type-provider_bundle-blue.svg)](https://github.com/brailleapps/wiki/wiki/Types)

# dotify.formatter.impl #
dotify.formatter.impl contains an implementation of the formatter interfaces of [dotify.api](https://github.com/brailleapps/dotify.api).

## Using ##
Download the [latest release](http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.daisy.dotify%22%20%20a%3A%22dotify.formatter.impl%22) from maven central and add it to your runtime environment.

Access the implementations via the following APIs in [dotify.api](http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.daisy.dotify%22%20%20a%3A%22dotify.api%22):
- `FormatterEngineMaker`
- `FormatterFactoryMaker`
- `ExpressionFactoryMaker`
- `PagedMediaWriterFactoryMaker`

 _or_ in an OSGi environment use:
- `FormatterEngineFactoryService`
- `FormatterFactory`
- `ExpressionFactory`
- `PagedMediaWriterFactoryMakerService`

## Building ##
Build with `gradlew build` (Windows) or `./gradlew build` (Mac/Linux)

## Testing ##

Tests are run with `gradlew test` (Windows) or `./gradlew test` (Mac/Linux)

### Adding tests ###

OBFL-to-PEF tests can be added by including lines such as the
following:

```java
testPEF("resource-files/foo-input.obfl", "resource-files/foo-expected.pef", false);
```

in a class that extends `AbstractFormatterEngineTest`. 

If you want the tests to be included in the overview page (linked to above)
the OBFL and PEF files need to be placed in
`test/org/daisy/dotify/engine/impl/resource-files` and named according
to the pattern `foo-input.obfl`/`foo-expected.pef`.

## Requirements & Compatibility ##
- Requires Java 8
- Compatible with SPI and OSGi

## Limitations ##
Compared to the latest [OBFL-version](http://braillespecs.github.io/obfl/obfl-specification.html), at least the following is not yet supported:

* marker-reference scope=volume and scope=document
* the text-style attribute outside of header/footers
* tables (incubating)
  * repeating headers
  * border intersections (see [issue #167](https://github.com/joeha480/dotify/issues/167))
  * render cell-border next to table border (see [issue #168](https://github.com/joeha480/dotify/issues/168))
  * table-row-spacing > 0 (see [issue #169](https://github.com/joeha480/dotify/issues/169))

Note that since OBFL does not have finalized releases, this list can be incomplete.

## More information ##
See the [common wiki](https://github.com/brailleapps/wiki/wiki) for more information.
