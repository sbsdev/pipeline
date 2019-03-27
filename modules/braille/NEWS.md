v1.12.0
=======

Changes
-------
- Support for fractional `line-height`
- Bugfixes

v1.11.2
=======

Changes
-------
- Syntax of style attributes has changed:
  http://braillespecs.github.io/braille-css/20181031/#style-attribute
- Support for `:-obfl-alternate-scenario` pseudo-class and `-obfl-scenario-cost` property
  (https://github.com/nlbdev/pipeline/issues/207)
- Support for `@-obfl-volume-transition` rules (https://github.com/braillespecs/obfl/issues/70,
  https://github.com/sbsdev/pipeline-mod-sbs/issues/68)
- CSS/XSL module for basic volume breaking
  (https://github.com/daisy/pipeline-mod-braille/issues/182,
  https://github.com/daisy/pipeline-mod-braille/pull/186)
- Various invisible changes (https://github.com/daisy/pipeline-mod-braille/issues/99,
  https://github.com/daisy/pipeline-mod-braille/pull/171,
  https://github.com/daisy/pipeline-mod-braille/pull/180, ...)
- Various bugfixes

Components
----------
- liblouis ([3.6.0](https://github.com/liblouis/liblouis/releases/tag/v3.6.0)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v)), liblouis-java
  ([3.1.0](https://github.com/liblouis/liblouis-java/releases/tag/3.1.0))
- **dotify** (**api** [**4.4.0**](https://github.com/brailleapps/dotify.api/releases/tag/releases%2Fv4.4.0), **common**
  [**4.3.0**](https://github.com/brailleapps/dotify.common/releases/tag/releases%2Fv4.3.0), hyphenator.impl
  [4.0.0](https://github.com/brailleapps/dotify.hyphenator.impl/releases/tag/releases%2Fv4.0.0), translator.impl
  [4.0.0](https://github.com/brailleapps/dotify.translator.impl/releases/tag/releases%2Fv4.0.0), **formatter.impl**
  [**4.4.0**](https://github.com/brailleapps/dotify.formatter.impl/releases/tag/releases%2Fv4.4.0), text.impl
  [4.0.0](https://github.com/brailleapps/dotify.text.impl/releases/tag/releases%2Fv4.0.0), **streamline-api**
  [**1.3.0**](https://github.com/brailleapps/streamline-api/releases/tag/releases%2Fv1.3.0), **streamline-engine**
  [**1.2.0**](https://github.com/brailleapps/streamline-engine/releases/tag/releases%2Fv1.2.0), **task.impl**
  [**4.5.0**](https://github.com/brailleapps/dotify.task.impl/releases/tag/releases%2Fv4.5.0))
- brailleutils (api
  [3.0.1](https://github.com/brailleapps/braille-utils.api/releases/tag/releases%2Fv3.0.1), impl
  [3.0.0](https://github.com/brailleapps/braille-utils.impl/releases/tag/releases%2Fv3.0.0), pef-tools
  [2.2.0](https://github.com/brailleapps/braille-utils.pef-tools/releases/tag/releases%2Fv2.2.0))
- **braille-css** ([**1.14.0**](https://github.com/daisy/braille-css/releases/tag/1.14.0))
- jsass ([4.1.0-p1](https://github.com/snaekobbi/jsass/releases/tag/4.1.0-p1))
- libhyphen ([2.8.8](https://github.com/snaekobbi/libhyphen-nar/releases/tag/)), jhyphen
  ([1.0.0](https://github.com/daisy/jhyphen/releases/tag/v1.0.0))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.11.1
=======

Changes
-------
- Support for extended `leader(<braille-string>[,[<integer>|<percentage>][,[left|center|right]]?]?)`
  function (https://github.com/sbsdev/pipeline-mod-sbs/issues/51,
  https://github.com/nlbdev/pipeline/issues/169)
- Support for `text-transform: -louis-emph-4` to `-louis-emph-10`
  (https://github.com/nlbdev/pipeline/issues/107)
- Support for `::after` and `::before` pseudo-elements inside elements with `display: none`
- Bugfixes (https://github.com/daisy/pipeline-mod-braille/issues/173, ...)
- Update to Liblouis 3.6.0

Components
----------
- **liblouis** ([**3.6.0**](https://github.com/liblouis/liblouis/releases/tag/v3.6.0)),
  liblouisutdml ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)),,
  liblouis-java ([3.1.0](https://github.com/liblouis/liblouis-java/releases/tag/3.1.0))
- dotify (api [4.1.0](https://github.com/brailleapps/dotify.api/releases/tag/releases%2Fv4.1.0), common
  [4.1.0](https://github.com/brailleapps/dotify.common/releases/tag/releases%2Fv4.1.0), hyphenator.impl
  [4.0.0](https://github.com/brailleapps/dotify.hyphenator.impl/releases/tag/releases%2Fv4.0.0), translator.impl
  [4.0.0](https://github.com/brailleapps/dotify.translator.impl/releases/tag/releases%2Fv4.0.0), formatter.impl
  [4.1.0](https://github.com/brailleapps/dotify.formatter.impl/releases/tag/releases%2Fv4.1.0), text.impl
  [4.0.0](https://github.com/brailleapps/dotify.text.impl/releases/tag/releases%2Fv4.0.0), streamline-api
  [1.0.0](https://github.com/brailleapps/streamline-api/releases/tag/releases%2Fv1.0.0), streamline-engine
  [1.1.0](https://github.com/brailleapps/streamline-engine/releases/tag/releases%2Fv1.1.0), task.impl
  [4.1.0](https://github.com/brailleapps/dotify.task.impl/releases/tag/releases%2Fv4.1.0))
- brailleutils (api
  [3.0.1](https://github.com/brailleapps/braille-utils.api/releases/tag/releases%2Fv3.0.1), impl
  [3.0.0](https://github.com/brailleapps/braille-utils.impl/releases/tag/releases%2Fv3.0.0), pef-tools
  [2.2.0](https://github.com/brailleapps/braille-utils.pef-tools/releases/tag/releases%2Fv2.2.0))
- braille-css ([1.13.0](https://github.com/daisy/braille-css/releases/tag/1.13.0))
- jsass ([4.1.0-p1](https://github.com/snaekobbi/jsass/releases/tag/4.1.0-p1))
- libhyphen ([2.8.8](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.8.8)), jhyphen
  ([1.0.0](https://github.com/daisy/jhyphen/releases/tag/v1.0.0))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.11.0
=======

Changes
-------
- New script for adding a braille rendition to an EPUB
  (https://github.com/snaekobbi/pipeline-mod-braille/pull/6,
  https://github.com/daisy/pipeline-mod-braille/issues/164,
  https://github.com/sbsdev/pipeline-mod-sbs/issues/58)
- More usable message log (https://github.com/daisy/pipeline-mod-braille/issues/38)
- `include-obfl` option now outputs OBFL even when conversion to PEF fails
  (https://github.com/daisy/pipeline-mod-braille/issues/124)
- Support for custom page counters (https://github.com/brailleapps/dotify/issues/165,
  https://github.com/brailleapps/dotify/issues/180,
  https://github.com/braillespecs/braille-css/issues/47)
- Fixes to volume breaking (https://github.com/brailleapps/dotify.formatter.impl/pull/28,
  https://github.com/nlbdev/pipeline/issues/80, https://github.com/nlbdev/pipeline/issues/118,
  https://github.com/nlbdev/pipeline/issues/121,
  https://github.com/sbsdev/pipeline-mod-sbs/issues/33,
  https://github.com/daisy/pipeline-mod-braille/issues/136)
- Fixed handling of cross-references in EPUB 3
  (https://github.com/daisy/pipeline-mod-braille/issues/126)
- Improved language detection in EPUB 3
- Addition of `dc:language` in PEF metadata
- Improved white space handling
- Fixed behavior of `target-content()` w.r.t. pseudo-elements
- Fixed border alignment (https://github.com/nlbdev/pipeline/issues/128)
- Support for `page` property inside `::before` and `::after` pseudo-elements
- Fixed support for `line-height` in combination with page footer
  (https://github.com/brailleapps/dotify/issues/196,
  https://github.com/brailleapps/dotify.formatter.impl/pull/29)
- Limited support of `target-counter()` to elements in normal flow
- Various other bugfixes (`text-transform`, `-obfl-fallback-collection`, ...)

Components
----------
- liblouis ([3.0.0.alpha1](https://github.com/liblouis/liblouis/releases/tag/v3.0.0.alpha1)),
  liblouisutdml ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)),
  liblouis-java ([3.1.0](https://github.com/liblouis/liblouis-java/releases/tag/3.1.0))
- **dotify** (**api** [**4.1.0**](https://github.com/brailleapps/dotify.api/releases/tag/releases%2Fv4.1.0), **common**
  [**4.1.0**](https://github.com/brailleapps/dotify.common/releases/tag/releases%2Fv4.1.0), **hyphenator.impl**
  [**4.0.0**](https://github.com/brailleapps/dotify.hyphenator.impl/releases/tag/releases%2Fv4.0.0), **translator.impl**
  [**4.0.0**](https://github.com/brailleapps/dotify.translator.impl/releases/tag/releases%2Fv4.0.0), **formatter.impl**
  [**4.1.0**](https://github.com/brailleapps/dotify.formatter.impl/releases/tag/releases%2Fv4.1.0), **text.impl**
  [**4.0.0**](https://github.com/brailleapps/dotify.text.impl/releases/tag/releases%2Fv4.0.0), **streamline-api**
  [**1.0.0**](https://github.com/brailleapps/streamline-api/releases/tag/releases%2Fv1.0.0), **streamline-engine**
  [**1.1.0**](https://github.com/brailleapps/streamline-engine/releases/tag/releases%2Fv1.1.0), **task.impl**
  [**4.1.0**](https://github.com/brailleapps/dotify.task.impl/releases/tag/releases%2Fv4.1.0))
- **brailleutils** (**api**
  [**3.0.1**](https://github.com/brailleapps/braille-utils.api/releases/tag/releases%2Fv3.0.1), **impl**
  [**3.0.0**](https://github.com/brailleapps/braille-utils.impl/releases/tag/releases%2Fv3.0.0), **pef-tools**
  [**2.2.0**](https://github.com/brailleapps/braille-utils.pef-tools/releases/tag/releases%2Fv2.2.0))
- braille-css ([1.13.0](https://github.com/daisy/braille-css/releases/tag/1.13.0))
- jsass ([4.1.0-p1](https://github.com/snaekobbi/jsass/releases/tag/4.1.0-p1))
- libhyphen ([2.8.8](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.8.8)), jhyphen
  ([1.0.0](https://github.com/daisy/jhyphen/releases/tag/v1.0.0))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.10.1
=======

Changes
-------
- Liblouis update
- Dotify update (https://github.com/daisy/pipeline-mod-braille/pull/138,
  https://github.com/daisy/pipeline-mod-braille/pull/139)
- Improved performance (https://github.com/snaekobbi/issues/issues/28,
  https://github.com/ndw/xmlcalabash1/pull/256) <!-- fixed memory leak and various step
  optimizations -->
- Improved thread safety (https://github.com/liblouis/liblouis-java/issues/8)
- Fix to PEF preview
- Support for new `border-align`, `border-top-align`, `border-right-align`, `border-bottom-align`,
  `border-left-align`, `border-style`, `border-top-style`, `border-right-style`,
  `border-bottom-style`, `border-left-style`, `border-width`, `border-top-width`,
  `border-right-width`, `border-bottom-width`, `border-left-width`, `border-top-pattern`,
  `border-right-pattern`, `border-bottom-pattern` and `border-left-pattern` properties and changed
  behavior of existing `border`, `border-top`, `border-right`, `border-bottom` and `border-left`
  properties (https://github.com/braillespecs/braille-css/issues/44)
- Improvements to print page number ranges
  - Changed behavior of `string()` keywords `page-start` and `page-start-except-last`: on the first
    page `page-start` now behaves like `page-first`
    (https://github.com/sbsdev/pipeline-mod-sbs/issues/42,
    https://github.com/snaekobbi/pipeline-mod-dedicon/issues/49)
  - Dropped support for `page-last-except-start` and `spread-last-except-start`
  - Fixed behavior of `page-last`, `page-start-except-last`, `spread-last` and
    `spread-start-except-last`: "last" now includes "border" pagenums
    (https://github.com/sbsdev/pipeline-mod-sbs/issues/45)
  - Fixed behavior of `page-start`, `page-start-except-last`, `spread-start` and
    `spread-start-except-last`: "start" now does not include "border" pagenums, except on the first
    page (https://github.com/sbsdev/pipeline-mod-sbs/issues/45,
    https://github.com/brailleapps/dotify/issues/150,
    https://github.com/brailleapps/dotify.formatter.impl/pull/16) <!--
  • Fixed behavior w.r.t. "border" pagenums that precede an element with top padding (78cbc55) -->
- Improved manual volume breaking (https://github.com/sbsdev/pipeline-mod-sbs/issues/33,
  https://github.com/brailleapps/dotify/issues/212,
  https://github.com/brailleapps/dotify.formatter.impl/issues/2)
- Support for `-obfl-underline: ⠂` (https://github.com/daisy/pipeline-mod-braille/issues/96,
  https://github.com/brailleapps/dotify.formatter.impl/pull/14,
  https://github.com/sbsdev/pipeline-mod-sbs/issues/34)
- Support for grouping endnotes according to volume
  (https://github.com/brailleapps/dotify.formatter.impl/pull/18,
  https://github.com/braillespecs/obfl/issues/58) <!--
  http://braillespecs.github.io/braille-css/20161201/obfl#lists-of-references -->
  - `display:-obfl-list-of-properties` value
  - support for `::-obfl-on-volume-start` and `::-obfl-on-volume-end` pseudo-elements on
    `-obfl-list-of-properties` elements
- Support for `@text-transform` rules (https://github.com/sbsdev/pipeline-mod-sbs/issues/38)
- Fixes to line breaking and white space handling
  (https://github.com/sbsdev/pipeline-mod-sbs/issues/61,
  https://github.com/sbsdev/pipeline-mod-sbs/issues/32, ...) <!-- 2568b3d, c44e94b, 6d0b8f2,
  e4b6911, https://github.com/sbsdev/pipeline-mod-sbs/issues/31,
  https://github.com/snaekobbi/pipeline-mod-dedicon/issues/58 -->
- Removal of erroneous empty pages <!-- https://github.com/snaekobbi/pipeline-mod-dedicon/issues/57,
  https://github.com/sbsdev/pipeline-mod-sbs/issues/33 -->
- Truncation of long header and footer lines
  (https://github.com/brailleapps/dotify.formatter.impl/pull/10,
  https://github.com/sbsdev/pipeline-mod-sbs/issues/28)
- Support for `counter-set:page` inside `@begin` and `@end` areas
  (https://github.com/daisy/pipeline-mod-braille/issues/121)
- Support for `symbols()` function with `target-counter()` on main page area
  (https://github.com/daisy/pipeline-mod-braille/issues/115,
  https://github.com/brailleapps/dotify.formatter.impl/pull/9)
- Support for `text-transform` on `target-counter()` function
  (https://github.com/daisy/pipeline-mod-braille/issues/114,
  https://github.com/brailleapps/dotify.formatter.impl/pull/9)
- Fixed behavior of `hyphens:none` <!-- https://github.com/sbsdev/pipeline-mod-sbs/issues/13 -->
- Fixed support for `margin-top` on `::-obfl-on-toc-start`, `::-obfl-on-toc-end`,
  `::-obfl-on-volume-start` and `::-obfl-on-volume-end` pseudo-elements <!--
  https://github.com/sbsdev/pipeline-mod-sbs/issues/31 -->
- Fixed behavior of `counter()` on `::alternate::alternate` <!--
  https://github.com/sbsdev/pipeline-mod-sbs/issues/59 -->
- Fixed behavior of `-obfl-evaluate()` when expression evaluates to nothing
  (https://github.com/brailleapps/dotify.formatter.impl/pull/15)
- Fixed behavior of `hyphens` in presence of `text-transform`
- Support for `list-style` as an alias for `list-style-type`
  (https://github.com/daisy/pipeline-mod-braille/issues/98)
- Support for CSS value `initial`
- Various other small fixes <!--
  • Allow blocks within blocks with a `-obfl-underline` property
    (https://github.com/brailleapps/dotify.formatter.impl/pull/17)
  • Fixed handling of SASS variables with spaces or special characters
  • Fixed style inheritance on `::-obfl-on-toc-start`, `::-obfl-on-toc-end`,
    `::-obfl-on-volume-start` and `::-obfl-on-volume-end` pseudo-elements
  • `content` property now only allowed on `::before`, `::after`, `::alternate` and
  • `::footnote-call` pseudo-elements
    ...
• Fixed behavior of `string-set` and `string()` within named flows
  (https://github.com/daisy/pipeline-mod-braille/issues/110,
  https://github.com/sbsdev/pipeline-mod-sbs/issues/36): omit for now because broken in 8d1a23a (and
  fixed in 5674a23 but not on master yet) -->

Components
----------
- **liblouis** ([**3.0.0.alpha1**](https://github.com/liblouis/liblouis/releases/tag/v3.0.0.alpha1)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), **liblouis-java**
  ([**3.1.0**](https://github.com/liblouis/liblouis-java/releases/tag/3.1.0))
- **dotify** (**api** [**3.1.0**](https://github.com/brailleapps/dotify.api/releases/tag/releases%2Fv3.1.0), **common**
  [**3.0.0**](https://github.com/brailleapps/dotify.common/releases/tag/releases%2Fv3.0.0), **hyphenator.impl**
  [**3.0.0**](https://github.com/brailleapps/dotify.hyphenator.impl/releases/tag/releases%2Fv3.0.0), **translator.impl**
  [**3.0.0**](https://github.com/brailleapps/dotify.translator.impl/releases/tag/releases%2Fv3.0.0), **formatter.impl**
  [**3.1.0**](https://github.com/brailleapps/dotify.formatter.impl/releases/tag/releases%2Fv3.1.0), **text.impl**
  [**3.0.0**](https://github.com/brailleapps/dotify.text.impl/releases/tag/releases%2Fv3.0.0), **task-api**
  [**3.0.0**](https://github.com/brailleapps/dotify.task-api/releases/tag/releases%2Fv3.0.0), **task-runner**
  [**2.0.0**](https://github.com/brailleapps/dotify.task-runner/releases/tag/releases%2Fv2.0.0), **task.impl**
  [**3.0.0**](https://github.com/brailleapps/dotify.task.impl/releases/tag/releases%2Fv3.0.0))
- brailleutils (api
  [3.0.0](https://github.com/brailleapps/braille-utils.api/releases/tag/releases%2Fv3.0.0), impl
  [3.0.0-beta](https://github.com/brailleapps/braille-utils.impl/releases/tag/releases%2Fv3.0.0-beta), pef-tools
  [2.0.0-alpha](https://github.com/brailleapps/braille-utils.pef-tools/releases/tag/releases%2Fv2.0.0-alpha))
- **braille-css** ([**1.13.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.13.0))
- jsass ([4.1.0-p1](https://github.com/snaekobbi/jsass/releases/tag/4.1.0-p1))
- libhyphen ([2.8.8](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.8.8)), jhyphen
  ([1.0.0](https://github.com/daisy/jhyphen/releases/tag/v1.0.0))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.10.0
=======

Changes
-------
- Improvements to in-script documentation (option descriptions etc.)
  (https://github.com/daisy/pipeline-mod-braille/pull/137)

v1.9.16
=======

Changes
-------
- Dotify update
- Bugfixes

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([2.0.0](https://github.com/liblouis/liblouis-java/releases/tag/2.0.0))
- **dotify** (**api** [**2.10.0**](https://github.com/brailleapps/dotify.api/releases/tag/releases%2Fv2.10.0), **common**
  [**2.1.0**](https://github.com/brailleapps/dotify.common/releases/tag/releases%2Fv2.1.0), hyphenator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv2.0.1), translator.impl
  [2.3.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv2.3.0), **formatter.impl**
  [**2.6.0**](https://github.com/brailleapps/dotify.formatter.impl/releases/tag/releases%2Fv2.6.0), text.impl
  [2.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv2.0.0), **task-api**
  [**2.3.0**](https://github.com/brailleapps/dotify.task-api/releases/tag/releases%2Fv2.3.0), **task-runner**
  [**1.1.0**](https://github.com/brailleapps/dotify.task-runner/releases/tag/releases%2Fv1.1.0), **task.impl**
  [**2.8.0**](https://github.com/brailleapps/dotify.task.impl/releases/tag/releases%2Fv2.8.0))
- brailleutils (api
  [3.0.0](https://github.com/brailleapps/braille-utils.api/releases/tag/releases%2Fv3.0.0), impl
  [3.0.0-beta](https://github.com/brailleapps/braille-utils.impl/releases/tag/releases%2Fv3.0.0-beta), pef-tools
  [2.0.0-alpha](https://github.com/brailleapps/braille-utils.pef-tools/releases/tag/releases%2Fv2.0.0-alpha))
- braille-css ([1.12.0](https://github.com/snaekobbi/braille-css/releases/tag/1.12.0))
- jstyleparser ([1.20-p9](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p9))
- jsass ([4.1.0-p1](https://github.com/snaekobbi/jsass/releases/tag/4.1.0-p1))
- libhyphen ([2.8.8](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.8.8)), jhyphen
  ([1.0.0](https://github.com/daisy/jhyphen/releases/tag/v1.0.0))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.15
=======

Changes
-------
- Bugfixes

v1.9.14
=======

Changes
-------
- More control over BRF output with `ascii-file-format` option
  (https://github.com/daisy/pipeline-mod-braille/issues/103)
- Support for block underlining with `-obfl-underline` property
  (https://github.com/braillespecs/obfl/issues/50, https://github.com/joeha480/dotify/pull/208,
  https://github.com/brailleapps/dotify.api/pull/2)
- Support for `@volume:last`
- Support for table of contents in end area of volume
  (https://github.com/braillespecs/obfl/issues/55)
- Support `page` property on elements flowed into `@begin` and `@end` areas of volumes
  (https://github.com/daisy/pipeline-mod-braille/issues/104)
- Fixed behavior of padding (https://github.com/daisy/pipeline-mod-braille/issues/109,
  https://github.com/snaekobbi/pipeline-mod-braille/issues/30)
- Support for OBFL variables `$sheets-in-volume` and `$sheets-in-document`
  (https://github.com/joeha480/dotify/issues/198, https://github.com/joeha480/dotify/pull/199)
- Support for collecting information about flows with `-obfl-use-when-collection-not-empty` property
  (https://github.com/joeha480/dotify/issues/200)
- Support for `text-transform` on `-obfl-evaluate()` function
  (https://github.com/daisy/pipeline-mod-braille/issues/114,
  https://github.com/brailleapps/dotify.formatter.impl/pull/9)
- Support for hyphenation with Hyphen on Windows
  (https://github.com/daisy/pipeline-mod-braille/issues/107)
- Internal changes (https://github.com/joeha480/dotify/issues/118,
  https://github.com/joeha480/dotify/issues/188, https://github.com/joeha480/dotify/pull/207, ...)
- Bugfixes (https://github.com/daisy/pipeline-mod-braille/issues/50, ...)

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([2.0.0](https://github.com/liblouis/liblouis-java/releases/tag/2.0.0))
- **dotify** (**api** [**2.8.0**](https://github.com/brailleapps/dotify.api/releases/tag/releases%2Fv2.8.0), common
  [2.0.2](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv2.0.2), hyphenator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv2.0.1), translator.impl
  [2.3.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv2.3.0), **formatter.impl**
  [**2.4.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv2.4.0), text.impl
  [2.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv2.0.0), task-api
  [2.1.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv2.1.0), task-runner
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-runner%2Fv1.0.0), task.impl
  [2.4.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv2.4.0))
- **brailleutils** (**api**
  [**3.0.0**](https://github.com/brailleapps/braille-utils.api/releases/tag/releases%2Fv3.0.0), **impl**
  [**3.0.0-beta**](https://github.com/brailleapps/braille-utils.impl/releases/tag/releases%2Fv3.0.0-beta), **pef-tools**
  [**2.0.0-alpha**](https://github.com/brailleapps/braille-utils.pef-tools/releases/tag/releases%2Fv2.0.0-alpha))
- **braille-css** ([**1.11.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.11.0))
- **jstyleparser** ([**1.20-p9**](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p9))
- jsass ([4.1.0-p1](https://github.com/snaekobbi/jsass/releases/tag/4.1.0-p1))
- **libhyphen** ([**2.8.8**](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.8.8)), jhyphen
  ([1.0.0](https://github.com/daisy/jhyphen/releases/tag/v1.0.0))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.13
=======

Changes
-------
- Support for non-standard hyphenation with Hyphen
  (https://github.com/snaekobbi/pipeline-mod-braille/issues/55)
- Internal changes
- Bugfixes

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([2.0.0](https://github.com/liblouis/liblouis-java/releases/tag/2.0.0))
- **dotify** (**api** [**2.7.0**](https://github.com/brailleapps/dotify.api/releases/tag/releases%2Fv2.7.0), common
  [2.0.2](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv2.0.2), hyphenator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv2.0.1), translator.impl
  [2.3.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv2.3.0), **formatter.impl**
  [**2.3.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv2.3.0), text.impl
  [2.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv2.0.0), task-api
  [2.1.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv2.1.0), task-runner
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-runner%2Fv1.0.0), **task.impl**
  [**2.4.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv2.4.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.10.1**](https://github.com/snaekobbi/braille-css/releases/tag/1.10.1))
- **jstyleparser** ([**1.20-p8**](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p8))
- jsass ([4.1.0-p1](https://github.com/snaekobbi/jsass/releases/tag/4.1.0-p1))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([1.0.0](https://github.com/daisy/jhyphen/releases/tag/v1.0.0))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.12
=======

Changes
-------
- Improved support for `symbols()` function
  (https://github.com/snaekobbi/pipeline-mod-braille/issues/15)
- Support for non-standard hyphenation (https://github.com/snaekobbi/pipeline-mod-braille/issues/55)
- Internal changes (https://github.com/daisy/pipeline-mod-braille/issues/100, ...)
- Bugfixes

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), **liblouis-java**
  ([**2.0.0**](https://github.com/liblouis/liblouis-java/releases/tag/2.0.0))
- dotify (api [2.5.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv2.5.0), common
  [2.0.2](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv2.0.2), hyphenator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv2.0.1), translator.impl
  [2.3.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv2.3.0), formatter.impl
  [2.2.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv2.2.1), text.impl
  [2.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv2.0.0), task-api
  [2.1.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv2.1.0), task-runner
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-runner%2Fv1.0.0), task.impl
  [2.3.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv2.3.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.9.1**](https://github.com/snaekobbi/braille-css/releases/tag/1.9.1))
- **jstyleparser** ([**1.20-p7**](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p7))
- jsass ([4.1.0-p1](https://github.com/snaekobbi/jsass/releases/tag/4.1.0-p1))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.11
=======

Changes
-------
- New option `include-obfl` (https://github.com/daisy/pipeline-mod-braille/issues/90)
- New option `maximum-number-of-sheets`
- Support for XSLT in `stylesheet` option
  (https://github.com/snaekobbi/pipeline-mod-braille/issues/63)
- Improved support for numbering with `symbols()` function
  (https://github.com/snaekobbi/pipeline-mod-braille/issues/15)
- Support for colspan and rowspan on data cells of tables that are layed out as lists
- Support for `page-start-except-last` and `spread-start-except-last` keywords in `string()`
  function
- Parameter `skip-margin-top-of-page` (https://github.com/daisy/pipeline-mod-braille/issues/97)
- Bugfixes (https://github.com/braillespecs/obfl/issues/31,
  https://github.com/joeha480/dotify/issues/134, https://github.com/joeha480/dotify/pull/189,
  https://github.com/joeha480/dotify/issues/194, ...)

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- **dotify** (**api** [**2.5.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv2.5.0), common
  [2.0.2](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv2.0.2), hyphenator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv2.0.1), **translator.impl**
  [**2.3.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv2.3.0), **formatter.impl**
  [**2.2.1**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv2.2.1), **text.impl**
  [**2.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv2.0.0), task-api
  [2.1.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv2.1.0), task-runner
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-runner%2Fv1.0.0), **task.impl**
  [**2.3.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv2.3.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.9.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.9.0))
- **jstyleparser** ([**1.20-p6**](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p6))
- jsass ([4.1.0-p1](https://github.com/snaekobbi/jsass/releases/tag/))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.10
=======

Changes
-------
- New epub3-to-pef script (https://github.com/snaekobbi/pipeline-mod-braille/issues/43,
  https://github.com/daisy/pipeline-mod-braille/pull/79)
- Support for SASS style sheets (https://github.com/daisy/pipeline-mod-braille/pull/78)
- New options `duplex`, `page-width`, `page-height`, `levels-in-footer`, `hyphenation`,
  `line-spacing`, `capital-letters`, `include-captions`, `include-images`, `include-line-groups`,
  `include-production-notes`, `show-braille-page-numbers`, `show-print-page-numbers` and
  `force-braille-page-break` (https://github.com/snaekobbi/pipeline-mod-braille/issues/27)
- Improved support for laying out tables as lists
  - `::list-header` pseudo-element
  - Support pseudo-elements such as `::before` and pseudo-classes such as `:first-child` on
    `::table-by()` and `::list-item` pseudo-elements
  - Improved algorithm for finding headers
- Support for footnotes and endnotes (https://github.com/snaekobbi/pipeline-mod-braille/pull/4,
  https://github.com/snaekobbi/pipeline-mod-braille/issues/9,
  https://github.com/snaekobbi/pipeline-mod-braille/issues/12)
  - `@footnotes` page area
  - `max-height` and `-obfl-fallback-flow` properties
  - `::footnote-call` and `::alternate` pseudo-elements
    (https://github.com/snaekobbi/braille-css/issues/12)
  - `target-content()` function
  - `volume` argument for `flow()` function
- Support for matrix tables (https://github.com/snaekobbi/pipeline-mod-braille/issues/14)
  - `display:table` property
  - `-obfl-table-col-spacing`, `-obfl-table-row-spacing`, `-obfl-preferred-empty-space` and
    `render-table-by:column` properties
- Support for `page` property inside `@begin` and `@end` rules
- Support for `xml-stylesheet` processing instruction
  (https://github.com/snaekobbi/pipeline-mod-braille/issues/53)
- Support for `:not()` and `:has()` pseudo-classes
  (https://github.com/snaekobbi/braille-css/issues/8,
  https://github.com/snaekobbi/braille-css/issues/14)
- Support for `xml:space="preserve"` in default CSS
  (https://github.com/daisy/pipeline-mod-braille/issues/53)
- Support for rowgap in PEF preview (https://github.com/daisy/pipeline-mod-braille/issues/52)
- Bugfixes (https://github.com/daisy/pipeline-mod-braille/issues/73, ...)

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- **dotify** (**api** [**2.4.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv2.4.0), **common**
  [**2.0.2**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv2.0.2), hyphenator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv2.0.1), **translator.impl**
  [**2.1.1**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv2.1.1), **formatter.impl**
  [**2.1.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv2.1.0), text.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv1.0.0), **task-api**
  [**2.1.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv2.1.0), **task-runner**
  [**1.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-runner%2Fv1.0.0), **task.impl**
  [**2.1.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv2.1.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.8.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.8.0))
- jstyleparser ([1.20-p5](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p5))
- **jsass** ([**4.1.0-p1**](https://github.com/snaekobbi/jsass/releases/tag/4.1.0-p1))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.9
======

Changes
-------
- New `toc-depth` option for generating table of contents
- Support for rendering table of contents at the beginning of volumes
  - `display:-obfl-toc` value
  - `-obfl-toc-range` property
  - `::-obfl-on-toc-start`, `::-obfl-on-volume-start`, `::-obfl-on-volume-end` and
    `::-obfl-on-toc-end` pseudo-elements
- Advanced support for generated content
  - stacked pseudo-elements like `::before::before`
  - `::duplicate` pseudo-element
  - `-obfl-evaluate()` function
- Support for laying out tables as lists
  - `render-table-by` and `table-header-policy` properties
  - `::table-by()` and `::list-item` pseudo-elements
- Bugfixes

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- dotify (api [2.1.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv2.1.0), common
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv2.0.1), hyphenator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv2.0.1), translator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv2.0.1), formatter.impl
  [2.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv2.0.0), text.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv1.0.0), task-api
  [2.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv2.0.0), task.impl
  [2.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv2.0.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.7.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.7.0))
- **jstyleparser** ([**1.20-p5**](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p5))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.8
======

Changes
-------
- New `ascii-table` option (https://github.com/snaekobbi/pipeline-mod-braille/issues/56,
  https://github.com/daisy/pipeline-mod-braille/pull/56)
- Support for marks in left or right margin (https://github.com/joeha480/dotify/issues/145)
  - `@left` and `@right` page margins
  - `-obfl-marker` and `-obfl-marker-indicator()`
- Support for `letter-spacing` and `word-spacing`
  (https://github.com/snaekobbi/pipeline-mod-braille/issues/24)
- Initial support for volumes (https://github.com/snaekobbi/pipeline-mod-braille/issues/13,
  https://github.com/daisy/pipeline-mod-braille/pull/61)
  - `@volume`, `@volume:first`, `@volume:last` and `@volume:nth()` rules
  - `min-length` and `max-length` properties
  - `@begin` and `@end` volume areas
  - `flow` and `flow()`
- Fixes in `string()` and `string-set` (https://github.com/daisy/pipeline-mod-braille/issues/64,
  https://github.com/daisy/pipeline-mod-braille/issues/65)
- Fixes in logging (https://github.com/daisy/pipeline-assembly/issues/87)
- Major revision of translator API

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- **dotify** (**api** [**2.1.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv2.1.0), common
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv2.0.1), hyphenator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv2.0.1), translator.impl
  [2.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv2.0.1), **formatter.impl**
  [**2.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv2.0.0), text.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv1.0.0), task-api
  [2.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv2.0.0), task.impl
  [2.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv2.0.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.6.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.6.0))
- **jstyleparser** ([**1.20-p4**](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p4))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.7
======

Changes
-------
- Support for hyphenation in Dotify translator
  (https://github.com/daisy/pipeline-mod-braille/issues/44)
- Fixes in `page-break-before` and `page-break-after`
- Support for `orphans` and `widows`
- Support for print page number ranges (https://github.com/snaekobbi/pipeline-mod-braille/issues/31,
  https://github.com/joeha480/obfl/issues/24)
- Support `text-transform` in headers and footers

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- **dotify** (**api** [**2.0.1**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv2.0.1), **common**
  [**2.0.1**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv2.0.1), **hyphenator.impl**
  [**2.0.1**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv2.0.1), **translator.impl**
  [**2.0.1**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv2.0.1), **formatter.impl**
  [**2.0.0-alpha**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv2.0.0-alpha), text.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv1.0.0), **task-api**
  [**2.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv2.0.0), **task.impl**
  [**2.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv2.0.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- braille-css ([1.4.0](https://github.com/snaekobbi/braille-css/releases/tag/1.4.0))
- jstyleparser ([1.20-p3](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p3))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.6
======

Changes
-------
- Support for multi-line headers and footers
- Support for `page-break-before:right`, `page-break-after:right`, `page-break-before:avoid` and
  `page-break-after:always`
- Support for `string-set` and `counter-set`
- Support for translation while formatting
- Support for qualified names in CSS attribute selectors
- Use of `(formatter:dotify)` by default
- Bug fixes in `text-indent` and `text-align`
  (https://github.com/daisy/pipeline-mod-braille/issues/54,
  https://github.com/daisy/pipeline-mod-braille/issues/55)
- Fixes in white space handling

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- **dotify** (**api** [**1.4.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv1.4.0), common
  [1.2.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv1.2.0), hyphenator.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv1.0.0), **translator.impl**
  [**1.2.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv1.2.0), **formatter.impl**
  [**1.2.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv1.2.0), text.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv1.0.0), task-api
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv1.0.0), **task.impl**
  [**1.0.1**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv1.0.1))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.4.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.4.0))
- **jstyleparser** ([**1.20-p3**](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p3))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.5
======

Changes
-------
- Integration of Dotify's TaskSystem (https://github.com/daisy/pipeline-mod-braille/pull/39)
- Support for row spacing (https://github.com/snaekobbi/pipeline-mod-braille/issues/26,
  https://github.com/snaekobbi/braille-css/issues/5)
- Correct handling of empty blocks (https://github.com/daisy/pipeline-mod-braille/issues/49)

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))  
- **dotify** (api [1.2.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv1.2.0), **common**
  [**1.2.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv1.2.0), hyphenator.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv1.0.0), translator.impl
  [1.1.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv1.1.0), **formatter.impl**
  [**1.1.3**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv1.1.3), **text.impl**
  [**1.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.text.impl%2Fv1.0.0), **task-api**
  [**1.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task-api%2Fv1.0.0), **task.impl**
  [**1.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.task.impl%2Fv1.0.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.3.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.3.0))
- jstyleparser ([1.20-p2](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p2))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.4
======

Changes
-------
- New `stylesheet` option (https://github.com/daisy/pipeline-mod-braille/issues/46) replaces
  `default-stylesheet` option (https://github.com/daisy/pipeline-mod-braille/issues/34)
- Improvements to default style sheets (https://github.com/daisy/pipeline-mod-braille/issues/40)
- Support for more border patterns (https://github.com/daisy/pipeline-mod-braille/issues/45)
- Bug fixes in margins (https://github.com/daisy/pipeline-mod-braille/pull/42) and line breaking
  (https://github.com/daisy/pipeline-mod-braille/pull/43)

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- **dotify** (**api** [**1.2.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv1.2.0), common
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv1.0.0), hyphenator.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv1.0.0), **translator.impl**
  [**1.1.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv1.1.0), formatter.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv1.0.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- braille-css ([1.2.0](https://github.com/snaekobbi/braille-css/releases/tag/1.2.0))
- jstyleparser ([1.20-p2](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p2))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.3
======

Changes
-------
- Bug fixes (https://github.com/daisy/pipeline-mod-braille/issues/35,
  https://github.com/daisy/pipeline-mod-braille/issues/33)

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- dotify (api [1.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv1.0.1), common
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv1.0.0), hyphenator.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv1.0.0), translator.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv1.0.0), formatter.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv1.0.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.2.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.2.0))
- jstyleparser ([1.20-p2](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p2))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.2
======

Changes
-------
- Correct handling of white space (https://github.com/snaekobbi/pipeline-mod-braille/issues/52)
- Support for vertical positioning (https://github.com/snaekobbi/pipeline-mod-braille/issues/28,
  https://github.com/snaekobbi/braille-css/issues/2)
- Support for namespaces in CSS (https://github.com/snaekobbi/pipeline-mod-braille/issues/11)
- Fixed bug in system startup (https://github.com/snaekobbi/system/issues/2)

Components
----------
- liblouis ([2.6.3](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.4.0](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- dotify (api [1.0.1](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv1.0.1), common
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv1.0.0), hyphenator.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv1.0.0), translator.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv1.0.0), formatter.impl
  [1.0.0](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv1.0.0))
- brailleutils (api
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), impl
  [2.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), pef-tools
  [1.0.0](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.1.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.1.0))
- **jstyleparser** ([**1.20-p2**](https://github.com/snaekobbi/jStyleParser/releases/tag/jStyleParser-1.20-p2))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9.1
======

Changes
-------
- HTML to PEF conversion script
- Direct DTBook to PEF conversion script (not through ZedAI)
  (https://github.com/snaekobbi/pipeline-mod-braille/issues/45)
- `transform` option for transformer queries
- Dotify based formatter (https://github.com/daisy/pipeline-mod-braille/pull/11,
  https://github.com/snaekobbi/pipeline-mod-braille/pull/2, https://github.com/snaekobbi/pipeline-mod-braille/issues/32,
  https://github.com/snaekobbi/pipeline-mod-braille/pull/33)
- Support for `text-transform` property (https://github.com/daisy/pipeline-mod-braille/pull/23)
- Better logging (https://github.com/daisy/pipeline-mod-braille/issues/19)
- Framework redesign (https://github.com/daisy/pipeline-mod-braille/pull/15,
  https://github.com/snaekobbi/pipeline-mod-braille/pull/1)
- Other internal changes (https://github.com/daisy/pipeline-mod-braille/issues/10,
  https://github.com/daisy/pipeline-mod-braille/pull/25, https://github.com/daisy/pipeline-mod-braille/pull/29,
  https://github.com/snaekobbi/pipeline-mod-braille/pull/3, https://github.com/snaekobbi/pipeline-mod-braille/pull/35,
  https://github.com/snaekobbi/pipeline-mod-braille/issues/44)

Components
----------
- **liblouis** ([**2.6.3**](https://github.com/liblouis/liblouis/releases/tag/v2.6.3)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), **liblouis-java**
  ([**1.4.0**](https://github.com/liblouis/liblouis-java/releases/tag/1.4.0))
- **dotify** (**api** [**1.0.1**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.api%2Fv1.0.1), **common**
  [**1.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.common%2Fv1.0.0), **hyphenator.impl**
  [**1.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.hyphenator.impl%2Fv1.0.0), **translator.impl**
  [**1.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.translator.impl%2Fv1.0.0), **formatter.impl**
  [**1.0.0**](https://github.com/joeha480/dotify/releases/tag/releases%2Fdotify.formatter.impl%2Fv1.0.0))
- **brailleutils** (**api**
  [**2.0.0**](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.api%2Fv2.0.0), **impl**
  [**2.0.0**](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.impl%2Fv2.0.0), **pef-tools**
  [**1.0.0**](https://github.com/brailleapps/brailleutils/releases/tag/releases%2Fbraille-utils.pef-tools%2Fv1.0.0))
- **braille-css** ([**1.0.0**](https://github.com/snaekobbi/braille-css/releases/tag/1.0.0))
- **jstyleparser** ([**1.20-p1**](https://github.com/snaekobbi/jStyleParser/releases/tag/jstyleparser-1.20-p1))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))

v1.9
====

Components
----------
- liblouis ([2.5.4](https://github.com/liblouis/liblouis/releases/tag/liblouis_2_5_4)), liblouisutdml
  ([2.5.0](https://github.com/liblouis/liblouisutdml/releases/tag/v2.5.0)), liblouis-java
  ([1.2.0](https://github.com/liblouis/liblouis-java/releases/tag/1.2.0))
- brailleutils (core [1.2.0](https://github.com/daisy/osgi-libs/releases/tag/brailleutils-core-1.2.0), catalog
  [1.2.0](https://github.com/daisy/osgi-libs/releases/tag/brailleutils-catalog-1.2.0))
- jstyleparser ([1.13](https://github.com/daisy/osgi-libs/releases/tag/jstyleparser-1.13.0-p1))
- libhyphen ([2.6.0](https://github.com/snaekobbi/libhyphen-nar/releases/tag/2.6.0)), jhyphen
  ([0.1.5](https://github.com/daisy/jhyphen/releases/tag/v0.1.5))
- texhyphj ([1.2](https://github.com/joeha480/texhyphj/releases/tag/release-1.2))
