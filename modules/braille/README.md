[pipeline-mod-braille][]
========================

[![Build Status](https://travis-ci.org/daisy/pipeline-mod-braille.png?branch=master)](https://travis-ci.org/daisy/pipeline-mod-braille)

This repository contains a library of utility modules for braille
production for the [DAISY Pipeline 2][pipeline]. The top-level
"*-to-pef" scripts that are build on these braille modules live in the
[pipeline-scripts][] repository.


Project layout
--------------
Because of the very modular nature of DAISY Pipeline 2, browsing the
code is not always easy. In order to make it more obvious where to
find a particular piece of code, I've tried to organize the modules
into subdirectories in a logical and consistent way.

The braille modules are divided into logical *groups*:

- [`common-utils`](common-utils/src/main)
- [`css-utils`](css-utils)
- [`dotify-utils`](dotify-utils)
- [`libhyphen-utils`](libhyphen-utils)
- [`liblouis-utils`](liblouis-utils)
- [`pef-utils`](pef-utils)
- [`texhyph-utils`](texhyph-utils)
- [`obfl-utils`](obfl-utils)

Each of these utility modules collect all the XSLT/XPath functions and
XProc steps of that group into one `library.xsl` and one
`library.xpl`, so that they can be made available with a single
import. These library files make up the interface between the scripts
and the utils, scripts should not have to use any lower-level parts
directly.

The implementation of the functions and steps can either be found in
the utils module itself (which is mostly the case when they are
written in XSLT/XProc), or otherwise in a submodule. Submodules are
grouped in a directory with the same name as the utils module minus
the `-utils`.  They typically contain Java code. Some recurring types
of modules are modules for Saxon XPath extension functions (ending in
`-saxon`) and modules for custom Calabash steps (`-calabash`).
Generally, the XPath and XProc bindings are separated from the core
functionality (`-core` modules). Precompiled native binaries are
bundled in `-native` modules.


Building
--------
Build and run the unit tests with:

```sh
mvn clean install
```

The required version of Java is 8.

Semantic versioning
-------------------
Individual modules are versioned according to [SemVer](http://semver.org/). In order to ease the
release process, the correct version must be set whenever a change is made to a module (in both
`maven/bom/pom.xml` and module's own POM).

Release procedure
-----------------
This project should be released via the super-project: see
http://daisy.github.io/pipeline/Contribute/Developer-Guide/Releasing/#release-procedure.

Authors
-------
- [Bert Frees][bert]

License
-------
Copyright 2012-2014 [DAISY Consortium][daisy] 

This program is free software: you can redistribute it and/or modify
it under the terms of the [GNU Lesser General Public License][lgpl]
as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.


[pipeline-mod-braille]: https://github.com/daisy/pipeline-mod-braille
[pipeline-scripts]: https://github.com/daisy/pipeline-scripts
[pipeline]: http://daisy.github.io/pipeline
[bert]: http://github.com/bertfrees
[daisy]: http://www.daisy.org
[lgpl]: http://www.gnu.org/licenses/lgpl.html
