/*===================ANOTAÇÕES==============================

1) SIMULAÇÃO:
   -Operações abertas. 
   OP_BUY chega a 20PIPS, tralling stop ativado.
   OP_SHELL recebe a ordem de CLOSE.
   Aguardar para OP_BUY receber mais pips de 20 em 20.
   OP_BUY foi estopado.
   FIM DE PROGRAMA. 
   
   OPERAÇÕES ABERTAS.


==========================================================*/




/*===================ATUALIZAÇÕES==============================



===========================================================*/


//+------------------------------------------------------------------+
//| Definição de Parametros                                          |
//+------------------------------------------------------------------+
input int MagicNumber=1001;  //Magic Number
input double Lots=0.01;

int modify;
int ticketbuy,ticketshell;
int ticket;



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
            //=================POINT=====================================
            double MyPoint=Point;
            if(Digits==3 || Digits==5) MyPoint=Point*10;




//===============ABERTURA DE ORDEM============================

      if(TotalOrdersCount()<2)
      {
   
      ticket   =    OrderSend(Symbol(),OP_BUY,Lots,Ask,0,0,0,NULL,MagicNumber,0,Blue);
      ticketbuy = OrderTicket();
      
      
      ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,0,0,0,NULL,MagicNumber,0,Red);
      ticketshell = OrderTicket();
 
      }
      
//===================TRALLING STOP============================      
      int cnt, total=OrdersTotal();
      for(cnt=0;cnt<total;cnt++)
      {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
         {
            if(OrderType()==OP_BUY)
            { 
                  double stnewprice = OrderOpenPrice();
               if(stnewprice< stnewprice+20*MyPoint)
               {
                  modify = OrderModify(OrderTicket(),OrderOpenPrice(),stnewprice+20*MyPoint,0,0,clrLightGreen);
                  
               }
               
            }         
         }
      
     }  
     
     
     if(modify==1) int close = OrderClose(ticketshell,Lots,Ask,0,0);
     
   }//FIM OnTick()
//+------------------------------------------------------------------+



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