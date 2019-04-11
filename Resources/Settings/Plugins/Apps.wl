(* ::Package:: *)

(* ::Section:: *)
(*BTools AppManager Plugin*)


BeginPackage["`AppManager`"]


appManagerPluginCommands;


EndPackage[]


(* ::Subsection:: *)
(*Private*)


Begin["`Private`"];


(* ::Text:: *)
(*I just pulled everything from the AppManagerPalette to integrate. Things will be updated bit by bit.*)


(* ::Subsubsection:: *)
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


(* ::Subsubsection:: *)
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


(* ::Subsubsection:: *)
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
					SystemOpen[file]
					],
			_,
				SystemOpen[file]
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


(* ::Subsubsection:: *)
(*Apps*)


(*selAllAppsBox=
	checkboxGrid@{
		"Use All Apps":>$selectAllApps
		};*)


(*appOpener=
	dynamicActionMenu["Open App",
		Table[
			With[{n=n},FileBaseName@n:>sysOpen@n],
			{n,appList}
			],
		Enabled->(Length@appList>0),
		TrackedSymbols:>{appList}
		];*)


(*appChooser=
	With[{bpop=
		GradientButtonPopupMenu[Dynamic@currentApp,{"apps"},
			sysOpen@whichPacF["AppDirectory"]@#&,
			ImageSize->$paletteWidth]
			},
		Dynamic[
			Insert[bpop,
				Enabled->(Length@appList>0),
				{1,2,-1}]/.{
					{"apps"}->(FileBaseName/@appList),
					("apps"->"apps")->
						RuleCondition[
							Thread[(FileBaseName/@appList)->
								(FileBaseName/@appList)],
							True
							]
					},
			TrackedSymbols:>{appList}
			]
		];*)


(* ::Subsubsection:: *)
(*Packages*)


(*packageOpener=
	With[{gather=fileNamesGather, format=formatFilePaths},
		openerSelector["Packages",
			Hold@
				With[
					{
						bits=
							Replace[
								DeleteDuplicatesBy[If[AtomQ[#], RandomReal[], First@#]&]/@
								{
									format@
										gather["*.nb"|"*.m"|"*.wl", "Packages"],
									Select[AtomQ@#||First@#=!="init"&]@
										format@
											gather["*.m"|"*.wl", "Kernel"],
									Select[!StringEndsQ[First@#, "Info"]&]@
										format@
											SortBy[
												FileNames["*.m"|"*.wl", whichPacF["AppDirectory"][currentApp]],
												{StringReverse@*FileExtension}
												]
									},
								{}->Nothing,
								1
								]
						},
					Flatten@Riffle[bits, Delimiter]
					],
			Hold@
				Join[
					gather["*.nb"|"*.m"|"*.wl", "Packages"],
					Select[FileBaseName@#=!="init"&]@gather["*.m"|"*.wl", "Kernel"],
					Select[!StringEndsQ[FileBaseName@#, "Info"]&]@
						FileNames["*.m"|"*.wl", whichPacF["AppDirectory"][currentApp]]
					]
			]
		];*)


(* ::Subsubsection:: *)
(*FE*)


(*feOpener=
	openerSelector["Front End", "*.nb", "FrontEnd", 4];*)


(* ::Subsubsection:: *)
(*Private Opener*)


(*privateOpener=
	openerSelector["Private", "*.nb"|"*.wl"|"*.m", "Private", 5];*)


(* ::Subsubsection:: *)
(*Template Opener*)


(*templateOpener=
	openerSelector["Resources", "*.nb"|"*.wl"|"*.m"|".tr", "Resources", 8];*)


(* ::Subsubsection:: *)
(*Config*)


(*configOpener=
	With[{gather=fileNamesGather, format=formatFilePaths},
		openerSelector["Config",
			Hold@
				format@
					SortBy[FileNameDepth]@
						Join[
							FileNames["*Info.m"|"*Info.wl",
								whichPacF["AppDirectory"][currentApp]
								],
							gather["*.m"|"*.wl","Config"]
							],
			Hold@
				Join[
					FileNames["*.m"|"*.wl",whichPacF["AppDirectory"][currentApp]],
					gather["*.m"|"*.wl","Config"]
					]
			]
		];*)


(* ::Subsubsection:: *)
(*Project*)


(*projOpener=
	With[{gather=fileNamesGather, format=formatFilePaths},
		openerSelector["Project",
			Hold@
				format@
					SortBy[FileNameDepth]@
						Join[
							FileNames["README*",
								whichPacF["AppDirectory"][currentApp]
								],
							FileNames[
								"*.png"|"*.html"|"*.md"|"*.nb",
								whichPacF["AppDirectory"][currentApp,"project"],
								\[Infinity]
								]
							],
			Hold@
				Join[
					FileNames["README*",
						whichPacF["AppDirectory"][currentApp]
						],
					FileNames[
						"*.png"|"*.html"|"*.md"|"*.nb",
						whichPacF["AppDirectory"][currentApp,"project"],
						\[Infinity]
						]
					]
			]
		]*)


(* ::Subsubsection:: *)
(*Regen*)


(*regenMenu=
	paletteActionMenu["Regenerate", {
		"Loader":>
			sysOpen@whichPacF["AppRegenerateInit"][currentApp],
		"PacletInfo":>
			(
				sysOpen@whichPacF["AppRegeneratePacletInfo"][currentApp]
				),
		"Directories":>
			(
				whichPacF["AppRegenerateDirectories"][currentApp];
				sysOpen@whichPacF["AppDirectory"]@currentApp
				),
		"LoadInfo":>
			(
				sysOpen@whichPacF["AppRegenerateLoadInfo"][currentApp]
				)
		}
	];*)


(* ::Subsubsection:: *)
(*AddDependency*)


(*updateDeps=
	paletteButton["Add Dependency",
		whichPacF["AppAddDependency"][currentApp]
		];*)


(* ::Subsubsection:: *)
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


(* ::Subsubsection:: *)
(*New*)


(*newMenu=
	paletteActionMenu["New Notebook",{
		"Code":>
			SetOptions[whichPacF["GenerateNewPackage"][],
				StyleDefinitions\[Rule]
					FrontEnd`FileName[
						Evaluate@{whichPacF["$PackageName"]},
						"CodeNotebook.nb"
						]
				],
		"Package":>
			whichPacF["GenerateNewPackage"][],
		"Data":>
			With[{old=Notebooks[]},
				FrontEndTokenExecute["NewPackage"];
				whichPacF["MakeIndentable"][
					First@DeleteCases[Notebooks[], Alternatives@@old],
					"Code"
					]
				],
		"Text":>
			FrontEndTokenExecute["NewText"],
		"Script":>
			FrontEndTokenExecute["NewScript"],
		"Palette":>
			whichPacF["PaletteTemplateNotebook"][],
		"HTML"\[RuleDelayed]
			whichPacF["HTMLTemplateNotebook"][],
		"Service"\[RuleDelayed]
			If[FileExistsQ@whichPacF["AppPath"][$appName, "Resources","Templates",
						"ServiceConnectionTemplate.nb"],
				Off[General::shdw];
				System`CellFrameStyle;
				On[General::shdw];
				CreateDocument@
					Import@
						whichPacF["AppPath"][$appName, "Resources","Templates",
							"ServiceConnectionTemplate.nb"
							]
				],
		"Curated Data"\[RuleDelayed]
			If[FileExistsQ@whichPacF["AppPath"][$appName, "Resources","Templates",
						"CuratedDataTemplate.nb"],
				Off[General::shdw];
				System`CellFrameStyle;
				On[General::shdw];
				CreateDocument@
					Import@
						whichPacF["AppPath"][$appName, "Resources","Templates",
							"CuratedDataTemplate.nb"
							]
				]
		}];*)


(* ::Subsubsection:: *)
(*Add*)


(*overwriteBox=
	Grid[{
		{Checkbox@Dynamic@overwriteFlag,Style["Overwrite existing",Gray]}
		},
		Alignment->Bottom
		];*)


(*With[{currentApp=HoldPattern[currentApp]},
addContent[loc_,cont:Except[True|False]:None,
	name:_String|_List|None:None,allowOpen:True|False:True]:=
	With[{
			files=
				Replace[cont,{
					Directory:>
						SystemDialogInput["Directory",".nb"],
					None:>
						SystemDialogInput["FileOpen",".nb"]
					}]
			},
			With[{block=
				Hold@
					If[name===None,
						whichPacF["AppAddContent"][ReleaseHold@currentApp,files,
							Sequence@@Flatten@{loc},
							OverwriteTarget\[Rule]TrueQ@overwriteFlag],
						whichPacF["AppAddContent"][ReleaseHold@currentApp,files,
							Sequence@@DeleteCases[
								Flatten@{name,loc},
								Except[_String]
								],
							OverwriteTarget\[Rule]TrueQ@overwriteFlag]
						]
				},
				If[allowOpen,
					ReleaseHold@block,
					Block[{SystemOpen=Null},
						ReleaseHold@block
						]
					]
				];
			With[{c=ReleaseHold@currentApp},
				currentApp="";
				currentApp=c
				]
			]
	];*)


(*currentExtensionPath[appBit_,nbo_:Automatic]:=
	With[{nb=Replace[nbo,Automatic:>InputNotebook[]]},
		With[{base=If[appBit===None,$Failed,Quiet@NotebookFileName@nb]},
			If[base===$Failed,
				Replace[
					If[appBit===None,
						Hold@Evaluate[WindowTitle/.AbsoluteOptions[nb,WindowTitle]],
						WindowTitle/.AbsoluteOptions[nb,WindowTitle]
						],{
						Hold[s_]|
							s_String?(StringMatchQ[""|("Untitled-"~~NumberString)]):>
							Replace[
								SystemDialogInput["FileSave",
									whichPacF["AppDirectory"]@@
										Flatten@{currentApp,
											If[appBit===None,Nothing,appBit],
											s<>
												Replace[CurrentValue[nb,
														StyleDefinitions],{
														"Package.nb"|
															Notebook[{
																___,
																Cell[
																	StyleData[
																		StyleDefinitions->"Package.nb"]],
																___
																},
																___]->
															".wl",
														"Notepad.nb"|
															Notebook[{
																___,
																Cell[
																	StyleData[
																		StyleDefinitions->"Notepad.nb"]],
																___
																},
																___]->
															".txt",
														"Script.nb"|
															Notebook[{
																___,
																Cell[
																	StyleData[
																		StyleDefinitions->"Script.nb"]],
																___
																},
																___]->
															".wls",
														_->
														".nb"
													}]
											}
									],
								f_String:>
									If[StringMatchQ[f,whichPacF["AppDirectory"][currentApp]~~__],
										RotateRight@FileNameSplit@
											FileNameDrop[f,
												FileNameDepth@whichPacF["AppDirectory"][currentApp]],
										{FileNameTake[f]}
										]
								]
						}],
				{FileNameTake@base}
				]
			]
		];*)


(*addStuff=
	paletteActionMenu["Add File",
		{
			"Package":>addContent["Packages"],
			"Palette":>addContent["Palettes"],
			"Stylesheet":>addContent["Stylesheets"],
			Delimiter,
			"Ref Page":>addContent["Symbols"],
			"Guide":>addContent["Guides"],
			"Tutorial":>addContent["Tutorials"],
			Delimiter,
			"Application":>
				addContent[""],
			"Misc"\[RuleDelayed]
				addContent[{"Private","Misc"}],
			"Private":>
				addContent["Private"],
			"Custom":>
				Replace[SystemDialogInput["FileOpen",".nb"],
					f_String?FileExistsQ:>
						addContent["",FileNameTake@f,
							Sequence@@Most@FileNameSplit@
								FileNameDrop[
									SystemDialogInput["FileSave",
										whichPacF["AppDirectory"][currentApp]<>"."<>FileExtension@f],
									FileNameDepth@whichPacF["AppDirectory"][currentApp]
									]
							]
					]
			},
		Method\[Rule]"Queued",
		ImageSize\[Rule]$paletteContentWidth
		];*)


(*addDir=
	paletteActionMenu["Add Directory",
		{
			"Package":>addContent["Packages",Directory],
			"Palette":>addContent["Palettes",Directory],
			"Stylesheet":>addContent["Stylesheets",Directory],
			Delimiter,
			"Ref Page":>addContent["Symbols",Directory],
			"Guide":>addContent["Guides",Directory],
			"Tutorial":>addContent["Tutorials",Directory],
			Delimiter,
			"Application":>
				addContent["",Directory],
			"Misc"\[RuleDelayed]
				addContent[{"Private","Misc"},Directory],
			"Private":>
				addContent["Private",Directory],
			"Custom":>
				Replace[SystemDialogInput["Directory",".nb"],
					d_String?DirectoryQ:>
						addContent[{},FileBaseName@d,
							Sequence@@Most@FileNameSplit@
								FileNameDrop[
									SystemDialogInput["Directory",
										whichPacF["AppDirectory"][currentApp]],
									FileNameDepth@whichPacF["AppDirectory"][currentApp]
									]
							]
					]
			},
		Method\[Rule]"Queued",
		ImageSize\[Rule]$paletteContentWidth
		];*)


(*addNB=
	paletteActionMenu["Add Current",
		{
			"Package":>
				addContent["Packages",
					InputNotebook[],
					First@currentExtensionPath["Packages"]],
			"Palette":>
				addContent["Palettes",
					InputNotebook[],
					First@currentExtensionPath["Palettes"]],
			"Stylesheet":>
				addContent["Stylesheets",
					InputNotebook[],
					First@currentExtensionPath["Stylesheets"]],			
			Delimiter,
			"Ref Page":>
				addContent["Symbols",
					InputNotebook[],
					First@currentExtensionPath["Symbols"]],
			"Guide":>
				addContent["Guides",
					InputNotebook[],
					First@currentExtensionPath["Guides"]],
			"Tutorial":>
				addContent["Tutorials",
					InputNotebook[],
					First@currentExtensionPath["Tutorials"]],
			Delimiter,
			"Application":>
				addContent["",InputNotebook[],
						First@currentExtensionPath[""]],
			"Misc"\[RuleDelayed]
				addContent[{"Private","Misc"},
					InputNotebook[],
					First@currentExtensionPath[{"Private","Misc"}]],
			"Private":>
				addContent[{"Private"},InputNotebook[],
					First@currentExtensionPath["Private"]],
			"Custom":>
				addContent["",InputNotebook[],
					currentExtensionPath[None]]
			},
		Method\[Rule]"Queued",
		ImageSize\[Rule]$paletteContentWidth
		];*)


(* ::Subsubsection:: *)
(*Docs Openers*)


(*refOpener=
	dynamicActionMenu["Open Ref Page",
		Table[
			With[{n=n},
				StringJoin@Riffle[FileNameSplit@#,"\[VeryThinSpace]\[RightGuillemet]\[VeryThinSpace]"]&@
				FileNameDrop[
					FileNameJoin@{DirectoryName@n,FileBaseName@n},
					FileNameDepth@whichPacF["AppDirectory"][currentApp,"ReferencePages"]
				]:>sysOpen@n],
			{n,FileNames["*.nb",
				whichPacF["AppDirectory"][currentApp,"ReferencePages"],\[Infinity]]}],
		Enabled->
			(Length@FileNames["*.nb",
				whichPacF["AppDirectory"][currentApp,"ReferencePages"],\[Infinity]]>0),
		TrackedSymbols:>{currentApp}
		];*)


(*guideOpener=
	dynamicActionMenu["Open Guide",
			Table[
				With[{n=n},
					StringJoin@Riffle[FileNameSplit@#,"\[VeryThinSpace]\[RightGuillemet]\[VeryThinSpace]"]&@
					FileNameDrop[
						FileNameJoin@{DirectoryName@n,FileBaseName@n},
						FileNameDepth@whichPacF["AppDirectory"][currentApp,"Guides"]
					]:>sysOpen@n],
				{n,FileNames["*.nb",whichPacF["AppDirectory"][currentApp,"Guides"],\[Infinity]]}],
			Enabled->
				(Length@FileNames["*.nb",whichPacF["AppDirectory"][currentApp,"Guides"],\[Infinity]]>0),
		TrackedSymbols:>{currentApp}
		];*)


(*tutorialOpener=
	dynamicActionMenu["Open Tutorial",
			Table[
				With[{n=n},
					StringJoin@Riffle[FileNameSplit@#,"\[VeryThinSpace]\[RightGuillemet]\[VeryThinSpace]"]&@
					FileNameDrop[
						FileNameJoin@{DirectoryName@n,FileBaseName@n},
						FileNameDepth@whichPacF["AppDirectory"][currentApp,"Tutorials"]
					]:>sysOpen@n],
				{n,FileNames["*.nb",whichPacF["AppDirectory"][currentApp,"Tutorials"],\[Infinity]]}],
			Enabled->
				(Length@FileNames["*.nb",whichPacF["AppDirectory"][currentApp,"Tutorials"],\[Infinity]]>0),
		TrackedSymbols:>{currentApp}
		];*)


(* ::Subsubsection:: *)
(*Doc Autogenerate*)


(*docAutoButton=
	paletteActionMenu["Autogenerate from App",
		{
			"Ref Page":>
				Replace[NotebookRead@InputNotebook[],{
					s_String:>
						If[StringEndsQ[s,"`"],
							whichPacF["DocGenGenerateSymbolPages"][s],
							ToExpression[s,StandardForm,
								whichPacF["DocGenGenerateSymbolPages"]
								]
							]
					}],
			"Guide Page":>
				Replace[NotebookRead@InputNotebook[],
					s_String:>whichPacF["DocGenGenerateGuide"][s]
					],
			"Docs Paclet":>
				Replace[NotebookRead@InputNotebook[],
					s_String:>
						whichPacF["DocGenGenerateDocumentation"][s]
					],
			Delimiter,
			"Ref Page HTML":>
				Replace[NotebookRead@InputNotebook[],
					s_String:>
						With[{pages=
							If[StringEndsQ[s,"`"],
								whichPacF["DocGenGenerateSymbolPages"][s,Visible->False],
								ToExpression[s,StandardForm,
									Function[Null,
										whichPacF["DocGenGenerateSymbolPages"][#,Visible->False],
										HoldFirst
										]
									]
								]
							},
							sysOpen@First@Flatten@List@
								whichPacF["GenerateHTMLDocumentation"][s,
									CloudDeploy->True,
									"CopyAssets"->False
									]
							]
					],
			"Paclet HTML":>
				Replace[NotebookRead@InputNotebook[],
					s_String:>
						Replace[
							Lookup[
								whichPacF["DocGenGenerateDocumentation"][
									s,
									False,
									CloudDeploy->True,
									"CopyAssets"->False
									],
								"HTML"
								],
							{___,c_CloudObject,___}:>sysOpen@c
							]
					]
			}];*)


(* ::Subsubsection:: *)
(*Doc Buttons*)


(*docTemp=
	paletteActionMenu["Make Template",{
		"Symbol Page":>
			With[{s=NotebookRead@InputNotebook[]},
				If[MatchQ[s,_String?(StringMatchQ[#,("$"|"`"|WordCharacter)..]&)],
					CreateDocument@whichPacF["SymbolPageTemplate"]@{s},
					CreateDocument@whichPacF["SymbolPageTemplate"]@{"Symbol"}
					]
				],
		"Guide Page":>
			With[{s=NotebookRead@InputNotebook[]},
				If[MatchQ[s,_String],
					CreateDocument@whichPacF["GuideTemplate"]@{s},
					CreateDocument@whichPacF["GuideTemplate"]@{"Guide"}
					]
				],
		"Tutorial Page":>
			With[{s=NotebookRead@InputNotebook[]},
				If[MatchQ[s,_String],
					CreateDocument@whichPacF["TutorialTemplate"]@{s},
					CreateDocument@whichPacF["TutorialTemplate"]@{"Tutorial"}
					]
				]
		},
		Method->"Queued"
		];
(*		"App Tutorial Template":>
			paletteDialog[
				With[{docs=(
					Needs[currentApp<>"`"];
					whichPacF["AppTutorialNotebook"]@(currentApp)
					)},
					CreateDocument@docs
					],
				"Generating tutorial template"
				];*)
docGen=
	paletteActionMenu["Generate from Notebook",{
		"Symbol Pages":>
			With[{nb=InputNotebook[]},
				paletteDialog[
					With[{s=NotebookRead@nb},
						If[MatchQ[s,
							_String?(StringMatchQ[#,"$"|"`"|WordCharacter..]&)],
							Block[{$DocActive=currentApp},
								ToExpression[s, StandardForm,
									whichPacF["DocGenGenerateSymbolPages"]
									]
								],
							Block[{$DocActive=currentApp},
								whichPacF["DocGenGenerateSymbolPages"]@nb
								]
							]
						],
					"Generating symbol pages"
					]
				],
		"Guide Pages":>
			With[{nb=InputNotebook[]},
				paletteDialog[
					Block[{$DocActive=currentApp},
						whichPacF["DocGenGenerateGuide"]@nb
						],
					"Generating guide pages"
					]
				],
		"Tutorial Pages":>
			With[{nb=InputNotebook[]},
				paletteDialog[
					Block[{$DocActive=currentApp},
						whichPacF["DocGenGenerateTutorial"]@nb
						],
					"Generating tutorial pages"
					]
				]
		},
		Method->"Queued"
		];
docSave=
	paletteActionMenu["Generate and Save",{
		"Symbol Pages":>
			With[{nb=InputNotebook[]},
				paletteDialog[
					Block[{$DocActive=currentApp},
						Quiet@
							CreateDirectory[
								whichPacF["AppDirectory"][currentApp,"Symbols"],
								CreateIntermediateDirectories->True
								];
						whichPacF["DocGenSaveSymbolPages"][
							nb,
							whichPacF["AppDirectory"][currentApp,"Symbols"],
							False
							]
						],
					"Generating symbol pages"
					]
				],
		"Guide Pages":>
			With[{nb=InputNotebook[]},
				paletteDialog[
					Block[{$DocActive=currentApp},
						Quiet@
							CreateDirectory[
								whichPacF["AppDirectory"][currentApp,"Guides"],
								CreateIntermediateDirectories->True
								];
						whichPacF["DocGenSaveGuide"][
							nb,
							whichPacF["AppDirectory"][currentApp,"Guides"],
							False
							]
						],
					"Generating guide pages"
					]
				],
		"Tutorial Pages":>
			With[{nb=InputNotebook[]},
				paletteDialog[
					Block[{$DocActive=currentApp},
						whichPacF["DocGenGenerateTutorial"][
							nb,
							whichPacF["AppDirectory"][currentApp,"Tutorials"],
							False
							]
						],
					"Generating tutorial pages"
					]
				],
		Delimiter,
		"Symbol Web Pages":>
			With[{nb=InputNotebook[]},
				paletteDialog[
					sysOpen@First@Flatten@List@
						With[{s=NotebookRead@nb},
							If[MatchQ[s,
								_String?(StringMatchQ[#,"$"|"`"|WordCharacter..]&)],
								Block[{$DocActive=currentApp},
									ToExpression[s, StandardForm,
										Function@
										whichPacF["DocGenGenerateSymbolPages"][
											#,
											Visible->False,
											"PostFunction"->
												Function[page,
													Function[NotebookClose[page];#]@
													whichPacF["GenerateHTMLDocumentation"][page,
														CloudDeploy->True,
														"CopyAssets"->False
														]
													]
											]
										]
									],
								Block[{$DocActive=currentApp},
									whichPacF["DocGenGenerateSymbolPages"][nb,
										Visible->False,
										"PostFunction"->
											Function[page,
												Function[NotebookClose[page];#]@
												whichPacF["GenerateHTMLDocumentation"][page,
													CloudDeploy->True,
													"CopyAssets"->False
													]
												]
										]
									]
								]
							],
					"Generating symbol web pages"
					]
				],
		"Guide Web Pages":>
			With[{nb=InputNotebook[]},
				paletteDialog[
					Block[{
						$DocActive=currentApp,
						notebooks
						},
						sysOpen@First@Flatten@List@
							whichPacF["DocGenGenerateGuide"][nb,
								Visible->False,
								"PostFunction"->
									Function[page,
										Function[NotebookClose[page];#]@
										whichPacF["GenerateHTMLDocumentation"][page,
											CloudDeploy->True,
											"CopyAssets"->False
											]
										]
								];
						],
					"Generating guide web pages"
					]
				],
		"Tutorial Web Pages":>
			With[{nb=InputNotebook[]},
				paletteDialog[
					Block[{$DocActive=currentApp,notebooks},
						notebooks=
							whichPacF["DocGenGenerateTutorial"][
								nb,
								whichPacF["AppDirectory"][currentApp,"Tutorials"],
								False,
								Visible->False
								];
						Function[
							Map[NotebookClose,Flatten@{notebooks}];
							sysOpen@First@Flatten@{#}
							]@
							whichPacF["GenerateHTMLDocumentation"][
								notebooks,
								CloudDeploy->True,
								"CopyAssets"->False
								]
						],
					"Generating tutorial pages"
					]
				]
		},
		Method->"Queued"
		];*)


(* ::Subsubsection:: *)
(*App Docs*)


(*appDocs=
	dynamicActionMenu["Application Symbols",
		Join[
			{
				"Symbol Page Template":>
					paletteDialog[
						With[{docs=
							whichPacF["AppSymbolNotebook"]@(currentApp)
							},
							CreateDocument@docs
							],
						"Creating symbol page template"
						],
				Delimiter
				},
			With[{pkgs=FileBaseName/@whichPacF["AppPackages"][currentApp]},
				Map[
					#<>" Symbol Page Template":>
						paletteDialog[
							CreateDocument@whichPacF["AppPackageSymbolNotebook"][currentApp,#],
							"Creating doc template"
							]&,
					pkgs
					]
				],
			{
				Delimiter,
				"Save All Pages":>
					paletteDialog[
						With[{pkgs=FileBaseName/@whichPacF["AppPackages"][currentApp]},
							Map[
								With[{nb=
									CreateDocument[
										whichPacF["AppPackageSymbolNotebook"][currentApp,#],
										Visible->False
										]
									},
									whichPacF["DocGenSaveSymbolPages"][
										nb,
										whichPacF["AppDirectory"][currentApp,"Symbols"],
										False
										];
									NotebookClose[nb]
									]&,
								pkgs
								]
							],
						"Creating ref pages"
						],
				Delimiter
				},
			With[{pkgs=FileBaseName/@whichPacF["AppPackages"][currentApp]},
				Map[
					"Save "<>#<>" Pages":>
						paletteDialog[
							With[{nb=
								CreateDocument[
									whichPacF["AppPackageSymbolNotebook"][currentApp,#],
									Visible->False
									]
								},
								whichPacF["DocGenSaveSymbolPages"][
									nb,
									whichPacF["AppDirectory"][currentApp,"Symbols"],
									False
									];
								NotebookClose[nb]
								],
							"Creating ref pages"
							]&,
					pkgs
					]
				]
			],
			Enabled->(Length@whichPacF["AppPackages"][currentApp]>0),
			Method->"Queued",
			TrackedSymbols:>{currentApp}
			];*)


(*appGuides=
	dynamicActionMenu["Application Guides",
		Join[
			{
				"Guide Template":>
					paletteDialog[
						With[{docs=(
							Needs[currentApp<>"`"];
							whichPacF["AppGuideNotebook"]@(currentApp)
							)},
							CreateDocument@docs
							],
						"Creating guide template"
						],
				Delimiter
				},
			With[{pkgs=FileBaseName/@whichPacF["AppPackages"][currentApp]},
				Map[
					#<>" Guide":>
						paletteDialog[
							CreateDocument@whichPacF["AppGuideNotebook"][currentApp,#],
							"Creating guide template"
							]&,
					pkgs
					]
				],
			{
				Delimiter,
				"Save Guide":>
					paletteDialog[
						With[{nb=(
							Needs[currentApp<>"`"];
							CreateDocument[whichPacF["AppGuideNotebook"]@(currentApp),Visible->False]
							)},
							whichPacF["DocGenSaveGuide"][
								nb,
								whichPacF["AppDirectory"][currentApp,"Guides"],
								False
								];
							NotebookClose[nb]
							],
						"Creating guide page"
						],
				"Save Package Guides":>
					paletteDialog[
						With[{pkgs=FileBaseName/@whichPacF["AppPackages"][currentApp]},
							Map[
								With[{nb=(
									Needs[currentApp<>"`"];
									CreateDocument[whichPacF["AppGuideNotebook"]@(currentApp),Visible->False]
									)},
									whichPacF["DocGenSaveGuide"][
										nb,
										whichPacF["AppPackageGuideNotebook"][currentApp,#],
										False
										];
									NotebookClose[nb]
									]&,
								pkgs
								]
							],
						"Creating guide pages"
						],
				Delimiter
				},
			With[{pkgs=FileBaseName/@whichPacF["AppPackages"][currentApp]},
				Map[
					"Save "<>#<>" Guide":>
						paletteDialog[
							Map[
								addContent["Guides",#,
									currentExtensionPath["Guides",#],
									False]&,
								Block[{$DocActive=currentApp},
									whichPacF["DocGenGenerateGuide"]@
										CreateDocument[
											whichPacF["AppPackageGuideNotebook"][currentApp,#],
											Visible->False
											]
									]
								],
							"Creating guide page"
							]&,
					pkgs
					]
				]
			],
			Enabled->(Length@whichPacF["AppPackages"][currentApp]>0),
			Method->"Queued",
			TrackedSymbols:>{currentApp}
			];*)


(*appTutorials=
	dynamicActionMenu["Application Tutorial",
		Join[
			{
				"Tutorial Template":>
					paletteDialog[
						With[{docs=(
							Needs[currentApp<>"`"];
							whichPacF["AppTutorialNotebook"]@(currentApp)
							)},
							CreateDocument@docs
							],
						"Creating Tutorial template"
						],
				Delimiter
				},(*
			With[{pkgs=FileBaseName/@AppPackages[currentApp]},
				Map[
					#<>" Tutorial":>
						paletteDialog[
							CreateDocument@AppPackageTutorialNotebook[currentApp,#],
							"Creating tutorial template"
							]&,
					pkgs
					]
				],*)
			{(*
				Delimiter,*)
				"Save Tutorial":>
					paletteDialog[
						With[{docs=(
							Needs[currentApp<>"`"];
							whichPacF["AppTutorialNotebook"]@(currentApp)
							)},
							Map[
								addContent["Tutorials",#,
									currentExtensionPath["Tutorials",#],
									False]&,
								Block[{$DocActive=currentApp},
									whichPacF["DocGenGenerateTutorial"]@
										CreateDocument[docs,
											Visible->False
											]
									]
								]
							],
						"Creating tutorial page"
						](*,
				Delimiter*)
				}(*,
			With[{pkgs=FileBaseName/@AppPackages[currentApp]},
				Map[
					"Save "<>#<>" Tutorial"\[RuleDelayed]
						paletteDialog[
							Map[
								addContent["Tutorials",#,
									currentExtensionPath["Tutorials",#],
									False]&,
								whichPacF["DocGenGenerateTutorial"]@
									CreateDocument[
										AppPackageTutorialNotebook[currentApp,#],
										Visible\[Rule]False
										]
								],
							"Creating Tutorial page"
							]&,
					pkgs
					]
				]*)
			],
			Enabled->(Length@whichPacF["AppPackages"][currentApp]>0),
			Method->"Queued",
			TrackedSymbols:>{currentApp}
			];*)


(* ::Subsubsection:: *)
(*DocInfo*)


(*docInfoM=
	paletteButton["Regenerate DocInfo",
		sysOpen@whichPacF["AppRegenerateDocInfo"][currentApp]
		];
indexDocs=
	paletteButton["Index Documentation",
		paletteDialog[
			whichPacF["AppIndexDocs"]@currentApp,
			"Indexing documentation"
			]
		];*)


(* ::Subsubsection:: *)
(*Copy*)


(*copyURLLinks=
	paletteActionMenu["Copy URL",{
		"README":>
			CopyToClipboard@
				URLBuild@{
					AppwhichPacF["PacletSiteURL"][currentApp],
					"README"
					},
		"GitHub Repo":>
			CopyToClipboard@
				whichPacF["AppGitHubRepo"][currentApp,None]
		}];*)


(*copyZIPLinks=
	paletteActionMenu["Copy ZIP URL",{
		"Cloud":>
			CopyToClipboard@First@
				CloudObject@URLBuild@{
					whichPacF["$AppCloudExtension"],
					currentApp<>".zip"},
		"Google Drive":>
			CopyToClipboard@
				FileNameJoin@{
					whichPacF["SyncPath"]["Google Drive"],
					whichPacF["$AppCloudExtension"],
					currentApp<>".zip"
					},
		"DropBox":>
			CopyToClipboard@
				FileNameJoin@{
					whichPacF["SyncPath"]["DropBox"],
					whicPacF["$AppCloudExtension"],
					currentApp<>".zip"
					},
		"OneDrive":>
			CopyToClipboard@
				FileNameJoin@{
					whichPacF["SyncPath"]["OneDrive"],
					whichPacF["$AppCloudExtension"],
					currentApp<>".zip"
					}
		}];

copyPacletURL=
	paletteActionMenu["Copy Paclet URL",{
		"Server":>
			CopyToClipboard@
				AppwhichPacF["PacletSiteURL"][
					"ServerBase"\[Rule]Default,
					"ServerName"\[Rule]Default,
					"UploadInstallLink"\[Rule]Automatic
					],
		Delimiter,
		"Paclet":>
			CopyToClipboard@URLBuild@{
				AppwhichPacF["PacletSiteURL"]@currentApp,
				"Paclets",
				StringJoin@{
					Insert[
						Lookup[whichPacF["AppPacletInfo"]@currentApp,{"Name","Version"}],
						"-",2],
					".paclet"
					}
				},
		"Site":>
			CopyToClipboard@AppwhichPacF["PacletSiteURL"]@currentApp,
		"Installer":>
			CopyToClipboard@whichPacF["AppPacletInstallerURL"]@currentApp,
		"Uninstaller":>
			CopyToClipboard@whichPacF["AppPacletUninstallerURL"]@currentApp,
		Delimiter,
		"Google Drive":>
			CopyToClipboard@FileNameJoin@{
				AppwhichPacF["PacletSiteURL"][currentApp,
					"ServerBase"\[Rule]"Google Drive"],
				"paclets",
				StringJoin@{
					Insert[
						Lookup[whichPacF["AppPacletInfo"]@currentApp,{"Name","Version"}],
						"-",2],
					".paclet"
					}
				},
		"Site":>
			CopyToClipboard@
				AppwhichPacF["PacletSiteURL"][currentApp,
					"ServerBase"\[Rule]"Google Drive"],
		"Installer":>
			CopyToClipboard@
				whichPacF["AppPacletInstallerURL"][currentApp,
					"ServerBase"\[Rule]"Google Drive"],
		"Uninstaller":>
			CopyToClipboard@
				whichPacF["AppPacletUninstallerURL"][currentApp,
					"ServerBase"\[Rule]"Google Drive"],
		Delimiter,
		"DropBox":>
			CopyToClipboard@FileNameJoin@{
				AppwhichPacF["PacletSiteURL"][currentApp,
					"ServerBase"\[Rule]"DropBox"],
				"paclets",
				StringJoin@{
					Insert[
						Lookup[whichPacF["AppPacletInfo"]@currentApp,{"Name","Version"}],
						"-",2],
					".paclet"
					}
				},
		"Site":>
			CopyToClipboard@
				AppwhichPacF["PacletSiteURL"][currentApp,
					"ServerBase"\[Rule]"DropBox"],
		"Installer":>
			CopyToClipboard@
				whichPacF["AppPacletInstallerURL"][currentApp,
					"ServerBase"\[Rule]"DropBox"],
		"Uninstaller":>
			CopyToClipboard@
				whichPacF["AppPacletUninstallerURL"][currentApp,
					"ServerBase"\[Rule]"DropBox"],
		Delimiter,
		"OneDrive":>
			CopyToClipboard@FileNameJoin@{
				AppwhichPacF["PacletSiteURL"][currentApp,
					"ServerBase"\[Rule]"OneDrive"],
				"paclets",
				StringJoin@{
					Insert[
						Lookup[whichPacF["AppPacletInfo"]@currentApp,{"Name","Version"}],
						"-",2],
					".paclet"
					}
				},
		"Site":>
			CopyToClipboard@
				AppwhichPacF["PacletSiteURL"][currentApp,
					"ServerBase"\[Rule]"OneDrive"],
		"Installer":>
			CopyToClipboard@
				whichPacF["AppPacletInstallerURL"][currentApp,
					"ServerBase"\[Rule]"OneDrive"],
		"Uninstaller":>
			CopyToClipboard@
				whichPacF["AppPacletUninstallerURL"][currentApp,
					"ServerBase"\[Rule]"v"]
		}];*)


(* ::Subsubsection:: *)
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


(* ::Subsubsection:: *)
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


(* ::Subsubsection:: *)
(*Open*)


(*uploadServerOpen=
	paletteActionMenu["Open Server",{
		"Primary":>
			sysOpen@
				URLBuild@{
					whichPacF["PacletSiteURL"][
						"ServerName"\[Rule]Default,
						"ServerBase"\[Rule]Default
						],
					"main.html"
					},
		"Google Drive":>
			sysOpen@
				whichPacF["PacletSiteURL"][
					"ServerBase"->"GoogleDrive",
					"ServerName"\[Rule]None
					],
		"DropBox":>
			sysOpen@
				whichPacF["PacletSiteURL"][
					"ServerBase"->"DropBox",
					"ServerName"\[Rule]None
					],
		"OneDrive":>
			sysOpen@
				whichPacF["PacletSiteURL"][
					"ServerBase"->"OneDrive",
					"ServerName"\[Rule]None
					]
		}];
uploadCurrentOpen=
	paletteActionMenu["Open App Server",{
		"Primary"\[RuleDelayed]
			sysOpen@
				URLBuild@Append[
					URLParse@
						URLBuild@
							{
								whichPacF["PacletSiteURL"][
									"ServerName"\[Rule]Default,
									"ServerBase"\[Rule]Default
									],
								"main.html"
								},
					"Fragment"->currentApp
					],
		"Google Drive"\[RuleDelayed]
			sysOpen@
				whichPacF["PacletSiteURL"][
					"ServerBase"->"GoogleDrive",
					"ServerName"\[Rule]currentApp
					],
		"DropBox"\[RuleDelayed]
			sysOpen@
				whichPacF["PacletSiteURL"][
					"ServerBase"->"DropBox",
					"ServerName"\[Rule]currentApp
					],
		"OneDrive":>
			sysOpen@
				whichPacF["PacletSiteURL"][
					"ServerBase"->"OneDrive",
					"ServerName"\[Rule]currentApp
					]
		}];*)


(* ::Subsubsection:: *)
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
            pushToServerFlag=!=False,
            updatePacletFlag=!=False,
            TrueQ[publishServerFlag]
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
  		      		whichPacF["AppPublish"][
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


(* ::Subsubsection:: *)
(*CreateRelease*)


(*createReleaseButton=
	paletteButton["Publish Release",
		paletteDialog[
			With[{r=
				whichPacF["AppGit"][
					"GitHubCreateRelease",
					currentApp
					]
				},
				Quiet[
					SystemOpen@r["HTMLURL"]
					]
				],
			"Publishising release"
			]
		]*)


(* ::Subsubsection:: *)
(*Upload*)


(*uploadHelpFiles=
	paletteActionMenu["Upload File",{
	"Default Server Page":>
		sysOpen@
			whichPacF["AppPacletServerPage"][
				"ServerName"\[Rule]Default,
				"ServerBase"\[Rule]Default
				],
	"Server Page":>
		sysOpen@
			whichPacF["AppPacletServerPage"][currentApp],
	Delimiter,
	"README":>
		If[FileExistsQ@whichPacF["AppPath"][currentApp,"README.md"],
			sysOpen@
				whichPacF["AppDeployReadme"][currentApp]	
			],
	"Images":>
		If[Length@FileNames["*",whichPacF["AppPath"][currentApp,"project","imgs"]]>0,
			sysOpen@First@
				AppDeployImages[currentApp]
			],
	"CSS":>
		If[Length@FileNames["*",whichPacF["AppPath"][currentApp,"project","css"]]>0,
			sysOpen@First@
				AppDeployCSS[currentApp]
			],
	"HTML":>
		If[Length@FileNames["*",whichPacF["AppPath"][currentApp,"project","css"]]>0,
			sysOpen@First@
				whichPacF["AppDeployHTML"][currentApp]
			]
		},
		Enabled\[Rule]
			Dynamic[
				FileExistsQ@whichPacF["AppPath"][currentApp,"README.md"]||
				Length@FileNames["*",whichPacF["AppPath"][currentApp,"project","imgs"]]>0
				]
		];*)


(*uploadPaclet=
	paletteActionMenu["Upload Paclet",{
		"Upload to Server":>
			paletteDialog[
				whichPacF["AppPacletUpload"][
					currentApp,
					"ServerBase"\[Rule]Default,
					"ServerName"\[Rule]Default
					],
				"Uploading paclet to default server"
				],
		"Upload to Cloud":>
			paletteDialog[whichPacF["AppPacletUpload"]@currentApp,
				"Uploading paclet to Wolfram Cloud"
				],
		"Upload to Drive":>
			paletteDialog[
				whichPacF["AppPacletUpload"][currentApp,
					"ServerBase"\[Rule]"Google Drive"],
				"Uploading paclet to Google Drive"
				],
		"Upload to DropBox":>
			paletteDialog[
				whichPacF["AppPacletUpload"][currentApp,
					"ServerBase"\[Rule]"DropBox"],
				"Uploading paclet to DropBox"
				],
		"Upload to OneDrive":>
			paletteDialog[
				whichPacF["AppPacletUpload"][currentApp,
					"ServerBase"\[Rule]"OneDrive"],
				"Uploading paclet to OneDrive"
				],
		Delimiter,
		"Backup to Cloud":>
			paletteDialog[
				whichPacF["AppPacletBackup"][currentApp,
					"Cloud"
					],
				"Backing up paclet to Wolfram Cloud"
				],
		"Backup to Drive":>
			paletteDialog[
				whichPacF["AppPacletBackup"][currentApp,
					"GoogleDrive"
					],
				"Backing up paclet to Google Drive"
				],
		"Backup to DropBox":>
			paletteDialog[
				whichPacF["AppPacletBackup"][currentApp,
					"DropBox"
					],
				"Backing up paclet to DropBox"
				],
		"Backup to OneDrive":>
			paletteDialog[
				whichPacF["AppPacletBackup"][currentApp,
					"OneDrive"
					],
				"Backing up paclet to OneDrive"
				]
		},
		Method\[Rule]"Queued"
		];*)


(* ::Subsubsection:: *)
(*Upload Regen*)


(*uploadRegen=
	paletteActionMenu["Make Config File",
	{
		"PacletInfo":>
			sysOpen@whichPacF["AppRegeneratePacletInfo"]@currentApp,
		Delimiter,
		"BundleInfo":>
			sysOpen@whichPacF["AppRegenerateBundleInfo"]@currentApp,
		"UploadInfo":>
			sysOpen@whichPacF["AppRegenerateUploadInfo"]@currentApp
		}];*)


(* ::Subsubsection:: *)
(*Toolbar*)


addAppsToolbar[]:=CreateMessagePopup["Toolbar still in progress! Sorry!"];


(* ::Subsubsection:: *)
(*Exported*)


appManagerPluginCommands =
  { 
  "Update Dependencies":>
    updateDeps[],
  "Regenerate Loader":>
    (
      AppExecute["RegenerateLoaderFile", currentApp];
      CreateMessagePopup["Regenerated loader"]
      ),
  "Regenerate Layout":>
    (
      AppExecute["RegenerateDirectories", currentApp];
      CreateMessagePopup["Rebuilt directory structure"]
      ),
  "Publish":>
    publishApp[],
   "Open Toolbar":>
     addAppsToolbar[]
  };


(* ::Subsubsection:: *)
(*End*)


End[];


(* ::Subsection:: *)
(*Exports*)


appManagerPluginCommands
