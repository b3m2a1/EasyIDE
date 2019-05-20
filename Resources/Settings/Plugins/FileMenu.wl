(* ::Package:: *)

(* ::Section:: *)
(*File Menu*)


BeginPackage["`FileMenu`"]


openFile;
newFile;


EndPackage[]


(* ::Subsection:: *)
(*Private*)


Begin["Private`"];


(* ::Subsubsection::Closed:: *)
(*getDir*)


getDir[]:=
  Replace[IDEPath[$CurrentIDENotebook], Except[_String]->$HomeDirectory];


(* ::Subsubsection:: *)
(*openFile*)


openFile[f_String]:=
  If[FileExistsQ[f],
    IDEOpen[$CurrentIDENotebook, f]
    ];
openFile[]:=
  openFile@
    SystemDialogInput["FileOpen", getDir[]]


(* ::Subsubsection:: *)
(*newFile*)


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


(* ::Subsubsection:: *)
(*End*)


End[]


(* ::Subsection:: *)
(*Exposed*)


<|
  "Type"->"Menu",
  "Name"->"File",
  "Menu"->{
    "New":>newFile[],
    "Open":>openFile[],
    "Scratch":>IDEOpen[$CurrentIDENotebook, Notebook[{}]]
    }
 |>
