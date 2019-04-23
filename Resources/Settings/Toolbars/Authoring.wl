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
    None:>Ems["New", FileNameJoin@{IDEPath[], "book"}, "book"]
    ]


(* ::Subsubsection:: *)
(*getBookRoot*)


getBookRoot[]:=
  SelectFirst[FileNames["content", IDEPath[], 5], DirectoryQ, None]


(* ::Subsubsection::Closed:: *)
(*getPostsRoot*)


getPostsRoot[]:=
  FileNameJoin@{getBookRoot[], "posts"};


(* ::Subsubsection::Closed:: *)
(*getChapters*)


getChapters[]:=
  Select[DirectoryQ]@FileNames["*", getPostsRoot[]];


(* ::Subsubsection::Closed:: *)
(*getSections*)


getSections[]:=
  FileNames["*.nb", getChapters[]];


(* ::Subsubsection::Closed:: *)
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
(*makeNewSection*)


makeNewSection[chap_, name_]:=
  With[{secs=FileNames["*.nb", chap], num=StringSplit[FileBaseName[chap], "-"][[1]]},
    (Pause[.1];IDEOpen[#])&@
      Export[
        FileNameJoin@{
          chap,
          TemplateApply["``-``-``",
            {num, ToString[Length[secs]+1], FileBaseName@name<>".nb"}
            ]
          },
        Notebook[
          {
            Cell[
              BoxData@MathLink`CallFrontEnd@FrontEnd`ReparseBoxStructurePacket@
                PrettyString[<|
                  "Title"->FileBaseName@name,
                  "ID"->num<>"."<>ToString[Length[secs]+1],
                  "Date"->DateString[Now],
                  "Authors"->{},
                  "Categories"->{},
                  "Tags"->{}
                  |>],
              "Metadata"
              ],
            Cell[FileBaseName@name, "Section"]
            },
          StyleDefinitions->FrontEnd`FileName[{"BTools"}, "MarkdownNotebook.nb"]
          ]
        ]
    ]


(* ::Subsubsection::Closed:: *)
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


(* ::Subsubsection::Closed:: *)
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
    IDEOpen@Export[
      FileNameJoin@{DirectoryName@First@chaps, "toc.nb"},
      Notebook[
        Flatten@{
         Cell["Table of Contents", "Section"],
         KeyValueMap[
           {
             Cell[FileBaseName@#, "Subsection"],
             Cell[
               BoxData@ToBoxes@
                 Hyperlink[
                   FileBaseName[#], 
                   FileNameTake[#, -2],
                   BaseStyle->{
                     "Text"
                     },
                   Evaluator->Automatic,
                   ButtonData->FileNameTake[#, -2],
                   ButtonFunction->Function[
                     SystemOpen[
                       FileNameJoin@Flatten@{
                         DirectoryName@IDEPath[Key["ActiveFile"]], 
                         #[[1]]
                         }
                      ]
                    ]
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
(*End*)


End[]


(* ::Subsection:: *)
(*Expose Toolbar*)


{
  "Initialize Book":>initBook[],
  "New Chapter":>newChapter[],
  "New Section":>newSection[],
  "Create TOC":>createTOC[],
  "Create Booklet":>createBooklet[]
  }
