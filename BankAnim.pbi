DeclareModule BKA
  
Structure Clip
  ImageId.i ; Grab from SpriteId
  
  OriginalImageId.i; Original Sprite before Grab
  X.l
  Y.l
  Width.l
  Height.l
EndStructure

Structure Frame
  *Clip.Clip
  Delay.l
  Opacity.l
  Anchor.Point
EndStructure

Structure Anim
  Name.s
  List Frame.Frame()
  Loop.b
EndStructure  

Structure Board
  Name.s
  BoardId.i
  List Clip.Clip()
  List Anim.Anim()
EndStructure

Structure Model
  Name.s
  List *Anim.Anim()
EndStructure

Structure Object
  Name.s
  *Model.Model
  CurrentImageId.i
  Coord.point
  
  CurrentAnimIndex.l               ;current Animation
  frameIndex.l
  NextFrameTime.i
EndStructure

Structure Bank
  Name.s
  List Board.Board()
  List Model.Model()
  List Object.Object()
EndStructure

;- Declare Clip
Declare.i AddClipToBoard(*Board.Board,X.l,Y.l,Width.l,Height.l)
Declare.b LoadClipsFromFile(FileName.s,*Board.Board)
Declare.i GetClipFromIndex(*Board.Board,clipIndex.l)
Declare SetXmlClip(*ClipsNode,*Board.Board,Map ClipIndex.s())
Declare GetXmlClip(*ClipsNode,*Board)
;- Declare Anim
Declare.i AddAnimToBoard(*Board.Board,Name.s="",Loop.b=#True)
Declare.i AddFrameToAnim(*Clip,*Anim.Anim,Delay.l=150,Opacity.l=255)
Declare.i SetAnim(*Anim.Anim,*Board,stringToAnim.S,Loop.b=#True,Name.s="")
Declare.i GetAnimByName(*Board.Board,Name.s)
Declare.i SetFrameOpacity(*Frame.Frame,Opacity.l=255)
Declare.i SetFrameDelay(*Frame.Frame,Delay.l=150)
Declare SetXmlFrame(*AnimNode,*Anim.Anim,Map ClipIndex.s())
Declare SetXmlAnim(*BoardNode,*Board.Board,Map ClipIndex.s())
Declare GetXmlFrame(*AnimNode,*Board.Board,*Anim)
Declare GetXmlAnim(*AnimsNode,*Board)
;-Declare Board
Declare.i AddBoardToBank(ImageId.i,Name.s,*Bank.Bank)
Declare.b IsBoardExist(*Board,*Bank.Bank=0)
Declare.i GetBoardByName(Name.s,*Bank.Bank=0)
Declare.s GetBoardNameFromAnim(*Bank.Bank,*Anim)
Declare.s Base64EncodeFile(FileName.s) ; Encode a file to a Base64 string.
Declare.l Base64CatchImage(Image.l, Base64.s, flags.l = 0) ; Create a new image from a Base64 string.
Declare SetXmlBoard(*BoardsNode,*Bank.Bank,Map ClipIndex.s())
Declare GetXmlBoard(*BoardsNode,*Bank)
;-Declare Model
Declare.i NewModel(*Bank.Bank,Name.s="")
Declare.b IsModelExist(*Model,*Bank.Bank=0)
Declare.i GetModelByName(Name.s,*Bank.Bank=0)
Declare AddAnimToModel(*Anim,*Model.Model)
Declare.i GetFrameFromModel(*Model.Model,CurrentAnimIndex.l,FrameIndex.l)
Declare SetXmlModel(*BankNode,*Bank.Bank)
Declare GetXmlModel(*ModelsNode,*Bank)
;-Declare Object
Declare.i NewObject(*Bank.Bank,*Model.Model=0,Name.s="")
Declare.b IsObjectExist(*Object,*Bank.Bank=0)
Declare.i GetObjectByName(Name.s,*Bank.Bank=0)
Declare LinkModelToObject(*Model.Model,*Object.object,Name.s="")
Declare.b SetObjectAnim(*Object.Object,Index.i)
Declare PauseObjectAnim(*Object.Object,val.b)
Declare RenderObject(*Object.Object)
;-Declare Bank
Declare.b IsBankExist(*Bank)
Declare.i NewBank(Name.s="")
Declare SetXmlBank(*MainNode,*Bank.Bank)
Declare GetXmlBank(*BankNode)
Declare SaveBank(*Bank.Bank,Name.s="")
Declare CheckXml(Xml.i,FileName.s)
Declare LoadBank(Name.s)
EndDeclareModule

Module BKA
  
Global NewList Bank.Bank()


;-Clip

;===================================================================
;              Add Clip To Board
;      Input:   BoardId = Board Pointer
;               Name = The Name you want to use
;               *Bank = Bank Pointer 
;               
;      Return:  Clip pointer
;===================================================================
Procedure.i AddClipToBoard(*Board.Board,X.l,Y.l,Width.l,Height.l)
  AddElement(*Board\Clip())
  *Board\Clip()\X=X
  *Board\Clip()\Y=Y
  *Board\Clip()\Width=Width
  *Board\Clip()\Height=Height
  *Board\Clip()\OriginalImageId=*Board\BoardId
  *Board\Clip()\ImageId=GrabImage(*Board\BoardId,#PB_Any,X,Y,Width,Height)
  ProcedureReturn *Board\Clip()
EndProcedure

;===================================================================
;              Load Clips from .ini file
;      Input:   FileName.s
;               *Board = Board Pointer

;      Return:  #True / #False
;===================================================================
Procedure.b LoadClipsFromFile(FileName.s,*Board.Board)
  If OpenPreferences(GetFilePart(fileName,#PB_FileSystem_NoExtension)+".ini")
    ExaminePreferenceGroups()
    While NextPreferenceGroup()
      AddClipToBoard(*Board, ReadPreferenceLong("X",0),ReadPreferenceLong("Y",0),ReadPreferenceLong("Width",0),ReadPreferenceLong("Height",0))
    Wend  
    ClosePreferences()
    ProcedureReturn #True
  Else
    Debug "No INI"
    ;TODO check is intersting or not
    ;AddElement(*Bank\SpriteSheet()\clip())
    
    ;*Bank\SpriteSheet()\clip()\ImageID=*Bank\SpriteSheet()\ImageId
    ProcedureReturn #False
    ;MessageRequester("Error LoadSpriteSheet()","can't load "+Chr(24)+fileName+Chr(24),#PB_MessageRequester_Error)
    ;End
  EndIf 
EndProcedure

;===================================================================
;              Get Clip Pointer From Index in Board
;      Input:   FileName.s
;               *Board = Board Pointer
;               clipIndex.l = Index
;      Return:  No Return
;===================================================================
Procedure.i GetClipFromIndex(*Board.Board,clipIndex.l)
  ;If IsBoardExist(*Board)=#True
  SelectElement(*Board\Clip(),clipIndex)
  ProcedureReturn *Board\Clip()
  ;Else
  ;   Debug "GetClipFromIndex Error : *Board no exist "+Str(*Board)
  ;EndIf
EndProcedure


;===================================================================
;              Set Clip Data to Xml
;      Input:   *ClipsNode = XML node pointer
;               *Board = Board Pointer
;               Map ClipIndex.s() = Map clip index to clip pointer 
;      Return:  No Return
;===================================================================
Procedure SetXmlClip(*ClipsNode,*Board.Board,Map ClipIndex.s())
  ForEach *Board\Clip()
    ClipIndex(Str(*Board\Clip()))=Str(ListIndex(*Board\Clip()))
    *ClipNode=CreateXMLNode(*ClipsNode, "Clip")
    SetXMLAttribute(*ClipNode, "Index", Str(ListIndex(*Board\Clip())))
    SetXMLAttribute(*ClipNode, "X", Str(*Board\Clip()\X))
    SetXMLAttribute(*ClipNode, "Y", Str(*Board\Clip()\Y))
    SetXMLAttribute(*ClipNode, "Width", Str(*Board\Clip()\Width))
    SetXMLAttribute(*ClipNode, "Height", Str(*Board\Clip()\Height))
  Next
EndProcedure

;===================================================================
;              Get Clip Data from Xml
;      Input:   *ClipsNode = XML node pointer
;               *Board = Board Pointer
;              
;      Return:  No Return
;===================================================================
Procedure GetXmlClip(*ClipsNode,*Board)
  For c=1 To XMLChildCount(*ClipsNode)
    *ClipNode=ChildXMLNode(*ClipsNode,c)
    If GetXMLNodeName(*ClipNode)="Clip"
      Protected.l X,Y,Width,Height
      ExamineXMLAttributes(*ClipNode)
      While NextXMLAttribute(*ClipNode)
        Select XMLAttributeName(*ClipNode)
          Case "Index"
            Index=Val(XMLAttributeValue(*ClipNode))
          Case "X"
            X=Val(XMLAttributeValue(*ClipNode))
          Case "Y"
            Y=Val(XMLAttributeValue(*ClipNode))
          Case "Width"
            Width=Val(XMLAttributeValue(*ClipNode))
          Case "Height"
            Height=Val(XMLAttributeValue(*ClipNode))
        EndSelect
      Wend  
      Debug "Addclip"
      AddClipToBoard(*Board, X,Y,Width,Height)
    EndIf
  Next
EndProcedure

;-Anim

;===================================================================
;              Add Anim To Board
;      Input:   Board = Board Pointer
;               Name = The Anim Name
;               Loop = #True or  #False
;               
;      Return:  Anim pointer
;===================================================================
Procedure.i AddAnimToBoard(*Board.Board,Name.s="",Loop.b=#True)
  AddElement(*Board\Anim())
  If Name=""
    Name="Anim "+Str(ListSize(*Board\Anim()))
  EndIf
  *Board\Anim()\Name=Name
  *Board\Anim()\Loop=Loop
  ProcedureReturn *Board\Anim()
EndProcedure

;===================================================================
;              Add Frame To Anim
;      Input:   *Clip = Clip Pointer to add on Anim
;               *Anim = Anim pointer
;               Delay = Frame delay in millisecond
;               Opacity = 0  - 255 
;               
;      Return:  Frame pointer
;===================================================================
Procedure.i AddFrameToAnim(*Clip,*Anim.Anim,Delay.l=150,Opacity.l=255)
  AddElement(*Anim\Frame())
  *Anim\Frame()\Clip=*Clip
  *Anim\Frame()\Delay=Delay
  *Anim\Frame()\Opacity=Opacity
  ProcedureReturn *Anim\Frame()
EndProcedure

;===================================================================
;              Set Anim
;      Input:   *Anim = Anim pointer
;               *Board = Board Pointer
;               stringToAnim.s = string with index list  ex:"1,2,3,4,5"
;               Loop = #True / #False You can Loop anim or not 
;               Name.s = Anim Name ex:"Hero Walk Up"
;      Return: No Return
;===================================================================
Procedure.i SetAnim(*Anim.Anim,*Board,stringToAnim.S,Loop.b=#True,Name.s="")
  Protected z.l
  Protected *Clip
  ClearList(*Anim\Frame())
  If Name<>""
    *Anim\Name=Name
  EndIf   
  *Anim\Loop=Loop
  For z=1 To CountString(stringToAnim,",")+1
    Debug "Add Frame:"+StringField(stringToAnim,z,",")
    *Clip=GetClipFromIndex(*Board,Val(StringField(stringToAnim,z,",")))
    AddFrameToAnim(*Clip,*Anim)
  Next
EndProcedure

;===================================================================
;              Get Anim By Name
;      Input:   Board = Board Pointer
;               Name = The Anim Name you want to use
;               
;      Return:  Anim pointer
;===================================================================
Procedure.i GetAnimByName(*Board.Board,Name.s)
  ForEach *Board\Anim()
    If *Board\Anim()\Name=Name
      ProcedureReturn *Board\Anim()
    EndIf
  Next
  Debug Name+" Anim No Found in this Board"
  ProcedureReturn #False
EndProcedure

;===================================================================
;              Set Frame Opacity
;      Input:   *Frame = Frame Pointer
;               Opacity = 0  - 255 
;               
;      Return:  No Return
;===================================================================
Procedure.i SetFrameOpacity(*Frame.Frame,Opacity.l=255)
  *Frame\Opacity=Opacity
EndProcedure

;===================================================================
;              Set Frame Delay
;      Input:  *Frame = Frame Pointer
;              Delay.l = Delay in millisecond
;               
;      Return:  No Return
;===================================================================
Procedure.i SetFrameDelay(*Frame.Frame,Delay.l=150)
  *Frame\Delay=Delay
EndProcedure

;===================================================================
;              Set Frame to XML
;      Input:  *AnimNode = XML Node pointer
;              *Anim = *Anim pointer
;              Map ClipIndex.s() = Map clip index to clip pointer 
;               
;      Return:  No Return
;===================================================================
Procedure SetXmlFrame(*AnimNode,*Anim.Anim,Map ClipIndex.s())
  ForEach *Anim\Frame()
    *FrameNode=CreateXMLNode(*AnimNode, "Frame")
    SetXMLAttribute(*FrameNode, "Index", Str(ListIndex(*Anim\Frame())))
    SetXMLAttribute(*FrameNode, "Clip", ClipIndex(Str(*Anim\Frame()\Clip)))
    SetXMLAttribute(*FrameNode, "Delay", Str(*Anim\Frame()\Delay))
    SetXMLAttribute(*FrameNode, "Opacity", Str(*Anim\Frame()\Opacity))
  Next
EndProcedure

;===================================================================
;              Set Anim to XML
;      Input:  *BoardNode = XML Node pointer
;              *Board = *Board pointer
;              Map ClipIndex.s() = Map clip index to clip pointer 
;               
;      Return:  No Return
;===================================================================
Procedure SetXmlAnim(*BoardNode,*Board.Board,Map ClipIndex.s())
  ForEach *Board\Anim()
    *AnimNode=CreateXMLNode(*BoardNode, "Anim")
    SetXMLAttribute(*AnimNode, "Name", *Board\Anim()\Name)
    SetXMLAttribute(*AnimNode, "Loop", Str(*Board\Anim()\Loop))
    SetXmlFrame(*AnimNode,*Board\Anim(),ClipIndex())
  Next
EndProcedure

;===================================================================
;              Get Frame to XML
;      Input:  *AnimNode = XML Node pointer
;              *Board = *Board pointer
;              *Anim = *Anim Pointer 
;               
;      Return:  No Return
;===================================================================
Procedure GetXmlFrame(*AnimNode,*Board.Board,*Anim)
  For f=1 To XMLChildCount(*AnimNode)
    *FrameNode=ChildXMLNode(*AnimNode,f)
    If GetXMLNodeName(*FrameNode)="Frame"
      Protected.l Index,ClipIndex,Delay,Opacity
      ExamineXMLAttributes(*FrameNode)
      While NextXMLAttribute(*FrameNode)
        Select XMLAttributeName(*FrameNode)
          Case "Index"
            Index=Val(XMLAttributeValue(*FrameNode))
          Case "Clip"
            ClipIndex=Val(XMLAttributeValue(*FrameNode))
          Case "Delay"
            Delay=Val(XMLAttributeValue(*FrameNode))
          Case "Opacity"
            Opacity=Val(XMLAttributeValue(*FrameNode))
        EndSelect
      Wend  
      Debug "Add Frame "+Str(Index)
      SelectElement(*Board\Clip(),ClipIndex)
      AddFrameToAnim(*Board\Clip(),*Anim,Delay,Opacity)
    EndIf
  Next
EndProcedure

;===================================================================
;              Get Anim From Xml
;      Input:  *AnimsNode = XML Node pointer
;              *Board = *Board pointer
;               
;      Return:  No Return
;===================================================================
Procedure GetXmlAnim(*AnimsNode,*Board)
  For a=1 To XMLChildCount(*AnimsNode)
    *AnimNode=ChildXMLNode(*AnimsNode,a)
    If GetXMLNodeName(*AnimNode)="Anim"
      Protected Name.s,Loop.b
      ExamineXMLAttributes(*AnimNode)
      While NextXMLAttribute(*AnimNode)
        Select XMLAttributeName(*AnimNode)
          Case "Name"
            Name=XMLAttributeValue(*AnimNode)
          Case "Loop"
            Loop=Val(XMLAttributeValue(*AnimNode))
        EndSelect
      Wend  
      Debug "Add Anim "+Name
      *Anim=AddAnimToBoard(*Board,Name,Loop)
      GetXmlFrame(*AnimNode,*Board,*Anim)
    EndIf
  Next
EndProcedure

;-Board 

;===================================================================
;              Add Board To Bank
;      Input:   ImageId = Image Id pointer
;               Name = The Name you want to use
;               *Bank = Bank Pointer 
;               
;      Return:  Board pointer
;===================================================================
Procedure.i AddBoardToBank(ImageId.i,Name.s,*Bank.Bank)
  AddElement(*Bank\Board())
  *Bank\Board()\BoardId=ImageId
  *Bank\Board()\Name=Name
  ProcedureReturn *Bank\Board()
EndProcedure

;===================================================================
;              Is Board Exist
;      Input:   *Board = Pointer to Board Structure
;               *Bank.Bank = 0 check all Bank else use *Bank pointer
;               
;      Return:  #True if Found or #False
;===================================================================
Procedure.b IsBoardExist(*Board,*Bank.Bank=0)
  If *Bank=0
    ForEach Bank()
      *Bank=Bank()
      ForEach *Bank\Board()
        If *Bank\Board()=*Board
          ProcedureReturn #True
        EndIf 
      Next
    Next
  Else
    ForEach *Bank\Board()
      If *Bank\Board()=*Board
        ProcedureReturn #True
      EndIf 
    Next
  EndIf
  Debug "⚠️ IsBoardExist() "+Str(*Board)+" Board no exist"
  ProcedureReturn #False
EndProcedure

;===================================================================
;              Get Board By Name
;      Input:   Name.s = Board name
;               *Bank.Bank = 0 check all Bank else use *Bank pointer
;               
;      Return:  Board pointer if Found or #False
;===================================================================
Procedure.i GetBoardByName(Name.s,*Bank.Bank=0)
  If *Bank=0
    ForEach Bank()
      *Bank=Bank()
      ForEach *Bank\Board()
        If *Bank\Board()\Name=Name
          ProcedureReturn *Bank\Board()
        EndIf 
      Next
    Next
  Else
    ForEach *Bank\Board()
      If *Bank\Board()\Name=Name
        ProcedureReturn *Bank\Board()
      EndIf 
    Next
  EndIf
  Debug "⚠️ GetBoardByName() "+Chr(34)+Name+Chr(34)+" No Found"
  ProcedureReturn #False
EndProcedure

;===================================================================
;              Get Board Name From Anim
;      Input:   *Bank.Bank = Bank pointer
;               *Anim = Anim Pointer
;               
;      Return:  String with anim name
;===================================================================
Procedure.s GetBoardNameFromAnim(*Bank.Bank,*Anim)
  ForEach *Bank\Board()
    ForEach  *Bank\Board()\Anim()
      If  *Bank\Board()\Anim()=*Anim
        ProcedureReturn *Bank\Board()\Name
      EndIf
    Next
  Next
  Debug "Error GetAnimSpriteSheetName()"
EndProcedure

;===================================================================
;              Encode a file to a Base64 string.
;     Author : Flype
;     Source : https://www.purebasic.fr/english/viewtopic.php?f=12&t=25152
;
;     Input:  FileName.s = Filepath 
;     Return : file convert to String
;===================================================================
Procedure.s Base64EncodeFile(FileName.s) ; Encode a file to a Base64 string.
  
  Protected FileID.l, FileSize.l, FileBuff.l, Base64Size.l, Base64Buff.s
  
  FileID = ReadFile(#PB_Any, FileName)
  If FileID
    FileSize = Lof(FileID)
    FileBuff = AllocateMemory(FileSize)
    If FileBuff
      ReadData(FileID, FileBuff, FileSize)
      Base64Buff=Base64Encoder(FileBuff, FileSize)
      FreeMemory(FileBuff)
    EndIf
    CloseFile(FileID)
  Else
    Debug "Error loading file "+FileName
  EndIf
  Debug "Base64:"+Base64Buff
  ProcedureReturn Base64Buff
  
EndProcedure

;===================================================================
;              Create a new image from a Base64 string.
;     Author : Flype
;     Source : https://www.purebasic.fr/english/viewtopic.php?f=12&t=25152
;
;     Input:  Image.l = Number or #PB_Any
;             Base64.s = String with Base64 image encoded
;             flags.l = ImageSize
;     Return : ImageId
;===================================================================
Procedure.l Base64CatchImage(Image.l, Base64.s, flags.l = 0) ; Create a new image from a Base64 string.
  
  Protected Base64Size.l, ImageBuff.l, ImageSize.l, result.l
  
  Base64Size = Len(Base64)
  ImageBuff = AllocateMemory(Base64Size)
  Debug "ImageBuff"
  If ImageBuff
    ImageSize = Base64Decoder(Base64, ImageBuff,Base64Size)
    Debug "ImageSize"+Str(ImageSize)
    If ImageSize
      result = CatchImage(Image, ImageBuff, ImageSize, flags)
      Debug "Restult;"+Str(result)
    EndIf
    FreeMemory(ImageBuff)
  EndIf
  
  ProcedureReturn result
  
EndProcedure

;===================================================================
;              Set Board to XML
;      Input:  *BoardsNode = XML Node pointer
;              *Bank= Bank Pointer
;              Map ClipIndex.s() = Map clip index to clip pointer 
;               
;      Return:  No Return
;===================================================================
Procedure SetXmlBoard(*BoardsNode,*Bank.Bank,Map ClipIndex.s())
  ForEach *Bank\Board()
    *BoardNode=CreateXMLNode(*BoardsNode, "Board")
    SetXMLAttribute(*BoardNode, "Name", *Bank\Board()\Name)
    *BinNode=CreateXMLNode(*BoardNode, "Binary")
    SaveImage(*Bank\Board()\BoardId,GetTemporaryDirectory()+"tmp.png",#PB_ImagePlugin_PNG)
    SetXMLNodeText(*BinNode, Base64EncodeFile(GetTemporaryDirectory()+"tmp.png"))    
    *ClipsNode=CreateXMLNode(*BoardNode, "Clips")
    SetXmlClip(*ClipsNode,*Bank\Board(),ClipIndex())
    *AnimsNode=CreateXMLNode(*BoardNode, "Anims")
    SetXmlAnim(*AnimsNode,*Bank\Board(),ClipIndex())
  Next
EndProcedure

;===================================================================
;              Get Board From XML
;      Input:  *BoardsNode = XML Node pointer
;              *Bank= Bank Pointer
;               
;      Return:  No Return
;===================================================================
Procedure GetXmlBoard(*BoardsNode,*Bank)
  For b=1 To XMLChildCount(*BoardsNode)
    *BoardNode=ChildXMLNode(*BoardsNode,b)
    If GetXMLNodeName(*BoardNode)="Board"
      Protected Name.s
      ExamineXMLAttributes(*BoardNode)
      While NextXMLAttribute(*BoardNode)
        Select XMLAttributeName(*BoardNode)
          Case "Name"
            Name=XMLAttributeValue(*BoardNode)
        EndSelect
      Wend  
      ;TODO Load IMageID
      
      *Board.Board=AddBoardToBank(-1,Name,*Bank)
      For c=1 To XMLChildCount(*BoardNode)
        *ChildNode=ChildXMLNode(*BoardNode,c)
        Select GetXMLNodeName(*ChildNode)
          Case "Binary"
            Debug "Binary"
            *Board\BoardId=Base64CatchImage(#PB_Any,GetXMLNodeText(*ChildNode))
            Debug *Board\BoardId
          Case "Clips"
            GetXmlClip(*ChildNode,*Board)
          Case "Anims"
            GetXmlAnim(*ChildNode,*Board)
        EndSelect
      Next
    EndIf
  Next
EndProcedure

;-Model

;===================================================================
;              New Model
;      Input:   *Bank = Bank Pointer
;               Name.s = New Model Name
;               
;      Return:  Model Pointer
;===================================================================
Procedure.i NewModel(*Bank.Bank,Name.s="")
  AddElement(*Bank\Model())
  If Name=""
    Name="Model "+Str(ListSize(*Bank\Model()))
  EndIf
  *Bank\Model()\Name=Name
  ProcedureReturn *Bank\Model()
EndProcedure

;===================================================================
;              Is Model Exist
;      Input:   *Model = Model pointer
;               
;      Return:  #True if exist else #False
;=================================================================== 
Procedure.b IsModelExist(*Model,*Bank.Bank=0)
  If *Bank=0
    ForEach Bank()
      *Bank=Bank()
      ForEach *Bank\Model()
        If *Bank\Model()=*Model
          ProcedureReturn #True
        EndIf 
      Next
    Next
  Else
    ForEach *Bank\Model()
      If *Bank\Model()=*Model
        ProcedureReturn #True
      EndIf 
    Next
  EndIf
  Debug "⚠️ IsModelExist() "+Str(*Object)+" Model no exist"
  ProcedureReturn #False
EndProcedure

;===================================================================
;              Get Model By Name
;      Input:   Name  = Model Name
;               *Bank = Bank Pointer 
;               
;      Return:  Model Pointer or  #False if no found
;=================================================================== 
Procedure.i GetModelByName(Name.s,*Bank.Bank=0)
  If *Bank=0
    ForEach Bank()
      *Bank=Bank()
      ForEach *Bank\Model()
        If *Bank\Model()\Name=Name
          ProcedureReturn *Bank\Model()
        EndIf 
      Next
    Next
  Else
    ForEach *Bank\Model()
      If *Bank\Model()\Name=Name
        ProcedureReturn *Bank\Model()
      EndIf 
    Next
  EndIf
  Debug "⚠️ GetModelByName() "+Chr(34)+Name+Chr(34)+" No Found"
  ProcedureReturn #False
EndProcedure

;===================================================================
;              Add Anim to Model
;      Input:   *Anim = Anim Pointer
;               *Model = Model Pointer 
;               
;      Return:  No return
;=================================================================== 
Procedure AddAnimToModel(*Anim,*Model.Model)
  If IsModelExist(*Model)
    AddElement(*Model\anim())
    *Model\anim()=*Anim
  Else
    Debug "⚠️ AddAnimToModel() Error : Model no exist"
    End
  EndIf 
EndProcedure

;===================================================================
;              Get Frame From Model
;      Input:   *Model = Model Pointer
;               CurrentAnimIndex = Current Anim Index
;               FrameIndex = Frame Index
;               
;      Return:  Frame Pointer
;===================================================================
Procedure.i GetFrameFromModel(*Model.Model,CurrentAnimIndex.l,FrameIndex.l)
  ;Display SpriteSheet Image Id
  If ListSize(*Model\Anim())=0
    
    Debug "GetFrameFromModel() Error : No Anim defined"
    
  Else
    ;Display Anim   
    If CurrentAnimIndex>=0 And CurrentAnimIndex<ListSize(*Model\anim())
      
      SelectElement(*Model\anim(),CurrentAnimIndex)
      
      If FrameIndex>=0 And FrameIndex<ListSize(*Model\anim()\Frame())
        SelectElement(*Model\anim()\Frame(),FrameIndex)
        ProcedureReturn *Model\anim()\Frame()
      Else
        Debug "GetFrameFromModel() Error : Frameindex="+Str(FrameIndex)+" must be >=0 and <="+Str(ListSize(*Model\anim()\Frame())-1) 
        ProcedureReturn #False
      EndIf
      
    Else
      
      Debug "GetFrameFromModel() Error : Frameindex="+Str(FrameIndex)+" must be >=0 and <="+Str(ListSize(*Model\anim()\Frame())-1)
      ProcedureReturn #False
      
    EndIf 
  EndIf
EndProcedure

;===================================================================
;              Set Model to Xml
;      Input:   *BankNode= Xml node pointer
;               *Bank = Bank Pointer 
;               
;      Return:  No return
;=================================================================== 
Procedure SetXmlModel(*BankNode,*Bank.Bank)
  ForEach *Bank\Model()
    *ModelNode=CreateXMLNode(*BankNode, "Model")
    SetXMLAttribute(*ModelNode, "Name", *Bank\Model()\Name)
    ForEach *Bank\Model()\anim()
      *AnimNode=CreateXMLNode(*ModelNode, "Anim")
      *Anim.Anim=*Bank\Model()\anim()
      SetXMLAttribute(*AnimNode, "BoardName", GetBoardNameFromAnim(*Bank,*Anim))
      SetXMLAttribute(*AnimNode, "AnimName", *Anim\Name)
    Next
  Next
EndProcedure

;===================================================================
;              Get Model from Xml
;      Input:   *ModelsNode= Xml node pointer
;               *Bank = Bank Pointer 
;               
;      Return:  No return
;=================================================================== 
Procedure GetXmlModel(*ModelsNode,*Bank)
  For m=1 To XMLChildCount(*ModelsNode)
    *ModelNode=ChildXMLNode(*ModelsNode,m)
    If GetXMLNodeName(*ModelNode)="Model"
      Protected Name.s,Loop.b
      ExamineXMLAttributes(*ModelNode)
      While NextXMLAttribute(*ModelNode)
        Select XMLAttributeName(*ModelNode)
          Case "Name"
            Name=XMLAttributeValue(*ModelNode)
        EndSelect
      Wend  
      Debug "Add Model "+Name
      *Model=NewModel(*Bank,Name)
      For a=1 To XMLChildCount(*ModelNode)
        *AnimNode=ChildXMLNode(*ModelNode,m)
        If GetXMLNodeName(*AnimNode)="Anim"
          Protected BoardName.s,AnimMame.s
          ExamineXMLAttributes(*AnimNode)
          While NextXMLAttribute(*AnimNode)
            Select XMLAttributeName(*AnimNode)
              Case "BoardName"
                BoardName=XMLAttributeValue(*AnimNode)
              Case "AnimName"
                AnimMame=XMLAttributeValue(*AnimNode)
            EndSelect
          Wend
          *Board=GetBoardByName(BoardName,*Bank)
          If *Board<>#False
            *Anim=GetAnimByName(*Board,AnimMame)
            If *Anim<>#False
              AddAnimToModel(*Anim,*Model)
            Else
              Debug "Can't Find Anim "+AnimMame+" To link with Model "+Name
            EndIf 
          Else
            Debug "Can't Find Board "+BoardMame+" with Anim"+AnimName+" To link with Model "+Name
          EndIf 
          
        EndIf
      Next a
    EndIf
  Next m
  
  
EndProcedure

;-Object

;===================================================================
;              New Object
;      Input:   *Bank = Bank pointer
;               *Model = Model pointer
;               Name = Object Name  
;               
;      Return:  No pointer
;===================================================================  
Procedure.i NewObject(*Bank.Bank,*Model.Model=0,Name.s="")
  AddElement(*Bank\Object())
  *Bank\Object()\Model=*Model
  If Name="" And *Model<>0
    *Bank\Object()\Name=*Model\Name
  Else
    *Bank\Object()\Name=Name
  EndIf
  ProcedureReturn *Bank\Object()
EndProcedure

;===================================================================
;              Is Object Exist
;      Input:   *Object = Object pointer
;               
;      Return:  #True if exist else #False
;=================================================================== 
Procedure.b IsObjectExist(*Object,*Bank.Bank=0)
  If *Bank=0
    ForEach Bank()
      *Bank=Bank()
      ForEach *Bank\Object()
        If *Bank\Object()=*Object
          ProcedureReturn #True
        EndIf 
      Next
    Next
  Else
    ForEach *Bank\Object()
      If *Bank\Object()=*Object
        ProcedureReturn #True
      EndIf 
    Next
  EndIf
  Debug "⚠️ IsObjectExist() "+Str(*Object)+" Object no exist"
  ProcedureReturn #False
  
EndProcedure

;===================================================================
;              Get Object By Name
;      Input:   Name.s = Object name
;               *Bank.Bank = 0 check all Bank else use *Bank pointer
;               
;      Return:  Object pointer if Found or #False
;===================================================================
Procedure.i GetObjectByName(Name.s,*Bank.Bank=0)
  If *Bank=0
    ForEach Bank()
      *Bank=Bank()
      ForEach *Bank\Object()
        If *Bank\Object()\Name=Name
          ProcedureReturn *Bank\Object()
        EndIf 
      Next
    Next
  Else
    ForEach *Bank\Object()
      If *Bank\Object()\Name=Name
        ProcedureReturn *Bank\Object()
      EndIf 
    Next
  EndIf
  Debug "⚠️ GetObjectByName() "+Chr(34)+Name+Chr(34)+" No Found"
  ProcedureReturn #False
EndProcedure

;===================================================================
;              Link Model to Object
;      Input:   *Model = model pointer
;               *Object.Object = Object Pointer
;               Name = 
;               
;      Return:  Object pointer if Found or #False
;===================================================================
Procedure LinkModelToObject(*Model.Model,*Object.object,Name.s="")
  If *Model<>0
    *Object\Model=*Model
    If Name=""
      *Object\Name=*Model\Name
    Else
      *Object\Name=Name
    EndIf
  EndIf
EndProcedure

;===================================================================
;              Change Anim index on Object
;      Input:   *Object = Object pointer
;               Index.i = Anim Index
;               
;      Return:  Object pointer if Found or #False
;===================================================================
Procedure.b SetObjectAnim(*Object.Object,Index.i)
  If Index>=0 And Index<ListSize(*Object\Model\anim())
    *Object\CurrentAnimIndex=Index
    *Object\FrameIndex=0
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf 
EndProcedure

;===================================================================
;              Pause Object Animation
;      Input:   *Object = Object pointer
;               val = #True / #False
;               
;      Return:  No Return
;===================================================================
Procedure PauseObjectAnim(*Object.Object,val.b)
  If val=#True
    *Object\NextFrameTime=-1
  Else
    *Object\NextFrameTime=0
  EndIf 
EndProcedure

;===================================================================
;              Render Object
;      Input:   *Object = Object pointer
;               
;      Return:  No Return
;===================================================================
Procedure RenderObject(*Object.Object)
  Protected Opacity.c=255
  Protected Event.l
  If *Object\Model=0
    Debug "RenderModel() Error : No Model Linked to Object"
    ProcedureReturn #False
  EndIf 
  ;Animation Frame
  If SelectElement(*Object\Model\anim(),*Object\CurrentAnimIndex)<>0
    If ListSize(*Object\Model\anim()\Frame())
      If ElapsedMilliseconds()>*Object\NextFrameTime ; It's time to go to next Frame
        If *Object\NextFrameTime<>-1                 ; If Animation not paused
          *Object\FrameIndex=*Object\FrameIndex+1    ; Change Frame
                                                     ;Event=#Anim_Event_ChangeFrame
          If *Object\FrameIndex>ListSize(*Object\Model\anim()\Frame())-1 ; If anim's End Loop to first Frame
            If *Object\Model\anim()\Loop=#True
              *Object\FrameIndex=0
              ;Event=#Anim_Event_Loop
            Else
              *Object\FrameIndex=ListSize(*Object\Model\anim()\frame())-1
              ;Event=#Anim_Event_End
            EndIf 
          EndIf
          *Object\NextFrameTime=ElapsedMilliseconds()+*Object\Model\anim()\Frame()\delay
        EndIf
      EndIf
      
      Protected *Frame.Frame
      *Frame=GetFrameFromModel(*Object\Model,*Object\CurrentAnimIndex,*Object\FrameIndex)
      If *Frame<>#False 
        If IsImage(*Frame\Clip\ImageId)
          *Object\CurrentImageId=*Frame\Clip\ImageID     
        Else 
          Debug "⚠️ RenderModel() Error : Clip Image Id not initialized AnimIndex="+Str(*Object\CurrentAnimIndex)+" FrameIndex="+Str(*Object\FrameIndex)
          ProcedureReturn #False
        EndIf
      Else
        Debug "⚠️ RenderModel() Error : *Frame not initialized AnimIndex="+Str(*Object\CurrentAnimIndex)+" FrameIndex="+Str(*Object\FrameIndex)
        ProcedureReturn #False
      EndIf 
    EndIf 
  EndIf 
  ;DrawImage Only if i
  If IsImage(*Object\CurrentImageId)
    DrawAlphaImage(ImageID(*Object\CurrentImageId),*Object\Coord\x-*Frame\Anchor\x,*Object\Coord\y-*Frame\Anchor\y,*Frame\Opacity)
  EndIf 
EndProcedure

;- Bank

;===================================================================
;              Check if Bank Exist
;      Input:   *Bank = Bank pointer
;               
;      Return:  No Return
;===================================================================
Procedure.b IsBankExist(*Bank)
  ForEach Bank()
    If Bank()=*Bank
      ProcedureReturn #True
    EndIf 
  Next
  ProcedureReturn #False
EndProcedure

;===================================================================
;              Create New Bank
;      Input:   Name = Bank Name
;               
;      Return:  Return Bank Pointer
;===================================================================
Procedure.i NewBank(Name.s="")
  AddElement(Bank())
  If Name=""
    Name="Bank "+Str(ListIndex(Bank()))
  EndIf
  Bank()\Name=Name
  ProcedureReturn Bank()
EndProcedure

;===================================================================
;              Set Bank to Xml
;      Input:   *MainNode = Xml Node
;               *Bank = Bank Pointer
;               
;      Return:  No return
;===================================================================
Procedure SetXmlBank(*MainNode,*Bank.Bank)
  NewMap ClipIndex.s()
  *BankNode= CreateXMLNode(*MainNode, "Bank")
  SetXMLAttribute(*BankNode, "Name", *Bank\Name)
  *BoardsNode= CreateXMLNode(*BankNode, "Boards")
  SetXmlBoard(*BoardsNode,*Bank.Bank,ClipIndex())
  *ModelsNode= CreateXMLNode(*BankNode, "Models")
  SetXmlModel(*ModelsNode,*Bank)
EndProcedure

;===================================================================
;              Get Bank from Xml
;      Input:   *BankNode = Xml Node
;               
;      Return:  Return bank pointer
;===================================================================
Procedure GetXmlBank(*BankNode)
  ExamineXMLAttributes(*BankNode)
  Protected Name.s
  While NextXMLAttribute(*BankNode)
    Select XMLAttributeName(*BankNode)
      Case "Name"
        Name.s=XMLAttributeValue(*BankNode)
    EndSelect
  Wend  
  *Bank=NewBank(Name)
  
  For c=1 To XMLChildCount(*BankNode)
    *ChildNode=ChildXMLNode(*BankNode,c)
    Select GetXMLNodeName(*ChildNode)
      Case "Boards"
        GetXmlBoard(*ChildNode,*Bank)
      Case "Models"
        GetXmlModel(*ChildNode,*Bank)
      Default
        Debug "⚠️ GetXmlBank() Error XML "+GetXMLNodeName(*ChildNode)+" Unknow"
    EndSelect
  Next
  ProcedureReturn *Bank
EndProcedure

;===================================================================
;              Save Bank
;      Input:   *Bank = Bank Pointer
;               Name.s= Filename
;               
;      Return:  No return
;===================================================================
Procedure SaveBank(*Bank.Bank,Name.s="")
  Protected.i Xml,MainNode,BankNode,SpriteSheetNode,ClipNode,AnimNode
  Xml = CreateXML(#PB_Any)
  *MainNode=RootXMLNode(xml)
  SetXmlBank(*MainNode,*Bank.Bank)
  FormatXML(XML, #PB_XML_ReFormat,4)
  SaveXML(xml, Name)
EndProcedure

;===================================================================
;              Check Xml
;      Input:   Xml = XmlId
;               FileName.s= Filename
;               
;      Return:  #True Xml is Ok / #False ... Xml Error
;===================================================================
Procedure CheckXml(Xml.i,FileName.s)
  Protected Message.s
  If XMLStatus(xml) <> #PB_XML_Success
    Message = "Error in the XML file:" + GetFilePart(Filename) + Chr(13)
    Message + "Message: " + XMLError(Xml) + Chr(13)
    Message + "Line: " + Str(XMLErrorLine(Xml)) + "   Character: " + Str(XMLErrorPosition(Xml))
    MessageRequester("Error", Message)
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

;===================================================================
;              Load Bank
;      Input:   Name = FilneNamedir
;               
;      Return:  Bank Pointer
;===================================================================
Procedure.i LoadBank(Name.s)
  If FileSize(Name)>0
   Xml=LoadXML(#PB_Any,Name)
    If Xml<>0
      If CheckXml(Xml,Name)=#False
        Debug "XML Error"
        End
      EndIf
      *MainNode=MainXMLNode(Xml)
      ProcedureReturn GetXmlBank(*MainNode)
    EndIf
  Else
    Debug "⚠️ LoadBank() File "+Chr(34)+Name+Chr(34)+" No exist !"
    End
  EndIf 
  EndProcedure
  
EndModule


;- Demo

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration
    #Mode_Create_Bank
    #Mode_Load_Bank
  EndEnumeration
  
  Mode=#Mode_Create_Bank;TODO change to try
    
  InitSprite()
  UsePNGImageDecoder()
  UsePNGImageEncoder()
  
  Define winMain.i = OpenWindow(#PB_Any,0,0,1024,800,"Press [Esc] to close",#PB_Window_ScreenCentered | #PB_Window_SystemMenu)
  OpenWindowedScreen(WindowID(winMain), 0, 0,1024,800, 1, 0, 0)
  UseModule BKA
  
  Select Mode
    Case #Mode_Create_Bank
      Define *Bank=NewBank()
      Define *Board=AddBoardToBank(LoadImage(#PB_Any,"24493.png"),"Vieux",*Bank)
      LoadClipsFromFile("24493.png",*Board)
      ; First Animation
      Define *Anim=AddAnimToBoard(*Board)
      SetAnim(*Anim,*Board,"1,2,3,4,5,6")
      ; Second Animation
      *Anim=AddAnimToBoard(*Board)
      SetAnim(*Anim,*Board,"7,8,9,10,11,12")
      Define *Model=NewModel(*Bank,"Hero")
      AddAnimToModel(*Anim,*Model)
      SaveBank(*Bank,"Bank_Testouille.xml")
      Define *Object=NewObject(*Bank,*Model)
       
    Case #Mode_Load_Bank
      Define *Bank=LoadBank("Bank_Testouille.xml")
      Define *Model=GetModelByName("Hero",*Bank)
      Define *Object=NewObject(*Bank,*Model)
      
  EndSelect

  Define Event.i,Val.b
  Repeat
    Repeat
      Event = WindowEvent()
      Select Event 
        Case #PB_Event_CloseWindow
          ;gfx::FreeSpriteSheet(*SpriteSheet)
          End
        Case #PB_Event_LeftClick
          ;Obj::SetObjectAnim(*Object,0)
        Case #PB_Event_RightClick
          ;Obj::SetObjectAnim(*Object,1)
          val=1-val
          ;Obj::PauseObjectAnim(*Object,val)
        Case #PB_Event_Gadget
          If EventGadget() = 0
            End
          EndIf
        Case #PB_Event_CloseWindow
          End 
      EndSelect
    Until Event = 0
    
    ClearScreen(RGB(255,0,0))
    
    StartDrawing(ScreenOutput())
    If RenderObject(*Object)=#True;Obj::#Anim_Event_Loop
      Debug "Loop"
    EndIf
    StopDrawing() 
    FlipBuffers()
  ForEver 
  
CompilerEndIf 
; IDE Options = PureBasic 6.00 Beta 2 (Windows - x64)
; CursorPosition = 1163
; FirstLine = 1163
; Folding = --------
; EnableXP
; CompileSourceDirectory
; EnableCompileCount = 50
; EnableBuildCount = 0
; EnableExeConstant