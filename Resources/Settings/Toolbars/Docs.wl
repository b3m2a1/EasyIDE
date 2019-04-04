(* ::Package:: *)

BeginPackage["`DocsToolbar`"];
metadataEditor;
docsTemplates;
docsOpsMenu;
EndPackage[];


Begin["`Private`"];


overrideGetNbData[nb_, k_, d_]:=
	CurrentValue[nb, Flatten@{TaggingRules, k}, d];
overrideGetNbData[nb_, k_]:=
	CurrentValue[nb, Flatten@{TaggingRules, k}];
overrideSetNbData[nb_, k_, d_]:=
	(CurrentValue[nb, Flatten@{TaggingRules, k}] = d);


patchTaggingRules[e_]:=
  e/.TaggingRules:>(Sequence@@{TaggingRules, "EasyIDE", "Options", TaggingRules});

catchCreateDocument[expr_]:=
  Block[
    {
      CreateDocument=IDEOpen[$CurrentIDENotebook, #]&
      },
    expr
    ];
catchCreateDocument~SetAttributes~HoldFirst;

withIDE[expr_]:=
  Block[
   {
     EasyIDE`Dependencies`SimpleDocs`Package`Private`getNbData =
       overrideGetNbData,
     EasyIDE`Dependencies`SimpleDocs`Package`Private`setNbData =
       overrideSetNbData,
     e = Hold[expr] // patchTaggingRules
     },
    catchCreateDocument[
      ReleaseHold[DeleteCases[e, Verbatim[Needs]["SimpleDocs`"], \[Infinity]]]
      ]
   ];
withIDE~SetAttributes~HoldFirst;

metadataEditor =
  RawBoxes@
    ReplaceAll[
      ToBoxes@
        Framed[
          $MetadataEditor // patchTaggingRules,
          ImageSize->{{100, 500}, {55, 1000}},
          Background->White,
          RoundingRadius->5,
          BaseStyle->"Panel",
          FrameStyle->GrayLevel[.8]
          ],
      TagBox[g_GridBox, "Grid"]:>g
      ]


docsTemplates = 
  ReplacePart[$InsertionMenu, 
    1-> 
     Button[
      "Insert",
      BaseStyle->"PluginMenu",
      Appearance->Inherited,
      FrameMargins->{{10,10},{0,0}},
      ImageSize->{Automatic,28}
      ]
    ];


docsOpsMenu=
  ReplacePart[
    Replace[$HamburgerMenu, 
      {
        (k_:>v_):>
          k:>withIDE[v]
        },
      2
      ],
    1-> 
     Button[
      "Menu",
      BaseStyle->"PluginMenu",
      Appearance->Inherited,
      FrameMargins->{{10,10},{0,0}},
      ImageSize->{Automatic,28}
      ]
    ]


End[]


{
  metadataEditor,
  docsTemplates,
  docsOpsMenu
  }
