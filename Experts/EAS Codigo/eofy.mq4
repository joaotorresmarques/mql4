//+------------------------------------------------------------------+
//|                                                         EoFY.mq4 |
//|                                 Ryan Sheehy, CurrencySecrets.com |
//|                                   http://www.currencysecrets.com |
 /*
  * DON'T FORGET TO SELECT "ALL HISTORY" FROM ACCOUNT HISTORY TAB!!!
  * This script helps to calculate a summarised version of all trades
  * done in a particular financial year. It converts all sales and 
  * purchase transactions into the base currency.
  * 1. Loop through all HISTORICAL trades between a predetermined date
  *    range.
  * 2. Calculate PURCHASE & SALE amounts for each trade
  *    - for the sake of consistency, BUY orders will be considered PURCHASES
  *      and SELL orders will be considered SALES (regardless of which was
  *      performed first)
  *    - PURCHASE and SALE amounts will be converted into their BASE 
  *      currency 
  * 3. Calculate charges: COMMISSIONS & SWAPS
  *    - generally these will already be converted into their BASE currency
  *      and therefore no conversion will be necessary
  *    - it will be assumed that COMMISSIONS are negative amounts
  *    - SWAPS will be listed in the Expenses area (even though they may
  *      have a positive value and therefore be income)
  * 4. Calculate open and closing positions (stock)
  *    - positions that are open prior to the beginning of the year form
  *      the O/STOCK
  *    - positions that are open at the end of the year form the C/STOCK
  *    - the values of these are in the BASE currency
  * 5. Output calculations.
  *    - at the moment it's just to Print
  */
//+------------------------------------------------------------------+
#property copyright "Ryan Sheehy, CurrencySecrets.com"
#property link      "http://www.currencysecrets.com"

extern string eofyStr = "2012.06.30 23:59"; // the last day and minute of the financial year


//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
      datetime eofy = StrToTime(eofyStr);
      getHistoricalTrades(eofy);
//----
   return(0);
  }
//+------------------------------------------------------------------+

void getHistoricalTrades(datetime endFY) {
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
   }  
   
   // now we need to check for open positions that may have been entered during the FY
   
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