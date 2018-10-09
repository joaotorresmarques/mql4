//+------------------------------------------------------------------+
//|                                             простой советник.mq4 |
//|                               Copyright © 2011, Хлыстов Владимир |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, http://cmillion.narod.ru"
#property link      "cmillion@narod.ru"
//--------------------------------------------------------------------
extern string  MA1="";     
extern int     period_1             = 7,           //Период усреднения для вычисления первой MA.
               ma_shift_1           = 0,           //Сдвиг индикатора относительно ценового графика.
               ma_method_1          = MODE_EMA,    //Метод усреднения. Может быть любым из значений методов скользящего среднего (Moving Average).
                                                   //MODE_SMA 0 Простое скользящее среднее 
                                                   //MODE_EMA 1 Экспоненциальное скользящее среднее 
                                                   //MODE_SMMA 2 Сглаженное скользящее среднее 
                                                   //MODE_LWMA 3 Линейно-взвешенное скользящее среднее 

               applied_price_1      = PRICE_OPEN,  //Используемая цена. Может быть любой из ценовых констант.
                                                   //PRICE_CLOSE 0 Цена закрытия 
                                                   //PRICE_OPEN 1 Цена открытия 
                                                   //PRICE_HIGH 2 Максимальная цена 
                                                   //PRICE_LOW 3 Минимальная цена 
                                                   //PRICE_MEDIAN 4 Средняя цена, (high+low)/2 
                                                   //PRICE_TYPICAL 5 Типичная цена, (high+low+close)/3 
                                                   //PRICE_WEIGHTED 6 Взвешенная цена закрытия, (high+low+close+close)/4 

               timeframe_1          = 0;           //Период. Может быть одним из периодов графика. 0 означает период текущего графика.
extern string  MA2="";     
extern int     period_2             = 14,          //Период усреднения для вычисления второй MA.
               ma_shift_2           = 0,           //Сдвиг индикатора относительно ценового графика.
               ma_method_2          = MODE_LWMA,   //Метод усреднения. Может быть любым из значений методов скользящего среднего (Moving Average).
               applied_price_2      = PRICE_OPEN,  //Используемая цена. Может быть любой из ценовых констант.
               timeframe_2          = 0;           //Период. Может быть одним из периодов графика. 0 означает период текущего графика.
extern string  общие.параметры="";     
extern int     Stoploss             = 0,           //стоплосс
               Takeprofit           = 0,           //тейкпрофит
               TrailingStop         = 0,           //трейлингстоп, если 0, то нет трейлинга
               NoLoss               = 0,           //перевод в безубыток, если 0, то нет перевода в безубыток
               MaxOrders            = 1;           //максимальное кол-во ордеров одновременно на счете
extern double  Lot                  = 0.1,         //если Lot=0, то лот расчитывается от свободных средств
               risk                 = 10;          //процент свободных средств для расчета плавающего ордера
extern bool    CloseRevers          = true;        //закрывать ордера при встречном сигнале
extern int     Magic                = 1234567890;
//--------------------------------------------------------------------
int TimeBar,STOPLEVEL;
//--------------------------------------------------------------------
int start()
{
   int Ticket,STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL),b,s,tip;
   double OSL,OTP,OOP,StLo,SL,TP;
   for (int i=0; i<OrdersTotal(); i++)
   {    
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      { 
         if (OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
         { 
            tip = OrderType(); 
            if (tip<2)
            {
               OSL   = NormalizeDouble(OrderStopLoss(),Digits);
               OTP   = NormalizeDouble(OrderTakeProfit(),Digits);
               OOP   = NormalizeDouble(OrderOpenPrice(),Digits);
               Ticket = OrderTicket();
               SL=0;TP=0;
               if (tip==OP_BUY)             
               {
                  b++;
                  if (OSL==0 && Stoploss>=STOPLEVEL && Stoploss!=0)
                  {
                     SL = NormalizeDouble(Bid - Stoploss   * Point,Digits);
                  } 
                  else SL=OSL;
                  if (OTP==0 && Takeprofit>=STOPLEVEL && Takeprofit!=0)
                  {
                     TP = NormalizeDouble(Ask + Takeprofit * Point,Digits);
                  } 
                  else TP=OTP;
                  if (NoLoss>=STOPLEVEL && OSL<OOP && NoLoss!=0)
                  {
                     if (OOP <= NormalizeDouble(Bid-NoLoss*Point,Digits)) SL = OOP;
                  }
                  if (TrailingStop>=STOPLEVEL && TrailingStop!=0)
                  {
                     StLo = NormalizeDouble(Bid-TrailingStop*Point,Digits);
                     if (StLo >= OOP && StLo <= NormalizeDouble(Bid-STOPLEVEL*Point,Digits) && StLo > OSL) SL = StLo;
                  }
                  if (SL > OSL || TP != OTP)
                  {  
                     if (!OrderModify(Ticket,OOP,SL,TP,0,White)) Print("Error order ",Ticket);
                  }
               }                                         
               if (tip==OP_SELL)        
               {
                  s++;
                  if (OSL==0 && Stoploss>=STOPLEVEL && Stoploss!=0)
                  {
                     SL = NormalizeDouble(Ask + Stoploss   * Point,Digits);
                  }
                  else SL=OSL;
                  if (OTP==0 && Takeprofit>=STOPLEVEL && Takeprofit!=0)
                  {
                     TP = NormalizeDouble(Bid - Takeprofit * Point,Digits);
                  }
                  else TP=OTP;
                  if (NoLoss>=STOPLEVEL && (OSL>OOP || OSL==0) && NoLoss!=0)
                  {
                     if (OOP >= NormalizeDouble(Ask+NoLoss*Point,Digits)) SL = OOP;
                  }
                  if (TrailingStop>=STOPLEVEL && TrailingStop!=0)
                  {
                     StLo = NormalizeDouble(Ask+TrailingStop*Point,Digits);
                     if (StLo <= OOP && StLo >= NormalizeDouble(Ask+STOPLEVEL*Point,Digits) && (StLo < OSL || OSL==0)) SL = StLo;
                  }
                  if ((SL < OSL || OSL==0) || TP != OTP)
                  {  
                     if (!OrderModify(Ticket,OOP,SL,TP,0,White)) Print("Error order ",Ticket);
                  }
               } 
            }
         }
      }
   } 
   if (TimeBar==Time[0]) return(0);

   double MA10 = NormalizeDouble(iMA(NULL,timeframe_1,period_1,ma_shift_1,ma_method_1,applied_price_1,0),Digits);
   double MA11 = NormalizeDouble(iMA(NULL,timeframe_1,period_1,ma_shift_1,ma_method_1,applied_price_1,1),Digits);
   double MA20 = NormalizeDouble(iMA(NULL,timeframe_2,period_2,ma_shift_2,ma_method_2,applied_price_2,0),Digits);
   double MA21 = NormalizeDouble(iMA(NULL,timeframe_2,period_2,ma_shift_2,ma_method_2,applied_price_2,1),Digits);

   if (MA10>=MA20&&MA11<MA21)
   {
      if (CloseRevers) CLOSEORDER(OP_SELL);
      if (MaxOrders>b)       
      {
         if (OrderSend(Symbol(),OP_BUY, LOT(),NormalizeDouble(Ask,Digits),2,0,0,"простой советник",Magic,3)!=-1) TimeBar=Time[0]; 
         else Print("OrderSend BUY Error ",GetLastError(),"  SL ",SL,"  TP ",TP);
      }
   }
   if (MA10<=MA20&&MA11>MA21)
   {
      if (CloseRevers) CLOSEORDER(OP_BUY);
      if (MaxOrders>s) 
      {
         if (OrderSend(Symbol(),OP_SELL,LOT(),NormalizeDouble(Bid,Digits),2,0,0,"простой советник",Magic,3)!=-1) TimeBar=Time[0]; 
         else Print("OrderSend SELL Error ",GetLastError(),"  SL ",SL,"  TP ",TP);
      }
   }
return(0);
}
//--------------------------------------------------------------------
void CLOSEORDER(int ord)
{
   for (int i=0; i<OrdersTotal(); i++)
   {                                               
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if (OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
         {
            if (OrderType()==OP_BUY && ord==OP_BUY)
               OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,CLR_NONE);
            if (OrderType()==OP_SELL && ord==OP_SELL)
               OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,CLR_NONE);
         }
      }   
   }
}
//--------------------------------------------------------------------
double LOT()
{
   if (Lot!=0) return(Lot);
   double MINLOT = MarketInfo(Symbol(),MODE_MINLOT);
   double LOT = AccountFreeMargin()*risk/100/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   if (LOT>MarketInfo(Symbol(),MODE_MAXLOT)) LOT = MarketInfo(Symbol(),MODE_MAXLOT);
   if (LOT<MINLOT) LOT = MINLOT;
   if (MINLOT<0.1) LOT = NormalizeDouble(LOT,2); else LOT = NormalizeDouble(LOT,1);
   return(LOT);
}
//--------------------------------------------------------------------

