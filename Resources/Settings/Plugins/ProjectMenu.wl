(* ::Package:: *)

BeginPackage["`ProjectMenu`"];
setProject;
newProject;
EndPackage[];


Begin["`Private`"];


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
  setProject@SystemDialogInput["Directory", IDEPath[$CurrentIDENotebook]];


newProject[]:=
  Module[{newDir=SystemDialogInput["Directory"]},
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
