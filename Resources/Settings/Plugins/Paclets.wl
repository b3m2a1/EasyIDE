(* ::Package:: *)

{
  "Create":>
    With[
      {
        pb=
          PacletExecute["Bundle", IDEPath[$CurrentIDENotebook]]
        },
       StringForm["Created paclet at:\n ``",
         Short[pb]
         ];
       If[StringQ[pb], SystemOpen@DirectoryName[pb]]
      ],
  "Update Info":>
    With[
      {
        pi=
          PacletExecute[
            "GeneratePacletInfo", 
            IDEPath[$CurrentIDENotebook]
            ]
        },
       CreateMessagePopup[
         StringForm["Generated PacletInfo at:\n ``",
           Short[pi]
           ]
         ]
      ]
  }
