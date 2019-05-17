(* ::Package:: *)

(* ::Section:: *)
(*Window Menu*)


(* ::Subsection:: *)
(*Exposed*)


BeginPackage["`WindowMenu`"]
setTheme;
setStylesheet;
addToolbar;
EndPackage[]


(* ::Subsection:: *)
(*Private*)


Begin["`WindowMenu`Private`"];


(* ::Subsubsection:: *)
(*getThemes*)


getThemes[]:=
  FileBaseName/@
    Select[DirectoryQ[#]&&FileBaseName[#]!="FileViewer"&]@
      FileNames[
        "*",
        FEFindFileOnPath[FrontEnd`FileName[{"EasyIDE"}, "Extensions"]]
        ]


(* ::Subsubsection:: *)
(*setTheme*)


setTheme[]:=
  CreateAttachedInputDialog[
    <|
      "Header"->"Set Theme",
      "Fields"->{
        "Choose a theme for the IDE",
        <|
          "Name"->None,
          "ID"->"Theme",
          "Type"->{PopupMenu, Map[#->#&, getThemes[]]}
          |>
        },
      "SubmitAction"->
        Function[
          SetNotebookStyleTheme[$CurrentIDENotebook, #Theme]
          ]
      |>
    ]


(* ::Subsubsection:: *)
(*setStylesheet*)


setStylesheet[]:=
  CreateAttachedInputDialog[
    <|
      "Header"->"Set Stylesheet",
      "Fields"->{
        "Choose a stylesheet for the current file",
        <|
          "Name"->None,
          "ID"->"Stylesheet",
          "Type"->{PopupMenu, FE`Evaluate@FEPrivate`GetPopupList["MenuListStyleDefinitions"]}
          |>
        },
      "SubmitAction"->
        Function[
          SetThemedStylesheet[$CurrentIDENotebook,
            GetThemedStylesheet[#Stylesheet]
            ];
          IDEData[$CurrentIDENotebook, 
            {"Options", StyleDefinitions}
            ]=#Stylesheet
          ]
      |>
    ]


(* ::Subsubsection:: *)
(*getToolbars*)


getToolbars[]:=
  FileBaseName/@FileNames["*.wl",
    FileNames["Toolbars", $IDESettingsPath]
    ]


(* ::Subsubsection:: *)
(*addToolbar*)


addToolbar[]:=
  CreateAttachedInputDialog[
    <|
      "Header"->"Add Toolbar",
      "Fields"->{
        "Choose a toolbar to add",
        <|
          "Name"->None,
          "ID"->"Toolbar",
          "Type"->{PopupMenu, Map[#->#&, getToolbars[]]},
          "Default"->getToolbars[][[1]]
          |>
        },
      "SubmitAction"->
        Function[
          IDEAddToolbar[$CurrentIDENotebook, #Toolbar]
          ]
      |>
    ]


(* ::Subsubsection:: *)
(*End*)


End[]


(* ::Subsection:: *)
(*Menu Spec*)


<|
  "Type"->"Menu",
  "Name"->"Window",
  "Menu"->{
    "Add Toolbar":>addToolbar[],
    "Set Theme":>setTheme[],
    "Set Stylesheet":>setStylesheet[]
    }
 |>
