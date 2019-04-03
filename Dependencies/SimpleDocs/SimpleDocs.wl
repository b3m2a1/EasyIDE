(* ::Subsection::Closed:: *)
(*Temp Loading Flag Code*)


Temp`PackageScope`SimpleDocsLoading`Private`$PackageLoadData=
  If[#===None, <||>, Replace[Quiet@Get@#, Except[_?OptionQ]-><||>]]&@
    Append[
      FileNames[
        "LoadInfo."~~"m"|"wl",
        FileNameJoin@{DirectoryName@$InputFileName, "Config"}
        ],
      None
      ][[1]];
Temp`PackageScope`SimpleDocsLoading`Private`$PackageLoadMode=
  Lookup[Temp`PackageScope`SimpleDocsLoading`Private`$PackageLoadData, "Mode", "Primary"];
Temp`PackageScope`SimpleDocsLoading`Private`$DependencyLoad=
  TrueQ[Temp`PackageScope`SimpleDocsLoading`Private`$PackageLoadMode==="Dependency"];


(* ::Subsection:: *)
(*Main*)


If[Temp`PackageScope`SimpleDocsLoading`Private`$DependencyLoad,
  If[!TrueQ[Evaluate[Symbol["`SimpleDocs`PackageScope`Private`$LoadCompleted"]]],
    Get@FileNameJoin@{DirectoryName@$InputFileName, "SimpleDocsLoader.wl"}
    ],
  If[!TrueQ[Evaluate[Symbol["SimpleDocs`PackageScope`Private`$LoadCompleted"]]],
    <<SimpleDocs`SimpleDocsLoader`,
   BeginPackage["SimpleDocs`"];
   EndPackage[];
   ]
  ]