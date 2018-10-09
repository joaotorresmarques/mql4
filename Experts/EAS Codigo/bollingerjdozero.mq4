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
extern double BBtop;        //   MEDIA DE CIMA
extern double BBbottom;    //    MEDIA DE BAIXO
extern double BBmidle;    //     MEDIA DO MEIO

extern double Lot = 0.1;
extern int Magic = 1001;
extern int TakeProfit = 200;
extern int StopLoss = 50;
extern int StopMultd = 20;
bool Buysignal;
bool Shellsignal;
int Openbuy;
int Openshell;

//------------------------------------------------------------

double  TP=NormalizeDouble(TakeProfit*StopMultd,Digits);
double  SL=NormalizeDouble(StopLoss*StopMultd,Digits);



double slb=NormalizeDouble(Ask-SL*Point,Digits);  //ST BUY
double sls=NormalizeDouble(Bid+SL*Point,Digits);


double tpb=NormalizeDouble(Ask+TP*Point,Digits);
double tps=NormalizeDouble(Bid-TP*Point,Digits);   



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

//------------------MEDIAS MOVEIS------------------------------------------
      BBtop = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_UPPER,0);
      BBbottom = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,0);
      BBmidle = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_MAIN,0); 
      

//------------------CRITERIO PARA ABERTURA DE ORDEM------------------------
  
     if(Low[0] < BBbottom && Close[1] > Low[0]) Buysignal = true; 
     
     if( High[0] > BBtop && Close[1] > High[0]) Shellsignal = true;
     
     
    
     

//---------------------ABERTURA DE ORDEM-----------------------------------         
   if( Buysignal == true && OrdersTotal()<1)
   {
      Openbuy = OrderSend(NULL,OP_BUY,Lot,Ask,0,0,0,NULL,Magic,0,Blue);  
   }       
   
   if( Shellsignal == true && OrdersTotal()<1)
   {
      Openshell = OrderSend(NULL,OP_SELL,Lot,Bid,0,0,0,NULL,Magic,0,Red);
   }


        
//------------------------TRALLING STOP-----------------------------------  
   if( Openbuy ==1 ||  Openshell ==1)
   {
      if(OrdersTotal()>0)
      {
         for(int i=0; i<=OrdersTotal(); i++)
         {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            {
               if(OrderType() == OP_BUY)        OrderModify(OrderTicket(),0,slb,tpb,0,CLR_NONE); 

                  else if(OrderType() == OP_SELL)     OrderModify(OrderTicket(),0,OrderStopLoss(),tpb,0,CLR_NONE); 
             }                                                  
                                                                          
        } 
       }
   }
            
           
         
         
         










  }
//+------------------------------------------------------------------+
