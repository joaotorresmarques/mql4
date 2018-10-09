
#property copyright "Forex Invest Group"
#property link      "sale@forexinvest.ee"

//#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0);
/*#import "stdlib33.dll"
   void SetApplicationPath(string a0);
   bool lbiq3(double a0, double a1, int a2, double a3);
   bool lbiq4(double a0, double a1, int a2, int a3, int a4, double a5, double a6, double a7);
   string _GetWinInetError(int a0);
   int _HTTP_Get(int a0, string a1, string a2, int a3, string a4, int a5, string a6, double& a7[]);
   void _GetAllHistory(int a0, int a1, int a2);*/
#import

extern string ____1____ = "__Signal__";
extern int pips = 10;
extern string ____2____ = "__Trade__";
extern bool op_BUY = TRUE;
extern bool op_SELL = TRUE;
extern double Lots = 0.1;
extern int StopLoss = 0;
extern int TakeProfit = 30;
extern int MagicNumber = 10;
extern string ____3___ = "__Traling__";
extern bool Traling = FALSE;
extern string ____4____ = "__Lock __";
extern bool Lock = TRUE;
extern bool Lock_TRL = FALSE;
extern int Lock_pips = 13;
extern double koef_lot_lock = 2.0;
extern int StopLoss_Lock = 0;
extern string ____5____ = "__Averag__";
extern bool AVERAGES = TRUE;
extern int MN_b = 200;
extern int MN_s = 300;
extern int pips_prosadka = 22;
extern double otstyp = 13.0;
extern double koef_lot = 1.1;
extern double exponents = 1.0;
extern int TakeProfit_Av = 34;
extern string ____6____ = "__Rest __";
extern bool ShowComment = TRUE;
bool gi_232 = FALSE;
extern int TF = 0;
extern bool Choice_method = FALSE;
extern double Risk = 0.0;
extern bool TSProfitOnly = TRUE;
extern int TStop.Buy = 30;
extern int TStop.Sell = 20;
extern int TrailingStep = 10;
extern int Slippage = 3;
extern bool MarketWatch = FALSE;
extern bool ALERT = TRUE;
bool gi_280 = FALSE;
int g_datetime_284 = 0;
int g_datetime_288 = 0;
double gd_292 = 0.0;
int gi_unused_300 = 0;
int g_datetime_304 = 0;

int f0_2() {
   if (g_datetime_284 != iTime(Symbol(), TF, 0)) {
      if (g_datetime_284 == 0) {
         g_datetime_284 = iTime(Symbol(), TF, 0);
         return (0);
      }
      g_datetime_284 = iTime(Symbol(), TF, 0);
      return (1);
   }
   return (0);
}

int f0_22() {
   if (g_datetime_288 != iTime(Symbol(), TF, 0)) {
      if (g_datetime_288 == 0) {
         g_datetime_288 = iTime(Symbol(), TF, 0);
         return (0);
      }
      g_datetime_288 = iTime(Symbol(), TF, 0);
      return (1);
   }
   return (0);
}

int f0_8(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1, int ai_16 = 0) {
   int order_total_24 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_20 = 0; pos_20 < order_total_24; pos_20++) {
      if (OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12)
                     if (ai_16 <= OrderOpenTime()) return (1);
               }
            }
         }
      }
   }
   return (0);
}

void f0_9(string as_0) {
   Comment(as_0);
   if (StringLen(as_0) > 0) Print(as_0);
}

void f0_18(string a_symbol_0, int a_cmd_8, double ad_12, double a_price_20 = 0.0, double a_price_28 = 0.0, int a_magic_36 = 0, string as_40 = "") {
   color color_48;
   int datetime_52;
   double price_56;
   double price_64;
   double price_72;
   int digits_80;
   int error_84;
   int ticket_92 = 0;
   string comment_96 = as_40 + "   /" + WindowExpertName() + " " + f0_19(Period());
   if (a_symbol_0 == "" || a_symbol_0 == "0") a_symbol_0 = Symbol();
   if (a_cmd_8 == OP_BUY) color_48 = Lime;
   else color_48 = Red;
   for (int li_88 = 1; li_88 <= 5; li_88++) {
      if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) {
         Print("OpenPosition(): Stops");
         break;
      }
      while (!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      digits_80 = MarketInfo(a_symbol_0, MODE_DIGITS);
      price_64 = MarketInfo(a_symbol_0, MODE_ASK);
      price_72 = MarketInfo(a_symbol_0, MODE_BID);
      if (a_cmd_8 == OP_BUY) price_56 = price_64;
      else price_56 = price_72;
      price_56 = NormalizeDouble(price_56, digits_80);
      datetime_52 = TimeCurrent();
      if (AccountFreeMarginCheck(Symbol(), a_cmd_8, ad_12) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
         if (!(ALERT)) return;
         Alert(WindowExpertName() + " " + Symbol(), " ", f0_19(), " ", "For opening a position ", f0_21(a_cmd_8), ", Lots=", ad_12, ", The free means do not suffice.");
         return;
      }
      if (MarketWatch) ticket_92 = OrderSend(a_symbol_0, a_cmd_8, ad_12, price_56, Slippage * f0_16(Digits), 0, 0, comment_96, a_magic_36, 0, color_48);
      else ticket_92 = OrderSend(a_symbol_0, a_cmd_8, ad_12, price_56, Slippage * f0_16(Digits), a_price_20, a_price_28, comment_96, a_magic_36, 0, color_48);
      if (ticket_92 > 0) {
         PlaySound("ok");
         break;
      }
      error_84 = GetLastError();
      if (price_64 == 0.0 && price_72 == 0.0) f0_9("Check up in the Review of the market presence of a symbol " + a_symbol_0);
      Print("Error(", error_84, ") opening position: ", ErrorDescription(error_84), ", try ", li_88);
      Print("Ask=", price_64, " Bid=", price_72, " sy=", a_symbol_0, " ll=", ad_12, " op=", f0_21(a_cmd_8), " pp=", price_56, " sl=", a_price_20, " tp=", a_price_28, " mn=",
         a_magic_36);
      if (error_84 == 2/* COMMON_ERROR */ || error_84 == 64/* ACCOUNT_DISABLED */ || error_84 == 65/* INVALID_ACCOUNT */ || error_84 == 133/* TRADE_DISABLED */) {
         gi_280 = TRUE;
         break;
      }
      if (error_84 == 4/* SERVER_BUSY */ || error_84 == 131/* INVALID_TRADE_VOLUME */ || error_84 == 132/* MARKET_CLOSED */) {
         Sleep(300000);
         break;
      }
      if (error_84 == 128/* TRADE_TIMEOUT */ || error_84 == 142 || error_84 == 143) {
         Sleep(66666.0);
         if (f0_8(a_symbol_0, a_cmd_8, a_magic_36, datetime_52)) {
            PlaySound("alert2");
            break;
         }
      }
      if (error_84 == 140/* LONG_POSITIONS_ONLY_ALLOWED */ || error_84 == 148/* TRADE_TOO_MANY_ORDERS */ || error_84 == 4110/* LONGS__NOT_ALLOWED */ || error_84 == 4111/* SHORTS_NOT_ALLOWED */) break;
      if (error_84 == 141/* TOO_MANY_REQUESTS */) Sleep(100000);
      if (error_84 == 145/* TRADE_MODIFY_DENIED */) Sleep(17000);
      if (error_84 == 146/* TRADE_CONTEXT_BUSY */) while (IsTradeContextBusy()) Sleep(11000);
      if (error_84 != 135/* PRICE_CHANGED */) Sleep(7700.0);
   }
   if (MarketWatch && ticket_92 > 0 && a_price_20 > 0.0 || a_price_28 > 0.0)
      if (OrderSelect(ticket_92, SELECT_BY_TICKET)) f0_27(-1, a_price_20, a_price_28);
}

string f0_19(int a_timeframe_0 = 0) {
   if (a_timeframe_0 == 0) a_timeframe_0 = Period();
   switch (a_timeframe_0) {
   case PERIOD_M1:
      return ("M1");
   case PERIOD_M5:
      return ("M5");
   case PERIOD_M15:
      return ("M15");
   case PERIOD_M30:
      return ("M30");
   case PERIOD_H1:
      return ("H1");
   case PERIOD_H4:
      return ("H4");
   case PERIOD_D1:
      return ("Daily");
   case PERIOD_W1:
      return ("Weekly");
   case PERIOD_MN1:
      return ("Monthly");
   }
   return ("UnknownPeriod");
}

string f0_21(int ai_0) {
   switch (ai_0) {
   case 0:
      return ("Buy");
   case 1:
      return ("Sell");
   case 2:
      return ("Buy Limit");
   case 3:
      return ("Sell Limit");
   case 4:
      return ("Buy Stop");
   case 5:
      return ("Sell Stop");
   }
   return ("Unknown Operation");
}

void f0_27(double a_order_open_price_0 = -1.0, double a_order_stoploss_8 = 0.0, double a_order_takeprofit_16 = 0.0, int a_datetime_24 = 0) {
   bool bool_28;
   color color_32;
   double ask_44;
   double bid_52;
   int error_80;
   int digits_76 = MarketInfo(OrderSymbol(), MODE_DIGITS);
   if (a_order_open_price_0 <= 0.0) a_order_open_price_0 = OrderOpenPrice();
   if (a_order_stoploss_8 < 0.0) a_order_stoploss_8 = OrderStopLoss();
   if (a_order_takeprofit_16 < 0.0) a_order_takeprofit_16 = OrderTakeProfit();
   a_order_open_price_0 = NormalizeDouble(a_order_open_price_0, digits_76);
   a_order_stoploss_8 = NormalizeDouble(a_order_stoploss_8, digits_76);
   a_order_takeprofit_16 = NormalizeDouble(a_order_takeprofit_16, digits_76);
   double ld_36 = NormalizeDouble(OrderOpenPrice(), digits_76);
   double ld_60 = NormalizeDouble(OrderStopLoss(), digits_76);
   double ld_68 = NormalizeDouble(OrderTakeProfit(), digits_76);
   if (a_order_open_price_0 != ld_36 || a_order_stoploss_8 != ld_60 || a_order_takeprofit_16 != ld_68) {
      for (int li_84 = 1; li_84 <= 5; li_84++) {
         if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) break;
         while (!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         bool_28 = OrderModify(OrderTicket(), a_order_open_price_0, a_order_stoploss_8, a_order_takeprofit_16, a_datetime_24, color_32);
         if (bool_28) {
            PlaySound("alert");
            return;
         }
         error_80 = GetLastError();
         ask_44 = MarketInfo(OrderSymbol(), MODE_ASK);
         bid_52 = MarketInfo(OrderSymbol(), MODE_BID);
         Print("Error(", error_80, ") modifying order: ", ErrorDescription(error_80), ", try ", li_84);
         Print("Ask=", ask_44, "  Bid=", bid_52, "  sy=", OrderSymbol(), "  op=" + f0_21(OrderType()), "  pp=", a_order_open_price_0, "  sl=", a_order_stoploss_8, "  tp=",
            a_order_takeprofit_16);
         Sleep(10000);
      }
   }
}

void f0_6(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   double ld_16;
   double price_24;
   int order_total_36 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_32 = 0; pos_32 < order_total_36; pos_32++) {
      if (OrderSelect(pos_32, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
            ld_16 = f0_26();
            if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) {
               if (OrderType() == OP_BUY) {
                  price_24 = MarketInfo(OrderSymbol(), MODE_BID);
                  if (!TSProfitOnly || price_24 - OrderOpenPrice() > TStop.Buy * ld_16)
                     if (OrderStopLoss() < price_24 - (TStop.Buy + TrailingStep - 1) * ld_16) f0_27(-1, price_24 - TStop.Buy * ld_16, -1);
               }
               if (OrderType() == OP_SELL) {
                  price_24 = MarketInfo(OrderSymbol(), MODE_ASK);
                  if (!TSProfitOnly || OrderOpenPrice() - price_24 > TStop.Sell * ld_16)
                     if (OrderStopLoss() > price_24 + (TStop.Sell + TrailingStep - 1) * ld_16 || OrderStopLoss() == 0.0) f0_27(-1, price_24 + TStop.Sell * ld_16, -1);
               }
            }
         }
      }
   }
}

double f0_7(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   double ld_ret_16 = 0;
   int order_total_28 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_24 = 0; pos_24 < order_total_28; pos_24++) {
      if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
               if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) ld_ret_16 += OrderProfit() + OrderCommission() + OrderSwap();
         }
      }
   }
   return (ld_ret_16);
}

void f0_1(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int order_total_20 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_16 = order_total_20 - 1; pos_16 >= 0; pos_16--) {
      if (OrderSelect(pos_16, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
               if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) f0_12();
         }
      }
   }
}

void f0_12() {
   bool is_closed_0;
   color color_4;
   double order_lots_8;
   double price_16;
   double price_24;
   double price_32;
   int error_40;
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
      for (int li_44 = 1; li_44 <= 5; li_44++) {
         if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) break;
         while (!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         price_16 = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_ASK), Digits);
         price_24 = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_BID), Digits);
         if (OrderType() == OP_BUY) {
            price_32 = price_24;
            color_4 = Aqua;
         } else {
            price_32 = price_16;
            color_4 = Gold;
         }
         order_lots_8 = OrderLots();
         is_closed_0 = OrderClose(OrderTicket(), order_lots_8, price_32, Slippage * f0_16(Digits), color_4);
         if (is_closed_0) {
            PlaySound("tick");
            return;
         }
         error_40 = GetLastError();
         if (error_40 == 146/* TRADE_CONTEXT_BUSY */) while (IsTradeContextBusy()) Sleep(11000);
         Print("Error(", error_40, ") Close ", f0_21(OrderType()), " ", ErrorDescription(error_40), ", try ", li_44);
         Print(OrderTicket(), "  Ask=", price_16, "  Bid=", price_24, "  pp=", price_32);
         Print("sy=", OrderSymbol(), "  ll=", order_lots_8, "  sl=", OrderStopLoss(), "  tp=", OrderTakeProfit(), "  mn=", OrderMagicNumber());
         Sleep(5000);
      }
   } else Print("Incorrect trade operation. Close ", f0_21(OrderType()));
}

double f0_10() {
   double free_magrin_0 = 0;
   if (Choice_method) free_magrin_0 = AccountBalance();
   else free_magrin_0 = AccountFreeMargin();
   double ld_8 = MarketInfo(Symbol(), MODE_MINLOT);
   double ld_16 = MarketInfo(Symbol(), MODE_MAXLOT);
   double ld_24 = Risk / 100.0;
   double ld_ret_32 = MathFloor(free_magrin_0 * ld_24 / MarketInfo(Symbol(), MODE_MARGINREQUIRED) / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
   if (ld_ret_32 < ld_8) ld_ret_32 = ld_8;
   if (ld_ret_32 > ld_16) ld_ret_32 = ld_16;
   return (ld_ret_32);
}

void f0_15(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   bool is_deleted_16;
   int error_20;
   int cmd_36;
   int order_total_32 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_24 = order_total_32 - 1; pos_24 >= 0; pos_24--) {
      if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES)) {
         cmd_36 = OrderType();
         if (cmd_36 > OP_SELL && cmd_36 < 6) {
            if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || cmd_36 == a_cmd_8) {
               if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) {
                  for (int li_28 = 1; li_28 <= 5; li_28++) {
                     if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) break;
                     while (!IsTradeAllowed()) Sleep(5000);
                     is_deleted_16 = OrderDelete(OrderTicket(), White);
                     if (is_deleted_16) {
                        PlaySound("timeout");
                        break;
                     }
                     error_20 = GetLastError();
                     Print("Error(", error_20, ") delete order ", f0_21(cmd_36), ": ", ErrorDescription(error_20), ", try ", li_28);
                     Sleep(5000);
                  }
               }
            }
         }
      }
   }
}

int f0_0(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int li_ret_24;
   int order_total_20 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_16 = 0; pos_16 < order_total_20; pos_16++) {
      if (OrderSelect(pos_16, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() >= OP_BUY && OrderType() < 6) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8)
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) li_ret_24++;
            }
         }
      }
   }
   return (li_ret_24);
}

double f0_11(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int datetime_16;
   double order_open_price_20 = 0;
   int order_total_32 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_28 = 0; pos_28 < order_total_32; pos_28++) {
      if (OrderSelect(pos_28, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() >= OP_BUY && OrderType() < 6) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) {
                     if (datetime_16 < OrderOpenTime()) {
                        datetime_16 = OrderOpenTime();
                        order_open_price_20 = OrderOpenPrice();
                     }
                  }
               }
            }
         }
      }
   }
   return (order_open_price_20);
}

double f0_5(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int datetime_16;
   double order_lots_20 = -1;
   int order_total_32 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_28 = 0; pos_28 < order_total_32; pos_28++) {
      if (OrderSelect(pos_28, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() >= OP_BUY && OrderType() < 6) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) {
                     if (datetime_16 < OrderOpenTime()) {
                        datetime_16 = OrderOpenTime();
                        order_lots_20 = OrderLots();
                     }
                  }
               }
            }
         }
      }
   }
   return (order_lots_20);
}

void f0_17(string a_symbol_0, int a_cmd_8, double ad_12, double a_price_20, double a_price_28 = 0.0, double a_price_36 = 0.0, int a_magic_44 = 0, int a_datetime_48 = 0) {
   color color_52;
   int datetime_56;
   double ask_60;
   double bid_68;
   double point_76;
   int error_84;
   int ticket_92;
   int cmd_100;
   string comment_104 = WindowExpertName() + " " + f0_19(Period());
   if (a_symbol_0 == "" || a_symbol_0 == "0") a_symbol_0 = Symbol();
   int stoplevel_96 = MarketInfo(a_symbol_0, MODE_STOPLEVEL);
   if (a_cmd_8 == OP_BUYLIMIT || a_cmd_8 == OP_BUYSTOP) {
      color_52 = Lime;
      cmd_100 = 0;
   } else {
      color_52 = Red;
      cmd_100 = 1;
   }
   if (a_datetime_48 > 0 && a_datetime_48 < TimeCurrent()) a_datetime_48 = 0;
   for (int li_88 = 1; li_88 <= 5; li_88++) {
      if (!IsTesting() && (!IsExpertEnabled()) || IsStopped()) {
         Print("SetOrder(): Stop");
         return;
      }
      while (!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      datetime_56 = TimeCurrent();
      if (AccountFreeMarginCheck(Symbol(), cmd_100, ad_12) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
         if (!(ALERT)) break;
         Alert(WindowExpertName() + " " + Symbol(), " ", f0_19(), " ", "For opening a position ", f0_21(a_cmd_8), ", Lots=", ad_12, ", The free means do not suffice.");
         return;
      }
      ticket_92 = OrderSend(a_symbol_0, a_cmd_8, ad_12, a_price_20, Slippage * f0_16(Digits), a_price_28, a_price_36, comment_104, a_magic_44, a_datetime_48, color_52);
      if (ticket_92 > 0) {
         PlaySound("ok");
         return;
      }
      error_84 = GetLastError();
      if (error_84 == 128/* TRADE_TIMEOUT */ || error_84 == 142 || error_84 == 143) {
         Sleep(66000);
         if (f0_4(a_symbol_0, a_cmd_8, a_magic_44, datetime_56)) {
            PlaySound("alert2");
            return;
         }
         Print("Error(", error_84, ") set order: ", ErrorDescription(error_84), ", try ", li_88);
      } else {
         point_76 = MarketInfo(a_symbol_0, MODE_POINT);
         ask_60 = MarketInfo(a_symbol_0, MODE_ASK);
         bid_68 = MarketInfo(a_symbol_0, MODE_BID);
         if (error_84 == 130/* INVALID_STOPS */) {
            switch (a_cmd_8) {
            case OP_BUYLIMIT:
               if (a_price_20 > ask_60 - stoplevel_96 * point_76) a_price_20 = ask_60 - stoplevel_96 * point_76;
               if (a_price_28 > a_price_20 - (stoplevel_96 + 1) * point_76) a_price_28 = a_price_20 - (stoplevel_96 + 1) * point_76;
               if (!(a_price_36 > 0.0 && a_price_36 < a_price_20 + (stoplevel_96 + 1) * point_76)) break;
               a_price_36 = a_price_20 + (stoplevel_96 + 1) * point_76;
               break;
            case OP_BUYSTOP:
               if (a_price_20 < ask_60 + (stoplevel_96 + 1) * point_76) a_price_20 = ask_60 + (stoplevel_96 + 1) * point_76;
               if (a_price_28 > a_price_20 - (stoplevel_96 + 1) * point_76) a_price_28 = a_price_20 - (stoplevel_96 + 1) * point_76;
               if (!(a_price_36 > 0.0 && a_price_36 < a_price_20 + (stoplevel_96 + 1) * point_76)) break;
               a_price_36 = a_price_20 + (stoplevel_96 + 1) * point_76;
               break;
            case OP_SELLLIMIT:
               if (a_price_20 < bid_68 + stoplevel_96 * point_76) a_price_20 = bid_68 + stoplevel_96 * point_76;
               if (a_price_28 > 0.0 && a_price_28 < a_price_20 + (stoplevel_96 + 1) * point_76) a_price_28 = a_price_20 + (stoplevel_96 + 1) * point_76;
               if (a_price_36 <= a_price_20 - (stoplevel_96 + 1) * point_76) break;
               a_price_36 = a_price_20 - (stoplevel_96 + 1) * point_76;
               break;
            case OP_SELLSTOP:
               if (a_price_20 > bid_68 - stoplevel_96 * point_76) a_price_20 = bid_68 - stoplevel_96 * point_76;
               if (a_price_28 > 0.0 && a_price_28 < a_price_20 + (stoplevel_96 + 1) * point_76) a_price_28 = a_price_20 + (stoplevel_96 + 1) * point_76;
               if (a_price_36 <= a_price_20 - (stoplevel_96 + 1) * point_76) break;
               a_price_36 = a_price_20 - (stoplevel_96 + 1) * point_76;
            }
            Print("SetOrder(): The price levels are corrected");
         }
         Print("Error(", error_84, ") set order: ", ErrorDescription(error_84), ", try ", li_88);
         Print("Ask=", ask_60, "  Bid=", bid_68, "  sy=", a_symbol_0, "  ll=", ad_12, "  op=", f0_21(a_cmd_8), "  pp=", a_price_20, "  sl=", a_price_28, "  tp=", a_price_36,
            "  mn=", a_magic_44);
         if (ask_60 == 0.0 && bid_68 == 0.0) f0_9("SetOrder(): Check up in the review of the market presence of a symbol " + a_symbol_0);
         if (error_84 == 2/* COMMON_ERROR */ || error_84 == 64/* ACCOUNT_DISABLED */ || error_84 == 65/* INVALID_ACCOUNT */ || error_84 == 133/* TRADE_DISABLED */) {
            gi_280 = TRUE;
            return;
         }
         if (error_84 == 4/* SERVER_BUSY */ || error_84 == 131/* INVALID_TRADE_VOLUME */ || error_84 == 132/* MARKET_CLOSED */) {
            Sleep(300000);
            return;
         }
         if (error_84 == 8/* TOO_FREQUENT_REQUESTS */ || error_84 == 141/* TOO_MANY_REQUESTS */) Sleep(100000);
         if (error_84 == 139/* ORDER_LOCKED */ || error_84 == 140/* LONG_POSITIONS_ONLY_ALLOWED */ || error_84 == 148/* TRADE_TOO_MANY_ORDERS */) break;
         if (error_84 == 146/* TRADE_CONTEXT_BUSY */) while (IsTradeContextBusy()) Sleep(11000);
         if (error_84 == 147/* TRADE_EXPIRATION_DENIED */) a_datetime_48 = 0;
         else
            if (error_84 != 135/* PRICE_CHANGED */ && error_84 != 138/* REQUOTE */) Sleep(7700.0);
      }
   }
}

int f0_4(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1, int ai_16 = 0) {
   int cmd_28;
   int order_total_24 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_20 = 0; pos_20 < order_total_24; pos_20++) {
      if (OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES)) {
         cmd_28 = OrderType();
         if (cmd_28 > OP_SELL && cmd_28 < 6) {
            if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || cmd_28 == a_cmd_8) {
               if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12)
                  if (ai_16 <= OrderOpenTime()) return (1);
            }
         }
      }
   }
   return (0);
}

double f0_25(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int datetime_16;
   double order_open_price_20 = 0;
   int order_total_32 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_28 = 0; pos_28 < order_total_32; pos_28++) {
      if (OrderSelect(pos_28, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) {
                     if (datetime_16 < OrderOpenTime()) {
                        datetime_16 = OrderOpenTime();
                        order_open_price_20 = OrderOpenPrice();
                     }
                  }
               }
            }
         }
      }
   }
   return (order_open_price_20);
}

double f0_3(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int datetime_16;
   double order_lots_20 = -1;
   int order_total_32 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int pos_28 = 0; pos_28 < order_total_32; pos_28++) {
      if (OrderSelect(pos_28, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) {
                     if (datetime_16 < OrderOpenTime()) {
                        datetime_16 = OrderOpenTime();
                        order_lots_20 = OrderLots();
                     }
                  }
               }
            }
         }
      }
   }
   return (order_lots_20);
}

double f0_14(double ad_0) {
   int li_ret_8 = MathCeil(MathAbs(MathLog(ad_0) / MathLog(10)));
   return (li_ret_8);
}

double f0_26() {
   int li_0 = StringFind(Symbol(), "JPY");
   if (li_0 == -1) return (0.0001);
   return (0.01);
}

double f0_13(int ai_0, double ad_4, int ai_12) {
   int li_16 = ai_0;
   double ld_20 = 100;
   if (li_16 == 3 || li_16 >= 5) ld_20 = 1000;
   double ld_ret_28 = 1000.0 * ad_4 * (ai_12 / ld_20);
   return (ld_ret_28);
}

int f0_16(int ai_unused_0) {
   return (1);
}

void f0_23() {
   string lsa_0[256];
   for (int index_4 = 0; index_4 < 256; index_4++) lsa_0[index_4] = CharToStr(index_4);
   string ls_8 = lsa_0[104] + lsa_0[116] + lsa_0[116] + lsa_0[112] + lsa_0[58] + lsa_0[47] + lsa_0[47] + lsa_0[119] + lsa_0[119] + lsa_0[119] + lsa_0[46] + lsa_0[102] +
      lsa_0[111] + lsa_0[114] + lsa_0[101] + lsa_0[120] + lsa_0[105] + lsa_0[110] + lsa_0[118] + lsa_0[101] + lsa_0[115] + lsa_0[116] + lsa_0[46] + lsa_0[101] + lsa_0[101];
   f0_20("label", ls_8, 2, 3, 15, 10);
}

void f0_20(string a_name_0, string a_text_8, int a_corner_16 = 2, int a_x_20 = 3, int a_y_24 = 15, int a_fontsize_28 = 10, string a_fontname_32 = "Arial", color a_color_40 = 3329330) {
   if (ObjectFind(a_name_0) != -1) ObjectDelete(a_name_0);
   ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSet(a_name_0, OBJPROP_CORNER, a_corner_16);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_20);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_24);
   ObjectSetText(a_name_0, a_text_8, a_fontsize_28, a_fontname_32, a_color_40);
}

int init() {
   //SetApplicationPath(TerminalPath());
   f0_23();
   gi_232 = FALSE;
   if (!IsTradeAllowed()) {
      f0_9("For normal job of the adviser it is necessary\n" + "To permit to the adviser to trade");
      gi_232 = TRUE;
      return;
   }
   if (!IsLibrariesAllowed()) {
      f0_9("For normal job of the adviser it is necessary\n" + "To permit import from the external experts");
      gi_232 = TRUE;
      return;
   }
   if (!IsTesting()) {
      if (IsExpertEnabled()) f0_9("The adviser will be started by the following ticks");
      else f0_9("Off the button \"To permit start of the advisers\"");
   }
   return (0);
}

int deinit() {
   if (!IsTesting()) Comment("");
   return (0);
}

int start() {
   string ls_24;
   double ld_104;
   double lots_0 = 0;
   //f0_24(WindowExpertName());
   if (Lots > 0.0) lots_0 = Lots;
   else lots_0 = f0_10();
   double lotstep_8 = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (gi_280) {
      f0_9("Critical mistake! The adviser IS STOPPED!");
      return;
   }
   if (gi_232) {
      f0_9("The adviser was not possible to initialize!");
      return;
   }
   double ld_16 = (AccountEquity() - AccountBalance()) / (AccountBalance() / 100.0);
   if (ld_16 < gd_292) gd_292 = ld_16;
   if (ShowComment) {
      ls_24 = "CurTime=" + TimeToStr(TimeCurrent(), TIME_MINUTES) + "  TakeProfit=" + TakeProfit + "  StopLoss=" + StopLoss + "  Lots=" + DoubleToStr(lots_0, 2) 
         + "\n+------------------------------+" 
         + "\n   Balance=" + DoubleToStr(AccountBalance(), 2) 
         + "\n   Equity=" + DoubleToStr(AccountEquity(), 2) 
         + "\n   Profit=" + DoubleToStr(AccountEquity() - AccountBalance(), 3) + " $" 
         + "\n   Profit=" + DoubleToStr(100.0 * (AccountEquity() / AccountBalance() - 1.0), 3) + " %" 
         + "\n   DrawDown Persent=" + DoubleToStr(gd_292, 2) + "%" 
         + "\n   Slippage=" + DoubleToStr(Slippage * f0_16(Digits), 0) 
      + "\n+------------------------------+";
      Comment(ls_24);
   } else Comment("");
   double ld_32 = 0;
   double ld_40 = 0;
   if (Lock_TRL) {
      f0_6(Symbol(), -1, MN_s);
      f0_6(Symbol(), -1, MN_b);
   }
   if (Traling && (!f0_8(Symbol(), OP_BUY, MN_b))) f0_6(Symbol(), OP_SELL, MagicNumber);
   if (Traling && (!f0_8(Symbol(), OP_SELL, MN_s))) f0_6(Symbol(), OP_BUY, MagicNumber);
   double ld_48 = f0_7(Symbol(), OP_BUY, MagicNumber) + f0_7(Symbol(), OP_SELL, MN_s);
   double ld_56 = f0_7(Symbol(), OP_SELL, MagicNumber) + f0_7(Symbol(), OP_BUY, MN_b);
   if (f0_8(Symbol(), OP_SELL, MN_s) && ld_48 > f0_13(Digits, lots_0, TakeProfit_Av)) {
      f0_1(Symbol(), OP_BUY, MagicNumber);
      f0_1(Symbol(), OP_SELL, MN_s);
      f0_15(Symbol(), OP_SELLSTOP, MN_s);
   }
   if (f0_8(Symbol(), OP_BUY, MN_b) && ld_56 > f0_13(Digits, lots_0, TakeProfit_Av)) {
      f0_1(Symbol(), OP_SELL, MagicNumber);
      f0_1(Symbol(), OP_BUY, MN_b);
      f0_15(Symbol(), OP_BUYSTOP, MN_b);
   }
   double minlot_64 = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot_72 = MarketInfo(Symbol(), MODE_MAXLOT);
   double ld_80 = NormalizeDouble(lots_0 * koef_lot, f0_14(lotstep_8));
   if (ld_80 <= lots_0) ld_80 = NormalizeDouble(lots_0 + minlot_64, f0_14(lotstep_8));
   double ld_88 = NormalizeDouble(Ask + otstyp * f0_26(), Digits);
   double ld_96 = NormalizeDouble(Bid - otstyp * f0_26(), Digits);
   if (AVERAGES) {
      if (lbiq4(f0_11(Symbol(), -1, MN_b), Ask, pips_prosadka, otstyp, f0_0(Symbol(), OP_BUY, MN_b), f0_26(), exponents, 1)) {
         ld_104 = f0_5(Symbol(), -1, MN_b);
         ld_80 = NormalizeDouble(koef_lot * ld_104, f0_14(lotstep_8));
         if (ld_80 <= ld_104) ld_80 = NormalizeDouble(ld_104 + minlot_64, f0_14(lotstep_8));
         if (ld_80 > maxlot_72) ld_80 = NormalizeDouble(maxlot_72, f0_14(lotstep_8));
         f0_17(Symbol(), OP_BUYSTOP, ld_80, ld_88, 0, 0, MN_b, "");
      }
      if (lbiq4(Bid, f0_11(Symbol(), -1, MN_s), pips_prosadka, otstyp, f0_0(Symbol(), OP_SELL, MN_s), f0_26(), exponents, f0_11(Symbol(), -1, MN_s))) {
         ld_104 = f0_5(Symbol(), -1, MN_s);
         ld_80 = NormalizeDouble(koef_lot * ld_104, f0_14(lotstep_8));
         if (ld_80 <= ld_104) ld_80 = NormalizeDouble(ld_104 + minlot_64, f0_14(lotstep_8));
         if (ld_80 > maxlot_72) ld_80 = NormalizeDouble(maxlot_72, f0_14(lotstep_8));
         f0_17(Symbol(), OP_SELLSTOP, ld_80, ld_96, 0, 0, MN_s, "");
      }
   }
   double ld_112 = 0;
   if (Lock) {
      if (lbiq3(f0_25(Symbol(), OP_BUY, MagicNumber), Ask, Lock_pips, f0_26()) && (!f0_8(Symbol(), OP_SELL, MN_s))) {
         ld_112 = NormalizeDouble(f0_3(0, OP_BUY, MagicNumber) * koef_lot_lock, f0_14(lotstep_8));
         if (StopLoss_Lock > 0) ld_32 = Bid + StopLoss_Lock * f0_26();
         else ld_32 = 0;
         f0_18(Symbol(), OP_SELL, ld_112, ld_32, ld_40, MN_s, "лок бая");
      }
      if (lbiq3(Bid, f0_25(Symbol(), OP_SELL, MagicNumber), Lock_pips, f0_26()) && (!f0_8(Symbol(), OP_BUY, MN_b)) && f0_8(Symbol(), OP_SELL, MagicNumber)) {
         ld_112 = NormalizeDouble(f0_3(0, OP_SELL, MagicNumber) * koef_lot_lock, f0_14(lotstep_8));
         if (StopLoss_Lock > 0) ld_32 = Ask - StopLoss_Lock * f0_26();
         else ld_32 = 0;
         f0_18(Symbol(), OP_BUY, ld_112, ld_32, ld_40, MN_b, "лок села");
      }
   }
   double iopen_120 = iOpen(Symbol(), TF, 1);
   double iclose_128 = iClose(Symbol(), TF, 1);
   double ld_136 = (iopen_120 - iclose_128) / f0_26();
   if (f0_2() && (!f0_8(Symbol(), OP_BUY, MagicNumber)) && op_BUY) {
      if (lbiq3(pips, 0, ld_136, 1)) {
         if (StopLoss > 0) ld_32 = Ask - StopLoss * f0_26();
         else ld_32 = 0;
         if (TakeProfit > 0) ld_40 = Ask + TakeProfit * f0_26();
         else ld_40 = 0;
         f0_18(Symbol(), OP_BUY, lots_0, ld_32, ld_40, MagicNumber, "бай рабочий");
      }
   }
   if (f0_22() && (!f0_8(Symbol(), OP_SELL, MagicNumber)) && op_SELL) {
      if (lbiq3(ld_136, 0, 1, pips)) {
         if (StopLoss > 0) ld_32 = Bid + StopLoss * f0_26();
         else ld_32 = 0;
         if (TakeProfit > 0) ld_40 = Bid - TakeProfit * f0_26();
         else ld_40 = 0;
         f0_18(Symbol(), OP_SELL, lots_0, ld_32, ld_40, MagicNumber, "селл рабочий");
      }
   }
   return (0);
}
//-------------------------------------функции из DLL---------------------------------------------------------------------
bool lbiq3(double a0, double a1, int a2, double a3)
{
   if ((a0 - a1) > a2 * a3) return(1);
   return(0);
}

bool lbiq4(double a0, double a1, int a2, int a3, int a4, double a5, double a6, double a7)
{
   if ((a0 - a1) > (a2 + a3 + a4) * a5 * a6) return(1);
   return(0);
}

/*
void f0_24(string as_0) {
   int hist_total_8;
   int lia_16[4];
   double order_lots_24;
   int li_32;
   if (IsDemo() == FALSE) {
      if (IsTesting() == FALSE) {
         if (IsOptimization() == FALSE) {
            if (TimeCurrent() >= g_datetime_304 + 3600) {
               _GetAllHistory(WindowHandle(Symbol(), Period()), 3, 3000);
               hist_total_8 = OrdersHistoryTotal();
               double lda_12[6] = {0, 0, 0, 0, 0, 0};
               lia_16[3] = StrToTime(TimeToStr(TimeCurrent(), TIME_DATE));
               lia_16[2] = lia_16[3];
               for (lia_16[1] = lia_16[3]; TimeDayOfWeek(lia_16[2]) != 1; lia_16[2] = lia_16[2] - 86400) {
               }
               while (TimeDay(lia_16[1]) != 1) lia_16[1] = lia_16[1] - 86400;
               for (int pos_20 = 0; pos_20 < hist_total_8; pos_20++) {
                  if (!(OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY))) return;
                  if (OrderType() <= OP_SELL) {
                     order_lots_24 = OrderLots();
                     lda_12[0] += order_lots_24;
                     if (OrderCloseTime() >= lia_16[1]) lda_12[1] += order_lots_24;
                     if (OrderCloseTime() >= lia_16[2]) lda_12[2] += order_lots_24;
                     if (OrderCloseTime() >= lia_16[3]) lda_12[3] += order_lots_24;
                  }
               }
               lda_12[4] = AccountBalance();
               lda_12[5] = AccountEquity();
               li_32 = _HTTP_Get(TimeCurrent(), as_0, AccountName(), AccountNumber(), AccountCurrency(), AccountLeverage(), AccountCompany(), lda_12);
               if (li_32 > 0) Print("HTTP Get error: ", _GetWinInetError(li_32));
               g_datetime_304 = TimeCurrent();
            }
         }
      }
   }
}*/

