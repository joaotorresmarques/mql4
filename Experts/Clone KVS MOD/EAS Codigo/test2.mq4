//+------------------------------------------------------------------+
//|                                                        test2.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
datetime endFY;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int y = TimeYear(endFY) - 1;
   int m = TimeMonth(endFY);
   int d = TimeDay(endFY);
   int h = TimeHour(endFY);
   int n = TimeMinute(endFY);
   string s = StringConcatenate( y, ".", m, ".", d, " ", h, ":", n );
   datetime startFY = StrToTime(s);
   Print( "Calculating FY data from " + TimeToStr(startFY, TIME_DATE|TIME_MINUTES) + " to " + TimeToStr(endFY, TIME_DATE|TIME_MINUTES) );
   double opBal, clBal, sales, purch, cogs, comm, swap, tickVal, lotVal;
   int tot, i;
   bool flag = true;
   
   tot = OrdersHistoryTotal();
   // first we'll progress through the historical trades
   for ( i = tot; i >= 0; i-- ) {    
      if ( OrderSelect( i, SELECT_BY_POS, MODE_HISTORY ) ) {
         lotVal = OrderLots() * MarketInfo(OrderSymbol(), MODE_LOTSIZE);
         if ( OrderClosePrice() == OrderOpenPrice() ) {
            tickVal = MarketInfo(OrderSymbol(), MODE_TICKVALUE);
         } else if ( OrderType() == OP_BUY ) {                                    
            tickVal = OrderProfit() / (lotVal * (OrderClosePrice() - OrderOpenPrice()));
         } else if ( OrderType() == OP_SELL ) {
            tickVal = OrderProfit() / (lotVal * (OrderOpenPrice() - OrderClosePrice()));
         }
         if ( OrderOpenTime() > startFY && OrderOpenTime() <= endFY ) {
            if ( OrderType() == OP_BUY ) {
               purch += (OrderOpenPrice() * lotVal * tickVal);                  
            } else if ( OrderType() == OP_SELL ) {
               sales += (OrderOpenPrice() * lotVal * tickVal); 
            }
         }
         if ( OrderCloseTime() > startFY && OrderCloseTime() <= endFY ) {
            if ( OrderType() == OP_BUY ) {
               sales += (OrderClosePrice() * lotVal * tickVal);
            } else if ( OrderType() == OP_SELL ) {
               purch += (OrderClosePrice() * lotVal * tickVal); 
            }
         }
         // calculate the opening positions' value
         if ( OrderOpenTime() <= startFY && OrderCloseTime() > startFY ) {
            if ( OrderType() == OP_BUY ) {
               opBal += (OrderOpenPrice() * lotVal * tickVal);      
            } else if ( OrderType() == OP_SELL ) {
               opBal -= (OrderOpenPrice() * lotVal * tickVal);
            }   
         } 
         // calculate the closing positions' value
         if ( OrderOpenTime() <= endFY && OrderCloseTime() > endFY ) {
            if ( OrderType() == OP_BUY ) {
               clBal += (OrderOpenPrice() * lotVal * tickVal);
            } else if ( OrderType() == OP_SELL ) {
               clBal -= (OrderOpenPrice() * lotVal * tickVal);
            }
         } 
         comm += OrderCommission(); // should already be denominated in base currency
         swap += OrderSwap(); // should already be denominated in base currency
      }
       tot = OrdersTotal();
   for ( i = tot; i >= 0; i-- ) {
      if ( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) ) {
         lotVal = OrderLots() * MarketInfo(OrderSymbol(), MODE_LOTSIZE);
         tickVal = MarketInfo(OrderSymbol(), MODE_TICKVALUE);
         // check if trades opened prior to the start FY = o/bal
         if ( OrderOpenTime() <= startFY ) {
            if ( OrderType() == OP_BUY ) {
               opBal += OrderOpenPrice() * lotVal * tickVal;
            } else if ( OrderType() == OP_SELL ) {
               opBal -= OrderOpenPrice() * lotVal * tickVal;
            }
         }
         // check if trades open after the end of the FY = c/bal
         if ( OrderOpenTime() <= endFY ) {
            if ( OrderType() == OP_BUY ) {
               clBal += OrderOpenPrice() * lotVal * tickVal;
            } else if ( OrderType() == OP_SELL ) {
               clBal -= OrderOpenPrice() * lotVal * tickVal;
            }
         }
         if ( OrderOpenTime() > startFY && OrderOpenTime() <= endFY ) {
            if ( OrderType() == OP_BUY ) {
               purch += (OrderOpenPrice() * lotVal * tickVal);               
            } else if ( OrderType() == OP_SELL ) {
               sales += (OrderOpenPrice() * lotVal * tickVal);
            }
            comm += OrderCommission();
            swap += OrderSwap();
         }
      }
   } 
   cogs = opBal + purch - clBal;
   Print( "* Cost Of Goods Sold calcs -> (o/stock)$" + DoubleToStr(opBal, 2) + " + (purchases)$" + DoubleToStr(purch,2) + " - (c/stock)$" + DoubleToStr(clBal,2));
   Print( "NET PROFIT/LOSS = $" + DoubleToStr(sales - cogs + comm + swap, 2));
   Print( "less Expenses = (commissions)$" + DoubleToStr(comm, 2) + " + (swap charges/income)$" + DoubleToStr(swap, 2));
   Print( "Gross Profit/Loss = $" + DoubleToStr(sales - cogs, 2));
   Print( "less C.O.G.S.* = $" + DoubleToStr(cogs, 2));
   Print( "Total SALES = $" + DoubleToStr(sales, 2));
   
   }  
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
   
  }
//+------------------------------------------------------------------+
