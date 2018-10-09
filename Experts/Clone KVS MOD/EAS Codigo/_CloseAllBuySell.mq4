//+------------------------------------------------------------------+
//|                                             _CloseAllBuySell.mq4 |
//|                                           "СКРИПТЫ ДЛЯ ЛЕНИВОГО" |
//|         Скрипт закрывает все открытые Buy и Sell в активном окне |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//#property show_confirm
extern int    Slippage      = 5;     // Проскальзывание
int start()
{
bool   Result;
int    i,Pos,Error,Total;
//----
  Total=OrdersTotal();
  if(Total>0)
  {
     for(i=Total-1; i>=0; i--) 
     {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true) 
        {
           Pos=OrderType();
           if(Pos==OP_BUY || Pos==OP_SELL) // Только Buy и Sell
           {
              if(Pos==OP_BUY) 
              Result=OrderClose(OrderTicket(),
                                OrderLots(),
                                Bid,
                                Slippage,
                                CLR_NONE);
              else
              Result=OrderClose(OrderTicket(),
                                OrderLots(),
                                Ask,
                                Slippage,
                                CLR_NONE);
              if(Result!=true) 
              { 
                 Error=GetLastError(); 
                 Print("LastError = ",Error); 
              }
              else Error=0;
           }
        }
     }
  }
  return(0);
}
//+------------------------------------------------------------------+