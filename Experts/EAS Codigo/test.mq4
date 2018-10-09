//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double StopLoss = 200.0;
extern double TakeProfit = 200.0;
extern int PeriodoLargo = 200;
extern int PeriodoCorto = 5;
bool VelaNueva = false;





void NuevaBarra(){

   static datetime NuevoTime = 0; //Detectar novo tempo
   
   VelaNueva = false; //0 - mesma vela, 1- nova vela
   
   if(NuevoTime!=Time[0]){
    NuevoTime = Time[0];
    VelaNueva = True;
   
   
   
   }


}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
  
    
  NuevaBarra();
  

  
   if(VelaNueva == True){
   double MediaLarga = iMA(NULL,NULL, PeriodoLargo, 0, MODE_SMA,PRICE_CLOSE,0);
   double MediaCorto = iMA(NULL,NULL, PeriodoCorto,0,MODE_EMA, PRICE_OPEN,0);
   // Alert("Foi criado nova vela SMA, PERIODO: ", Periodo," VALOR DE:", Media1, "VELA EMA:", Media2 );
  
   string texto= "SIN DETERMINAR";
   
 
   
   if(MediaCorto < MediaLarga){ 
   texto = "TENDENCIA BAIXISTA";
   OrderSend(Symbol(),OP_SELL,1,Bid,3,Bid + StopLoss* Point, Bid - TakeProfit * Point,NULL,0,0,Red);
   
   }
      else if (MediaCorto > MediaLarga){
      texto = "TENDENCIA ALCISTA";
      OrderSend(Symbol(),OP_BUY,1,Ask,3, Ask - StopLoss * Point, Ask + TakeProfit * Point,NULL,0,0,Green);
         
      }   
         
         else texto = "TENDENCIA INDETERMINADA";
         
         
      
   ObjectDelete("TENDENCIA");
   ObjectCreate("TENDENCIA", OBJ_LABEL,0,0,0); //CRIA O ROTULO
   ObjectSet("TENDENCIA",OBJPROP_CORNER,1);
   ObjectSet("TENDENCIA",OBJPROP_XDISTANCE,30);
   ObjectSet("TENDENCIA",OBJPROP_YDISTANCE,30);
   ObjectSetText("TENDENCIA", texto,10, "Arial",Red);
  
   }
   
   
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

