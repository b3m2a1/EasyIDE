<a id="simpledocs" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

# SimpleDocs

 [![license](http://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

SimpleDocs is a paclet designed to make simplified Mathematica documentation that will always be cross version compatible and can easily be converted to Markdown to be shared on the web.

---

<a id="installation" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

# Installation

The easiest way to install Ems is using a paclet server installation:

```mathematica
PacletInstall[
  "SimpleDocs",
  "Site"->
    "http://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer"
  ]
```

If you've already installed it you can update using:

```mathematica
PacletUpdate[
  "SimpleDocs",
  "Site"->
    "http://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer"
  ]
```

Alternately you can download this repo as a ZIP file and put extract it in  ```$UserBaseDirectory/Applications```