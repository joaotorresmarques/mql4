#property copyright "Copyright 2013, ProfFX"
#property link      "http://euronis-free.com"



extern int TotalOrdersLimit = 1;
extern double     MaxRiskPercent             = 0.1; //Risk % per trade
extern int Magic=1;
extern bool       AccountIsMicro          = true;

extern double    TakeProfit=0; // TP
extern double    StopLoss=0; // SL 
extern bool      MonitorTakeProfit=true;
extern bool      MonitorStopLoss=true;

int NumberOrderLimitBuy = 0;
int NumberOrderLimitSell = 0;
int MaxHours=1;

double b_close,s_close;
double l_ihigh_0;
double l_ilow_8;
string atrresult ;
double Lots = 0;
   
   
int init() {
  
   return (0);
}

int deinit() {
   return (0);
}

int start() { if(AccountNumber() !=7249690) {Comment("No license for your account. Write on support@euronis-free.com"); return(0);}
      
      int    decimalPlaces=1;

      NumberOrderLimitBuy = TotalOrdersLimit;
      NumberOrderLimitSell = TotalOrdersLimit;
      
      if (NumberOrderLimitBuy == 1 && NumberOrderLimitSell == 0 && CountOrdersThisPairSELL() == 0) NumberOrderLimitBuy = 0;
      else
      if (NumberOrderLimitSell == 1 && NumberOrderLimitBuy == 0 && CountOrdersThisPairBUY() == 0) NumberOrderLimitSell = 0;
   
      // Lots Calculation
      if(AccountIsMicro==true) decimalPlaces=2;
  
      Lots = NormalizeDouble(AccountFreeMargin()*MaxRiskPercent/10000.0,decimalPlaces);
                                            
 
      //Filter 1
      b_close = iClose(Symbol(),PERIOD_H4,0);
      s_close = iClose(Symbol(),PERIOD_H4,1);
   
      //Filter 2
      l_ihigh_0 = iHigh(Symbol(), PERIOD_H4, 1);
      l_ilow_8 = iLow(Symbol(), PERIOD_H4, 1);
   
  
      // Filter 3 (Main Filter RSI20(H4) to decide trading when "Trending" only)
  
      /*H4, 20 period Rsi. When the Rsi is:
      > 55, market is trending up
      < 45, market is trending down
      in between, market is ranging */

      double rsi20 = iRSI(Symbol(),PERIOD_H4,20,PRICE_CLOSE,0);     
      if (rsi20 > 45 && rsi20 <  55) atrresult = "Range-Bound";
      if (rsi20 > 55) atrresult = "UP";
      if (rsi20 < 45) atrresult = "DOWN";
   
      // If Market is not Range bound, scan for trade opportunities
   
      if ( atrresult !=  "Range-Bound") 
      {
   
         Strategy_1();
      }
 
      // Trade Closing Logic (Look for Reversal in Trend to close open order dynamically)
   
      if ( CountOrdersThisPairBUY() > 0 || CountOrdersThisPairSELL() > 0 )
      
      {
         AutoSetTPSL();
         AfterHours();
      }
 
  
      return (0);
}

// Strategy to open orders

int Strategy_1() {
      string l_dbl2str_12;
  
      if ( CountOrdersThisPairSELL() == 0   &&  NumberOrderLimitSell > 0 &&  b_close > s_close  && atrresult == "UP" && Ask > l_ihigh_0 ) 
      {
      
         l_dbl2str_12 = DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD) / 10.0, 1);
      
         if (OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, 0, 0, l_dbl2str_12, Magic, 0, Red) != -1) 
         {
         
            NumberOrderLimitSell--;
      
         }
      
      }
      
      if (  CountOrdersThisPairBUY() == 0   && NumberOrderLimitBuy > 0 &&   b_close < s_close && atrresult == "DOWN"  && Bid < l_ilow_8) 
      {
   
         l_dbl2str_12 = DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD) / 10.0, 1);
         
         if (OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, 0, 0, l_dbl2str_12, Magic, 0, RoyalBlue) != -1) 
         {
            NumberOrderLimitBuy--;      
        
         }
      }
  
  
      return (0);
}

int CountOrdersThisPairBUY() {
   int l_count_0;
   for (int l_pos_4 = 0; l_pos_4 < OrdersTotal(); l_pos_4++) {
      OrderSelect(l_pos_4, SELECT_BY_POS);
      if (OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderMagicNumber() == Magic) l_count_0++;
   }
   return (l_count_0);
}

int CountOrdersThisPairSELL() {
   int l_count_0 = 0;
   for (int l_pos_4 = 0; l_pos_4 < OrdersTotal(); l_pos_4++) {
      OrderSelect(l_pos_4, SELECT_BY_POS);
      if (OrderSymbol() == Symbol() && OrderType() == OP_SELL  && OrderMagicNumber() == Magic) l_count_0++;
   }
   return (l_count_0);
}



void AutoSetTPSL() {

  int StopMultd=10;
   double TP=NormalizeDouble(TakeProfit*StopMultd,Digits);
   double SL=NormalizeDouble(StopLoss*StopMultd,Digits);
   
 //-------------------------------------------------------------------+
//Check open orders
//-------------------------------------------------------------------+
if(OrdersTotal()>0){
  for(int i=1; i<=OrdersTotal(); i++)          // Cycle searching in orders
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // If the next is available
        {
          if((MonitorTakeProfit==true)&&(TakeProfit>0)&&(OrderMagicNumber()==Magic)){ // monitor tp
          
                // Calculate take profit
                double tpb=NormalizeDouble(OrderOpenPrice()+TP*Point,Digits);
                double tps=NormalizeDouble(OrderOpenPrice()-TP*Point,Digits);
                    
                Comment("Modifying take profit");
                if((OrderType()==OP_BUY)&&(OrderTakeProfit()==0)&&(OrderSymbol()==Symbol())){ OrderModify(OrderTicket(),0,OrderStopLoss(),tpb,0,CLR_NONE); }
                if((OrderType()==OP_SELL)&&(OrderTakeProfit()==0)&&(OrderSymbol()==Symbol())){ OrderModify(OrderTicket(),0,OrderStopLoss(),tps,0,CLR_NONE); }
 
          } // monitor tp
          
          if((MonitorStopLoss==true)&&(StopLoss>0)&&(OrderMagicNumber()==Magic)){ // monitor sl
          
                   // Calculate stop loss
                   double slb=NormalizeDouble(OrderOpenPrice()-SL*Point,Digits);
                   double sls=NormalizeDouble(OrderOpenPrice()+SL*Point,Digits);
 
                   Comment("Modifying stop loss");
                   if((OrderType()==OP_BUY)&&(OrderStopLoss()==0)&&(OrderSymbol()==Symbol())){ OrderModify(OrderTicket(),0,slb,OrderTakeProfit(),0,CLR_NONE); }
                   if((OrderType()==OP_SELL)&&(OrderStopLoss()==0)&&(OrderSymbol()==Symbol())){ OrderModify(OrderTicket(),0,sls,OrderTakeProfit(),0,CLR_NONE); }
 
          }// monitor sl
          Comment("");
        }
     }
}

//----
int Error=GetLastError();
  if(Error==130){Alert("Wrong stops. Retrying."); RefreshRates();}
  if(Error==133){Alert("Trading prohibited.");}
  if(Error==2){Alert("Common error.");}
  if(Error==146){Alert("Trading subsystem is busy. Retrying."); Sleep(500); RefreshRates();}
 
//----------
   return(0);
  }
//----------

void AfterHours(){  
             
   for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS)){
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic ){
            if(CurTime() - OrderOpenTime() > MaxHours * (60 * 60) ){
               if(OrderType()==OP_BUY &&  b_close > s_close &&  atrresult == "UP" && Ask > l_ihigh_0){
                  OrderClose(OrderTicket(),OrderLots(),Bid,2,Red);
               }
               if(OrderType()==OP_SELL &&  b_close < s_close  && atrresult == "DOWN" && Bid < l_ilow_8 ){
                  OrderClose(OrderTicket(),OrderLots(),Ask,2,Red);
               }
              
            }
         }
      }
   }
}