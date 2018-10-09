/*========DESCRIÇÃO Martingale====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
murrey EA datas.
              
              *inserção de datas
========================================================================================================================*/
/*#property strict;
#property strict
#property  version "1.0"
#property  description "Reverse Trend" */

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; //BUY
extern int MagicNumber2 = 8080808; //SELL
extern int StopLoss = 10;
extern double Lots = 0.01;

static input string Option2 = "--------Options TrallingStop";
extern int TrallingStop =8;
extern int TrallingStep = 5;

static input string Option3 = "--------Options Martingale";
extern int MaxOrders = 100;

static input string Option4 = "--------Other Options";
extern int PipsCandle=15; 
extern int DistancePips=5; 
extern int MinuteFinish = 80; //encerrar ordem pendente

/*static input string Option5 = "--------Options DATE";
extern bool TuesdayTrade = true;
extern bool WednesdayTrade = true;
extern bool ThursdayTrade = true;
extern bool FridayTrade = true;*/

/*static input string Option6 = "--------Options Hour and Minute";
extern bool UseHourandMinute = false;
extern int HourTrade = 13;
extern int MinuteTrade = 10;*/

static input string CONTACT = "Joaotorresmarques1@Gmail.com";

string Robo = "Reverse Trend VIP 1.2";
int ticket,takeBUY,takeSELL,modify,error;
double iLots,lote;
datetime espera;
bool  STOPTUDOb,STOPTUDO2;


int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
   
//=========================CONTADOR DE ORDENS ABERTAS  
   int count,countsellstop,countbuystop,countsell,countbuy;
   
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
         if (OrderType() == OP_BUYSTOP) countbuystop++; 
         if (OrderType() == OP_BUY) countbuy++;    
      }
         
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber2)
       {
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
         if (OrderType() == OP_SELLSTOP) countsellstop++; 
         if (OrderType() == OP_SELL) countsell++;    
       }
   }//FIM CONTADOR 
 
      
   
 
                            
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  
    if((countbuy==0 && countbuystop==0) && (countsell==0 && countsellstop==0)  )
    {
         if(Ask-PipsCandle*MyPoint>Open[0])
         {
            ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots,Close[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
           
         } 
    }   

    if((countsell==0 && countsellstop==0) && (countbuy==0 && countbuystop==0))
    {
         if(Bid+PipsCandle*MyPoint<Open[0])
         {
           ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots,Open[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
         
         }        
      
    } 
     
  

    

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
 
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber) )
         {  
               if(OrderType()==OP_BUY)
               {
               
               
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
              
                  if(SL==0 && Bid+10*MyPoint>stnewpricebuy) modify= OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+10*MyPoint,0,0,clrLightGreen);
                  if(modify<=0) error = GetLastError();
                  Comment(error);
                 
               }//FIM OP_BUY  

               
               
               
              
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  

 
 

   

  }//FIM ONTICK
 