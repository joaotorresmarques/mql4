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
extern double BBup;        //   MEDIA DE CIMA
extern double BBlower;    //    MEDIA DE BAIXO
extern double BBmain;     //     MEDIA DO MEIO
  
extern double Lot = 0.1;
extern int Magic = 1001;
extern int TakeProfit = 200;
extern int StopLoss = 500;

bool Buysignal;
bool Shellsignal;
int Openbuy;
int Openshell;
/*static datetime new_time = 0; 

 bool isNewBar(datetime& new_time)
{
   if (new_time != Time[0])               
   {                                      
      new_time = Time[0];                 
      return(true);
   }
   else 
      return(false);
}
*/   
   

//------------------------------------------------------------





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
      BBup = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_UPPER,0);
      BBlower = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,0);
      BBmain = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_MAIN,0); 
      

//------------------CRITERIO PARA ABERTURA DE ORDEM------------------------
  
    //SINAL DE COMPRA
     if( Ask < BBlower && Close[1]>BBlower && Close[1] > Close[2]   ) Buysignal = true; 
     
    //SINAL DE VENDA 
     //if( High[1] > BBup && Close[0] > Close[1]) Shellsignal = true;
     
     
    
     

//---------------------ABERTURA DE ORDEM-----------------------------------         
   if( Buysignal == true && OrdersTotal()<1)
   {
      Openbuy = OrderSend(NULL,OP_BUY,Lot,Ask,0,0,0,NULL,Magic,0,Blue);  
   }       
   
   /*if( Shellsignal == true && OrdersTotal()<1)
   {
      Openshell = OrderSend(NULL,OP_SELL,Lot,Bid,0,0,0,NULL,Magic,0,Red);
   }
*/

   
//------------------------DEFINIÇÃO DE TAKE E STOP-----------------------------------  
   //if(isNewBar(new_time))
   //{
   
      if(OrdersTotal()>0)
      {
         for(int i=0; i<OrdersTotal(); i++)
         {
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if(OrderType() == OP_BUY)        OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-500*Point,Digits),0,0,clrPink); 
                  
         }                                                                            
      }
  
   //}
 


 
}
//+------------------------------------------------------------------+
