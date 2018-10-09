//+------------------------------------------------------------------+
//|                                               freeMan_v1.1.5.mq4 |
//|                                         http://all-webmoney.com  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011 http://all-webmoney.com"
#property link      "http://all-webmoney.com"



extern string BS = "---------------- Base settings---------------";
extern int    MagicNumber       = 89539235;
extern int    ProfitFactor      = 2;
extern int    StopLossFactor    = 14;
extern int    Slippage          = 3;
extern int    AccountOrders     = 5; 
extern int    Distance          = 10;        
extern bool   BarsControl       = true;

extern string MM = "---------------- Money Managment---------------";
extern bool   FixedLot          = false;
extern double Lots              = 0.01;
extern double MaximumRisk       = 0.7;
extern double DecreaseFactor    = 0;
extern string TS = "---------------- Trailing Settings ---------------";

extern bool   Trailing          = false;
extern int    MinProfit         = 20;
extern int    TrailingStop      = 60;
extern int    TrailingStep      = 20;

extern string NS = "---------------- NoLoss Settings ---------------";
extern bool   NoLoss            = true;
extern int    MinProfitB        = 30;
extern int    NoLossLevel       = 19;

extern string STS = "---------------- Strategy Settings ---------------";
extern bool   RsiTeacher        = true;
extern bool   RsiTeacher2       = true;

extern string RTS = "---------------- RSI Teacher Settings ---------------";
extern int    RSIPeriod          = 15;
extern int    RSIMA              = 5;
extern int    RSIPeriod2         = 20;
extern int    RSIMA2             = 9;
extern int    RSISellLevel       = 34;
extern int    RSIBuyLevel        = 70;
extern int    RSISellLevel2      = 34;
extern int    RSIBuyLevel2       = 68;
extern int    Shift              = 0;
extern bool   TrendFilter        = false;
extern int    MAMode             = 0;  // 0=SMA,1=EMA,2=SSMA,3=LWMA
extern int    MAPrice            = 0;  // 0=Close,1=Open,2=High,3=Low,4=Median,5=Typical,6=Weighted
extern int    MAFilter           = 20;

extern string TMS = "---------------- Time Settings ---------------";
extern bool   TradeOnFriday      =  true;
extern int    BaginTradeHour     = 0;
extern int    EndTradeHour       = 0;


// Global variables
 
double ShortOrderPrevProfit, ShortOrderPrevLot, ShortOrderPrevSL, ShortOrderPrevTP;
double LongOrderPrevProfit, LongOrderPrevLot, LongOrderPrevSL, LongOrderPrevTP;
int LongOrderPrevTicket, ShortOrderPrevTicket;
           
int buyOrders = 0, sellOrders = 0, allOrders = 0; 
string DivTrainStr = "; ";

// Long position ticket
int LongTicket = -1;

// Short position ticket
int ShortTicket = -1;


int CountBuyOrders = 0, CountSellOrders = 0;


//------------------------------------------------------------------
// initialization function                                  
//------------------------------------------------------------------
int init ()
{      
    
    if (Digits == 5) {
       Slippage = Slippage * 10;
       Distance = Distance * 10; 
       MinProfit =  MinProfit * 10;
       TrailingStop =  TrailingStop * 10;
       TrailingStep = TrailingStep * 10;
       MinProfitB = MinProfitB * 10;
       NoLossLevel = NoLossLevel * 10;       
              
    }
    return (0);
}

//------------------------------------------------------------------
// deinitialization function                                 |
//------------------------------------------------------------------
int deinit ()
{             
    return (0);
}


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start ()
{
    int i;
    bool BuySignal = false;
    bool SellSignal = false;


   if(Trailing) TrailPositions();
   if(NoLoss) CreateNoLoss();     
   //---- check for history and trading
   if(Bars < 100 || IsTradeAllowed() == false) return;
         
   GetCurrentOrders(Symbol());
   if (AccountFreeMargin() > 0)
      CheckForOpen();

   return (0);
}


//------------------------------------------------------------------
// Get open positions                                         |
//------------------------------------------------------------------
int GetCurrentOrders(string symbol)
  {
   
   int i = 0;         
   buyOrders = 0;
   sellOrders = 0;
   allOrders = OrdersTotal();
   for(i=0; i < allOrders; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType() == OP_BUY) buyOrders++;
         if(OrderType() == OP_SELL) sellOrders++;
        }
     }
     
   /*
      if(buyOrders > 0) return( buyOrders );
         else return(-sellOrders);
   */
   return;
  }
  
  
//------------------------------------------------------------------
// Calculate optimal lot size                                       
//------------------------------------------------------------------

double GetLotSize()
  {
   
   if (!FixedLot) {
      double lot = Lots;
      int    orders = HistoryTotal();     // history orders total
      int    losses = 0;                  // number of losses orders without a break    
      lot = NormalizeDouble(AccountFreeMargin()*MaximumRisk /(MarketInfo(Symbol(), MODE_LOTSIZE)/10), 2);    
   } else {
      lot = Lots;
   }
         
      if(DecreaseFactor>0) {
         for(int i = orders-1; i >= 0; i--)
           {
            if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY) == false) { Print("Error in history!"); break; }
            if(OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
            //----
            if(OrderProfit() > 0) break;
            if(OrderProfit() < 0) losses++;
           }
         if(losses>1) lot = NormalizeDouble(lot-lot*losses/DecreaseFactor, 2);
        }
              
      
      double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
      double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
      if (MinLot == 0) MinLot = 0.01;
      if (MaxLot == 0) MaxLot = 10000;
      if (lot < MinLot) lot = MinLot;
      if (lot > MaxLot) lot = MaxLot;
      
      //---- return lot size
      return(lot);
   
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double Lot;
   int    i;
   bool   tradeAllow = false;
   
     
   if (BarsControl)
      if(Volume[0] > 1) return;
      
   if (!TradeOnFriday)
      if (DayOfWeek() == 5) return;
      
      
   if (BaginTradeHour > 0 && EndTradeHour > 0) {
      if (Hour() >= BaginTradeHour || Hour() <= EndTradeHour) tradeAllow = true;
       
   } else {
      tradeAllow = true;
   }
      
   if (allOrders < AccountOrders || !AccountOrders && tradeAllow) {
         Lot = GetLotSize();  
         double MaxLot = MarketInfo(Symbol(), MODE_MINLOT);
         double MinLot = MarketInfo(Symbol(), MODE_MAXLOT); 
         double LotSize = MarketInfo(Symbol(), MODE_LOTSIZE);
         double LockLot;
                    
         
         double atr, TakeProfit, StopLoss;
                       
         if (Digits == 5)
               atr = iATR(NULL, 0, RSIPeriod, Shift) * 100000;   
         else 
               atr = iATR(NULL, 0, RSIPeriod, Shift) * 10000;    
         TakeProfit = atr * ProfitFactor;        
         StopLoss = atr * StopLossFactor;
         double SpreadPoints = MarketInfo(Symbol(), MODE_SPREAD) + 3;
         
         if (TakeProfit < SpreadPoints) TakeProfit = SpreadPoints;
         if (StopLoss < SpreadPoints) StopLoss = SpreadPoints; 
         
      
         //---- buy signal
         if (buyOrders < 1) {
            if (GetBuySignal()) {
                  Print(Lot);                  
                  LongTicket = OrderSend(Symbol(), OP_BUY, Lot, NormalizeDouble(Ask, Digits), Slippage, 0, 0, "freeMan 1.1.5 "+Period(), MagicNumber, 0, Green);                                                    
                  if (LongTicket > 0) {
                        OrderModify(LongTicket, Lot, NormalizeDouble(Ask-(StopLoss*Point), Digits), NormalizeDouble(Ask+(TakeProfit*Point),Digits), 0);
                        //buyOrders++; 
                     }
                                
                  
		            
	               return;       
            }         
         }
         else {
            
            //&& buyOrders < 2
               if (IsBuyLock()) {
                    LockLot =  LongOrderPrevProfit / TakeProfit ;
                    LockLot = NormalizeDouble(LockLot, 2);                    
                    if (LockLot < MinLot)
                        LockLot = MinLot;
                    if (LockLot > MaxLot)
                        LockLot = MaxLot;
                    if (LockLot < Lot)
                        LockLot = Lot;
                   
                    
                   
                    LongTicket = OrderSend(Symbol(), OP_BUY, LockLot, NormalizeDouble(Ask, Digits), Slippage, 0, 0, "freeMan 1.1.5 "+Period(), MagicNumber, 0, Green);                   
                    if (LongTicket > 0) {   
                        OrderModify(LongTicket, LockLot, NormalizeDouble(Ask-(StopLoss*Point), Digits), NormalizeDouble(Ask+(TakeProfit*Point), Digits), 0);
                        //buyOrders++;
                    }
                    
                    if (LongOrderPrevTP !=  NormalizeDouble(Ask+(TakeProfit*Point),Digits))
                        OrderModify(LongOrderPrevTicket, LongOrderPrevLot, LongOrderPrevSL, NormalizeDouble(Ask+(TakeProfit*Point),Digits), 0);                    
                    
                    return;
               } else {
                  //if (AccountFreeMargin() > 0) {
                     OrderSelect(LongTicket, SELECT_BY_TICKET);               
                     if ((MathAbs(OrderOpenPrice() - Ask) / Point) >=  Distance)                     
                        if (GetBuySignal()) {   
                                                                        
                              LongTicket = OrderSend(Symbol(), OP_BUY, Lot, NormalizeDouble(Ask, Digits), Slippage, 0, 0, "freeMan 1.1.5 "+Period(), MagicNumber, 0, Green);                                 
                              if (LongTicket > 0) {
                                 OrderModify(LongTicket, Lot, NormalizeDouble(Ask-(StopLoss*Point), Digits), NormalizeDouble(Ask+(TakeProfit*Point), Digits), 0);                           
                                 //buyOrders++;
                              }
	                           return;       
                        }           
                  //}// if (AccountFreeMargin() > 0)
               }// else
            
         }// else 
         
      	     
                   
          //--------------- sell signal -----------------
          if (sellOrders < 1) {
            if(GetSellSignal()) {
                                    
                 ShortTicket = OrderSend(Symbol(),OP_SELL, Lot, NormalizeDouble(Bid, Digits), Slippage, 0, 0, "freeMan 1.1.5 "+Period(), MagicNumber, 0, DarkGreen);                   
                 if (ShortTicket > 0) {
                     OrderModify(ShortTicket, Lot, NormalizeDouble(Bid+(StopLoss*Point),Digits), NormalizeDouble(Bid-(TakeProfit*Point), Digits), 0);
                     //sellOrders++;
                 }
                              
		                            	         
                 return;    
            }
          }
          else {
           
            //&& sellOrders < 2
                  if (IsSellLock() ) {
                    LockLot =  ShortOrderPrevProfit / TakeProfit ;
                    LockLot = NormalizeDouble(LockLot, 2);
                    if (LockLot < MinLot)
                        LockLot = MinLot;
                    if (LockLot > MaxLot)
                        LockLot = MaxLot;
                    if (LockLot < Lot)
                        LockLot = Lot;
                                        
                    ShortTicket = OrderSend(Symbol(),OP_SELL, LockLot, NormalizeDouble(Bid, Digits),Slippage, 0, 0, "freeMan 1.1.5 "+Period(), MagicNumber, 0, DarkGreen);                      
                    if (ShortTicket > 0) {
                        OrderModify(ShortTicket, LockLot, NormalizeDouble(Bid+(StopLoss*Point),Digits), NormalizeDouble(Bid-(TakeProfit*Point), Digits), 0);
                        //sellOrders++;
                    }
                    if (ShortOrderPrevTP != NormalizeDouble(Bid-(TakeProfit*Point),Digits))
                        OrderModify(ShortOrderPrevTicket, ShortOrderPrevLot, ShortOrderPrevSL, NormalizeDouble(Bid-(TakeProfit*Point),Digits), 0);                    
                    
                    return;
               } else {
                  //if (AccountFreeMargin() > 0) {                                                             
                     if ((MathAbs(OrderOpenPrice() - Bid) / Point) >=  Distance)
                        if(GetSellSignal()) {                                             
                             ShortTicket = OrderSend(Symbol(),OP_SELL, Lot, NormalizeDouble(Bid, Digits),Slippage, 0, 0, "freeMan 1.1.5 "+Period(), MagicNumber, 0, DarkGreen);                            
                             if (ShortTicket > 0) {   
                                 OrderModify(ShortTicket, Lot, NormalizeDouble(Bid+(StopLoss*Point),Digits), NormalizeDouble(Bid-(TakeProfit*Point), Digits), 0);
                                 //sellOrders++;
                             }
                             return;
                        }
                  //}// if (AccountFreeMargin() > 0)
                } //else
            
          }// else
                  
      }       
    
//----
  }
  



bool IsBuyLock() {
   
      if (LongTicket > 0 && AccountFreeMargin() > 0) {
         OrderSelect(LongTicket, SELECT_BY_TICKET);
         LongOrderPrevProfit = OrderProfit();
         LongOrderPrevTicket = LongTicket;
         LongOrderPrevLot = OrderLots();
         LongOrderPrevSL = OrderStopLoss();
         LongOrderPrevTP = OrderTakeProfit();         
         if (LongOrderPrevProfit < 0 && GetBuySignal() && MathAbs((OrderOpenPrice() - Ask) / Point) >= Distance ) {            
            return (true);
         } 
         return (false);   
      }     
}

bool IsSellLock() {
   if (ShortTicket > 0 && AccountFreeMargin() > 0) {        
         OrderSelect(ShortTicket, SELECT_BY_TICKET);
         ShortOrderPrevProfit = OrderProfit();
         ShortOrderPrevTicket = ShortTicket;
         ShortOrderPrevSL = OrderStopLoss();
         ShortOrderPrevTP = OrderTakeProfit();         
         if (ShortOrderPrevProfit < 0  && GetSellSignal() &&  MathAbs((OrderOpenPrice() - Bid) / Point) >= Distance  ) {
            return (true);
         } 
         return (false);   
      }   
}


//------------------------------------------------------------------
// Check for buy conditions                                         
//------------------------------------------------------------------
bool GetBuySignal () {
                                          
         double RSInow = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, Shift);         
         double RSIprev = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, Shift+1);                  
         double RSIMAnow = iMA(NULL,0, RSIMA, 0, MAMode, MAPrice, Shift);
         double RSIMApre = iMA(NULL,0, RSIMA, 0, MAMode, MAPrice, Shift+1);                              
                  
         double RSInow2 = iRSI(NULL, 0, RSIPeriod2, PRICE_CLOSE, Shift);         
         double RSIprev2 = iRSI(NULL, 0, RSIPeriod2, PRICE_CLOSE, Shift+1);                  
         double RSIMAnow2 = iMA(NULL,0, RSIMA2, 0, MAMode, MAPrice, Shift);
         double RSIMApre2 = iMA(NULL,0, RSIMA2, 0, MAMode, MAPrice, Shift+1);                              
                  
         double ATRnow = iATR(NULL, 0, RSIMA, Shift);
         double ATRPrev = iATR(NULL, 0, RSIMA, Shift+3);
                 
         double RSInowH1 = iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, Shift);
         
         double MAFilterNow = iMA(NULL, PERIOD_H1, MAFilter, 0, MAMode, MAPrice, Shift);
         double MAFilterPrev = iMA(NULL, PERIOD_H1, MAFilter, 0, MAMode, MAPrice, Shift+1);
                                        
         if ( ((MAFilterNow > MAFilterPrev && TrendFilter) || (!TrendFilter)) && 
            (RsiTeacher2 && (RSIprev2 < RSISellLevel2)&& (RSInow2 > RSIprev2) && (RSInowH1 < RSIBuyLevel2) &&  (RSIMAnow2 > RSIMApre2)) ||
            (RsiTeacher && (RSIprev < RSISellLevel )&& (RSInow > RSIprev) && (RSInowH1 < RSIBuyLevel) &&  (RSIMAnow > RSIMApre))
           )//if           
         {
             
             return (true);             
             
         }//---- buy if -------
    
    
    return (false);
}

//------------------------------------------------------------------
// Check for close sell conditions                                  
//------------------------------------------------------------------
bool GetSellSignal () {
         
         double RSInow = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, Shift);
         double RSIprev = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, Shift+1);         
         double RSIMAnow = iMA(NULL,0, RSIMA, 0, MAMode, MAPrice,Shift);
         double RSIMApre = iMA(NULL,0, RSIMA, 0, MAMode, MAPrice,Shift+1);             
         
         double RSInow2 = iRSI(NULL, 0, RSIPeriod2, PRICE_CLOSE, Shift);
         double RSIprev2 = iRSI(NULL, 0, RSIPeriod2, PRICE_CLOSE, Shift+1);         
         double RSIMAnow2 = iMA(NULL,0, RSIMA2, 0, MAMode, MAPrice,Shift);
         double RSIMApre2 = iMA(NULL,0, RSIMA2, 0, MAMode, MAPrice,Shift+1);             
         
         double ATRnow = iATR(NULL, 0, RSIMA, Shift);
         double ATRPrev = iATR(NULL, 0, RSIMA, Shift+3);
      
         double RSInowH1 = iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, Shift);                                                 
         
         double MAFilterNow = iMA(NULL, PERIOD_H1, MAFilter, 0, MAMode, MAPrice, Shift);
         double MAFilterPrev = iMA(NULL, PERIOD_H1, MAFilter, 0, MAMode, MAPrice, Shift+1);               
        
         //---- sell conditions----------                  
         if( ((MAFilterNow < MAFilterPrev && TrendFilter) || (!TrendFilter)) &&
            (RsiTeacher2 && (RSIprev2 > RSIBuyLevel2) && (RSInow2 < RSIprev2) && (RSInowH1 > RSISellLevel2) && (RSIMAnow2 < RSIMApre2)) ||           
            (RsiTeacher && (RSIprev > RSIBuyLevel) && (RSInow < RSIprev) && (RSInowH1 > RSISellLevel) && (RSIMAnow < RSIMApre))                    
           )// if  
           
         {
             
             return (true);
             
         }//---- sell if ------
   
   return (false);
}


//------------------------------------------------------------------
//  Trail positions 
//------------------------------------------------------------------
void TrailPositions()
{

  int orders = OrdersTotal();  
  for (int i=0; i<orders; i++) {
    if (!(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))) continue;
    if (OrderSymbol() != Symbol()) continue;
    {    
      if (OrderType() == OP_BUY) {
        if (Bid-OrderOpenPrice() > MinProfit * Point)  {
          if (OrderStopLoss() < Bid-(TrailingStop+TrailingStep-1) * Point)  {
          OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid-TrailingStop * Point, Digits), OrderTakeProfit(), 0, Gold);          
          }
        }
      }  
       
      if (OrderType() == OP_SELL) {
        if (OrderOpenPrice()-Ask > MinProfit * Point) {
          if (OrderStopLoss() > Ask+(TrailingStop+TrailingStep-1) * Point) {
          OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble(Ask+TrailingStop * Point, Digits), OrderTakeProfit(), 0, Gold);         
          }
        }
      }   
    }   
  }  
  
}
//------------------------------------------------------------------
// No Losee 
//------------------------------------------------------------------
void CreateNoLoss()
{
  
  int orders = OrdersTotal();
  for (int i=0; i<orders; i++)
  {
    if (!(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))) continue;
    if (OrderSymbol() != Symbol()) continue;
    {    
      if (OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) {
        if (Bid-OrderOpenPrice() > MinProfitB*Point) {
          if (OrderStopLoss() < Bid-(NoLossLevel-1)*Point) {
          OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + NoLossLevel * Point, OrderTakeProfit(), 0, Gold);           
          }
        }
      }
      if (OrderType() == OP_BUY && OrderStopLoss() == 0) {
        if (Bid-OrderOpenPrice() > MinProfitB * Point) {
          if (OrderStopLoss() < Bid-(NoLossLevel-1) * Point) {
          OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + NoLossLevel * Point, OrderTakeProfit(), 0, Gold);          
          }
        }
      }         
      if (OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice())  
      {
        if (OrderOpenPrice()-Ask > MinProfitB*Point) {
          if (OrderStopLoss() > Ask+(NoLossLevel-1)*Point) {
          OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - NoLossLevel * Point, OrderTakeProfit(), 0, Gold);           
          }
        }
      }  
      if (OrderType() == OP_SELL && OrderStopLoss() == 0) {
        if (OrderOpenPrice()-Ask > MinProfitB * Point) {
          if (OrderStopLoss() > Ask+(NoLossLevel-1) * Point) {
          OrderModify(OrderTicket(), OrderOpenPrice(),OrderOpenPrice() - NoLossLevel * Point, OrderTakeProfit(), 0, Gold);           
          }
        }        
      }   
    }   
  }  
  
    
 }
 