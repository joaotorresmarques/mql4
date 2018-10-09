//+------------------------------------------------------------------+
//|                                                Swiss Army EA.mq4 |
//|                   "It does everything but place its own orders!" |
//+------------------------------------------------------------------+
//|                                    Copyright © 2007, Ryan Klefas |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Ryan Klefas (Base 1.8)"
#property link      "rklefas@inbox.com"



extern string    id="==== Identity Settings ====================";
extern bool      ManageBy_Symbol=true;          // If true, EA will only manage order that have matching
                                                //     symbols
extern bool      ManageBy_Magic=false;          // If true, EA will only manage order that have matching
                                                //     magic numbers
                                                // If both are false, EA will manage ALL orders regardless 
                                                //     of magic numbers or symbols
extern int       MagicNumber=999999;            // Magic number EA will try to manage


extern string    manage="==== Stop Management ====================";
extern int       BreakEvenAt=0;                 // Set Stoploss to open order price at X pips profit
extern int       BreakEvenSlide=0;              // Move the breakeven point up or down around
                                                //     the order open price
extern int       TrailingStop=0;                // Stoploss follows behind current price by X pips
extern bool      OnlyTrailAfterProfit=false;    // Trailing Stop will only trail when order is profitable



extern string    close="==== Close-out Conditions ====================";
// Each of the following is a separate close out condition, which may be 
// executed.  If specific inputs are needed for the close out to occur, 
// they will appear directly below the true/false option

extern bool      ImmediateCloseOut=false;       // Actions immediately occur

extern bool      COND_Time=true;                // Actions occur at the specified time
extern int       CloseHour=23;                  // Hour to activate
extern int       CloseMinute=55;                // Minute to activate

extern bool      COND_MaxProfit_Dollar=false;    // Actions occur when total profits surpass specified level
extern int       MaxProfit_Dollar=100;           // Profit in dollars to activate

extern bool      COND_MaxProfit_Pips=false;      // Actions occur  when total profits surpass specified level
extern int       MaxProfit_Pip=50;               // Profit in pips to activate

extern bool      COND_MaxProfit_Percentage=false;  // Actions occur if max percentage profit is reached
extern int       MaxProfit_Percentage=25;        // Maximum percentage profit allowed

extern bool      COND_MaxLoss_Dollar=false;      // Actions occur  when total losses surpass specified level
extern int       MaxLoss_Dollar=100;             // Losses in dollars to activate

extern bool      COND_MaxLoss_Pips=false;        // Actions occur  when total losses surpass specified level
extern int       MaxLoss_Pip=50;                 // Losses in pips to activate

extern bool      COND_MaxLoss_Percentage=false;  // Actions occur if max percentage loss is reached
extern int       MaxLoss_Percentage=25;          // Maximum percentage loss allowed



extern string    action="==== Close-out Actions ====================";
extern bool      CloseBuys=false;               // All active buy orders will close
extern bool      CloseSells=false;              // All active sell orders will close
extern bool      DeletePendings=false;          // All pending orders will close
extern bool      CloseEverything=true;          // All orders will close


extern string    extra="==== Extra Settings ====================";
extern string    ExpertName="Swiss Army EA";    // Expert name: for aesthetic purposes
extern bool      Disable_Comments=false;        // EA will not display comments on screen
extern int       Slippage=3;                    // Slippage on closing orders





























       bool      CumulativeTrailingStop=false;
       bool      HedgeActiveOrders=false;       // All active orders will be hedged

//+------------------------------------------------------------------+
//| global variables                                              |
//+------------------------------------------------------------------+

       // Individual order types

   int longActive=0,  shortActive=0;
   int longStop=0,    shortStop=0;
   int longLimit=0,   shortLimit=0;
   
       // Accumulative order types
   
   int longPending=0, shortPending=0;
   int allLong=0,     allShort=0;
   int allActive=0,   allPending=0;
   int grandTotal=0;   
   
   
   double actualProfitMonitor=0;
   double actualProfitMonitor_pip=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   onScreenComment(91);
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
   onScreenComment(99);
   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   
   
   findMyOrders();

   if (allActive>0)
   {
      if (BreakEvenAt>0)
         breakEvenManager();
      if (TrailingStop>0)
         trailingStopManager();
   }
   

   onScreenComment(98);
   

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

   if (ImmediateCloseOut)
      actionFunction();


   
   if (COND_Time)
      if (Hour()==CloseHour && Minute()==CloseMinute)
         actionFunction();

   if (COND_MaxProfit_Dollar)
      if (actualProfitMonitor>MaxProfit_Dollar)
         actionFunction();
   
   if (COND_MaxLoss_Dollar)
      if ( actualProfitMonitor < (MaxLoss_Dollar * (-1)) )
         actionFunction();
   
   if (COND_MaxProfit_Pips)
      if (actualProfitMonitor_pip > MaxProfit_Pip)
         actionFunction();
   
   if (COND_MaxLoss_Pips)
      if ( actualProfitMonitor_pip < (MaxLoss_Pip * (-1)) )
         actionFunction();

   if (COND_MaxLoss_Percentage)
      if (balanceDeviation(2)>MaxLoss_Percentage)
         actionFunction();

   if (COND_MaxProfit_Percentage)
      if (balanceDeviation(1)>MaxProfit_Percentage)
         actionFunction();


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

      
   return(0);  // End of start function
}
  
//+------------------------------------------------------------------+
//| middle-man modules                                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

void closeLongOrder() // Base Version 1.8
{ versatileOrderCloser(1); }

//+------------------------------------------------------------------+

void closeShortOrder() // Base Version 1.8
{ versatileOrderCloser(2); }

//+------------------------------------------------------------------+

void deletePending() // Base Version 1.8
{ versatileOrderCloser(3); }

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| standardized modules and functions                               |
//+------------------------------------------------------------------+

void onScreenComment(int event) 
{

   if (Disable_Comments==false)
   {
      
      string draw = DoubleToStr(balanceDeviation(2), 2);
      string drup = DoubleToStr(balanceDeviation(1), 2);
      string prof = DoubleToStr(dollarCount(1), 2);
      string loss = DoubleToStr(dollarCount(2), 2);

      string header = ExpertName + " run-time statistics: \n\n";
      string manager, stopper, timer, breaker, trailer;
      string line = "\n";
                      
                      
      if (Minute()<10)
         timer = Hour() + ":0" + Minute();
      else
         timer = Hour() + ":" + Minute();
                      
           
      string ordercount = "\n" + "\n" +
             "Buy Active:  " + longActive + "\n" +
             "Sell Active:  " + shortActive + "\n" +
             "Buy Stop:  " + longStop +  "\n" +
             "Sell Stop:  " + shortStop + "\n" +
             "Buy Limit:  " + longLimit + "\n" +
             "Sell Limit:  " + shortLimit + "\n" +
             "Grand Total:  " + grandTotal
             ;
                 
      string stats = 
             "Current Time:  "                 + timer + "\n" +
             "Account Leverage:  "             + AccountLeverage() + ":1\n" + 
             line +
             "Total Profit (Dollars):  "       + prof + "\n" +
             "Total Profit (Pips):  "          + pipCount(1) + "\n" +
             "Percentage Profit:  "            + drup + "%\n" +
             line +
             "Total Loss (Dollars):  "         + loss + "\n" +
             "Total Loss (Pips):  "            + pipCount(2) + "\n" +
             "Percentage Loss (Drawdown):  "   + draw + "%\n"
             ;
      
      
      if (!TrailingStop>0)
         trailer = "Trailing Stop management disabled\n";
      else if (TrailingStop>0)
         trailer = "Trailing Stop management enabled\n";


      if (!BreakEvenAt>0)
         breaker = "Breakeven management disabled\n";
      else if (BreakEvenAt>0)
         breaker = "Breakeven management enabled\n";


      if (ManageBy_Magic==false && ManageBy_Symbol==false)
         manager = "Managing ALL orders in this terminal\n";
      else if (ManageBy_Magic && ManageBy_Symbol)
         manager = "Managing only orders that have magic number " + MagicNumber + " and of symbol " + Symbol() + "\n";     
      else if (ManageBy_Magic)
         manager = "Managing only orders that have magic number " + MagicNumber + "\n";     
      else if (ManageBy_Symbol)
         manager = "Managing only orders of symbol " + Symbol() + "\n";     



      switch (event)
      {

         case 91: Comment(ExpertName + " is waiting for the next tick to begin."); break;
         case 98: Comment(header + manager + trailer + breaker + stats + ordercount); break;
         case 99: Comment(" "); break;

      }
   }

}

//+------------------------------------------------------------------+

int simpleMagicGenerator() 
{

   return (MagicNumber);
}

//+------------------------------------------------------------------+

bool orderBelongsToMe()
{
   
   bool magicPermission=false;
   bool symbolPermission=false;
   
   
   if (ManageBy_Magic)
   {
      if (OrderMagicNumber() == simpleMagicGenerator())
         magicPermission=true;
   }
   else
      magicPermission=true;
      
      
   if (ManageBy_Symbol)
   {
      if (OrderSymbol() == Symbol())
         symbolPermission=true;
   }
   else
      symbolPermission=true;


   if ( symbolPermission && magicPermission )
      return (true);
   else
      return (false);
}

//+------------------------------------------------------------------+

void findMyOrders() 
{


   
   actualProfitMonitor=0; 
   actualProfitMonitor_pip=0;


   longActive=0;  shortActive=0;
   longStop=0;    shortStop=0;
   longLimit=0;   shortLimit=0;
   longPending=0; shortPending=0;
   allLong=0;     allShort=0;
   allActive=0;   allPending=0;
   grandTotal=0;   
   

   for(int cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if ( orderBelongsToMe() )
      {  
         if (OrderType()==OP_BUY)
            {longActive++; 
            actualProfitMonitor += OrderProfit();
            actualProfitMonitor_pip += ( (MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice()) / (MarketInfo(OrderSymbol(),MODE_POINT)) );
            }
         else if (OrderType()==OP_SELL)
            {
            shortActive++; 
            actualProfitMonitor += OrderProfit();
            actualProfitMonitor_pip += ( (OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK)) / (MarketInfo(OrderSymbol(),MODE_POINT)) );
            }
         else if (OrderType()==OP_BUYSTOP)
            longStop++;
         else if (OrderType()==OP_SELLSTOP)
            shortStop++;
         else if (OrderType()==OP_BUYLIMIT)
            longLimit++;
         else if (OrderType()==OP_SELLLIMIT)
            shortLimit++;
      }
   }



   longPending  = longStop + longLimit;
   shortPending = shortStop + shortLimit;
   allPending   = longPending + shortPending;
   allActive    = longActive + shortActive;
   allLong      = longStop + longLimit + longActive;
   allShort     = shortStop + shortLimit + shortActive;
   grandTotal   = allActive + allPending;
   
}

//+------------------------------------------------------------------+

void breakEvenManager() 
{

   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if (BreakEvenAt>0 && orderBelongsToMe())
      {
         if (OrderType()==OP_BUY)
         {
            if (MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice()>=MarketInfo(OrderSymbol(),MODE_POINT)*BreakEvenAt)
            {
               if (OrderStopLoss()<OrderOpenPrice() + BreakEvenSlide*MarketInfo(OrderSymbol(),MODE_POINT))
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() + BreakEvenSlide*MarketInfo(OrderSymbol(),MODE_POINT),OrderTakeProfit(),0,Green); 
            }
         }
         else if (OrderType()==OP_SELL)
         {
            if (OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK)>=MarketInfo(OrderSymbol(),MODE_POINT)*BreakEvenAt)
            {
               if (OrderStopLoss()>OrderOpenPrice() - BreakEvenSlide*MarketInfo(OrderSymbol(),MODE_POINT) || (OrderStopLoss()==0))
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() - BreakEvenSlide*MarketInfo(OrderSymbol(),MODE_POINT),OrderTakeProfit(),0,Red); 
            }
         }
      }
   }


}
   
//+------------------------------------------------------------------+

void trailingStopManager() 
{
   
   int cnt, total = OrdersTotal();

   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if (TrailingStop>0 && orderBelongsToMe())
      {
         if (OrderType()==OP_BUY)
         {
            if ((MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice()>MarketInfo(OrderSymbol(),MODE_POINT)*TrailingStop) || OnlyTrailAfterProfit==false)
            {
               if (OrderStopLoss()<MarketInfo(OrderSymbol(),MODE_BID)-MarketInfo(OrderSymbol(),MODE_POINT)*TrailingStop)
                  OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(OrderSymbol(),MODE_BID)-MarketInfo(OrderSymbol(),MODE_POINT)*TrailingStop,OrderTakeProfit(),0,Green); 
            }
         }
         else if (OrderType()==OP_SELL)
         {
            if ((OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK)>MarketInfo(OrderSymbol(),MODE_POINT)*TrailingStop) || OnlyTrailAfterProfit==false)
            {
               if ((OrderStopLoss()>(MarketInfo(OrderSymbol(),MODE_ASK)+MarketInfo(OrderSymbol(),MODE_POINT)*TrailingStop)) || (OrderStopLoss()==0))
                  OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(OrderSymbol(),MODE_ASK)+MarketInfo(OrderSymbol(),MODE_POINT)*TrailingStop,OrderTakeProfit(),0,Red); 
            }
         }
      }  
   }

}

//+------------------------------------------------------------------+

void versatileOrderCloser(int simpleType) 
{
   int cnt, total = OrdersTotal();

   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      
      if ( orderBelongsToMe() )
      {
         switch (simpleType)
         {
            case 4:
            case 3:
               if (OrderType()>OP_SELL)   OrderDelete(OrderTicket());
            break;
         
            case 2:
               if (OrderType()==OP_SELL)  OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),Slippage,CLR_NONE); 
            break;
         
            case 1:
               if (OrderType()==OP_BUY)   OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),Slippage,CLR_NONE); 
            break;
         
            default:
            Print ("versatileOrderCloser has been passed an invalid SimpleType parameter: " + simpleType);
         }
      }
   }
}


//+------------------------------------------------------------------+
//| customized modules and functions                                 |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+

void actionFunction()
{

   if (longActive>0)
      if (CloseBuys || CloseEverything)
         { Print(ExpertName + " is attempting to close all buy orders."); closeLongOrder();  }


   if (shortActive>0)
      if (CloseSells || CloseEverything)
        {Print(ExpertName + " is attempting to close all sell orders.");  closeShortOrder();  }
      
      
   if (allPending>0)
      if (DeletePendings || CloseEverything)
        { Print(ExpertName + " is attempting to close all pending orders."); deletePending();  }


}

//+------------------------------------------------------------------+

double balanceDeviation(int mode)
{
   double val;
   
   if (mode==2)
   {
      val = ( ((AccountEquity()/AccountBalance()) -1) * (-100) );
      if (val>0)
         return (val);
      else
         return (0);
   }
         
   if (mode==1)
   {
      val = ( ((AccountEquity()/AccountBalance()) -1) * (100) );
      if (val>0)
         return (val);
      else
         return (0);
   }
}

//+------------------------------------------------------------------+

int pipCount(int mode)
{
   int temp = actualProfitMonitor_pip;
   
   
   if (mode==1)
   {
      if (temp>0)
         return (temp);
      else
         return (0);

   }
         
   if (mode==2)
   {
      if (temp<0)
         return (MathAbs(temp));
      else
         return (0);
   }



}
//+------------------------------------------------------------------+

double dollarCount(int mode)
{
   
   if (mode==1)
   {
      if (actualProfitMonitor>0)
         return (actualProfitMonitor);
      else
         return (0);

   }
         
   if (mode==2)
   {
      if (actualProfitMonitor<0)
         return (MathAbs(actualProfitMonitor));
      else
         return (0);
   }



}
//+------------------------------------------------------------------+


