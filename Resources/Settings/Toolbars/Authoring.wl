(* ::Package:: *)

(* ::Section:: *)
(*Authoring Toolbar*)


(* ::Text:: *)
(*Basically just a superset of the standard Markdown stuff, but in this case we're set up explicitly to go to book format*)


BeginPackage["`AuthoringToolbar`"];


initBook;
newSection;
newChapter;
createTOC;
createBookNotebook;
createBooklet;


EndPackage[];


(* ::Subsection:: *)
(*Private*)


Begin["`AuthoringToolbar`Private`"];


(* ::Subsubsection:: *)
(*initBook*)


initBook[]:=
  Replace[
    getBookRoot[], 
    None:>
      CreateAttachedInputDialog[
        <|
          "Header"->"New Book",
          "Fields"->{
            "Provide a name for the new book",
            <|
              "Name"->None,
              "ID"->"Name"
              |>
            },
          "SubmitAction"->Function[
            IDEOpen@
              FileNameJoin@{
                Ems["New", FileNameJoin@{IDEPath[], FileBaseName@#Name}, "book"],
                "SiteConfig.wl"
                }
            ]
          |>
        ]
    ]


(* ::Subsubsection:: *)
(*getBookRoot*)


getBookRoot[]:=
  SelectFirst[FileNames["content", IDEPath[], 5], DirectoryQ, None]


(* ::Subsubsection:: *)
(*getPostsRoot*)


getPostsRoot[]:=
  FileNameJoin@{getBookRoot[], "posts"};


(* ::Subsubsection:: *)
(*getChapters*)


getChapters[]:=
  Select[DirectoryQ]@FileNames["*", getPostsRoot[]];


(* ::Subsubsection:: *)
(*getSections*)


getSections[]:=
  FileNames["*.nb", getChapters[]];


(* ::Subsubsection:: *)
(*makeNewChapter*)


makeNewChapter[name_]:=
  With[{root=initBook[], chaps=getChapters[]},
    CreateDirectory[
      FileNameJoin@{
        root,
        "posts",
        TemplateApply["``-``",
          {ToString[Length[chaps]+1], name}
          ]
        }
      ]
    ]


(* ::Subsubsection:: *)
(*makeMetaCell*)


makeMetaCell[params_]:=
  Cell[
    BoxData@MathLink`CallFrontEnd@FrontEnd`ReparseBoxStructurePacket@
      StringReplace[
        PrettyString@
          Merge[
            {
              params,
              <|
                "Slug"->Automatic,
                "Date"->DateString[Now],
                "Authors"->{},
                "Categories"->{},
                "Tags"->{}
                |>
              },
            First
            ],
       "\n"~~(Whitespace|"")->"\[IndentingNewLine]"
       ],
    "Metadata"
    ]


(* ::Subsubsection:: *)
(*makeNewSection*)


makeNewSection[chap_, name_]:=
  With[{secs=FileNames["*.nb", chap], num=StringSplit[FileBaseName[chap], "-"][[1]]},
    IDEOpen@
      Export[
        FileNameJoin@{
          chap,
          TemplateApply["``-``-``",
            {num, ToString[Length[secs]+1], FileBaseName@name<>".nb"}
            ]
          },
        Notebook[
          {
            makeMetaCell[<|
              "Title"->FileBaseName@name,
              "ID"->num<>"."<>ToString[Length[secs]+1]
              |>],
            Cell[FileBaseName@name, "Section",
              CellTags->{
                num<>"-"<>ToString[Length[secs]+1]<>"-"<>
                  StringReplace[FileBaseName@name, Whitespace->"-"]
                }
              ]
            },
          StyleDefinitions->FrontEnd`FileName[{"BTools"}, "MarkdownNotebook.nb"]
          ]
        ]
    ]


(* ::Subsubsection:: *)
(*newChapter*)


newChapter[]:=
  CreateAttachedInputDialog[
    <|
      "Header"->"New Chapter",
      "Fields"->{
        "Provide a name for the chapter",
        <|
          "Name"->None,
          "ID"->"Name",
          "Default"->"New Chapter"
          |>
        },
      "SubmitAction"->
        Function[makeNewChapter[#Name]]
      |>
    ]


(* ::Subsubsection:: *)
(*newSection*)


newSection[]:=
  CreateAttachedInputDialog[
    <|
      "Header"->"New Section",
      "Fields"->{
        "Provide a chapter and name for the section",
        <|
          "Name"->None,
          "ID"->"Chapter",
          "Type"->{PopupMenu, #->FileBaseName[#]&/@getChapters[]},
          "Default"->getChapters[][[1]]
          |>,
        <|
          "Name"->None,
          "ID"->"Name",
          "Default"->"Section"
          |>
        },
      "SubmitAction"->Function[makeNewSection[#Chapter, #Name]]
      |>
    ]


(* ::Subsubsection:: *)
(*createTOC*)


createTOC[]:=
  Module[{secs=getSections[], chaps},
    secs = KeySort@GroupBy[secs, DirectoryName, Sort];
    chaps = Keys[secs];
    Export[
      FileNameJoin@{Nest[DirectoryName, First@chaps, 2], "pages", "toc.nb"},
      Notebook[
        Flatten@{
          makeMetaCell[<|"Title"->"Table Of Contents", "Slug"->"toc"|>],
          Cell["Table of Contents", "Section", 
            CellTags->{"TableOfContents"},
            PageBreakAbove->True,
            PageBreakBelow->False
            ],
         KeyValueMap[
           {
             Cell[StringReplace[FileBaseName@#, "-"->". ", 1], "Subsection"],
             Cell[
               BoxData@ToBoxes@
                 Hyperlink[
                   StringSplit[FileBaseName[#], "-"][[-1]],
                   FileBaseName@#
                   ],
               "Item"
               ]&/@#2
             }&,
           secs
           ]
         },
        StyleDefinitions->FrontEnd`FileName[{"BTools"}, "MarkdownNotebook.nb"]
        ]
      ]
    ]


(* ::Subsubsection:: *)
(*createTitlePage*)


createTitlePage[sections_]:=
  Module[{title, author},
    title = FileBaseName@Nest[DirectoryName, getChapters[][[1]], 3];
    author = 
      Do[
        Replace[
          Lookup[
            FirstCase[
              NotebookGet[sec], 
              Cell[BoxData[a_], "Metadata", ___]:>
                ToExpression[a],
              <||>
              ],
            "Authors"
            ],
          {auth_, ___}:>Return[auth, Do]
          ],
        {sec, sections}
        ];
    Notebook[
      {
        Cell[title, "Title", CellTags->{"Title"}],
        Cell[Replace[author, Except[_String]->""], "Subtitle", CellTags->{"Author"}]
        }
      ]
    ]


(* ::Subsubsection:: *)
(*getStyleNotebook*)


$curDir = DirectoryName@$InputFileName;


getStyleNotebook[]:=
  Import[FileNameJoin@{$curDir, "BookReader.nb"}];


(* ::Subsubsection:: *)
(*createBookNotebook*)


createBookNotebook[]:=
  Module[
    {
      toc,
      titlePage,
      sections = getSections[],
      pages,
      nav,
      navCell
      },
    toc = FileNameJoin@{Nest[DirectoryName, sections[[1]], 3], "pages", "toc.nb"};
    If[!FileExistsQ[toc], createTOC[]];
    nav = KeySort@GroupBy[sections, DirectoryName, Sort];
    navCell = nav;
    titlePage = createTitlePage[sections][[1]];
    Notebook[
      Flatten@{
        titlePage,
        DeleteCases[Get[#][[1]],
          Cell[_, "Metadata", ___],
          3
          ]&@toc,
        KeyValueMap[
          {
            Cell[StringSplit[FileBaseName[#], "-", 2][[-1]], "Chapter",
              CellTags->
                {
                  StringReplace[FileBaseName[#], Whitespace->"-"]
                  }
              ],
            DeleteCases[Get[#][[1]],
              Cell[_, "Metadata", ___],
              3
              ]&/@#2
            }&,
          nav
          ]
        },
      {
        StyleDefinitions->
          getStyleNotebook[],
        TaggingRules->{
          "ChapterSectionData"->
            Map[
              Map[FileBaseName],
              KeyMap[FileBaseName, nav]
              ]
          },
        WindowTitle->
          "Book Reader: "<>
            FirstCase[titlePage, 
              Cell[t_, "Title", ___, CellTags->{"Title"}, ___]:>t, "Untitled",  Infinity]
        }
      ]
    ]


(* ::Subsubsection:: *)
(*createBooklet*)


createBooklet[]:=
  Module[{title, dir, nb},
    nb = createBookNotebook[];
    title = 
      FirstCase[nb, 
        Cell[t_, "Title", ___, CellTags->{"Title"}, ___]:>t, "Untitled",  Infinity];
    dir = DirectoryName@getBookRoot[];
    Export[
      FileNameJoin@{dir, ToString@title<>".pdf"},
      nb,
      "PDF"
      ]
    ]


(* ::Subsubsection:: *)
(*End*)


End[]


(* ::Subsection:: *)
(*Expose Toolbar*)


{
  "Initialize Book":>initBook[],
  "New Chapter":>newChapter[],
  "New Section":>newSection[],
  "Create TOC":>IDEOpen@createTOC[],
  "Create Book":>CreateDocument@createBookNotebook[],
  "Create PDF":>{SystemOpen@createBooklet[], Method->"Queued"}
  }
