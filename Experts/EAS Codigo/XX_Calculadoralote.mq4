//+------------------------------------------------------------------+
//|                                           XX_Calculadoralote.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int LotOpt() //--function: calculation Optimization Lots
   {
      if (lotopt) 
         {
           //----
           mrg = AccountBalance();
           if (mrg < 1000) {lot = 0.1;} 
           if ((mrg > 1000) && (mrg < 5000)) {lot = 0.1;}
           if ((mrg > 5000) && (mrg < 9000)) {lot = 0.2;}
           if ((mrg > 9000) && (mrg < 13000)) {lot = 0.3;}
           if ((mrg > 13000) && (mrg < 17000)) {lot = 0.4;}
           if ((mrg > 17000) && (mrg < 21000)) {lot = 0.5;}
           if ((mrg > 21000) && (mrg < 25000)) {lot = 0.6;}
           if ((mrg > 25000) && (mrg < 29000)) {lot = 0.7;}
           if ((mrg > 29000) && (mrg < 33000)) {lot = 0.8;}
           if ((mrg > 33000) && (mrg < 37000)) {lot = 0.9;}
           if ((mrg > 41000) && (mrg < 45000)) {lot = 1.0;}
           if (mrg > 45000) {lot = 1.5;}
         }
      else lot = Lots;
      return(lot);
      //----
   } //-end LotOpt()
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
   
  }
//+------------------------------------------------------------------+
