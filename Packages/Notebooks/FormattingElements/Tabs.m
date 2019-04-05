(* ::Package:: *)

(* Autogenerated Package *)

TabObject::usage="";
CreateTabRow::usage="";


NotebookCreateTab::usage="";
NotebookSwitchTab::usage="";
NotebookCloseTab::usage="";


IDETabExists::usage="Not sure where else this one would live...?";
IDETabNames::usage="Not sure where else this one would live...?"
IDETabNameFiles::usage="Not sure where else this one would live...?"


IDESwitchTab::usage="Switches the IDE tab";


Begin["`Private`"];


(* ::Subsection:: *)
(*TabData*)



(* ::Subsubsection::Closed:: *)
(*ideSetTab*)



ideSetTab[nb_, tabName_]:=
  IDEData[nb, "ActiveTab"] = tabName;


(* ::Subsubsection::Closed:: *)
(*IDETabNames*)



IDETabNames[nb_]:=
  Keys@IDEData[nb, "Tabs", {}];


(* ::Subsubsection::Closed:: *)
(*IDETabNameFiles*)



IDETabNameFiles[nb_]:=
  {Keys[#], Lookup[Values[#], "File", {}]}&@
    IDEData[nb, "Tabs", {}];


(* ::Subsubsection::Closed:: *)
(*IDETabExists*)



ideTabExists[nb_, tab_]:=
  ListQ@IDEData[nb, {"Tabs", tab}];
IDETabExists[nb_, tab_]:=
  ListQ@IDEData[nb, {"Tabs", tab}];


(* ::Subsection:: *)
(*Tab Objects*)



(* ::Subsubsection::Closed:: *)
(*CreateTabRow*)



CreateTabRow[refresh_]:=
  With[
    {
      tns=
        Quiet@Block[
          {CurrentValue=cv}, 
          IDETabNameFiles[FrontEnd`EvaluationNotebook[]]
          ]
      },
    Dynamic[
      refresh;
      Pane[
        Grid@List@MapThread[TabObject, tns], 
        BaseStyle->"TabbingRow"
        ],
      TrackedSymbols:>{refresh}
      ]/.cv->CurrentValue
    ]


(* ::Subsubsection::Closed:: *)
(*TabObject*)



TabObject[tabName_String, file_]:=
  Style[
    Panel[
      Grid[
        List@{
          MouseAppearance[
            RawBoxes@ButtonBox[
              ToBoxes@Pane[tabName, BaseStyle->"TabName"],
              BaseStyle->"TabName",
              ButtonData->tabName
              ],
            "LinkHand"
            ],
          RawBoxes@ButtonBox["", 
            BaseStyle->"TabCloseButton",
            ButtonData->tabName
            ]
          }
        ],
      BaseStyle->
        With[
          {
            c=
              Block[
                {CurrentValue=FrontEnd`CurrentValue}, 
                IDEData[FrontEnd`EvaluationNotebook[], "ActiveTab"]
                ]
            },
          FEPrivate`If[FEPrivate`SameQ[c, tabName], 
            "TabPanelActive", 
            "TabPanelBackground"
            ]
          ],
      BoxID->tabName<>"-tab"
      ],
    ContextMenu->FileEntryContextMenu[file]
    ]


(* ::Subsubsection::Closed:: *)
(*refreshTabs*)



refreshTabs[nb_]:=
  Replace[
    IDEData[nb, PrivateKey["TabsRefreshHandle"]],
    Hold[var_]:>(var=RandomReal[])
    ];


(* ::Subsection:: *)
(*Tabbing*)



(* ::Subsubsection::Closed:: *)
(*NotebookCreateTab*)



NotebookCreateTab[nb_NotebookObject, tabName_String, tabData_]:=
  (
    IDEData[nb, {"Tabs", tabName}] = tabData;
    refreshTabs[]
    )


(* ::Subsubsection::Closed:: *)
(*NotebookSwitchTab*)



NotebookSwitchTab[nb_NotebookObject, tabName_String, saveCurrent:True|False:True]:=
  Module[
    {
      file,
      active = IDEData[nb, "ActiveTab"]
      },
    If[active =!= tabName,
      If[saveCurrent, IDESave[nb, "AutoGenerateSave"->False]];
      file = IDEData[nb, {"Tabs", tabName, "File"}];
      NotebookPutFile[nb, file];
      ideSetTab[nb, tabName];
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*NotebookCloseTab*)



NotebookCloseTab[nb_NotebookObject, tabName_String, saveCurrent:True|False:True]:=
  Module[
    {
      active = IDEData[nb, "ActiveTab"],
      tabs = IDEData[nb, "Tabs"]
      },
    If[MemberQ[Keys@tabs, tabName],
      WithNotebookPaused[
        nb,
        tabs = DeleteCases[tabs, tabName->_];
        If[tabName == active,
          If[Length@tabs > 0,
            NotebookSwitchTab[nb, Keys[tabs][[1]]],
            If[saveCurrent, NotebookSaveContents[nb, "AutoGenerateSave"->False]];
            NotebookPutContents[nb, Notebook[{}]];
            IDEData[nb, "ActiveTab"] = None;
            ]
          ];
        IDEData[nb, "Tabs"] = tabs;
        ];
      refreshTabs[]
      ]
    ]


(* ::Subsection:: *)
(*IDE*)



(* ::Subsubsection::Closed:: *)
(*IDESwitchTab*)



IDESwitchTab[nb_NotebookObject, tagName_]:=
  NotebookSwitchTab[nb, tagName];
IDESwitchTab[ide_IDENotebookObject, tagName_]:=
  IDESwitchTab[ide["Notebook"], tagName];


End[];



