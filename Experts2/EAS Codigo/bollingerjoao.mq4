//+------------------------------------------------------------------+
//|                                                bollingerjoao.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


int periodo = 20;
int desviacion =2;
double StopLoss = 100;
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
    double bbsup = iBands(Symbol(),0,periodo,desviacion,0,PRICE_CLOSE,MODE_UPPER,1);
   double bbinf = iBands(Symbol(),0, periodo, desviacion,0, PRICE_CLOSE,MODE_LOWER,1);
   double mediabb = iMA(Symbol(),0,periodo,0,MODE_SMA,PRICE_CLOSE,1);
   
    double bbsup2 = iBands(Symbol(),0,periodo,desviacion,0,PRICE_CLOSE,MODE_UPPER,2);
   double bbinf2 = iBands(Symbol(),0, periodo, desviacion,0, PRICE_CLOSE,MODE_LOWER,2);
   double mediabb2 = iMA(Symbol(),0,periodo,0,MODE_SMA,PRICE_CLOSE,2);
   
   double OrdenesMercado = OrdersTotal();
   
   if((Open[2] > bbsup2) && (Close[2] > bbsup2)){
      if(OrdenesMercado < 1){
         if(Close[1] < bbsup){
            if(Bid < Close[1]){
               OrderSend( Symbol(), OP_SELL, 1.0, Bid,3,High[2] + StopLoss * Point, mediabb2,"BANDABOLLINGERV1.0",1,0,Red);
            
            }
         
         }
      
      }
   
   
   }
  }
//+------------------------------------------------------------------+
