/*========DESCRIÇÃO Martingale====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
versão com erros de take
========================================================================================================================*/
/*#property strict;
#property strict
#property  version "1.0"
#property  description "Reverse Trend" */

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; //BUY
extern int MagicNumber2 = 8080808; //SELL
extern int StopLoss = 5;
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

static input string CONTACT = "Joaotorresmarques1@Gmail.com";

string Robo = "Reverse Trend VIP 1.2";
int ticket,takeBUY,takeSELL;
double iLots,lote;
datetime espera;


int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {        
//=========================CONTADOR DE ORDENS ABERTAS  
   int count,countsell,countbuy;
   
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
         if (OrderType() == OP_BUY) countbuy++;    
      }
         
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber2)
       {
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
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
      case 3: takeSELL = TrallingStop*1; break;
      case 4: takeSELL = TrallingStop*1; break;
      case 5: takeSELL = TrallingStop*1; break;
      case 6: takeSELL = TrallingStop*1; break;
      case 7: takeSELL = TrallingStop*1; break;
      case 8: takeSELL = TrallingStop*1; break;
      case 9: takeSELL = TrallingStop*1;  break;
   } 
   if(count >= 10) takeSELL = TrallingStop+count*1;
   
    switch(countbuy) 
   {
      case 0: takeBUY = TrallingStop;         break;
      case 1: takeBUY = TrallingStop*1; break;
      case 2: takeBUY = TrallingStop*1; break;
      case 3: takeBUY = TrallingStop*1; break;
      case 4: takeBUY = TrallingStop*1; break;
      case 5: takeBUY = TrallingStop*1; break;
      case 6: takeBUY = TrallingStop*1; break;
      case 7: takeBUY = TrallingStop*1; break;
      case 8: takeBUY = TrallingStop*1; break;
      case 9: takeBUY = TrallingStop*1; break;
   } 
   if(count >= 10) takeBUY = TrallingStop+count*1;      
                 
//++++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR TODAS AS ORDENS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

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
                     if(OrderOpenPrice()<OrderClosePrice()) bool STOPTUDOb = true; 

                  }//FIM OP_BUY
                     
               }//FIM MAGICNUMBER 
               
               if(OrderMagicNumber()==MagicNumber2)
               {  
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice()) bool  STOPTUDO2 = true;
                     
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
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + 10*60;
                     }   
                  
                  }//FIM ORDERMAGIC 
                  
                  if(OrderMagicNumber()==MagicNumber2)
                  {  if(OrderType()==OP_SELL )
                     {
                      if(STOPTUDO2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + 10*60;
                     }
                  }//FIM ORDERMAGIC
                  
                }//FIM SELECT 
           
            }//FIM CONTADOR                 
            
//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
   
                         
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  if(Time[0]>espera){
  if(OrdersTotal()==0)
  {
      ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,NULL,MagicNumber,0,Blue);
      ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,NULL,MagicNumber2,0,Red);
  }    
   }
   
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
              
                  if(SL==0 && Ask+takeBUY*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+takeBUY*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+TrallingStep*MyPoint,0,0,clrLightGreen);
               
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
      
    
   for (int trade1=OrdersTotal()-1; trade1>=0; trade1--) 
   {
      if (OrderSelect(trade1,SELECT_BY_POS,MODE_TRADES)==true) 
      { 
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
         {          
            if(OrderType()==OP_SELL)
            {
              if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,0,0,NULL,MagicNumber2,0,clrGreenYellow);
                break;                                                                  
            }//FIM OP_BUY 
           
         }
 
       }
   }

   for (int trade14=OrdersTotal()-1; trade14>=0; trade14--) 
   {
      if (OrderSelect(trade14,SELECT_BY_POS,MODE_TRADES)==true) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {          
            if(OrderType()==OP_BUY)
            {
              if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,0,0,NULL,MagicNumber,0,clrGreenYellow);
                break;                                                                  
            }//FIM OP_BUY 
          }
      }
    }
  
   

   

  }//FIM ONTICK
 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
 /*
    for (int trade31=OrdersTotal()-2; trade31>=0; trade31--) 
    {
      if (OrderSelect(trade31,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber || OrderMagicNumber()==MagicNumber2) )
         {  
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy2 = OrderOpenPrice();
                  double SL2 = OrderStopLoss();
              
                  if(SL2==0 && Ask+takeBUY*MyPoint>stnewpricebuy2) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy2+takeBUY*MyPoint,0,0,clrLightGreen);
                  
                  if(SL2>0 && (OrderStopLoss()<(Ask+TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL2+TrallingStep*MyPoint,0,0,clrLightGreen);
               }//FIM OP_BUY  

               
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell2 = OrderOpenPrice();
                  double SLsell2 = OrderStopLoss();
               
                  if(SLsell2==0 && Bid-takeSELL*MyPoint<stnewpricesell2) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell2-takeSELL*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell2>0 && (OrderStopLoss()>(Bid-TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell2-TrallingStep*MyPoint,0,0,clrLightGreen);
               }//FIM OP_SELL
              
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR   
    */