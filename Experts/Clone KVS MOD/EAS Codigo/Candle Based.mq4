//+------------------------------------------------------------------+
//|                                                 Candle Based.mq4 |
//|                                                Piotr Kuchniewski |
//|                                           pkuchniewski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Piotr Kuchniewski"
#property link      "pkuchniewski@gmail.com"

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
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


extern double TrailingSL = 200;
extern bool BE = true;
extern bool DynamicLot = true;

static datetime new_time = 0;           // a part of the code which checks if there is a new bar 

extern double LOT = 0.01;
extern int SL = 200;
extern int TP = 2000;

   // Computer uses these particular numbers to identify orders:
int BUY = 0; // 0 for OP_BUY
int SELL = 1;   // 1 for OP_SELL 
//______________________________________________________________________________________________________________
// Account Balance
double accountBalance()
{
   if (DynamicLot)
   {
      double acc = AccountBalance(); 
 
      if (acc>10)
      {
        LOT = 0.01*(acc/10);
        return(LOT);
      }
        else
      {
        LOT = 0.01;
      }
   }
}
//+------------------------------------------------------------------------------------------------------------------------------------+ 3)
// TrailingStopLoss - moves SL of open orders------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------+
bool TrailingStopLoss()
{
   double TS = TrailingSL/100000;
   
   for(int g = 0; g <= OrdersTotal(); g++)
   {
      if (OrderSelect(g,SELECT_BY_POS,MODE_TRADES))
      {
         if (OrderType() == BUY)
         {
            double diffbuy = Bid - OrderStopLoss();

            if (diffbuy > TS)
            {
               if (BE == true)
               if (OrderStopLoss() > OrderOpenPrice()+0.001)
                  continue;
               OrderModify(OrderTicket(),OrderOpenPrice(), Bid - TS, OrderTakeProfit(),0);
            }
         }
         if (OrderType() == SELL)
         { 
            double diffsell = OrderStopLoss() - Ask;
            //Alert ("DIFFSELL:",diffsell);
            if (diffsell > TS)
            {  
               if (BE == true)
               if (OrderStopLoss() < OrderOpenPrice()-0.001)
                  continue;
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TS,OrderTakeProfit(),0);
            }
         }
      }
   }
}
//+------------------------------------------------------------------------------------------------------------------------------------+ 3)
// FloatingProfit - Returns floating profit expressed as a percentage and prints a label in a window-----------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------+
double FloatingProfit() // Function's name.
{
   double percentReturned; // Value to be returned by the function.
   double accountBalance = AccountBalance(); // Account balance.
   double accountEquity = AccountEquity(); // Account equity.
   
   double diff = accountBalance - accountEquity; // A difference between account balance and account equity.
   
   double percent = MathAbs((diff/accountBalance)*100); // Absolute value of how much percent does the difference constitute of the 
                                                        // account balance.                                                       
   string Percent; // String to be printed.
   
   color col; // Color of the string to be used.
   
   if (accountEquity < accountBalance) // If the account equity is smaller than account balance,(floating profit shows loss):
   {  
      Percent = StringConcatenate("-",percent); // Print minus and a value of loss expressed as a percentage.
      col = Red; // Use red color to print a string.
      percentReturned = percent*(-1); // Value to be returned by the function.
   }   
      
   if (accountEquity >= accountBalance) // If the account equity is bigger or equal to account balance(floating profit shows profit):
   {
      Percent = StringConcatenate("+",percent); // Print plus and a value of profit expressed as a percentage.
      col = LimeGreen; // Use lime green color to print a string.
      percentReturned = percent;
   }   
    
   ObjectCreate("Percent", OBJ_LABEL, 0, 0, 0); // Create a lable named: "Percent".
      ObjectSetText("Percent",Percent,30,"Arial Black",col); // String to be printed, size of a font, name of a font and its color.
      ObjectSet("Percent", OBJPROP_CORNER, 0); // Corner of a window (upper left) following parameters should refer to.
      ObjectSet("Percent", OBJPROP_XDISTANCE, 30); // Horizonatal distance from the corner expressed in pixels.
      ObjectSet("Percent", OBJPROP_YDISTANCE, 40); // Vertical distance from the corner expressed in pixels.  

   return(percentReturned);
}
//___________________________________________________________________________________________________________________
// returns true, if there's a new bar, otherwise false
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
int start()
  {
//----

bool success = false;
FloatingProfit();
TrailingStopLoss();
accountBalance();

   if (OrdersTotal() == 0)
   {
      if (Ask > High[1])
      {
         if(isNewBar(new_time))
         OrderSend (Symbol(),OP_BUY, LOT, Ask,2,Ask-SL*Point,Ask+TP*Point);
      }
      if (Bid < Low[1])
      {
         if(isNewBar(new_time))
         OrderSend (Symbol(),OP_SELL, LOT, Bid,2,Bid+SL*Point,Bid-TP*Point);
      }
   }
   if (OrdersTotal() == 1)
   {   
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES))     
      { 
         if (OrderType() == BUY)
         {
            if (Bid < Low[1])
            {

               {
                  if(OrderClose(OrderTicket(),OrderLots(),Bid,5))
                  {
                //     success = true;
                  }
               }
            }
         }
         if (OrderType() == SELL)
         {
            if (Ask > High[1])
            {
               {
                  if(OrderClose(OrderTicket(),OrderLots(),Ask,5))
                  {
                  //   success = true;
                  }
               }            
            }
         }
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+