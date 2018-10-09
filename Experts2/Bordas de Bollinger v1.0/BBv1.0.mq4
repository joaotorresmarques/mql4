/*=============================================================
 Info:    Bordas de Bollinger - João Marcos Torres
 Name:    BBv1.0.mq4
 Author:  João Marcos Torres
 Version: 1.0 //Apenas alterar a versão quando estiver em conta real.
 Update:  22/02/2016 
 Notes:   
=============================================================*/

/*--------------------------ANOTAÇÕES---------------------------------
      
      1) Estudar contador de vitorias e derrotas para colocar como ObjectCreate.
      2) Fiz um estudo rapido do RSI com alguns parametros e quase todos foram GAIN.
      estudar mais afundo sobre a media usada e os parametros.
      Concerteza irei usar BB+RSI. Rumo ao Santo graal! :)
      
      MTF_rsi_sar muito interessante, tem os IF's pra enviar mercado.
      
      
---------------------------------------------------------------------*/


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
  
extern int Magic = 1001;
extern int TakeProfit = 200; //TAKEPROFIT NAO IRÁ EXISTIR. APENAS OBJ DE ESTUDO AQUI.
extern int StopLoss = 500; //STOPLOSS INICIAL;

extern double Lot = 0.1; //O PADRÃO SERÁ ESSE. MÁS PENSO EM: 1)CONTADOR CONFORME DINDIN. 2)DE ACORDO COM O SINAL DO RSI.
bool Buysignal;
bool Shellsignal;
double slbuy = NormalizeDouble(OrderOpenPrice()-100*Point,Digits); //50Pips

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

//-----------------------BB e RSI------------------------------------------
   double BBup = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_UPPER,0);        //   MEDIA DE CIMA
   double BBmain= iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_MAIN,0);     //     MEDIA DO MEIO
   double BBlower =iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,0);    //    MEDIA DE BAIXO
   double RSI = iRSI(NULL,NULL,6,PRICE_CLOSE,0);
      

//------------------CRITERIO PARA ABERTURA DE ORDEM------------------------
  
    //SINAL DE COMPRA
     if((Ask < BBlower) && RSI < 30) Buysignal = true; 
     // if(iRSI(NULL,0,5,PRICE_CLOSE,0)<30) RSI!!!!
    //SINAL DE VENDA 
     //if( High[1] > BBup && Close[0] > Close[1]) Shellsignal = true;
     
     
    
     

//---------------------ABERTURA DE ORDEM-----------------------------------         
   if( Buysignal == true && OrdersTotal()<1)
   {
      OrderSend(NULL,OP_BUY,Lot,Ask,0,0,0,NULL,Magic,0,Blue);  
   }       
   
   /*if( Shellsignal == true && OrdersTotal()<1)
   {
      OrderSend(NULL,OP_SELL,Lot,Bid,0,0,0,NULL,Magic,0,Red);
   }
*/

   
//------------------------DEFINIÇÃO DE TAKE E STOP-----------------------------------  
   /*SLINICIAL=10, se chegar a 10+ então subir SP, depois acrescentar de 5 em 5 pips. ( PROJETO).
   
   */
   
   //if(isNewBar(new_time))
   //{
   
      if(OrdersTotal()>0)
      {
         for(int i=0; i<OrdersTotal(); i++)
         {
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if(OrderType() == OP_BUY)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),slbuy,0,0,clrPink); 
               
               }   
         }                                                                            
      }
  
   //}
 


 
}
//+------------------------------------------------------------------+

/*
if(TotalOrdersCount()==0)
     {
      int result=0;
      if((iRSI(NULL,0,14,PRICE_CLOSE,0)<25)) // Here is the open buy condition
        {
         result=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,"EXAMPLE OF RSI AUTOMATED",MagicNumber,0,Blue);
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
        
        
        UM EXEMPLLO MASSA PRA FAZER O STOPLOSS AUTOMATICO. DEPOIS DE 10 ACRESCENTAR 5PIPS.
        EA rsi-automated
        */