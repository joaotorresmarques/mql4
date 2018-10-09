//+------------------------------------------------------------------+
//|                                                      2MA_RSI.mq4 |
//|                                                      TO StatBars |
//|                                          http://euronis-free.com |
//+------------------------------------------------------------------+
#property copyright "TO StatBars"
#property link      "http://euronis-free.com"

extern int MA_Fast_Period = 5;
extern int MA_Fast_Method = 1;
extern int MA_Fast_Price = 5;

extern int MA_Slow_Period = 21;
extern int MA_Slow_Method = 1;
extern int MA_Slow_Price = 5;

extern int RSI_Period = 21;
extern int RSI_Price = 5;
extern double RSI_Level = 50;

extern bool Trailinf_Flag = true;
extern int Trailing_Stop = 100;
extern int Trailing_Step = 5;

extern int Magic_Number = 89403;
extern double lot = 0.1;

int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   
    // Трейлинг
   if( Trailinf_Flag )
   {
      // Трал
      if( Orders_Total_by_type( OP_BUY,  Magic_Number, Symbol()) > 0 )
      {
         // для BUY
         for( int i = OrdersTotal() ; i >= 0 ; i--)
         {
            OrderSelect( i, SELECT_BY_POS, MODE_TRADES);
            if( OrderType() == OP_BUY && OrderMagicNumber() == Magic_Number && OrderSymbol() == Symbol() )
               Step_Standart_TS(OrderTicket(), Trailing_Stop, Trailing_Step);
         }
      }
      if( Orders_Total_by_type( OP_SELL,  Magic_Number, Symbol()) > 0 )
      {
         // для SELL
         for( i = OrdersTotal() ; i >= 0 ; i--)
         {
            OrderSelect( i, SELECT_BY_POS, MODE_TRADES);
            if( OrderType() == OP_SELL && OrderMagicNumber() == Magic_Number && OrderSymbol() == Symbol() )
               Step_Standart_TS(OrderTicket(), Trailing_Stop, Trailing_Step);
         }
      }
   }
   
   if( IsTesting() || IsOptimization() )
   if(!isNewBar())return(0);
   
   
   double MA_f_1 = iMA( Symbol(),Period(), MA_Fast_Period, 0, MA_Fast_Method, MA_Fast_Price, 1);
   double MA_f_2 = iMA( Symbol(),Period(), MA_Fast_Period, 0, MA_Fast_Method, MA_Fast_Price, 2);
   double MA_s_1 = iMA( Symbol(),Period(), MA_Slow_Period, 0, MA_Slow_Method, MA_Slow_Price, 1);
   double MA_s_2 = iMA( Symbol(),Period(), MA_Slow_Period, 0, MA_Slow_Method, MA_Slow_Price, 2);
   
   double RSI_1 = iRSI( Symbol(), Period(), RSI_Period, RSI_Price, 1);
   
   if( MA_f_1 > MA_s_1 && MA_f_2 <= MA_s_2 )
   {
      CloseOrder_by_type( OP_SELL, Magic_Number, Symbol()) ;
      if( Orders_Total_by_type( OP_BUY, Magic_Number, Symbol()) == 0 )
      {
         if( RSI_1 > RSI_Level )
         {
            OrderSend( Symbol(), OP_BUY, lot, Ask, 3,0*Point,0*Point, NULL, Magic_Number, 0, Aqua);
         }
         else
         {
            i = 2;
            while(true)
            {
               if( iRSI( Symbol(), Period(), RSI_Period, RSI_Price, i) > RSI_Level )
               {
                  OrderSend( Symbol(), OP_BUY, lot, Ask, 3,0*Point,0*Point, NULL, Magic_Number, 0, Aqua);
                  break;
               }
               if( MA_f_1 < MA_s_1 && MA_f_2 >= MA_s_2 )break;
               i++;
            }
         
         }
      }
   }
   
   if( MA_f_1 < MA_s_1 && MA_f_2 >= MA_s_2 )
   {
      CloseOrder_by_type( OP_BUY, Magic_Number, Symbol()) ;
      if( Orders_Total_by_type( OP_SELL, Magic_Number, Symbol()) == 0 )
      {
         if( RSI_1 < RSI_Level )
         {
            OrderSend( Symbol(), OP_SELL, lot, Bid, 3,0*Point,0*Point, NULL, Magic_Number, 0, Magenta);
         }
         else
         {
            i = 2;
            while(true)
            {
               if( iRSI( Symbol(), Period(), RSI_Period, RSI_Price, i) < RSI_Level )
               {
                  OrderSend( Symbol(), OP_SELL, lot, Bid, 3,0*Point,0*Point, NULL, Magic_Number, 0, Magenta);
                  break;
               }
               if( MA_f_1 > MA_s_1 && MA_f_2 <= MA_s_2 )break;
               i++;
            }
         
         }
      }
   }
   
   return(0);
  }
//+------------------------------------------------------------------+

void Step_Standart_TS(int iTicket,double TrailingStop, double TrailingStep)
{
      if( OrderTicket() !=  iTicket)OrderSelect(iTicket, SELECT_BY_TICKET, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
      {
         if(OrderType()==OP_BUY)   // long position is opened
         {
            if(TrailingStop > 0)  
            {                 
               if( Bid - OrderOpenPrice() > Point*TrailingStop )
               {
                  if( OrderStopLoss() + Point*TrailingStep < Bid - Point*TrailingStop )
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                  }
               }
            }
         }
         else // go to short position
         {
            // check for trailing stop
            if(TrailingStop>0)  
            {                 
               if( ( OrderOpenPrice() - Ask > Point*TrailingStop ) ||  ( NormalizeDouble( OrderStopLoss(), Digits) == 0 ) )
               {
                  if( ( OrderStopLoss() - Point*TrailingStep > Ask + Point*TrailingStop ) || ( NormalizeDouble( OrderStopLoss(), Digits) == 0 ))
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                  }
               }
            }
         }
      }
}

bool isNewBar()
{
  static datetime BarTime;  
   bool res=false;
    
   if (BarTime!=Time[0]) 
      {
         BarTime=Time[0];  
         res=true;
      } 
   return(res);
}

//---- Возвращает количество ордеров указанного типа ордеров ----//
int Orders_Total_by_type(int type, int mn, string sym)
{
   int num_orders=0;
   for(int i= OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if( OrderMagicNumber() == mn && type == OrderType() && sym==OrderSymbol())
         num_orders++;
   }
   return(num_orders);
}

//---- Закрытие ордера по типу и комментарию ----//
void CloseOrder_by_type(int type, int mn, string sym)
{
   for(int i= OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber() == mn && type == OrderType() && sym==OrderSymbol())
         if(OrderType()<=1)OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
         else OrderDelete(OrderTicket());
   }
}