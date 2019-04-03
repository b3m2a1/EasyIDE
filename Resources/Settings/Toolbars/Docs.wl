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
withNewTaggingRules[expr_]:=
  Block[
   {
     EasyIDE`Dependencies`SimpleDocs`Package`Private`getNbData =
       overrideGetNbData,
     EasyIDE`Dependencies`SimpleDocs`Package`Private`setNbData =
       overrideSetNbData,
     e = Hold[expr] // patchTaggingRules
     },
    ReleaseHold[DeleteCases[e, Verbatim[Needs]["SimpleDocs`"], \[Infinity]]]
   ];
withNewTaggingRules~SetAttributes~HoldFirst;

metadataEditor = 
  $MetadataEditor // patchTaggingRules;


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
          k:>withNewTaggingRules[v]
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
  docsOpsMenu,
  }
