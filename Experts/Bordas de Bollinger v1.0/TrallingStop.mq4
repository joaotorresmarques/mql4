//+------------------------------------------------------------------+
//|                                                            x.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
int MagicNumber=1;
int ticket;

input double Lots=0.01;      //LOT. Concerteza sofrerá alteração.
input double AutoStop=20;     //Tralling stop
input double StopLoss=30;    //Stoploss FIXO.


double SLbuy,SLshell;
int modify;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

//=================POINT=====================================
            double MyPoint=Point;
            if(Digits==3 || Digits==5) MyPoint=Point*10;
            
            
   if(OrdersTotal()==0)
      {
         ticket   =      OrderSend(Symbol(),OP_BUY,1.0,Ask,0,0,0,NULL,MagicNumber,0,Blue);      
         
      }
 
 
  int cnt, total=OrdersTotal();
      for(cnt=0;cnt<total;cnt++)
      {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
         {
            if(OrderType()==OP_BUY)
            {  
             double stnewpricebuy = OrderOpenPrice();
             double SL = OrderStopLoss();
                  
                  if(SL<=0 && Ask-20*MyPoint>stnewpricebuy)
                  {
                     modify = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+10*MyPoint,0,0,clrLightGreen);
                  } 
                     
                  if(SL>0 && Ask-20*MyPoint>SL)
                  {
                     modify = OrderModify(OrderTicket(),OrderOpenPrice(),SL+10*MyPoint,0,0,clrLightGreen);
                  }   
                  
                  else if(Ask+30*MyPoint<stnewpricebuy)
                  {
                     OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrAliceBlue);
                     }
            
              
               
            }
            }}
 
 
 
 
 
 
 
  }
//+------------------------------------------------------------------+
