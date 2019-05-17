(* ::Package:: *)

BeginPackage["`FileMenu`"]
openFile;
newFile;
EndPackage[]


Begin["Private`"];


getDir[]:=
  Replace[IDEPath[$CurrentIDENotebook], Except[_String]->$HomeDirectory];


openFile[f_String]:=
  If[FileExistsQ[f],
    IDEOpen[$CurrentIDENotebook, f]
    ];
openFile[]:=
  openFile@
    SystemDialogInput["FileOpen", getDir[]]


newFile[]:=
  Module[{newFileName=SystemDialogInput["FileSave", getDir[]]},
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
