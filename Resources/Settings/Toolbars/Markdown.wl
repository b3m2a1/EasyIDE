(* ::Package:: *)

BeginPackage["`MarkdownToolbar`"];
mdEdits;
mdTemplates;
EndPackage[];


Begin["`Private`"];


installYT[]:=
  (
    If[PacletManager`PacletFind["ServiceConnection_YouTube"]=={},
      PacletInstall[]
      ];
    ServiceConnect["YouTube"]
    )


makeYTLinkBox[so_, handle_]:=
  TemplateBox[
    {
      ToBoxes@
        Hyperlink[
          Image[
            #,
            ImageSize->ImageDimensions[#]
            ]&@Import[
              so["Search", "part"->"snippet", "q"->handle][
                "items", 1, "snippet", "thumbnails", "high", "url"
                ]
              ],
          URLBuild@<|
              "Scheme"->"https",
              "Domain"->"www.youtube.com",
              "Path"->{"watch"},
              "Query"->{"v"->handle}
              |>
          ],
      so["EmbedIFrame","id"->handle]
      },
    "MarkdownInterpretation"
    ]


insertYTLink[nb_, handle_]:= 
  With[{so=installYT[]},
    NotebookWrite[
      nb,
      Cell[
        TextData@{
            Cell[BoxData@makeYTLinkBox[so, handle]]
            },
        "Text",
        GeneratedCell->Inherited,
        CellAutoOverwrite->Inherited
        ]
      ]
    ];
insertYTLink[]:=
  With[{nb=$CurrentIDENotebook},
    CreateWindowedInputDialog[
      <|
        "Header"->"YouTube Link",
        "Fields"->{
          "Provide a YouTube video handle. This is after 'v=' in a standard YouTube URL.",
          <|
            "ID"->"Handle",
            "Name"->None
            |>
          },
        "SubmitAction"->
          {
            Function[
              If[StringLength[#Handle]>0, insertYTLink[nb, #Handle]]
              ],
            Method->"Queued"
            }
        |>
      ]
    ]


lITemp[a_, b_, c_]:=
  TemplateBox[
    {
      a,
      b
      },
    "MarkdownLinkedImage"
    ]
linkedImageTemplate=
  lITemp["altText", "http://img.link.usually.svg"];
lILTemp[a_, b_, c_]:=
  TemplateBox[
    {a, b, c},
    "MarkdownLinkedImageLink"
    ]
linkedImageLinkTemplate=
  lILTemp[
    "altText",
    "http://img.usually.svg",
    "http://link.to.a.thing"
    ];
version=
  lILTemp["version", 
    "http://img.shields.io/badge/version-a.b.c-orange.svg",
    "http://github.com/user/repo/master/PacletInfo.m"
    ];
license=
  lITemp[
    "license", 
    "http://img.shields.io/badge/license-MIT-blue.svg",
    "https://opensource.org/licenses/MIT"
    ];


mdTemplates = {
  "VersionIcon" -> version,
  "LicenseIcon" -> license
  }


mdEdits = {
  "Add Image Border" :> addImageBorder[],
  "Add YouTube Link" :> insertYTLink[]
  }


addImageBorder[]:=
  Replace[NotebookRead@$CurrentIDENotebook,{
      g:GraphicsBox[TagBox[_RasterBox,___],___]:>
        NotebookWrite[$CurrentIDENotebook,
          ToBoxes@
            ImagePad[
              ImagePad[
                ImagePad[
                  ImagePad[ToExpression@g,1,Lighter@Gray],
                  13,
                  GrayLevel[.9]],
                1,Lighter@Gray],
              5,
              GrayLevel[0,0]
              ]
          ]
      }]


End[]


{
  Button[
   "Save Markdown",
   With[{nb=$CurrentIDENotebook},
     PreemptiveQueued[nb,
       WithActiveNotebookPath[nb,
         NotebookMarkdownSave[nb]
         ]
       ]
     ],
   Appearance->Inherited,
   FrameMargins->{{10,10},{0,0}},
   ImageSize->{Automatic,28}
   ],
  ActionMenu[
    Button[
      "Edit",
      BaseStyle->"PluginMenu",
      Appearance->Inherited,
      FrameMargins->{{10,10},{0,0}},
      ImageSize->{Automatic,28}
      ],
    mdEdits,
    Appearance->None,
    MenuAppearance->"Dropdown"
    ],
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
      ]&/@mdTemplates,
    Appearance->None,
    MenuAppearance->"Dropdown"
    ]
  }
