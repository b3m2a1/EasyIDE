(* ::Subsection::Closed:: *)
(*Temp Loading Flag Code*)


Temp`PackageScope`InterfaceObjectsLoading`Private`$PackageLoadData=
  If[#===None, <||>, Replace[Quiet@Get@#, Except[_?OptionQ]-><||>]]&@
    Append[
      FileNames[
        "LoadInfo."~~"m"|"wl",
        FileNameJoin@{DirectoryName@$InputFileName, "Config"}
        ],
      None
      ][[1]];
Temp`PackageScope`InterfaceObjectsLoading`Private`$PackageLoadMode=
  Lookup[Temp`PackageScope`InterfaceObjectsLoading`Private`$PackageLoadData, "Mode", "Primary"];
Temp`PackageScope`InterfaceObjectsLoading`Private`$DependencyLoad=
  TrueQ[Temp`PackageScope`InterfaceObjectsLoading`Private`$PackageLoadMode==="Dependency"];


(* ::Subsection:: *)
(*Main*)


If[Temp`PackageScope`InterfaceObjectsLoading`Private`$DependencyLoad,
  If[!TrueQ[Evaluate[Symbol["`InterfaceObjects`PackageScope`Private`$LoadCompleted"]]],
    Get@FileNameJoin@{DirectoryName@$InputFileName, "InterfaceObjectsLoader.wl"}
    ],
  If[!TrueQ[Evaluate[Symbol["InterfaceObjects`PackageScope`Private`$LoadCompleted"]]],
    <<InterfaceObjects`InterfaceObjectsLoader`,
   BeginPackage["InterfaceObjects`"];
   EndPackage[];
   ]
  ]