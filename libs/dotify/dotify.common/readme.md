[![Build Status](https://travis-ci.com/brailleapps/dotify.common.svg?branch=master)](https://travis-ci.com/brailleapps/dotify.common)
[![Type](https://img.shields.io/badge/type-library_bundle-blue.svg)](https://github.com/brailleapps/wiki/wiki/Types)
[![License: LGPL v2.1](https://img.shields.io/badge/License-LGPL%20v2%2E1%20%28or%20later%29-blue.svg)](https://www.gnu.org/licenses/lgpl-2.1)

# dotify.common #
Contains general classes that had to be implemented in order to support the other projects. 

## Using ##
To use the bundle, download the [latest release](http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.daisy.dotify%22%20AND%20a%3A%22dotify.common%22) from maven central.

Adding classes to this project should not be taken lightly as infrastructure dependencies can cause problems if overused.

## Building ##
Build with `gradlew build` (Windows) or `./gradlew build` (Mac/Linux)

## Testing ##
Tests are run with `gradlew test` (Windows) or `./gradlew test` (Mac/Linux)

## Requirements & Compatibility ##
- Requires Java 8
- Compatible with SPI and OSGi

## Javadoc ##
Javadoc for the latest Dotify Common development is available [here](http://brailleapps.github.io/dotify.common/latest/javadoc).

## More information ##
See the [common wiki](https://github.com/brailleapps/wiki/wiki) for more information.
