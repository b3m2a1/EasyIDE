<a id="bugtracker" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

# BugTracker

  [![license](http://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This is a bug tracking package for Mathematica, currently in beta.

---

<a id="installation" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

# Installation

The easiest way to install this package is using a paclet server installation:

```mathematica
PacletInstall[
  "BugTracker",
  "Site"->
    "http://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer"
  ]
```

If you've already installed it you can update using:

```mathematica
PacletUpdate[
  "BTools",
  "Site"->
    "http://www.wolframcloud.com/objects/b3m2a1.paclets/PacletServer"
  ]
```

Alternately you can download this repo as a ZIP file and put extract it in  ```$UserBaseDirectory/Applications```

---

<a id="usage" style="width:0;height:0;margin:0;padding:0;">&zwnj;</a>

# Usage

This bug tracker currently only supports converting to-and-from a formatted bug notebook to a list of bugs / bug dataset.

To start, create a new bug notebook:

```mathematica
<<BugTracker` 
 NewBugsNotebook[$TemporaryDirectory]
```

    (*Out:*)
    
![readme-7075886137484081466](project/img/readme-7075886137484081466.png)

![readme-5009766874165003355](project/img/readme-5009766874165003355.png)

Then click the  ```"Add Bug"```  button to create a popup window to add info on the new bug:

![readme-445044655558372174](project/img/readme-445044655558372174.png)

After adding parameters a new entry will be added at the bottom of the notebook:

![readme-5919741057952872355](project/img/readme-5919741057952872355.png)

You can see the parameters in there. The empty square is a check-box to mark resolved bugs. Here's an example of this in action:

![readme-3342069607634808987](project/img/readme-3342069607634808987.png)

We can convert these bugs to a list of  ```BugObjects```  or a  [```Dataset```](https://reference.wolfram.com/language/ref/Dataset.html) . We can either use the buttons in the docked menu to export to a file or the buttons below the search interface to write into the notebook. Here's what appears if we write the bug list to the notebook:

![readme-4431207052699221141](project/img/readme-4431207052699221141.png)

More work to make using these  ```BugObjects```  more convenient is in the pipeline and suggestions are welcome.