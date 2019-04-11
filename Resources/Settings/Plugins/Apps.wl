(* ::Package:: *)

(* ::Section:: *)
(*BTools AppManager Plugin*)


BeginPackage["`AppManager`"]


appManagerPluginCommands;


EndPackage[]


(* ::Subsection:: *)
(*Private*)


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*PreConfig*)


currentApp:=IDEPath[];


undefF[s_, h_:Identity, c_:"*"]:=
	Replace[
		Join[Names[c<>"`"<>s], Names[c<>"`*`"<>s],Names[c<>"`*`*`"<>s]],
		f:{___}:>
			ToExpression[
				SelectFirst[f, 
					ToExpression[#, StandardForm,
						Function[Null,
							Length@Join[
								OwnValues[#],
								DownValues[#],
								UpValues[#],
								SubValues[#]
								]>0,
							HoldAllComplete
							]
						]&,
					f[[1]]
					],
				StandardForm,
				h
				]
		];


whichPacF[s_, h_:Identity]:=
  ToExpression[
    Names["EasyIDE`Dependencies`BTools`*"<>s][[1]],
    StandardForm,
    h
    ];


openerSelector//ClearAll;


openerSelector[label_, Hold[listingFunction_], Hold[counter_]]:=
	Module[{flag, listing},
		With[{gather=fileNamesGather, format=formatFilePaths},
				EventHandler[
					dynamicActionMenu[label,
						flag;
						currentApp;
						If[ListQ@listing&&listing[[1]]==currentApp,
							listing,
							listing={currentApp, listingFunction}
							][[2]],
						Enabled->
							(Length@
								If[ListQ@listing&&listing[[1]]==currentApp,
									listing[[2]],
									counter
									]>0),
					TrackedSymbols:>{flag, currentApp}
					],
				{
					"MouseDown":>(flag=RandomReal[]),
					PassEventsDown->True
					}
				]
			]
	]
openerSelector[label_, types_, path_String, depth_:4]:=
	With[{gather=fileNamesGather, format=formatFilePaths},
		openerSelector[label,
			Hold[
				If[DirectoryQ@whichPacF["AppPath"][currentApp, path],
						format@
							gather[types, path],
						{}
						]
				],
			Hold[
				FileNames[
					types,
					whichPacF["AppPath"][currentApp, path],
					depth
					]
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*Formatting Objects*)


$paletteWidth=200;
$paletteContentWidth=200;


paletteButton[lbl_,cmd_,ops___]:=
	With[
		{
			uuid=CreateUUID[],
			nab=Lookup[{ops}, Enabled, True]
			},
		GradientButton[
			Replace[nab,
				{
					Verbatim[Dynamic][d_,e___]:>
						Dynamic[
							If[d===False, 
								Style[lbl, GrayLevel[.5]],
								Style[lbl, GrayLevel[.2]]
								], 
							e
							],
					False->
						Style[lbl, GrayLevel[.5]],
					_->
						Style[lbl, GrayLevel[.2]]
					}
				],
			Block[{$ContextPath={"System`"}}, Needs[$appName<>"`"]];
			cmd,
			ops,
			Method->"Queued",
			"UUID"->Automatic,
			FrameMargins->{{5,5},{2,0}},
			ImageSize->$paletteContentWidth,
			Appearance->"Palette"
			]/.
			Button[a___,
				Appearance->{app__Rule},
				b___]:>
				Button[a,
					Appearance->{
						app,
						Dynamic@
							If[TrueQ@paletteButtonRunning[uuid],
								"Pressed",
								Automatic
								]},
					b]
			];
paletteButton~SetAttributes~HoldRest;


paletteDialog//ClearAll;
paletteDialog[expr_,msg_,ops___]:=
	With[{nb=
		MessageDialog[
			Row@{msg,ProgressIndicator[Appearance->"Ellipsis"]},
			ops,
			WindowTitle->msg]
			},
		(NotebookClose@nb;#)&@CheckAbort[expr,NotebookClose@nb]
		];
paletteDialog~SetAttributes~HoldFirst;


paletteActionMenu[lbl_,actions_,ops___]:=
	GradientActionMenu[lbl,
		actions,
		ops,
		ImageSize->$paletteWidth,
		Appearance->"Palette",
		"UUID"->If[OptionValue[Method]==="Queued",Automatic,None]
		];


dynamicActionMenu[lbl_,actions_,ops___]:=
	With[{
		menu=
			paletteActionMenu[lbl,{"Label":>"Result"}],
		dynOps=Cases[Hold[ops],v:((Alternatives@@Keys@Options@Dynamic)->_):>v]
		},
		Dynamic[
			Insert[
				Insert[
					menu,
					FilterRules[{ops},Options@ActionMenu],
					{1,2,-1}
					]/.({"Label":>"Result"})->actions,
				FilterRules[{ops},Options@Button],
				{1,1,-1}
				],
			dynOps
			]
		];
dynamicActionMenu~SetAttributes~HoldRest;


checkboxGrid[vars:{{(_:>_)..}..}]:=
	Grid[
		ReplaceAll[vars,
			(tag_:>sym_):>
				Sequence@@{
					Checkbox@Dynamic@sym,
					Style[tag, Gray]
					}
			],
		Alignment->{Left, Bottom}
		];
checkboxGrid[vars:{(_:>_)..}]:=
	checkboxGrid[Thread[{vars}]];


(* ::Subsubsection::Closed:: *)
(*Functions*)


fileNamesGather//Clear
fileNamesGather[zargs___]:=
	Function[
		With[{pat=#,path={##2},dir=whichPacF["AppPath"][currentApp,##2]},
			Flatten@
				Riffle[
					Map[
						GatherBy[
							#,
							FileNameTake[#, FileNameDepth@dir+2]&
							]&,
						GatherBy[#,
							FileNameTake[#,
								{
									FileNameDepth@dir, 
									Min@{FileNameDepth@dir+1, FileNameDepth@#-1}
									}
								]&
							]
						]&@
					SortBy[
						{
							FileNameDepth@#+
								30*Boole@
									StringContainsQ[#,
										"__"~~(WordCharacter|" "|"$")..~~"__"
										]&,
							FileNameSplit[#][[-2]]&,
							FileBaseName[#]&,
							StringReverse@FileExtension[#]&
							}
						]@
						Select[
							StringContainsQ[StringTrim[#,dir],"__Future__"]||
							Not@
								StringContainsQ[StringTrim[#,dir],
									"__"~~(WordCharacter|" "|"$")..~~"__"]
							&]@
						FileNames[#, dir, \[Infinity]],
					Delimiter
					]
			]
		][zargs];


sysOpen[file_,app_:Automatic]:=
	With[
		{
			useApp=
				Switch[ToLowerCase@FileExtension[file],
					"m",
						"Mathematica",
					"html",
						"Atom",
					"mol"|"sdf"|"mol2"|"xyz"|"paclet",
						"TextWrangler",
					_,
						None
					]
			},
		Switch[$OperatingSystem,
			"MacOSX",
				If[!StringQ[useApp]||
					RunProcess[
						{
							"open",
							file,
							"-a",
							useApp
							},
						"ExitCode"
						]=!=0,
					IDEOpen[file]
					],
			_,
				IDEOpen[file]
			]
		];


formatFilePaths//Clear
formatFilePaths[zargs___]:=
	Function[
		Function[DeleteDuplicates[#, If[#===Delimiter, False, Equal[##]]&]]@
		Flatten@
			Table[
				With[{n=n},
					If[StringQ@n,
						With[
							{
								fp=
									FileNameDrop[
										FileNameJoin@{DirectoryName@n,FileBaseName@n},
										FileNameDepth@whichPacF["AppDirectory"][currentApp]
										]
									},
							With[{l=FileNameDepth[fp]},
								If[l>1,
									MapIndexed[
										If[#2[[1]]===l-1,
											If[#2[[1]]>1, StringRepeat["  ", #2[[1]]-1], ""]<>#:>sysOpen[n],
											With[{p=FileNameDrop[n, #2[[1]]-l+1]},
												If[#2[[1]]>1, StringRepeat["  ", #2[[1]]-1], ""]<>#<>"\[RightGuillemet]":>
													sysOpen[p]
												]
											]&,
										Rest@FileNameSplit[fp]
										],
									fp:>sysOpen[n]
									]
								]
							],
						n
						]
					],
				{n, #}
				]
			][zargs];


gitRepoQ[]:=
	TrueQ@whichPacF["GitRepoQ"]@whichPacF["AppPath"]@currentApp


loadGitBranches[forceReload:True|False:False]:=
	If[forceReload,
		Set[$gitBranches,
			If[gitRepoQ[],
				whichPacF["GitListWithCurrentBranch"]@
					whichPacF["AppPath"]@currentApp,
				{}
			 ]
 		],
		Replace[$gitBranches,
			Except[_List]:>
	 		loadGitBranches[True]
	 	]
		]


inputDialog[header_]:=
	DialogInput[
		{var},
		Column@Flatten@{
			header,
			EventHandler[
				InputField[Dynamic[var], String, BoxID->"input-field"],
				{"ReturnKeyDown":>DialogReturn[var]}
				]
			},
		NotebookDynamicExpression:>
			Refresh[
				FrontEnd`MoveCursorToInputField[
					EvaluationNotebook[], "input-field"
					],
				None
				]
		]


(* ::Subsubsection::Closed:: *)
(*Regen*)


regenActions=
	"Regenerate"->
	  {
  		"Loader":>
  		  (
         AppExecute["RegenerateLoaderFile", currentApp];
         CreatePopupMessage["Regenerated"]
         ),
  		"PacletInfo":>
  			(
  				AppExecute["RegeneratePacletInfo", currentApp];
  				CreatePopupMessage["Regenerated"];
  				),
  		"Directories":>
  			(
  				whichPacF["AppRegenerateDirectories"][currentApp];
  				),
     "Context Loaders":>
       (
         AppExecute["RegenerateContextLoaders", currentApp];
         CreatePopupMessage["Regenerated"]
         ),
  		"LoadInfo":>
  			(
  				sysOpen@whichPacF["AppRegenerateLoadInfo"][currentApp]
  				),
    	"BundleInfo":>
  			sysOpen@whichPacF["AppRegenerateBundleInfo"]@currentApp
  		}


(* ::Subsubsection::Closed:: *)
(*UpdateDependencies*)


updateDeps[]:=
	Module[{popup, r},
    popup = 
      CreateMessagePopup@
        Row@{"Updating dependencies", ProgressIndicator[Appearance->"Ellipsis"]};
	  AppExecute["UpdateDependencies", IDEPath[$CurrentIDENotebook]];
	  NotebookDelete[popup];
	  CreateMessagePopup["Dependencies updated"];
	  ];


(* ::Subsubsection::Closed:: *)
(*New*)


newPackage[]:=
  IDEOpen[Notebook[{}, StyleDefinitions->FrontEnd`FileName[{"BTools"}, "CodePackage.nb"]]];


(* ::Subsubsection::Closed:: *)
(*Git*)


(*gitCommit=
	paletteButton["Git Commit",
		whichPacF["AppGitCommit"][currentApp],
		Enabled->
			Dynamic[
				gitRefresh;gitRepoQ[], 
				TrackedSymbols:>{gitRefresh, currentApp}
				]
		];
gitOps=
	paletteActionMenu["Git Actions",
		{
			"Init":>
				(Quiet@whichPacF["AppGitInit"][currentApp];gitRefresh=RandomReal[]),
			Delimiter,
			"Edit README":>
				sysOpen@
					If[FileExistsQ@whichPacF["AppPath"][currentApp, "README.nb"],
						whichPacF["AppPath"][currentApp, "README.nb"],
						whichPacF["AppPath"][currentApp, "README.md"]
						],
			"Edit Ignore":>
				sysOpen@whichPacF["AppPath"][currentApp, ".gitignore"],
			"Edit Exclude":>
				sysOpen@whichPacF["AppPath"][currentApp, ".git", "info", "exclude"],
			Delimiter,
			"Regenerate README":>
				sysOpen@
					CopyFile[
						whichPacF["AppPath"]["BTools","Resources","Templates","README.nb"],
						whichPacF["AppPath"][currentApp,"README.nb"],
						OverwriteTarget->True
						],
			"Regenerate Ignore":>
				sysOpen@Quiet@
					whichPacF["AppRegenerateGitIgnore"][currentApp],
			"Regenerate Exclude":>
				sysOpen@Quiet@
					whichPacF["AppRegenerateGitExclude"][currentApp]
			}
		];
gitBranch=
	EventHandler[
		dynamicActionMenu[
			"Switch Branches",
			Replace[loadGitBranches[],
				l:{__}:>
					Join[
						{Style[First@l, Bold, Italic]:>None},
						Map[
							Function[
								#:>
									If[gitRepoQ[],
										CompoundExpression[
											Quiet@
												whichPacF["GitSwitchBranch"][
													whichPacF["AppPath"]@currentApp,
													#
													];
											loadGitBranches[True]
											]
										]
									],
							Rest@l
							], 
						{
							Delimiter, 
							"New Branch":>
								Replace[
									inputDialog["Provide a name for the branch:"],
									s_String:>
										(
											Quiet@
												whichPacF["GitSwitchBranch"][
													whichPacF["AppPath"]@currentApp,
													StringDelete[s, Except[WordCharacter]]
													];
											loadGitBranches[True]
											)
									]
							}
						]
					],
			Enabled->
				Dynamic[
					gitRefresh;gitRepoQ[], 
					TrackedSymbols:>{gitRefresh, currentApp}
					],
			Method->"Queued",
			TrackedSymbols:>{currentApp, $gitBranches}
			],
	"MouseEntered":>
		loadGitBranches[True]
	];*)


(* ::Subsubsection::Closed:: *)
(*GitHub*)


(*gitHubPush=
	paletteButton["Push to GitHub",
		Quiet@whichPacF["AppGitHubPush"][currentApp];
		SystemOpen[whichPacF["AppGitHubRepo"][currentApp,None]]
		];
gitHubConfigure=
	paletteButton["Create GitHub Repo",
		Quiet@whichPacF["AppGitHubConfigure"][currentApp]
		];
gitHubDelete=
	paletteButton["Delete GitHub Repo",
		Quiet@whichPacF["AppGitHubDelete"][currentApp]
		];*)


(* ::Subsubsection::Closed:: *)
(*Paclet*)


(*makePacletButton=
	paletteButton["Bundle Paclet",
		paletteDialog[
			With[{r=whichPacF["AppPacletBundle"][currentApp]},
					SystemOpen[DirectoryName[r]]
					],
			"Making Paclet"
			]
		];*)


(* ::Subsubsection:: *)
(*Publish*)


publishApp[]:=
  CreateAttachedInputDialog[
    <|
      "Header"->"Publish App",
      "State"->Dynamic[publishAppState],
      "Fields"-> <|
        <|
          "ID"->"Settings",
          "Name"->None,
          "Type"->{CheckboxBar, 
            {
              "GH"->"Push To GitHub",
              "SV"->"Push To Server",
              "PI"->"Update PacletInfo",
              "PS"->"Publish Server"
              },
            Appearance->"Horizontal"->{Automatic, 2}
            },
          "Default"->{
            If[gitPushFlag=!=False, "GH", Nothing],
            If[pushToServerFlag=!=False, "SV", Nothing],
            If[updatePacletFlag=!=False, "PI", Nothing],
            If[TrueQ[publishServerFlag], "PS", Nothing]
            }
          |>
        |>,
      "SubmitAction"->
        Function[
          gitPushFlag=MemberQ[#Settings, "GH"];
          pushToServerFlag=MemberQ[#Settings, "SV"];
          updatePacletFlag=MemberQ[#Settings, "PI"];
          publishServerFlag=MemberQ[#Settings, "PS"];
          makeSiteFlag=False;
          backupFlag=False;
          Module[{popup, r},
            popup = 
              CreateMessagePopup@
                Row@{"Publishing", ProgressIndicator[Appearance->"Ellipsis"]};
            r=
  		      		AppExecute[
  		      		  "Publish",
        					currentApp,
        					"PublishServer"->TrueQ[publishServerFlag],
        					"MakeSite"->TrueQ[makeSiteFlag],
        					"PushToGitHub"->gitPushFlag=!=False,
        					"PacletBackup"->backupFlag=!=False,
        					"PushToServer"->pushToServerFlag=!=False,
        					"UpdatePaclet"->updatePacletFlag=!=False
        					];
            NotebookDelete[popup];
            CreateMessagePopup@"Published"
      			 (*Quiet[
      			  If[gitPushFlag=!=False,
      						sysOpen@whichPacF["AppGitHubRepo"][currentApp]
      						];
      					If[publishServerFlag,
      						Replace[
      							whichPacF["PacletServerDeploymentURL"][],
      							s_String\[RuleDelayed]sysOpen@s
      							]
      						];
      					]*)
      				]
          ]
      |>
    ];


(* ::Subsubsection::Closed:: *)
(*CreateRelease*)


createRelease[]:=
  Module[{pop, r, url},
    pop = CreatePopupMessage["Drafting release..."];
    r = whichPacF["AppGit"]["GitHubCreateRelease", currentApp];
    NotebookDelete[pop];
    url = Replace[r["HTMLURL"], URL[s_]:>s];
    If[StringQ@url,
      CreatePopupMessage[StringForm["Created release at ``", url]],
      CreatePopupMessage["Failed to create release"]
      ];
    ]


(* ::Subsubsection::Closed:: *)
(*Toolbar*)


addAppsToolbar[]:=CreateMessagePopup["Toolbar still in progress! Sorry!"];


(* ::Subsubsection::Closed:: *)
(*Exported*)


appManagerPluginCommands =
  {
    "Publish":>
      publishApp[],
    "Create Release":>
      createRelease[],
    "Update Dependencies":>
      updateDeps[],
     regenActions,
     "New Package":>
       newPackage[],
     "Open Toolbar":>
       addAppsToolbar[]
    };


(* ::Subsubsection::Closed:: *)
(*End*)


End[];


(* ::Subsection:: *)
(*Exports*)


appManagerPluginCommands
