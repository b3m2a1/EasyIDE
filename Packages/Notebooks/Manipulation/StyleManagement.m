(* ::Package:: *)



GetMainStylesheet::usage="Gets a NotebookObject's stylesheet name";
SetMainStylesheet::usage="Sets a NotebookObject's stylesheet";


AddNotebookStyles::usage="";
RemoveNotebookStyles::usage="";
AddNotebookStylesheet::usage="";
RemoveNotebookStylesheet::usage="";


IDEAddStyles::usage="Adds styles to the IDE notebook";
IDERemoveStyles::usage="Removes styles from the IDE notebook";


IDEGetStylesheet::usage="Gets the IDE notebook stylesheet";
IDESetStylesheet::usage="Sets the IDE notebook stylesheet";


Begin["`Private`"];


(* ::Subsection:: *)
(*Styles*)



(* ::Subsubsection::Closed:: *)
(*GetMainStylesheet*)



GetMainStylesheet[nb_]:=
  Module[
    {
      s=CurrentValue[nb, StyleDefinitions]
      },
    If[Head[s]===Notebook,
      FirstCase[s, Cell[StyleData[StyleDefinitions->f_, ___], ___]:>f, None, \[Infinity]],
      s
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*SetMainStylesheet*)



SetMainStylesheet//Clear
SetMainStylesheet[nb_, f_]:=
  Module[
    {
      s=CurrentValue[nb, StyleDefinitions],
      scell,
      nbo,
      sPath = getCleanStylePath[nb, f]
      },
    If[Head[s]===Notebook,
      nbo = StyleSheetNotebookObject[nb];
      scell = 
        SelectFirst[Cells[nbo], 
          MatchQ[NotebookRead[#], Cell[StyleData[StyleDefinitions->_, ___], ___]]&,
          None
          ];
      If[scell === None,
        SelectionMove[nbo, Before, Notebook];
        NotebookWrite[nbo,
          Cell[StyleData[StyleDefinitions->sPath]]
          ],
        NotebookWrite[
          scell,
          Cell[StyleData[StyleDefinitions->sPath]]
          ]
        ],
      SetOptions[nb, StyleDefinitions->sPath]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*getCleanStylePath*)



getCleanStylePath[nb_, f_]:=
  Replace[f,
    {
      s_String?(StringEndsQ[#, ".nb"]&&!StringStartsQ[#, "-"]&):>
          s,
      s:FrontEnd`FileName[_, 
        _String?(StringEndsQ[#, ".nb"]&&!StringStartsQ[#, "-"]&), 
        ___
        ]:>
        s,
      s_String?(StringEndsQ[".nb"]&&StringStartsQ["-"]):>
        cleanStylesheetName[
          GetMainStylesheetName[nb],
          s
          ],
      fn:FrontEnd`FileName[_, 
            _String?(StringEndsQ[#, ".nb"]&&StringStartsQ[#, "-"]&), 
            ___
            ]:>
        cleanStylesheetName[
          GetMainStylesheetName[nb],
          fn
          ],
      s_String?(!StringEndsQ[#, ".nb"]&):>
        cleanStylesheetName[
          GetMainStylesheetName[nb],
          "-"<>StringTrim[s, "-"]<>".nb"
          ],
      FrontEnd`FileName[p_, s_String?(Not@*StringEndsQ[".nb"]), ___]:>
        cleanStylesheetName[
          GetMainStylesheetName[nb],
          FrontEnd`FileName[p, Evaluate["-"<>StringTrim[s, "-"]<>".nb"]]
          ]
      }
    ]


(* ::Subsubsection::Closed:: *)
(*GetMainStylesheetName*)



GetMainStylesheetName//Clear
GetMainStylesheetName[main:_String|_FrontEnd`FileName]:=
  (* this will definitely need to be robustified... *)
  Replace[main, 
    {
      FrontEnd`FileName[_, fn_, ___]:>
        StringSplit[fn, "."|"-"][[1]],
      s_String:>
        StringSplit[s, "."|"-"][[1]]
      }
    ];
GetMainStylesheetName[nb_NotebookObject]:=
  GetMainStylesheetName[GetMainStylesheet[nb]]


(* ::Subsubsection::Closed:: *)
(*cleanStylesheetName*)



cleanStylesheetName[mainName_, sheet_]:=
  Replace[sheet,
    {
      FrontEnd`FileName[p_, s_String?(StringStartsQ["-"]), r___]:>
        With[{tt=mainName<>s},
          FrontEnd`FileName[p, tt, r]
          ],
      s_String?(StringStartsQ["-"]):>
        With[{mn=mainName<>s}, FrontEnd`FileName[{"EasyIDE", "Extensions"}, mn]],
      None:>
        With[{mn=mainName<>".nb"}, FrontEnd`FileName[{"EasyIDE"}, mn]]
      }
    ]


(* ::Subsubsection::Closed:: *)
(*getStylesheetDefsSection*)



getStylesheetDefsSection[data:{__Cell}, tag_String]:=
  Module[
    {sec},
    sec = 
      Cell[
        tag, 
        "Subsubsubsubsection",
        CellGroupingRules->{"SectionGrouping",200},
        CellTags->{tag}
        ];
    Cell[
      CellGroupData[
        Flatten@{
          sec,
          data
          },
        Closed
        ]
      ]
    ];
getStylesheetDefsSection[
  file:_String|_FrontEnd`FileName, 
  tag:_String|Automatic:Automatic
  ]:=
  Module[
    {
      fileName,
      data,
      sec
      },
    fileName=
      FrontEndExecute@
        FrontEnd`FindFileOnPath[file, "StyleSheetPath"];
    If[StringQ@fileName, 
      data = Cases[Get[fileName][[1]], Cell[_StyleData, ___], \[Infinity]];
      getStylesheetDefsSection[data, 
      Replace[tag, Automatic:>ToString@file]
      ],
      $Failed
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*AddNotebookStyles*)



AddNotebookStyles[nb_, styleData:_Cell, tag_]:=
  Module[
    {
      nbo,
      currDefs,
      defCells
      },
    currDefs = CurrentValue[nb, StyleDefinitions];
    If[Head[currDefs] =!= Notebook,
      CurrentValue[nb, StyleDefinitions]=
        Notebook[
          {
            Cell[StyleData[StyleDefinitions->currDefs]],
            styleData
            },
          StyleDefinitions->"PrivateStylesheetFormatting.nb"
          ],
      nbo = StyleSheetNotebookObject[nb];
      defCells = Cells[nbo, CellTags->tag];
      If[Length@defCells === 0,
        SelectionMove[nbo, After, Notebook];
        NotebookWrite[nbo, styleData],
        SelectionMove[defCells[[-1]], After, Cell];
        NotebookWrite[nbo, styleData]
        ]
      ]
    ]
AddNotebookStyles[nb_, styleData:{__Cell}, tag_]:=
  AddNotebookStyles[nb, getStylesheetDefsSection[styleData, tag], tag];


(* ::Subsubsection::Closed:: *)
(*AddNotebookStylesheet*)



AddNotebookStylesheet//Clear
AddNotebookStylesheet[nb_, fileName_, tag:_String|Automatic:Automatic]:=
  Module[
    {
      file = If[!StringQ[fileName], ToFileName[fileName], fileName],
      styles
      },
    styles = getStylesheetDefsSection[file, tag];
    If[styles=!=$Failed,
      AddNotebookStyles[nb, styles, 
        Replace[tag, Automatic:>ToString@file]
        ]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*RemoveNotebookStyles*)



RemoveNotebookStyles[nb_, tag_]:=
  Module[
    {
      nbo,
      defCells
      },
    nbo = StyleSheetNotebookObject[nb];
    defCells = Cells[nbo, CellTags->tag];
    FrontEndExecute@
      Flatten@Map[
        Function[
          {
            FrontEnd`SelectionMove[#, All, CellGroup],
            FrontEnd`SetOptions[
              NotebookSelection[nbo], 
              {
                Deletable->True,
                Editable->True
                }
              ],
            FrontEnd`NotebookDelete[
              nbo
              ]
          }
          ],
        defCells
        ]
    ]


(* ::Subsubsection::Closed:: *)
(*RemoveNotebookStylesheet*)



RemoveNotebookStylesheet//Clear
RemoveNotebookStylesheet[nb_, fileName_, tag:_String|Automatic:Automatic]:=
  RemoveNotebookStyles[
    nb,
    Replace[tag,
      Automatic:>If[!StringQ[fileName], ToFileName[fileName], fileName]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*prepStyleDefs*)



prepStyleDefs[rules:{(_String->_)..}]:=
  KeyValueMap[
    Cell[
      StyleData[#],
      Sequence@@Flatten@{#2}
      ]&,
    Association@rules
    ]


(* ::Subsection:: *)
(*IDE Stuff*)



(* ::Subsubsection::Closed:: *)
(*IDEAddStyles*)



IDEAddStyles//Clear


IDEAddStyles[nb_NotebookObject, styles:{__Cell}, tag_String]:=
  AddNotebookStyles[nb, styles, tag];
IDEAddStyles[ide_IDENotebookObject, styles:{__Cell}, tag_String]:=
  IDEAddStyles[ide["Notebook"], styles, tag];


IDEAddStyles[nb_NotebookObject, styles:_String|_FrontEnd`FileName]:=
  AddNotebookStylesheet[nb, styles];
IDEAddStyles[ide_IDENotebookObject, styles:_String|_FrontEnd`FileName]:=
  AddNotebookStylesheet[ide["Notebook"], styles];


IDEAddStyles[
  nb_NotebookObject, 
  rules:({(_String->_)..})|(_String->_)|(_Association), 
  tag_String
  ]:=
  AddNotebookStyles[nb, prepStyleDefs[Normal@Association[rules]], tag];
IDEAddStyles[
  ide_IDENotebookObject, 
  rules:{(_String->_)..}|(_String->_)|_Association, 
  tag_String
  ]:=IDEAddStyles[ide["Notebook"], rules, tag]


(* ::Subsubsection::Closed:: *)
(*IDERemoveStyles*)



IDERemoveStyles//Clear


IDERemoveStyles[nb_NotebookObject, tag_String]:=
  If[StringEndsQ[tag, ".nb"],
    RemoveNotebookStylesheet[nb, tag];,
    RemoveNotebookStyles[nb, tag];
    ];
IDERemoveStyles[nb_NotebookObject, tag_FrontEnd`FileName]:=
  RemoveNotebookStylesheet[nb, tag];
IDERemoveStyles[ide_IDENotebookObject, tag:_FrontEnd`FileName|_String]:=
  IDERemoveStyles[ide["Notebook"], tag]


(* ::Subsubsection::Closed:: *)
(*IDEGetStylesheet*)



IDEGetStylesheet[nb_NotebookObject]:=
  GetMainStylesheet[nb];
IDEGetStylesheet[ide_IDENotebookObject]:=
  IDEGetStylesheet[ide["Notebook"]];


(* ::Subsubsection::Closed:: *)
(*IDESetStylesheet*)



IDESetStylesheet[nb_NotebookObject, file:_String|_FrontEnd`FileName]:=
  SetMainStylesheet[nb, file];
IDESetStylesheet[ide_IDENotebookObject, file:_String|_FrontEnd`FileName]:=
  IDESetStylesheet[ide["Notebook"], file];


End[];



