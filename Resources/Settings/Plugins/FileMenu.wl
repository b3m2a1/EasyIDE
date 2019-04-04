(* ::Package:: *)

BeginPackage["`FileMenu`"]
openFile;
newFile;
EndPackage[]


Begin["Private`"];


openFile[f_String]:=
  If[FileExistsQ[f],
    IDEOpen[$CurrentIDENotebook, f]
    ];
openFile[]:=
  openFile@SystemDialogInput["FileOpen", IDEPath[$CurrentIDENotebook]]


newFile[]:=
  Module[{newFileName=SystemDialogInput["FileSave", IDEPath[$CurrentIDENotebook]]},
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


<|
  "Type"->"Menu",
  "Name"->"File",
  "Menu"->{
    "New":>newFile[],
    "Open":>openFile[],
    "Scratch":>IDEOpen[$CurrentIDENotebook, Notebook[{}]]
    }
 |>
