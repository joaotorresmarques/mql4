//+------------------------------------------------------------------+
//|                                                     CloseAll.mq4 |
//|                                      Version 3.01  (30-Sep-2011) |
//|                                                       CodersGuru |
//|                                            http://www.xpworx.com |
//+------------------------------------------------------------------+
#property copyright "CodersGuru"
#property link      "http://www.xpworx.com"
#property show_inputs
//+------------------------------------------------------------------+
extern int option = 0;
//+------------------------------------------------------------------+
// Set this prameter to the type of clsoing you want:
// 0- Close all (instant and pending orders) (Default)
// 1- Close all instant orders
// 2- Close all pending orders
// 3- Close by the magic number
// 4- Close by comment
// 5- Close orders in profit
// 6- Close orders in loss
// 7- Close not today orders
// 8- Close before day orders
//+------------------------------------------------------------------+
extern int magic_number = 0; // set it if you'll use closing option 3 - closing by magic number
extern string comment_text = ""; // set it if you'll use closing option 4 - closing by comment
extern int before_day = 0; // set it if you'll use closing option 8 - closing by before day
extern int Slippage = 5; //Slippage
//+------------------------------------------------------------------+
int start()
{
   CloseAll();
   return(0);
}
//+------------------------------------------------------------------+
int CloseAll()
{
   int total = OrdersTotal();
   int cnt = 0;
   
   switch (option)
   {
      case 0:
      {
         for (cnt = 0 ; cnt <=total ; cnt++)
         {
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if(OrderType()<=OP_SELL) CloseOrder(OrderTicket(),0,Slippage,5,500);
            if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
         }
         break;
      }
      case 1:
      {
         for (cnt = 0 ; cnt <total ; cnt++)
         {
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if(OrderType()<=OP_SELL) CloseOrder(OrderTicket(),0,Slippage,5,500);
         }
         break;
      }
      case 2:
      {
         for (cnt = 0 ; cnt <total ; cnt++)
         {
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
         }
         break;
      }
      case 3:
      {
         for (cnt = 0 ; cnt <total ; cnt++)
         {
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if (OrderMagicNumber() == magic_number)
            {
               if(OrderType()<=OP_SELL) CloseOrder(OrderTicket(),0,Slippage,5,500);
               if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
           }
         }         
         break;
      }
      case 4:
      {
         for (cnt = 0 ; cnt <total ; cnt++)
         {
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if (StringFind(OrderComment(),comment_text)>-1)
            {
               if(OrderType()<=OP_SELL) CloseOrder(OrderTicket(),0,Slippage,5,500);
               if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
           }
         }         
         break;
      }      
      case 5:
      {
         for (cnt = 0 ; cnt <total ; cnt++)
         {
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if(OrderProfit() > 0)
            {
               if(OrderType()<=OP_SELL) CloseOrder(OrderTicket(),0,Slippage,5,500);
               if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
           }
         }         
         break;
      }            
      case 6:
      {
         for (cnt = 0 ; cnt <total ; cnt++)
         {
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if(OrderProfit() < 0)
            {
               if(OrderType()<=OP_SELL) CloseOrder(OrderTicket(),0,Slippage,5,500);
               if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
           }
         }         
         break;
      }            
      case 7:
      {
         for (cnt = 0 ; cnt <total ; cnt++)
         {
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if(TimeDay(OrderOpenTime())!=TimeDay(TimeCurrent()))
            {
               if(OrderType()<=OP_SELL) CloseOrder(OrderTicket(),0,Slippage,5,500);
               if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
           }
         }         
         break;
      }   
      case 8:
      {
         for (cnt = 0 ; cnt <total ; cnt++)
         {
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if(TimeDay(OrderOpenTime())<before_day)
            {
               if(OrderType()<=OP_SELL) CloseOrder(OrderTicket(),0,Slippage,5,500);
               if(OrderType()>OP_SELL) OrderDelete(OrderTicket());
           }
         }         
         break;
      }                           
   }
}
//+------------------------------------------------------------------+
bool CloseOrder(int ticket, double lots, int slippage, int tries, int pause)
{
   bool result=false;
   double ask , bid;
   
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      RefreshRates();
      ask = NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),MarketInfo(OrderSymbol(),MODE_DIGITS));
      bid = NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),MarketInfo(OrderSymbol(),MODE_DIGITS));
      
      if(OrderType()==OP_BUY)
      {
         for(int c = 0 ; c < tries ; c++)
         {
            if(lots==0) result = OrderClose(OrderTicket(),OrderLots(),bid,slippage,Violet);
            else result = OrderClose(OrderTicket(),lots,bid,slippage,Violet);
            if(result==true) break; 
            else
            {
               Sleep(pause);
               RefreshRates();
               ask = NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),MarketInfo(OrderSymbol(),MODE_DIGITS));
               bid = NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),MarketInfo(OrderSymbol(),MODE_DIGITS));      
               continue;
            }
         }
      }
      if(OrderType()==OP_SELL)
      {
         for(c = 0 ; c < tries ; c++)
         {
            if(lots==0) result = OrderClose(OrderTicket(),OrderLots(),ask,slippage,Violet);
            else result = OrderClose(OrderTicket(),lots,ask,slippage,Violet);
            if(result==true) break; 
            else
            {
               Sleep(pause);
               RefreshRates();
               ask = NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),MarketInfo(OrderSymbol(),MODE_DIGITS));
               bid = NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),MarketInfo(OrderSymbol(),MODE_DIGITS));  
               continue;
            }
         }
      }
   }
   return(result);
}
//+------------------------------------------------------------------+