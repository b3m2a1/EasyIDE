(* ::Package:: *)

BeginPackage["`ProjectMenu`"];
setProject;
newProject;
EndPackage[];


Begin["`Private`"];


getDir[]:=
  Replace[IDEPath[$CurrentIDENotebook], Except[_String]->$HomeDirectory];


setProject[dir_]:=
  If[DirectoryQ[dir],
    With[
      {
        nb=
          Replace[$CurrentIDENotebook, Except[_NotebookObject]:>EvaluationNotebook[]]
        },
      IDEData[nb, {"Project", "Directory"}] = dir
      ]
    ];
setProject[]:=
  setProject@SystemDialogInput["Directory", getDir[]];


newProject[]:=
  Module[{newDir=SystemDialogInput["Directory", getDir[]]},
    If[StringQ@newDir,
      If[DirectoryQ[newDir],
        IDENotebookObject[newDir]
        ];
      ]
    ]


End[]


<|
  "Type"->"Menu",
  "Name"->"Project",
  "Menu"->{
    "New":>newProject[],
    "Set Directory":>setProject[]
    }
 |>
