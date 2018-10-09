
#property link "http://euronis-free.com"


extern double TakeProfit = 500;
extern double Lots = 1.0;
extern double StopLoss = 500;

int prevBar;

void start()
{
   CheckForOpen();
}
void CheckForOpen()
{
   double par0, par1;
   int res, cnt=0, ticket, total;
   total=OrdersTotal();
   par0=iSAR(NULL,0,0.02,0.2,0);
   par1=iSAR(NULL,0,0.02,0.2,1);
   double SAR0 = iSAR(NULL, 0, 0.02, 0.2, 0);

   for (int i=0; i < Bars; i++) 
   {
      double SAR = iSAR(NULL, 0, 0.02, 0.2, i);
      int cnt1 = 0;
      if (SAR0 > Close[0]) 
      {
         if (SAR < Close[i]) break;
      }
      if (SAR0 < Close[0]) 
      {
         if (SAR > Close[i]) break;
      }
      cnt1++;
   }

   if (!ExistPosition() && prevBar!=Bars)
   {
    //==========BUY============
    if (par1>Close[1] && par0<Bid)
    { 
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,4,Bid-StopLoss*Point,Bid+TakeProfit*Point,"",16380,0,Green);
      prevBar=Bars;
    }
    //===========SELL=========
    if (par1<Close[1] && par0>Ask)
    { 
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,4,Ask+StopLoss*Point,Ask-TakeProfit*Point,"",16380,0,Red);
      prevBar=Bars;
    } 
    else
    {
      if (cnt1<10 && par1<Close[1] && par0>Ask)
      {
         for(cnt=0;cnt<total;cnt++)
         {
            OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
            if(OrderType()<=OP_SELL &&OrderSymbol()==Symbol())
            {
               if(OrderType()==OP_BUY) 
               {
                  OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet) ; // закрываем позицию
                  OrderSend(Symbol(),OP_SELL,Lots,Bid,4,Ask+StopLoss *Point,Ask-TakeProfit*Point,"",16380,0,Red);
                  prevBar=Bars;
               }
            } 
         } 
      }
    }
   }
    
return(0);
}

//+------------------------------------------------------------------+
//| ¬озвращает флаг существовани€ ордера или позиции |
//+------------------------------------------------------------------+
bool ExistPosition() {
bool Exist=False;
for (int i=0; i<OrdersTotal(); i++) {
if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
if (OrderSymbol()==Symbol() /*&& OrderMagicNumber()==MAGIC*/) Exist=True;
}
}
return(Exist);
}