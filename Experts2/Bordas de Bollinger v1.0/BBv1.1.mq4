/*===================ANOTAÇÕES==============================

1) EA 2MA_DivergenceTrader
   Linha 441 Sleep "Otimo para fazer decisões de se o sistema der alguma bronca ele dormir por tantos minutos.
   Linha 422 CEBUY++. "Contador de vitorias e derrotas. analisar e testar."
   
2) EA bill_Williams
   Linhas 174. "Erros. otimo para implementar".
   
3) EA murrey_ea
   Linha 437 "Comentario de informação. Bastante interessante."
   Linha 785."Calculagem de Lots. bastante interessentante!"

4) EA PSAR_TRADER
   linha 142. "Erros".
   
5) EA SmartAssTrade_update2       
   linha 89. 'calculagem de lots"
   Linha 123. "Calculagem de ordem aberta"  

6) EA autopendigbyrsi
   Linha 465. "Função sandmail"
   
7) EA EA_RSI_MA_001a
   Linha 67. "Proibe a inicialização do EA se moeda tiver errada."
   
8) EA rsi_expert
   Linha 187. "erros"   
   
9) EA expertdeestudo
   EA que usa buysignal == true.   

10) EA trendlordfeaw9
   OrdersHistoryTotal().
   
11) EA report
   History      
   
   
** Se Preço for menor 20pips que ordem de operação encerrar.
Tralling stop ok   


===========================================================*/

/*===================ATUALIZAÇÕES==============================
05/03/16 - Iniciar operação com novo candle. Fazendo assim não repitir stops no mesmo candle.


===========================================================*/

#property copyright "João Marcos - BANDAS DE BOLLINGER"
#property link      "#"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Parametros de entrada                                            |
//+------------------------------------------------------------------+
input int MagicNumber=1001;  //Magic Number
input double Lots=0.01;      //LOT. Concerteza sofrerá alteração.
input double AutoStop=20;     //Tralling stop
input double StopLoss=15;    //Stoploss FIXO.


double SLbuy,SLshell;
int modify,ticket;



static datetime new_time = 0;

bool isNewBar(datetime& new_time)
{
   if (new_time != Time[0])               // this helps to avoid placing TRADES on the
   {                                      // same PEAK or BOTTOM multiple times.
      new_time = Time[0];                 //
      return(true);
   }
   else 
      return(false);
}

int OnInit()
  {
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
   //==============MEDIAS MOVEIS ===================================
    double BBupper = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_UPPER,0);        //   MEDIA DE CIMA
    double BBlower =iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,0);    //    MEDIA DE BAIXO
    double RSI = iRSI(NULL,NULL,21,PRICE_CLOSE,0);                     //    MEDIA DO RSI
    
    
    //=================POINT=====================================
    double MyPoint=Point;
    if(Digits==3 || Digits==5) MyPoint=Point*10;
     
   
   
   
   //===============ABERTURA DE ORDEM============================
   if(TotalOrdersCount()==0)
     {
      
      if(RSI <25 && (Low[1] < BBlower)) // Here is the open buy condition
        {
        if(isNewBar(new_time)){
         ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,0,0/*Ask-StopLoss*MyPoint*/,0,NULL,MagicNumber,0,Blue);
         ticket++;
         
         
           }                                           
         }
         
         
       if(RSI>75 && (High[1] > BBupper)) // Here is the open buy condition
        {
        if(isNewBar(new_time)){
         ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,0,0/*Bid+StopLoss*MyPoint*/,0,NULL,MagicNumber,0,Red);
         ticket++;
              }                         
         }  
        
 }

//==============================TRALLING STOP==============================================
   int cnt, total=OrdersTotal();
      for(cnt=0;cnt<total;cnt++)
      {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
         {
            if(OrderType()==OP_BUY)
            {  
              double st =  OrderStopLoss();
              double stnewprice = OrderOpenPrice(); 
              
               if(st<=0){   modify = OrderModify(OrderTicket(),OrderOpenPrice(),stnewprice-StopLoss*MyPoint,0,0,clrLightGreen);}
               
               else if(Ask+AutoStop*MyPoint>st)   modify = OrderModify(OrderTicket(),OrderOpenPrice(),st+AutoStop*MyPoint,0,0,clrLightGreen);
           
            
              
               
            }
      
      
      if(OrderType()==OP_SELL)
         {
          double st =  OrderStopLoss();
          double stnewprice = OrderOpenPrice();
          
          if(st<=0){   modify = OrderModify(OrderTicket(),OrderOpenPrice(),stnewprice+StopLoss*MyPoint,0,0,clrLightGreen);}
               
          else if(Bid-AutoStop*MyPoint<st)   modify = OrderModify(OrderTicket(),OrderOpenPrice(),st-AutoStop*MyPoint,0,0,clrLightGreen);
          //if(Bid-AutoStop*MyPoint<st);  modify = OrderModify(OrderTicket(),OrderOpenPrice(),st-AutoStop*MyPoint,0,0,clrLightGreen);
          
         
              
            
         }
      
      
      
      }//Fim SE Symbom=Symbol
           
      
   }//Fim loop tranding stop.

//FIM onTick()
}




//===============CONTADOR DE ORDENS ===================================
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