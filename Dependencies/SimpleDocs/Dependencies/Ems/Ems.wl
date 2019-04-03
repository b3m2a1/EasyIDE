(* ::Subsection::Closed:: *)
(*Temp Loading Flag Code*)


Temp`PackageScope`EmsLoading`Private`$PackageLoadData=
  If[#===None, <||>, Replace[Quiet@Get@#, Except[_?OptionQ]-><||>]]&@
    Append[
      FileNames[
        "LoadInfo."~~"m"|"wl",
        FileNameJoin@{DirectoryName@$InputFileName, "Config"}
        ],
      None
      ][[1]];
Temp`PackageScope`EmsLoading`Private`$PackageLoadMode=
  Lookup[Temp`PackageScope`EmsLoading`Private`$PackageLoadData, "Mode", "Primary"];
Temp`PackageScope`EmsLoading`Private`$DependencyLoad=
  TrueQ[Temp`PackageScope`EmsLoading`Private`$PackageLoadMode==="Dependency"];


(* ::Subsection:: *)
(*Main*)


If[Temp`PackageScope`EmsLoading`Private`$DependencyLoad,
  If[!TrueQ[Evaluate[Symbol["`Ems`PackageScope`Private`$LoadCompleted"]]],
    Get@FileNameJoin@{DirectoryName@$InputFileName, "EmsLoader.wl"}
    ],
  If[!TrueQ[Evaluate[Symbol["Ems`PackageScope`Private`$LoadCompleted"]]],
    <<Ems`EmsLoader`,
   BeginPackage["Ems`"];
   EndPackage[];
   ]
  ]