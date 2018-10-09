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
int ticket,takeBUY,takeSELL;
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
 
      
   switch(count) 
   {
      case 0: iLots = Lots; break;
      case 1: iLots = 0.02; break;
      case 2: iLots = 0.02; break;
      case 3: iLots = 0.03; break;
      case 4: iLots = 0.05; break;
      case 5: iLots = 0.08; break;
      case 6: iLots = 0.11; break;
      case 7: iLots = 0.15; break;
      case 8: iLots = 0.26; break;
      case 9: iLots = 0.29; break;
      case 10: iLots = 0.34; break;
   }
      if(count>=10) iLots = count*0.06;   
      
//=========================CONFIGURAÇÃO DE TAKES   
    switch(countsell) 
   {
      case 0: takeSELL = TrallingStop;         break;
      case 1: takeSELL = TrallingStop*1; break;
      case 2: takeSELL = TrallingStop*1; break;
      case 3: takeSELL = TrallingStop+count*1; break;
      case 4: takeSELL = TrallingStop+count*1; break;
      case 5: takeSELL = TrallingStop+count*1; break;
      case 6: takeSELL = TrallingStop+count*1; break;
      case 7: takeSELL = TrallingStop+count*1; break;
      case 8: takeSELL = TrallingStop+count*1; break;
      case 9: takeSELL = TrallingStop+count*1;  break;
   } 
   if(count >= 10) takeSELL = TrallingStop+count*1;
   
    switch(countbuy) 
   {
      case 0: takeBUY = TrallingStop;         break;
      case 1: takeBUY = TrallingStop*1; break;
      case 2: takeBUY = TrallingStop*1; break;
      case 3: takeBUY = TrallingStop+count*1; break;
      case 4: takeBUY = TrallingStop+count*1; break;
      case 5: takeBUY = TrallingStop+count*1; break;
      case 6: takeBUY = TrallingStop+count*1; break;
      case 7: takeBUY = TrallingStop+count*1; break;
      case 8: takeBUY = TrallingStop+count*1; break;
      case 9: takeBUY = TrallingStop+count*1; break;
   } 
   if(count >= 10) takeBUY = TrallingStop+count*1;      
         
//++++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR TODAS AS ORDENS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
if(OrdersTotal()==0)STOPTUDOb=false;  STOPTUDO2=false;

         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               if(OrderMagicNumber()==MagicNumber)
               {  
                  if(OrderType()==OP_BUY)
                  {
                     if(OrderOpenPrice()<OrderClosePrice()) STOPTUDOb = true; 
                    

                  }//FIM OP_BUY
                     
               }//FIM MAGICNUMBER 
               
               if(OrderMagicNumber()==MagicNumber2)
               {  
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice())  STOPTUDO2 = true;
                     
                  }//FIM OP_SELL
                  
               }//FIM MAGIC
               
           }//FIM ORDERSELECT
        }//FIM ORDERHISTORY 
            
          
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(i,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                     if(OrderType()==OP_BUY)
                     {
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }   
                  
                  }//FIM ORDERMAGIC 
                  
                  if(OrderMagicNumber()==MagicNumber2)
                  {  if(OrderType()==OP_SELL )
                     {
                      if(STOPTUDO2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }
                  }//FIM ORDERMAGIC
                  
                }//FIM SELECT 
           
            }//FIM CONTADOR  
                            
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  
    if((countbuy==0 && countbuystop==0) && (countsell==0 && countsellstop==0)  )
    {
         if(Ask-PipsCandle*MyPoint>Open[0])
         {
            ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots,Close[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
            ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber2,0,Red);
         } 
    }   

    if((countsell==0 && countsellstop==0) && (countbuy==0 && countbuystop==0))
    {
         if(Bid+PipsCandle*MyPoint<Open[0])
         {
           ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots,Open[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
           ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Close[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber2,0,Red); 
         }        
      
    } 
     
  

//++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR ORDENS PENDENTES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    for (int trade7=OrdersTotal()-1; trade7>=0; trade7--) 
   {
      if (OrderSelect(trade7,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {    
            if(OrderType()==OP_BUYSTOP)
            {   
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green);  
            }//FIM OP_BUYSTOP
            
         }
                  
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
         {  
            if(OrderType()==OP_SELLSTOP)
            {  
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green); 
            }//FIM OP_SELLSTOP
             
         }//FIM MAGIC
         
      }//FIM ORDERSELECT
    }//FIM CONTADOR
    

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
 
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber || OrderMagicNumber()==MagicNumber2) )
         {  
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
              
                  if(SL==0 ) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+takeBUY*MyPoint,0,0,clrLightGreen);
                  
                  //if(SL>0 && (OrderStopLoss()<(Ask+TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+TrallingStep*MyPoint,0,0,clrLightGreen);
               }//FIM OP_BUY  

               
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-takeSELL*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-takeSELL*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-TrallingStep*MyPoint,0,0,clrLightGreen);
               }//FIM OP_SELL
              
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  

 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ENVIO DE ORDEM MARTINGAE++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
   
 
  if(count<MaxOrders)
  {       
   for (int trade1=OrdersTotal()-1; trade1>=0; trade1--) 
   {
      if (OrderSelect(trade1,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {            
            if(OrderType()==OP_BUY)
            {
              if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,0,0,NULL,MagicNumber,0,clrGreenYellow);
               break;                                                                           
            }//FIM OP_BUY 
           
         } //FIM ORDERMAGIC 
              
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
         {
             if(OrderType()==OP_SELL)
             {
                if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,0,0,NULL,MagicNumber2,0,clrGreenYellow);
                break; 
             }//FIM OP_SELL
                   
         }//FIM ORDERMAGIC 
         
      }//FIM ORDERSELECT     
   }//FIM CONTADOR  
  }//FIM MAX ORDERS
   

   

  }//FIM ONTICK
 