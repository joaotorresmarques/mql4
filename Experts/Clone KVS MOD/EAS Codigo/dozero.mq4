//+------------------------------------------------------------------+
//|                                                       dozero.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| 1º EA. 
// Candle esta acima da MEDIA MOVEL DE 21 :: COMPRA. 
// Candle esta abaixo da MEDIA MOVEL DE 21 :: VENDA.
// 
//+------------------------------------------------------------------+

// PARAMETROS 

double ma          =        iMA(NULL,NULL,21,0,MODE_SMA,PRICE_CLOSE,0);
int takeprofit     =        0;
int stoploss       =        0;
int magicnumber    =        1001;
double lots       =        0.1;
int Current;


// FIM PARAMETROS
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
  

         if(Close[0] < ma){
         OrderSend(Symbol(),OP_SELL ,lots,Bid,0,0,0,NULL,magicnumber,0,Blue);
         }  
         
         else if(Close[0] > ma){
         OrderSend(Symbol(),OP_BUY,lots,Ask,0,0,0,NULL,magicnumber,0,Red);
         
         }
        
  
 


 
   }
//+------------------------------------------------------------------+
