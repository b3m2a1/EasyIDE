<a id="ems" class="Section" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

# Ems

 [![license](http://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Ems is a website builder initially developed as a Mathematica port of the pelican static site builder

---

<a id="installation" class="Section" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

# Installation

The easiest way to install Ems is using a paclet server installation:

```mathematica
PacletInstall[
  "Ems",
  "Site"->
    "http://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer"
  ]
```

If you've already installed it you can update using:

```mathematica
PacletUpdate[
  "Ems",
  "Site"->
    "http://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer"
  ]
```

Alternately you can download this repo as a ZIP file and put extract it in  ```$UserBaseDirectory/Applications```

---

<a id="screenshots" class="Section" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

# Screenshots

Here are a few screenshots of example sites that were built with Ems.

<a id="blog" class="Subsection" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

## Blog

![readme-1662041931382429234](project/img/readme-1662041931382429234.png)

<a id="portfolio" class="Subsection" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

## Portfolio

![readme-649061900144457109](project/img/readme-649061900144457109.png)

<a id="singlepagescroll" class="Subsection" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

## Single-Page Scroll

![readme-4848706735533894430](project/img/readme-4848706735533894430.png)

Most themes are based on  [Bootstrap](https://getbootstrap.com/) and are very customizable

---

Examples and usages can be found on the  [Wiki](https://github.com/b3m2a1/Ems/wiki)