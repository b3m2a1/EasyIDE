(* ::Subsection::Closed:: *)
(*Temp Loading Flag Code*)


Temp`PackageScope`BugTrackerLoading`Private`$PackageLoadData=
  If[#===None, <||>, Replace[Quiet@Get@#, Except[_?OptionQ]-><||>]]&@
    Append[
      FileNames[
        "LoadInfo."~~"m"|"wl",
        FileNameJoin@{DirectoryName@$InputFileName, "Config"}
        ],
      None
      ][[1]];
Temp`PackageScope`BugTrackerLoading`Private`$PackageLoadMode=
  Lookup[Temp`PackageScope`BugTrackerLoading`Private`$PackageLoadData, "Mode", "Primary"];
Temp`PackageScope`BugTrackerLoading`Private`$DependencyLoad=
  TrueQ[Temp`PackageScope`BugTrackerLoading`Private`$PackageLoadMode==="Dependency"];


(* ::Subsection:: *)
(*Main*)


If[Temp`PackageScope`BugTrackerLoading`Private`$DependencyLoad,
  If[!TrueQ[Evaluate[Symbol["`BugTracker`PackageScope`Private`$LoadCompleted"]]],
    Get@FileNameJoin@{DirectoryName@$InputFileName, "BugTrackerLoader.wl"}
    ],
  If[!TrueQ[Evaluate[Symbol["BugTracker`PackageScope`Private`$LoadCompleted"]]],
    <<BugTracker`BugTrackerLoader`
    ]
  ]