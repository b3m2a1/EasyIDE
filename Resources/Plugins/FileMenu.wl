(* ::Package:: *)

`FileMenu`Private`cpath = $ContextPath;


BeginPackage["`FileMenu`"];


openFile
newFile


Begin["`Private`"];


$ContextPath = DeleteDuplicates@Join[$ContextPath, cpath];


openFile[f_String]:=
  If[FileExistsQ[f],
    IDEOpen[EvaluationNotebook[], f]
    ];
openFile[]:=
  openFile@SystemDialogInput["FileOpen"]


newFile[]:=
  Module[{newFileName=SystemDialogInput["FileSave"]},
    If[StringQ@newFileName,
      If[!FileExistsQ[newFileName],
        If[FileExtension[newFileName]==="nb",
          Export[newFileName, Notebook[{}]],
          Export[newFileName, "", "Text"]
          ]
        ];
      openFile[newFileName]
      ]
    ]


End[]


EndPackage[]


<|
  "Type"->"Menu",
  "Name"->"File",
  "Menu"->{
    "New":>newFile[],
    "Open":>openFile[]
    }
 |>
