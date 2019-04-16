(* ::Package:: *)

(* ::Section:: *)
(*Git Plugin*)


BeginPackage["`GitPlugin`"];


gitPluginCommands;


EndPackage[];


(* ::Subsection:: *)
(*Private*)


Begin["`Private`"];


(* ::Subsubsection:: *)
(*initRepo*)


initRepo[]:=
  CreateMessagePopup[
    StringForm["Initialized git repo: \n``", 
      Git["Init", IDEPath[]]
      ]
    ];


(* ::Subsubsection:: *)
(*commitRepo*)


commitRepo[]:=
  CreateWindowedInputDialog[
    <|
      "Header"->"Commit to Git",
      "Fields"->{
        "Provide a commit message",
        <|
          "ID"->"Message",
          "Name"->None,
          "Default"->"Committed via EasyIDE @ ``"~TemplateApply~Now,
          "Options"->{
            FieldSize->{25, {5, 25}},
            FieldHint->"Commit message..."
            }
          |>
        },
    "SubmitAction"->
      Function[
        Git["Add", IDEPath[$CurrentIDENotebook], "All"->True];
        CreateMessagePopup[
          StringForm["Committed to git: \n``", 
            Git["Commit", 
              IDEPath[$CurrentIDENotebook],
              "Message"->#Message
              ]
            ]
          ]
        ]
    |>,
  (*<|
    "Position"->{-5, -5},
    "Alignment"->{Right, Top},
    "Anchor"->{Right, Top}
    |>,*)
  (*CellSize*)WindowSize->{350, All},
  "CreateCloseButton"->False
  ];


(* ::Subsubsection:: *)
(*gitPush*)


gitPush[]:=
  CreateMessagePopup[
    StringForm["Pushed to origin: \n``", 
      Git["PushOrigin", IDEPath[$CurrentIDENotebook]]
      ]
    ];


(* ::Subsubsection:: *)
(*gitPull*)


gitPull[]:=
  CreateMessagePopup[
    StringForm["Pulled from origin: \n``", 
      Git["PullOrigin", IDEPath[$CurrentIDENotebook]]
      ]
    ];


(* ::Subsubsection:: *)
(*createGitIgnore*)


createGitIgnore[]:=
  IDEOpen[Git["AddGitIgnore", IDEPath[]]];


(* ::Subsubsection:: *)
(*setRemote*)


setRemote[]:=
  CreateWindowedInputDialog[
    <|
      "Header"->"Set Remote",
      "Fields"->{
        "Provide a new remote URL for the repo",
        <|
          "ID"->"Remote",
          "Name"->None,
          "Default"->
            Replace[Git["GetRemoteURL", IDEPath[]] s_String?(StringStartsQ["fatal"]):>""],
          "Options"->{
            FieldHint->"remote"
            }
          |>
        },
    "SubmitAction"->
      Function[
        CreateMessagePopup[
          Replace[
            Git["SetRemoteURL", IDEPath[], "origin", #Remote],
            _String?(StringStartsQ["fatal: "]):>
              Git["AddRemote", IDEPath[], #Remote]
            ]
          ]
        ]
    |>,
  WindowSize->{350, All}
  ]


(* ::Subsubsection:: *)
(*openRemote*)


openRemote[]:=
  Replace[
    Git["GetRemoteURL", IDEPath[]],
    {
      s_String?(StringStartsQ["fatal:"]):>
        CreateMessagePopup[s],
      e_:>SystemOpen[e]
      }
    ]


(* ::Subsubsection:: *)
(*gitPluginCommands*)


gitPluginCommands=
  {
    "Initialize":>initRepo[],
    "Commit":>commitRepo[],
    "Push":>gitPush[],
    "Pull":>gitPull[],
    "Create GitIgnore":>createGitIgnore[],
    "Remotes"->{
      "Set Remote":>setRemote[],
      "Open Remote":>openRemote[]
      }
  }


(* ::Subsubsection:: *)
(*End*)


End[];


(* ::Subsection:: *)
(*Exposed*)


gitPluginCommands
