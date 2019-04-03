(* ::Package:: *)

(* Autogenerated Package *)

(* ::Text:: *)
(*Layer on top of lower-level clumsier implementation*)



$DocGenSettings::usage=
  "Settings for documentation generation";
DocGen::usage=
  "Generates various types of documentation";


PackageScopeBlock[
  $DocGenFunction::usage="The proper implementation function for most doc gens";
  ]


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*Settings*)



If[!TrueQ@$docGenInitialized,
  $DocGenBuildPermanent=True;
  If[FileExistsQ@PackageFilePath["Private", "DocGenConfig.wl"],
    Get@PackageFilePath["Private", "DocGenConfig.wl"]
    ];
  $docGenInitialized=False
  ];


If[!AssociationQ@$DocGenSettings,
  $DocGenSettings=
    <|
      Default->
        <|
          "RootDirectory"->
            FileNameJoin@{
              $UserBaseDirectory,
              "ApplicationData",
              "DocGen"
              },
          "TemporaryDirectory"->
            FileNameJoin@{$TemporaryDirectory, "DocGen_tmp"},
          "PacletsExtension"->
            "Paclets",
          "WebExtension"->
            "Web",
          "BuildPermanent"->
            $DocGenBuildPermanent,
          "NameColoring"->
            {
              "BUILT-IN SYMBOL"->RGBColor[0.023529, 0.427451, 0.729412],
              "GUIDE"->RGBColor[0.8, 0.4, 0],
              "TUTORIAL"->RGBColor[0.641154, 0.223011, 0.0623026],
              "MESSAGE"->RGBColor[0.86667, 0.06667, 0.],
              "PACKAGE"->Hue[0.6, 0.3, 0.7],
              "IMPORT/EXPORT FORMAT"->GrayLevel[0.541176],
              _?(Evaluate@StringStartsQ[$PackageName])->Hue[0.5754716981132075, 0.654320987654321, 0.6328125],
              "Global":>
                CurrentValue[
                  $FrontEndSession,
                  {AutoStyleOptions, "UndefinedSymbolStyle", FontColor},
                  RGBColor[0., 0.173, 0.765]
                  ]
              },
          "CurrentPaclet"->
            None,
          "LinkStyle"->
            {
              "System"->
                "RefLink",
              "Global"->
                "RefLink",
              _->
                "PackageLink"
              },
          "LinkBase"->
            {
              "System"->
                Nothing
              },
          "Footer"->Automatic,
          "FrontEnd"->None,
          "Stack":>$DocGenMessageStack
          |>
      |>
  ];


(* ::Subsubsection::Closed:: *)
(*DocGen*)



(* ::Subsubsubsection::Closed:: *)
(*$DocGenMethodRouter*)



$DocGenMethodRouter=
  <|
    "SymbolPage"->
      <|
        Automatic:>
          DocGenGenerateSymbolPages,
        "Save":>
          DocGenSaveSymbolPages,
        "Template":>
          SymbolPageTemplate,
        "Notebook":>
          SymbolPageNotebook
        |>,
    "Guide"->
      <|
        Automatic:>
          DocGenGenerateGuide,
        "Save":>
          DocGenSaveGuide,
        "Template":>
          GuideTemplate,
        "Notebook":>
          GuideNotebook
        |>,
    "MultiPackageOverview"->
      <|
        Automatic:>
          GenerateMultiPackageOverview,
        "Save":>
          SaveMultiPackageOverview,
        "Notebook":>
          MultiPackageOverviewNotebook
        |>,
    "Tutorial"->
      <|
        Automatic:>
          DocGenGenerateTutorial,
        "Save":>
          DocGenGenerateTutorial,
        "Template":>
          TutorialTemplate,
        "Notebook":>
          TutorialNotebook
        |>,
    "Paclet":>
      DocGenGenerateDocumentation,
    "HTML":>
      <|
        Automatic:>DocGenGenerateHTMLDocumentation,
        "Deploy":>DocGenHTMLCloudDeploy
        |>,
    "Index":>
      DocGenIndexDocumentation
    |>;


(* ::Subsubsubsection::Closed:: *)
(*docGenDefault*)



docGenDefault[docObj_, type_, fun_, meth_, methOps_, ops___]:=
  fun[docObj, Evaluate@FilterRules[{ops, methOps}, Options@fun]];
docGenDefault~SetAttributes~HoldFirst


$DocGenFunction=
  docGenDefault


(* ::Subsubsubsection::Closed:: *)
(*DocGen*)



DocGen//Clear
Options[DocGen]={Method->Automatic};
DocGen::badmeth=
  "Method `` for documentation type `` unknown. Acceptable methods are ``.";
DocGen::nogen=
  "Couldn't generate documentation of type `` for object ``";
DocGen[
  type:_String?(KeyExistsQ[$DocGenMethodRouter, #]&)|Automatic:Automatic,
  docObj:
    Except[
      "Function"|"Options"|"Methods"|
      _Rule|_RuleDelayed|{(_Rule|_RuleDelayed), ___}
      ],
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      typ=
        Replace[type,
          Automatic:>
            If[MatchQ[Unevaluated[docObj], {__String}],
              "Paclet",
              "SymbolPage"
              ]
          ],
      coloring=
        Lookup[{ops}, "ContextColoring", Automatic],
      links=
        Lookup[{ops}, "LinkStyle", Automatic],
      active=
        Lookup[{ops}, "ActiveContext", Automatic],
      line=
        Lookup[{ops}, "LineNumber", Automatic],
      fe=
        Lookup[{ops}, "FrontEnd", Automatic],
      base=
        Lookup[{ops}, "LinkBase", Automatic],
      targ=
        Lookup[{ops}, "TargetVersion", Automatic],
      meth=
        Lookup[{ops}, Method, Automatic],
      methOps={},
      fun,
      res
      },
    Block[
      {
        $DocGenActive=
          Replace[active, Automatic:>$DocGenActive],
        $DocGenColoring=
          Replace[coloring, Automatic:>$DocGenColoring],
        $DocGenLine=
          Replace[line, Automatic:>$DocGenLine],
        $DocGenLinkBase=
          Replace[base, Automatic:>$DocGenLinkBase],
        $DocGenLinkStyle=
          Replace[links, Automatic:>$DocGenLinkStyle],
        $DocGenVersionNumber=
          Replace[targ, Automatic:>$VersionNumber],
        $DocGenFE=
          Replace[fe,
            Except[_LinkObject?LinkReadyQ]:>
              If[!MatchQ[OwnValues[$DocGenFE],{_:>_LinkObject?LinkReadyQ}],
                Unevaluated[$DocGenFE=DocGenLoadFE[]],
                $DocGenFE
                ]
            ]
        },
      If[ListQ@meth, 
        methOps=Select[meth, OptionQ];
        meth=SelectFirst[meth, Not@*OptionQ]
        ];
      fun=$DocGenMethodRouter[typ];
      If[AssociationQ@fun,
        fun=fun[meth]
        ];
      If[MissingQ@fun,
        Message[DocGen::badmeth,
          meth,
          typ,
          Keys@$DocGenMethodRouter[typ]
          ];
        res=None,
        res=$DocGenFunction[docObj, typ, fun, meth, methOps, ops];
        If[Head[res]===fun, 
          Message[DocGen::nogen,
            typ,
            HoldForm[docObj]
            ]
          ];
        ];
      ];
    res/;res=!=None&&Head[res]=!=fun
    ];
DocGen[
  type:_String?(KeyExistsQ[$DocGenMethodRouter, #]&),
  "Function",
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      meth=Lookup[{ops}, Method, Automatic],
      methOps={},
      fun,
      res
      },
    If[ListQ@meth, 
      methOps=Select[meth, OptionQ];
      meth=SelectFirst[meth, Not@*OptionQ]
      ];
    fun=$DocGenMethodRouter[type];
    If[AssociationQ@fun,
      fun=fun[meth]
      ];
    fun
    ];
DocGen[
  type:_String?(KeyExistsQ[$DocGenMethodRouter, #]&),
  "Methods",
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      fun
      },
    fun=$DocGenMethodRouter[type];
    If[AssociationQ@fun,
      Keys@fun,
      Automatic
      ]
    ];
DocGen[
  type:_String?(KeyExistsQ[$DocGenMethodRouter, #]&),
  "Options",
  ops:OptionsPattern[]
  ]:=
  Options@DocGen[type, "Function"];
DocGen~SetAttributes~HoldAll


PackageAddAutocompletions[
  "DocGen",
  {Keys@$DocGenMethodRouter, {"Function", "Options", "Methods"}}
  ]


End[];


