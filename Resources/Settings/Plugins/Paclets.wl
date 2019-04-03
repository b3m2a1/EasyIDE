(* ::Package:: *)

{
  "Create":>
    With[
      {
        pb=
          PacletExecute["Bundle", IDEPath[$CurrentIDENotebook]]
        },
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
       If[StringQ[pi], IDEOpen[$CurrentIDENotebook, pi]]
      ]
  }
