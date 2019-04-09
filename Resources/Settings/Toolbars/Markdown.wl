(* ::Package:: *)

BeginPackage["`MarkdownToolbar`"];
insertYTLink;
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


insertYTLink[handle_]:= 
  With[{so=installYT[]},
    NotebookWrite[
      InputNotebook[],
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
  CreateAttachedInputDialog[
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
        Function[
          If[StringLength[#Handle]>0, insertYTLink[#Handle]]
          ]
      |>
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


End[]


{
  Button[
   "YouTube Link",
   insertYTLink[]
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
