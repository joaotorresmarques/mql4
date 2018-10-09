//+------------------------------------------------------------------+
//|                                             bollingerjdozero.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "João Marcos - BANDAS DE BOLLINGER"
#property link      "#"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Parametros de entrada                                            |
//+------------------------------------------------------------------+
input int MagicNumber=1982;  //Magic Number
input double Lots=0.01;      //Fixed Lots
input double StopLoss=30;    //Fixed Stop Loss (in Points)
input double TakeProfit=40; //Fixed Take Profit (in Points)
input int TrailingStop=25;   //Trailing Stop (in Points)
input int Slippage=3;

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
   
    double BBup = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_UPPER,0);        //   MEDIA DE CIMA
   double BBlower =iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,0);    //    MEDIA DE BAIXO
   
  double MyPoint=Point;
  if(Digits==3 || Digits==5) MyPoint=Point*10;
   
   double TheStopLoss=0;
   double TheTakeProfit=0;
   
   if(TotalOrdersCount()==0)
     {
      int result=0;
      if((iRSI(NULL,NULL,6,PRICE_CLOSE,0)<30) && (Low[0] < BBlower)) // Here is the open buy condition
        {
         result=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,NULL,MagicNumber,0,Blue);
         if(result>0)
           {
            TheStopLoss=0;
            TheTakeProfit=0;
            if(TakeProfit>0) TheTakeProfit=Ask+TakeProfit*MyPoint;
            if(StopLoss>0) TheStopLoss=Ask-StopLoss*MyPoint;
            int MyOrderSelect=OrderSelect(result,SELECT_BY_TICKET);
            int MyOrderModify=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
           }
        }
      if((iRSI(NULL,0,6,PRICE_CLOSE,0)>70) && (Low[0] > BBup)) // Here is the open Sell condition
        {
         result=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,"EXAMPLE OF RSI AUTOMATED",MagicNumber,0,Red);
         if(result>0)
           {
            TheStopLoss=0;
            TheTakeProfit=0;
            if(TakeProfit>0) TheTakeProfit=Bid-TakeProfit*MyPoint;
            if(StopLoss>0) TheStopLoss=Bid+StopLoss*MyPoint;
            int MyOrderSelect=OrderSelect(result,SELECT_BY_TICKET);
            int MyOrderModify=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
           }
        }
     }


 
}

int TotalOrdersCount()
  {
   int result=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      int MyOrderSelect=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==MagicNumber) result++;

     }
   return (result);
   }