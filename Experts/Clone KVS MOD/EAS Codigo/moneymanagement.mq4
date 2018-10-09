//+------------------------------------------------------------------+
//|                                              MoneyManagement.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                   https://M2P_Design@hotmail.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://M2P_Design@hotmail.com"
#property version   "1.00"
#property strict
extern double  LotSize = 0.01;
extern   bool    UseMM = false;
extern    int     Risk = 1;

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
// void OnTick()
//   {
//   if(UseMM==true) LotSize=Lots();
//   }
//+------------------------------------------------------------------+
//| Money Management function                                        |
//+------------------------------------------------------------------+
double Lots()
  {
   double lot=MathCeil(AccountFreeMargin()*Risk/1000)/100;
   if(lot<MarketInfo(Symbol(),MODE_MINLOT))
      lot=MarketInfo(Symbol(),MODE_MINLOT);
   if(lot>MarketInfo(Symbol(),MODE_MAXLOT))
      lot=MarketInfo(Symbol(),MODE_MAXLOT);

   return(lot);
  }
//+------------------------------------------------------------------+
