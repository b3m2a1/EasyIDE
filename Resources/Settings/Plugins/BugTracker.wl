(* ::Package:: *)

{
  "Create Tracker":>
    With[
      {
        f=
          SystemDialogInput["FileSave", IDEPath[$CurrentIDENotebook, "project/BugTracker.nb"]]
        },
      Block[{NotebookOpen = IDEOpen[$CurrentIDENotebook, #]&},
        NewBugsNotebook[DirectoryName[f], FileBaseName[f]<>".nb"]
        ]
      ]
  }
