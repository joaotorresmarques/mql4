//+------------------------------------------------------------------+
//|                                          XX_Contadordeordens.mq4 |
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
   int TotaldeOrdens()
{

   int resultado=0;
   for(int i=0; i<OrdersTotal(); i++)
   {
   
      OrderSelect(i,SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber()==magicnumber) resultado++;
      
   }
   
   return(resultado);

}
  }
//+------------------------------------------------------------------+
