(* ::Package:: *)



WithNotebookPaused::usage="Pauses the notebook temporarily to execute code";
PreemptiveQueued::usage="Evaluates preemptive code in a queued fashion";


(* ::Text:: *)
(*Consistent references to the current IDE notebook*)



$CurrentIDENotebook::usage="";
$CurrentIDE::usage="";


Begin["`Private`"];


(* ::Subsection:: *)
(*IDE Refs*)



$CurrentIDENotebook := EvaluationNotebook[];
$CurrentIDE := IDENotebookObject[$CurrentIDENotebook];


(* ::Subsection:: *)
(*Helpers*)



(* ::Subsubsection::Closed:: *)
(*WithPausedNotebook*)



(* ::Text:: *)
(*
	Helper function to suspend the screen while updating the nb
*)



WithNotebookPaused[nb_NotebookObject, expr_]:=
  Block[
  {
    paused = If[TrueQ@paused, True, False],
    FrontEnd`$TrackingEnabled = False,
    setDataCalls 
      (* 
	            Should I catch all of the ideSetNbData calls...? 
	            I could batch them all up at once and maybe decrease the amount of processing time...
	            *)
    },
    If[paused,
      expr,
      Internal`WithLocalSettings[
        FrontEndExecute@
          FrontEnd`NotebookSuspendScreenUpdates[nb];,
        paused = True;
        expr,
        FrontEndExecute@
          FrontEnd`NotebookResumeScreenUpdates[nb];
        ]
      ]
    ];
WithNotebookPaused~SetAttributes~HoldRest


(* ::Subsubsection::Closed:: *)
(*IDEPreemptive*)



PreemptiveQueued[nb_, expr_]:=
  MessageDialog[
    DynamicModule[
      {},
      Null,
      Initialization:>{
        Internal`WithLocalSettings[
          Null,
          Block[
            {
              $CurrentIDENotebook=nb
              },
            expr
            ],
          NotebookClose[EvaluationNotebook[]]
          ]
        },
      SynchronousInitialization -> False
      ],
    Visible->False,
    Evaluator->CurrentValue[nb, Evaluator]
    ];
PreemptiveQueued~SetAttributes~HoldRest


End[];



