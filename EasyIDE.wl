(* ::Subsection::Closed:: *)
(*Temp Loading Flag Code*)


Temp`PackageScope`EasyIDELoading`Private`$PackageLoadData=
  If[#===None, <||>, Replace[Quiet@Get@#, Except[_?OptionQ]-><||>]]&@
    Append[
      FileNames[
        "LoadInfo."~~"m"|"wl",
        FileNameJoin@{DirectoryName@$InputFileName, "Config"}
        ],
      None
      ][[1]];
Temp`PackageScope`EasyIDELoading`Private`$PackageLoadMode=
  Lookup[Temp`PackageScope`EasyIDELoading`Private`$PackageLoadData, "Mode", "Primary"];
Temp`PackageScope`EasyIDELoading`Private`$DependencyLoad=
  TrueQ[Temp`PackageScope`EasyIDELoading`Private`$PackageLoadMode==="Dependency"];


(* ::Subsection:: *)
(*Main*)


If[Temp`PackageScope`EasyIDELoading`Private`$DependencyLoad,
  If[!TrueQ[Evaluate[Symbol["`EasyIDE`PackageScope`Private`$LoadCompleted"]]],
    Get@FileNameJoin@{DirectoryName@$InputFileName, "EasyIDELoader.wl"}
    ],
  If[!TrueQ[Evaluate[Symbol["EasyIDE`PackageScope`Private`$LoadCompleted"]]],
    <<EasyIDE`EasyIDELoader`,
   BeginPackage["EasyIDE`"];
   EndPackage[];
   ]
  ]