//+------------------------------------------------------------------+
//|                                                 LoadHistory.mq4
//|                                          Copyright 2012, K Lam
//+------------------------------------------------------------------+
//
//Version 2
// fix in unknow the timeframe H1
//load all timeframe, leave the frame M1

#property copyright "Copyright 2010, K Lam"
#property link      "FXKill.U"

#define Version  20130121

#import "kernel32.dll"
   int _lopen  (string path, int of);
   int _llseek (int handle, int offset, int origin);
   int _lread  (int handle, string buffer, int bytes);
   int _lclose (int handle);
#import
#import "user32.dll"
   int GetAncestor (int hWnd, int gaFlags);
   int GetParent (int hWnd);
   int GetDlgItem (int hDlg, int nIDDlgItem);
   int SendMessageA (int hWnd, int Msg, int wParam, int lParam);
   int PostMessageA (int hWnd, int Msg, int wParam, int lParam);
#import

#define LVM_GETITEMCOUNT   0x1004
#define WM_MDIACTIVATE     0x222
#define WM_MDIMAXIMIZE     0x0225
#define WM_MDINEXT         0x0224
#define WM_MDIDESTROY      0x0221

#define WM_SCROLL          0x80F9
#define WM_COMMAND         0x0111
#define WM_KEYUP           0x0101
#define WM_KEYDOWN         0x0100
#define WM_CLOSE           0x0010

#define VK_PGUP            0x21
#define VK_PGDN            0x22
#define VK_HOME            0x24
#define VK_END             0x23
#define VK_DOWN            0x28
#define VK_PLUS            0xBB
#define VK_MINUS           0xBD

bool loadhome = true; //false;
int nsymb;

bool Roundload = false;//true; //
//int LastPage=0;  //0 to close all not 0 then will leave the page open at last time frame
int LastPage=0; //0,1,5,15
int Pause=500;//8000               //Wait 500\ 0.5 scend
int KeyHome=500;
int HomeLoop=2000; //1000
string Symbols[];

int tf[10]={1,5,15,30,60,240,1440,10080,43200,0};

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start() {
   int iFrame;
//--------------------------------------------------------------------
   if(GlobalVariableCheck("glSymbolHandle")) {
      GlobalVariableSet("glSymbolHandle",WindowHandle(Symbol(),Period()));
      return;
   }
   
   if(Roundload) {
      for(iFrame=1;iFrame<10;iFrame++) {//new add Load all page exclude M1
         LastPage=tf[iFrame];
         MarketInfoToSymbols();
         DownloadHomeKey();
         }
      } else {
         MarketInfoToSymbols();
         DownloadHomeKey();
         }
   return;
}


//+------------------------------------------------------------------+
//| MarketInfoToSymbols()                                            |
//+------------------------------------------------------------------+
void MarketInfoToSymbols() {
   int i,handle,handleset,size;
   string symb="symbols     ",path;
   
   path=StringConcatenate(TerminalPath(),"\\history\\",AccountServer(),"\\symbols.sel");//\\symbols.raw"
   handle=_lopen(path,0);
   
   if(handle<0) {
      Print("Error Loding file symbols.sel : ",GetLastError());
      return;
   }
   
   handleset=FileOpen("quoting.set",FILE_READ | FILE_WRITE);
   
   if(handleset<0) {
      Print("Error Creating file quoting.set : ",GetLastError());
      return;
   }
   
   size=128;//size=1936;
   nsymb=_llseek(handle,0,2)/size; //_llseek(handle,i*size,0);
   for(i=0;i<nsymb;i++){
      _llseek(handle,4+(i*size),0);
      _lread(handle,symb,12);
      FileWrite(handleset,symb);
      }
      
   _lclose(handle);                                                  //close symbols.sel
   
   if(!FileSeek(handleset,0,SEEK_SET)) {
      Print("Error Seeking file quoting.set : ",GetLastError());
   }
   ArrayResize(Symbols,nsymb+1);
   
   for(i=1;i<=nsymb;i++){//for(i=0;i<nsymb;i++){
      Symbols[i]=FileReadString(handleset);
   }
   
   FileClose(handleset);
   FileDelete("quoting.set");
   return;
}

//+------------------------------------------------------------------+
//| DownloadHomeKey()                                                |
//+------------------------------------------------------------------+
void DownloadHomeKey() {
   int i,j,k,l,m,n;
   int hmain,handle,handlechart,count,num;
//   int tf[9]={1,5,15,30,60,240,1440,10080,43200};
   int TimeF[9]={33137,33138,33139,33140,35400,33136,33134,33141,33334};
   int StartBars,PreBars,CurrBars;
   
   GlobalVariableSet("glSymbolHandle",WindowHandle(Symbol(),Period()));
   hmain=GetAncestor(WindowHandle(Symbol(),Period()),2);
   if (hmain!=0) {
      handle=GetDlgItem(hmain,0xE81C);
      handle=GetDlgItem(handle,0x50);
      handle=GetDlgItem(handle,0x8A71);
      count=SendMessageA(handle,LVM_GETITEMCOUNT,0,0);
      } else Print("Error :",GetLastError());

   for(i=1;i<=count&&!IsStopped();i++) {
      OpenChart(i,hmain);
      Sleep(Pause);
      PostMessageA(hmain,WM_COMMAND,33042,0);
      Sleep(Pause);
      handlechart=GlobalVariableGet("glSymbolHandle");
         //PostMessageA(handlechart,WM_COMMAND,WM_SCROLL,0);
         SendMessageA(handlechart,WM_COMMAND,WM_MDIMAXIMIZE,0);
         for(m=0;m<8;m++) {
            PostMessageA(handlechart, WM_KEYDOWN, VK_MINUS,0);//Pass - Key for 10 time
            //PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);//Pass HOME Key
            Sleep(2);
            }
         j=2;
         StartBars=iBars(Symbols[i],tf[j]);
         //LOOP HOME FOR 30   
         if(loadhome)
            for(l=0;l<HomeLoop;l++) {
               //key in 30 time
               for(m=0;m<30;m++) {
                  PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);//Pass HOME Key
                  Sleep(2);
                  }
               CurrBars=iBars(Symbols[i],tf[j]);
               if(PreBars!=CurrBars) {
                  k=0;
                  PreBars=CurrBars;
                  } else k++;
               if(k>5) { //if 5 time is same then break
                  Print("Start Bar@",StartBars," Bar=",CurrBars," at ",Symbols[i]," Timeframe=",tf[j]);
                  break;
                  }            
               }//if(loadhome)
               
   //switch page each tf[10]
         for(n=0;n<10;n++) {
            LastPage=tf[n];
            Sleep(1000);
         switch(LastPage) {
            case 1: PostMessageA(handlechart,WM_COMMAND,TimeF[0],0);j=0; break;
            case 5: PostMessageA(handlechart,WM_COMMAND,TimeF[1],0);j=1; break;
            case 15: PostMessageA(handlechart,WM_COMMAND,TimeF[2],0);j=2; break;
            case 30: PostMessageA(handlechart,WM_COMMAND,TimeF[3],0);j=3; break;
            
            case 60: PostMessageA(handlechart,WM_COMMAND,TimeF[4],0);j=4; break;
            case 240: PostMessageA(handlechart,WM_COMMAND,TimeF[5],0);j=5; break;
            case 1440: PostMessageA(handlechart,WM_COMMAND,TimeF[6],0);j=6; break;
            case 10080: PostMessageA(handlechart,WM_COMMAND,TimeF[7],0);j=7; break;
            case 43200: PostMessageA(handlechart,WM_COMMAND,TimeF[8],0);j=8; break;
                        
            case 0: PostMessageA(GetParent(handlechart),WM_CLOSE,0,0); break;
            default: PostMessageA(handlechart,WM_COMMAND,TimeF[2],0);j=2; break;
            }
            StartBars=iBars(Symbols[i],tf[j]);
            Sleep(1000);
            
         if(loadhome)
         for(l=0;l<HomeLoop;l++) {
            //key in 30 time
            for(m=0;m<30;m++) {
               PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);//Pass HOME Key
               Sleep(2);
               }
            //PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);
            Sleep(KeyHome);
            //PostMessageA(handlechart, WM_KEYDOWN, VK_END,0);
            //Sleep(100);
            PostMessageA(handlechart,WM_COMMAND,33324,0);//Refresh
            Sleep(300);
            CurrBars=iBars(Symbols[i],tf[j]);
            
            if(PreBars!=CurrBars) {
               k=0;
               PreBars=CurrBars;
               //Print(Symbols[i]," Timeframe =",tf[j]," PreBars=",PreBars," CurrBars=",CurrBars," Bars=",iBars(Symbols[i],tf[j]));
               //Sleep(500);
               } else k++;
            
            if(k>5) { //if 5 time is same then break
               Print("Start Bar@",StartBars," Bar=",CurrBars," at ",Symbols[i]," Timeframe=",tf[j]);
               break;
               }
            PostMessageA(handlechart, WM_KEYDOWN, VK_END,0);//Sleep(100);
            
            }//for if(loadhome) for(l=0;l<HomeLoop;l++) {
         }//for(n=1;n<10;n++) {         
//         if(!Roundload) {            PostMessageA(GetParent(handlechart),WM_CLOSE,0,0);         }

         //Sleep(Pause);
   } //for(i=1;i<=count&&!IsStopped();i++) {

   GlobalVariableDel("glSymbolHandle");
   return;
}

//+------------------------------------------------------------------+
void OpenChart(int Num, int handle) {
   int hwnd;
   hwnd=GetDlgItem(handle,0xE81C); 
   hwnd=GetDlgItem(hwnd,0x50);
   hwnd=GetDlgItem(hwnd,0x8A71);
   PostMessageA(hwnd,WM_KEYDOWN,VK_HOME,0);
   while(Num>1) {
      PostMessageA(hwnd,WM_KEYDOWN,VK_DOWN,0);
      Num--;
   }
   PostMessageA(handle,WM_COMMAND,33160,0);
   return;
}
//+------------------------------------------------------------------+