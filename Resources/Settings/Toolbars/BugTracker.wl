(* ::Package:: *)

BeginPackage["`BugTracker`"];
addBugButton;
exportBugsMenu;
EndPackage[];


Begin["`Private`"];


addBugButton=
  "Add Bug":>
    With[{nb=$CurrentIDENotebook},
      FindBugsNotebook;
      PreemptiveQueued[
        nb,
        Replace[
          BugsNotebookAddDataDialog[
            WindowMargins->
              Function[{{#[[1]], Automatic}, {Automatic, #[[2]]}}]@MousePosition["ScreenAbsolute"]
            ],
          a_Association:>
            BugsNotebookAdd[nb, 
              a["Tag"],
              Normal@KeyDrop[a, "Tag"]
              ]
          ]
        ]
      ]


exportBugsMenu = 
  ActionMenu[
    Button[
      "Export",
      BaseStyle->"PluginMenu",
      Appearance->Inherited,
      FrameMargins->{{10,10},{0,0}},
      ImageSize->{Automatic,28}
      ],
    {
      "List":>
        Export[
          StringReplace[".nb"->"-List.m"]@NotebookFileName[],
          BugsNotebookToBugs@$CurrentIDENotebook
          ],
      "Dataset":>
        Export[
          StringReplace[".nb"->"-Dataset.mx"]@
            IDEPath[$CurrentIDENotebook, Key["ActiveFile"]],
          BugsToDataset@BugsNotebookToBugs@$CurrentIDENotebook
          ],
      "Index":>
        BuildBugIndex[
          DirectoryName[IDEPath[$CurrentIDENotebook, Key["ActiveFile"]]], 
          $CurrentIDENotebook
          ],
      "Markdown":>
        BugsNotebookMarkdownSave[$CurrentIDENotebook]
      },
    Appearance->None,
    MenuAppearance->"Dropdown"
    ]


End[]


{
  addBugButton,
  exportBugsMenu
  }
