//+------------------------+
//|       XRSI47           |
//+------------------------+
//
#property link "http://euronis-free.com"


// generic user input
extern double Lots=0.1;
extern int    Slippage=2;
extern int    RSISlow=4;
extern int    RSIFast=7;
extern int    RSIType=6;




//+------------------------------------+
//| EA load code                       |
//+------------------------------------+

int init()
  {
   Print("Init happened");
  }


//+------------------------------------+
//| EA unload code                     |
//+------------------------------------+

int deinit()
  {
   Print("DE-Init happened");
   Comment(" ");
  }



//+------------------------------------+
//| EA main code                       |
//+------------------------------------+

int start()
  {
   double p=Point;
   int      cnt=0;

   int      OrdersPerSymbol=0;

   double  pRSI4=0,  RSI4=0;
   double  pRSI7=0,  RSI7=0;
   bool    Rising=false, Falling=false;
   
   string TradeComment = "RSI";

   // Error checking & bar counting
   if(AccountFreeMargin()<(1000*Lots))        {Print("-----NO MONEY"); return(0);}
   if(Bars<100)                               {Print("-----NO BARS "); return(0);}

   // 2-period moving average on Bar[2]
    RSI4=iRSI(Symbol(),0,RSIFast,RSIType,0);
   pRSI4=iRSI(Symbol(),0,RSIFast,RSIType,1);
    RSI7=iRSI(Symbol(),0,RSISlow,RSIType,0);
   pRSI7=iRSI(Symbol(),0,RSISlow,RSIType,1);

   // Determine if there was a cross
   if(pRSI4<pRSI7 && RSI4>RSI7) {Rising=true;  Falling=false;}
   if(pRSI4>pRSI7 && RSI4<RSI7) {Rising=false; Falling=true;}
   
   // count the open orders for this symbol 
   OrdersPerSymbol=0;
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() == Symbol())
        {
         OrdersPerSymbol++;
        }
     }
     
   // Initial order placement
   if(OrdersPerSymbol==0)
     {
      //ENTRY Ask(buy, long) 
      if(Rising)
		  {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,Ask-(50*p),Ask+(50*p),TradeComment,10101,White);
         Print("Initial BUY");
        }
        
      //ENTRY Bid (sell, short)
      if(Falling)
        {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,Bid+(50*p),Bid-(50*p),TradeComment,10101,Red);
         Print("Initial SELL");
        }
     } //if


   // Existing order, determine if direction changed
   for(cnt=OrdersTotal();cnt>=0;cnt--)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol()==Symbol())
        {

         // RSI crossed down, so swap BUY for SELL
         if (OrderType() == OP_BUY && Falling)
           {
            OrderClose(OrderTicket(),Lots,Bid,Slippage,White);
            OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,Bid+(50*p),Bid-(50*p),TradeComment,10101,Red);
           } // if BUY


         // RSI crossed up, so swap SELL for BUY
         if (OrderType() == OP_SELL && Rising)
           {
            OrderClose(OrderTicket(),Lots,Ask,Slippage,Red);
            OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,Ask-(50*p),Ask+(50*p),TradeComment,10101,White);
           } //if SELL

        }//if OrderSymbol...
     }//for


   return(0);
  } // start()




