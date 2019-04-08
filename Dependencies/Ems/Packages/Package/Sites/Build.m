(* ::Package:: *)

(* Autogenerated Package *)

(* ::Subsubsection::Closed:: *)
(*Config*)



SiteOptions::usage=
  "Gets site options";
SetSiteOptions::usage=
  "Sets site options";


(* ::Subsubsection::Closed:: *)
(*Content*)



NewSite::usage=
  "Makes a new site";
NewPost::usage=
  "Makes a new post";
NewPage::usage=
  "Makes a new page";



(* ::Subsubsection::Closed:: *)
(*Build*)



BuildSite::usage=
  "Builds a website from a directory";
OpenSite::usage=
  "Opens a site from a directory";
DeploySite::usage=
  "Deploy a site from a directory";


$BuildErrors::usage=
  "The errors from the latest build"


Begin["`Private`"];


Ems; (* invoke the autoloader *)


(* ::Subsection:: *)
(*Config*)



(* ::Subsubsection::Closed:: *)
(*SiteOptions*)



SiteOptions//Clear
SiteOptions[dir_String?DirectoryQ, ops:Repeated[_, {0, 1}]]:=
  Block[{res=WebSiteOptions[dir, ops]},
    res/;Head[res]=!=WebSiteOptions
    ];
SiteOptions[name:Except[""|_?DirectoryQ, _String], ops:Repeated[_, {0, 1}]]:=
  With[{s=FileNameJoin@{$SiteDirectory, name}},
    SiteOptions[s, ops]/;DirectoryQ@s
    ];


(* ::Subsubsection::Closed:: *)
(*SetSiteOptions*)



SetSiteOptions[dir_String?DirectoryQ, ops:_?OptionQ]:=
  Block[{res=WebSiteSetOptions[dir, ops]},
    res/;Head[res]=!=WebSiteSetOptions
    ];
SetSiteOptions[name:Except[""|_?DirectoryQ, _String], ops:_?OptionQ]:=
  With[{s=FileNameJoin@{$SiteDirectory, name}},
    SetSiteOptions[s, ops]/;DirectoryQ@s
    ];


(* ::Subsection:: *)
(*Content*)



(* ::Subsubsection::Closed:: *)
(*NewSite*)



NewSite//Clear
NewSite[
  dir_String?(
    FileNameDepth[#]>1&&DirectoryQ@DirectoryName[#]&
    ),
  template:_String|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  Block[
    {
      temp=
        PackageFilePath[
          "Resources",
          "Templates",
          "blog"
          ],
      res
      },
    res=
      WebSiteInitialize[dir, 
        Replace[template, 
          {
            s:Except[""|_?DirectoryQ, _String]:>
              PackageFilePath[
                "Resources",
                "Templates",
                s
                ],
            Automatic->temp
            }
          ], 
        ops
        ];
    res/;Quiet[DirectoryQ@res]
  ];
NewSite[
  name_String?(StringFreeQ[Whitespace|$PathnameSeparator]),
  template:_String|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  With[
    {
      r=NewSite[FileNameJoin@{$SiteDirectory, name}, template, ops]
      },
    r/;Quiet[DirectoryQ@r]
    ]


(* ::Subsubsection::Closed:: *)
(*NewContent*)



NewContent[
  dir_String?DirectoryQ,
  place_String,
  name:_String|Automatic:Automatic,
  content:_List|_Cell|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  With[{r=WebSiteNewContent[dir, place, name, content, ops]},
    r/;Quiet[FileExistsQ@r]
    ]


(* ::Subsubsection::Closed:: *)
(*NewPage*)



NewPage[
  dir_String?DirectoryQ,
  name:_String|Automatic:Automatic,
  content:_List|_Cell|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  With[{r=WebSiteNewContent[dir, "pages", name, content, ops]},
    r/;Quiet[FileExistsQ@r]
    ]


(* ::Subsubsection::Closed:: *)
(*NewPost*)



NewPost[
  dir_String?DirectoryQ,
  name:_String|Automatic:Automatic,
  content:_List|_Cell|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  With[{r=WebSiteNewContent[dir, "posts", name, content, ops]},
    r/;Quiet[FileExistsQ@r]
    ]


(* ::Subsubsection::Closed:: *)
(*NewTableOfContents*)



NewTableOfContents[
  dir_String?DirectoryQ
  ]:=
  With[{r=WebSiteNewTableOfContents[dir]},
    r/;Quiet[FileExistsQ@r]
    ]


(* ::Subsection:: *)
(*Build*)



(* ::Subsubsection::Closed:: *)
(*BuildSite*)



BuildSite//Clear


Options[BuildSite]=
  Options[WebSiteBuild];
BuildSite[
  dir_String?DirectoryQ,
  files:
    {(_String?FileExistsQ|((_String?FileExistsQ)->_List))..}|
      s_?(StringPattern`StringPatternQ)|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  Block[
    {
      $WebSiteDirectory=$SiteDirectory,
      $WebSitePath=$SitePath,
      $WebSiteThemePath=$SiteThemePath
      },
    WebSiteBuild[dir, files, ops]
    ];


BuildSite[
  name_String?(Not@*DirectoryQ),
  files:
    {(_String?FileExistsQ|((_String?FileExistsQ)->_List))..}|
      s_?(StringPattern`StringPatternQ)|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  With[{f=FileNameJoin@{$SiteDirectory, name}},
    BuildSite[f, files, ops]/;DirectoryQ[f]
    ]


(* ::Subsubsection::Closed:: *)
(*OpenSite*)



OpenSite[dir_String?DirectoryQ]:=
  PySimpleServerOpen@
    With[{fns=FileNames["*.html", FileNameJoin@{dir, "docs"}]},
      If[Length@fns>0,
        FileNameJoin@{dir, "docs"},
        FileNameJoin@{dir, "output"}
        ]
      ];
OpenSite[name_String]:=
  With[{d=FileNameJoin@{$SiteDirectory, name}},
    OpenSite[d]/;DirectoryQ[d]
    ]


(* ::Subsubsection::Closed:: *)
(*DeploySite*)



Options[DeploySite]=
  Options[WebSiteDeploy];
DeploySite[
  dir_String?DirectoryQ,
  uri:_String|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  With[
    {odir=
      With[{fns=FileNames["*.html", FileNameJoin@{dir, "docs"}]},
        If[Length@fns>0,
          FileNameJoin@{dir, "docs"},
          FileNameJoin@{dir, "output"}
          ]
        ]
      },
    WebSiteDeploy[odir, uri, ops]
    ];


(* ::Subsubsection::Closed:: *)
(*BuildErrors*)



$BuildErrors:=
  Replace[$WebSiteBuildErrors,
    Except[_Association?(Length[#]>0&)]->None
    ]


End[];


