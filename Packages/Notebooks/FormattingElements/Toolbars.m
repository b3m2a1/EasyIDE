(* ::Package:: *)



CreateToolbarsBox::usage="Creates a box to display the notebook's toolbars";


AddNotebookToolbar::usage="Adds a toolbar to a Notebook";
RemoveNotebookToolbar::usage="Removes a toolbar from a Notebook";


IDEAddToolbar::usage="Adds a toolbar to the IDE";
IDERemoveToolbar::usage="Removes a toolbar from the IDE";


Begin["`Private`"];


(* ::Subsection:: *)
(*Toolbars*)



(* ::Subsubsection::Closed:: *)
(*refreshToolbars*)



refreshToolbars[nb_]:=
  Replace[
    IDEData[nb, PrivateKey["ToolbarRefreshHandle"]],
    Hold[var_]:>(var=RandomReal[])
    ]


(* ::Subsubsection::Closed:: *)
(*reopenFileToolbarBox*)



reopenFileToolbarBox[ft_]:=
  GridBox[
    {
      {
        PaneBox["", ImageSize->{0, 15}],
        ButtonBox["", BaseStyle->"ToolbarShowButton", ButtonData->ft]
        }
      },
     BaseStyle->"ToolbarCell"
     ]


(* ::Subsubsection::Closed:: *)
(*makeIDEToolbarGrid*)



makeIDEToolbarGrid[nb_, tags_]:=
  Module[
    {
      ft = IDEData[nb, "FileToolbar"],
      data=Lookup[IDEData[nb, {"Toolbars", "Cells"}], DeleteDuplicates@tags]
      },
    If[!MemberQ[tags, ft]&&StringQ[ft],
      data = Prepend[data, reopenFileToolbarBox[ft]]
      ];
    If[Length@data===0,
      None,
      GridBox[
        Thread[{data}],
        BaseStyle->"Toolbars"
        ]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*CreateToolbarsBox*)



CreateToolbarsBox[toolbarRefresh_]:=
  With[
    {
      h=
        FrontEnd`CurrentValue[
          FrontEnd`EvaluationNotebook[], 
          {TaggingRules, "EasyIDE", "Toolbars", "Column"},
          None
          ]
     },
    DynamicBox[
      FEPrivate`If[
        FEPrivate`SameQ[FEPrivate`Head[h], GridBox],
        h,
        PaneBox["", ImageSize->{0, 10}]
        ]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*RemoveNotebookToolbar*)



RemoveNotebookToolbar[nb_, tag_]:=
  Module[{cell, tools, tags},
    WithNotebookPaused[
      nb,
      tags = IDEData[nb, {"Toolbars", "Tags"}, {}];
      If[!ListQ@tags, tags = {}];
      If[MemberQ[tags, tag], 
        IDEData[nb, {"Toolbars", "Tags"}] = DeleteCases[tags, tag];
        IDEData[nb, {"Toolbars", "Cells", tag}] = None
        ];
      If[MemberQ[tags, tag],
        IDEData[nb, {"Toolbars", "Column"}] = 
          makeIDEToolbarGrid[nb, DeleteCases[tags, tag]]
        ]
      ];
    refreshToolbars[nb]
    ]


(* ::Subsubsection::Closed:: *)
(*AddNotebookToolbar*)



AddNotebookToolbar[nb_, toolbar_, tag_]:=
  Module[{cell, tools, tags},
    tools = Flatten@{toolbar};
    tools=
      If[Head[#]=!=Cell,
        StyleBox[ToBoxes[#], "ToolbarElement"],
        #
        ]&/@tools;
    tools =
      GridBox[
        {
          {
            GridBox[{tools}, BaseStyle->"ToolbarElementRow"],
            ButtonBox["", BaseStyle->"ToolbarCloseButton", ButtonData->tag]
            }
          },
        BaseStyle->"ToolbarCell"
        ];
    WithNotebookPaused[
      nb,
      tags = IDEData[nb, {"Toolbars", "Tags"}, {}];
      If[!ListQ@tags, tags = {}];
      If[!MemberQ[tags, tag], 
        IDEData[nb, {"Toolbars", "Tags"}] = Append[tags, tag]
        ];
      IDEData[nb, {"Toolbars", "Cells", tag}] = tools;
      If[IDEData[nb, {"Toolbars", "Cells", tag}] =!= tools,
        IDEData[nb, {"Toolbars", "Cells"}] = {};
        IDEData[nb, {"Toolbars", "Cells", tag}] = tools;
        ];
      IDEData[nb, {"Toolbars", "Column"}] = 
        makeIDEToolbarGrid[nb, Append[tags, tag]];
      ];
    refreshToolbars[nb]
    ];
AddNotebookToolbar[nb_, tag_String]:=
  Replace[
    getToolbarExpression[tag],
    a_Association?(KeyExistsQ[#, "Toolbar"]&):>
      AddNotebookToolbar[nb, a["Toolbar"], tag]
    ];


(* ::Subsubsubsection::Closed:: *)
(*getToolbarExpression*)



getToolbarExpression[s_String]:=
  Replace[
    FileNames[s<>".wl", FileNames["Toolbars", $IDESettingsPath]],
    {
      {f_, ___}:>LoadPlugin[f, "Toolbar"],
      _->None
      }
    ]


(* ::Subsection:: *)
(*IDE*)



(* ::Subsubsection::Closed:: *)
(*IDEAddToolbar*)



IDEAddToolbar[nb_NotebookObject, toolbar_, tag_String]:=
  (AddNotebookToolbar[nb, toolbar, tag];);
IDEAddToolbar[nb_NotebookObject, tag_String]:=
  (AddNotebookToolbar[nb, tag];);
IDEAddToolbar[ide_IDENotebookObject, toolbar_, tag_String]:=
  IDEAddToolbar[ide["Notebook"], toolbar, tag];
IDEAddToolbar[ide_IDENotebookObject, tag_String]:=
  IDEAddToolbar[ide["Notebook"], tag]


(* ::Subsubsection::Closed:: *)
(*IDERemoveToolbar*)



IDERemoveToolbar[nb_NotebookObject, tag_String]:=
  (RemoveNotebookToolbar[nb, tag];);
IDERemoveToolbar[ide_IDENotebookObject, tag_String]:=
  IDERemoveToolbar[ide["Notebook"], tag];


End[];



