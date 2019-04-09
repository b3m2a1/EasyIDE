(* ::Package:: *)

BeginPackage["`CodePackageToolbar`"];
loadPackage;
openPackage;
codeTemplates;
EndPackage[];


Begin["`Private`"];


createFailuresDialog[loadPackageFailures_]:=
	CreateDocument[
  Cell[BoxData@ToBoxes@#,
    Selectable->True,
    Background->White,
    CellFrame->1,
    CellFrameColor->GrayLevel[.7,.5]
    ]&/@If[Length@loadPackageFailures>100,
    Append[
      Take[
        loadPackageFailures,
        99
        ],
      Skeleton[
        Length@loadPackageFailures-99
        ]
      ],
    loadPackageFailures
    ],
  WindowTitle->"Failed to load",
  WindowSize->{All,150},
  Background->GrayLevel[.9],
  WindowElements->None,
  WindowFrameElements->{"CloseBox"},
  ShowCellBracket->False,
  CellBracketOptions->{
      "OverlapContent"->False
      }
  ];


loadPackage[]:=
  Block[{
      loadPackageFailures={},
      $ContextPath={"System`"},
      appExec=EasyIDE`Dependencies`BTools`Paclets`AppExecute,
      fn=IDEPath[$CurrentIDENotebook, Key["ActiveFile"]]
      },
    Catch[
      GeneralUtilities`WithMessageHandler[
        Replace[
          StringSplit[appExec["GetAppName", fn], "-"][[1]],
          {
            Except[_String]:>(
              Get@StringReplace[fn,".nb"->".m"];
              FrontEnd`Private`GetUpdatedSymbolContexts[];
              ),
            a_:>
              (
                Quiet@Needs[a<>"`"];
                With[
                  {
                    appFile=
                      StringTrim[
                        FileNameTake[fn, 
                          FileNameDepth[appExec["Path", a]]+1-FileNameDepth[fn]
                          ], 
                        ".nb"
                        ]
                    },
                  appExec["Get", a, appFile]
                  ];
                FrontEnd`Private`GetUpdatedSymbolContexts[];
                )
            }],
        AppendTo[loadPackageFailures,#]&
        ],
      _,
      AppendTo[
        loadPackageFailures,
        StringForm["Caught: ``", Short[#]]
        ]&
      ];
    If[Length@loadPackageFailures>0,
      createFailuresDialog[loadPackageFailures]
      ]
    ]


openPackage[]:=
	Catch@
	  Block[
	   {
      loadPackageFailures={}
      },
    GeneralUtilities`WithMessageHandler[
      SystemOpen@
        StringReplace[IDEPath[EvaluationNotebook[], Key["ActiveFile"]], ".nb"->".m"],
      AppendTo[loadPackageFailures,#]&
      ];
    If[Length@loadPackageFailures>0,
      createFailuresDialog[loadPackageFailures]
      ]
    ]


codeTemplates = 
	{
		"Package"->
		  {
Cell["Package Name", "CodeSection"],
      Cell["\<\[LeftCeiling]
  Package description
\[RightFloor]\>",
      "Text",
      Evaluatable->True
      ],
      Cell[BoxData[RowBox[{RowBox[{"Begin","[","\"\<`Private`\>\"","]"}],";"}]], "InputSection"],
      Cell[BoxData[RowBox[{RowBox[{"End","[","]"}],";"}]], "InputSection"],
      Cell["", "SectionSeparator"]
      }
		}


End[]


{
	"Load Package":>
		loadPackage[],
	"Open Package":>
		openPackage[],
	ActionMenu[
    Button[
      "Insert",
      BaseStyle->"PluginMenu",
      Appearance->Inherited,
      FrameMargins->{{10,10},{0,0}},
      ImageSize->{Automatic,28}
      ],
    With[{k=#[[1]], t=#[[2]]},
      k:>
        FrontEndExecute@
          FrontEnd`NotebookWrite[
            FrontEnd`InputNotebook[],
            t
            ]
      ]&/@codeTemplates,
    Appearance->None,
    MenuAppearance->"Dropdown"
    ]
 }
