
#property copyright "Copyright © 2011, Forex Cleaner Group."
#property link      "http://www.forexcleaner.com"

//#import "experts/libraries/forexcleaner.dll"
   //string connect_domain(string a0);
   //int tr(double a0, double a1, double a2, double a3, double a4, double a5, double a6, double a7, double a8);
//#import

//extern string passphrase = "License code";
extern int Magic = 12345;
extern string Order_Comment = "Forex Cleaner";
extern int Slippage = 2;
extern bool Stealth = TRUE;
extern bool MM = TRUE;
extern double lot = 0.2;

extern double Risk = 2.0; //Процент риска.
//--- При AutoMM = 20 и депозите в 1000$, лот будет равен 0,2. Далее лот будет увеличиваться исходя из свободных средств, то есть уже при депозите в 2000$ лот будет равен 0,4.
extern double Risk_Max = 30.0; //--- Максимальный риск

double g_str2int_124;
double g_str2dbl_132;
double g_str2int_140;
double g_str2int_148;
double gd_unused_156;
double gd_unused_164 = 0.0;
double gd_unused_172 = 0.0;
double gd_unused_180 = 0.0;
double gd_188 = 0.0;
bool gi_196 = FALSE;
double gd_200 = 222100.0;
int g_datetime_208;
int gi_212 = 0;
int g_time_216 = 0;

int init() {
   
   g_str2int_124 = 11;
   g_str2dbl_132 = 0.8;
   g_str2int_140 = 23;
   g_str2int_148 = 16;
   gd_unused_156 = 5;
   g_datetime_208 = TimeCurrent();
   
   
   //if (f0_13() == -1) return (-1);
   gi_212 = TRUE;
   f0_6();
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   string ls_0;
   double ld_16;
   if (gi_212 == FALSE) return (-1);
   //if ((!IsOptimization()) && !IsTesting())
      //if (f0_16() == -1) return (-1);
   if ((!IsOptimization()) && !IsTesting()) f0_3();
   if (f0_15() == 0) return (0);
   if (gd_200 == 222111.0) return (0);
   if (TimeCurrent() - g_datetime_208 > 1800 && (!IsOptimization()) && (!IsTesting())) {
      f0_6();
      g_datetime_208 = TimeCurrent();
   }
   if (Digits == 5 || Digits == 3) ld_16 = 10.0 * Point;
   else ld_16 = Point;
   int li_24 = f0_8();
   int li_28 = f0_2();
   f0_10(li_28);
   if (li_28 == 0) {
      gi_196 = FALSE;
      if (MM == TRUE) lot = f0_0();
      if (Stealth == FALSE) {
         if (li_24 == 1) {
            f0_14(Symbol(), 0, lot, NormalizeDouble(Ask, Digits), Slippage, 0, 0, Order_Comment, Magic, 0, Blue);
            Sleep(3000);
            f0_4();
         }
         if (li_24 == 2) {
            f0_14(Symbol(), 1, lot, NormalizeDouble(Bid, Digits), Slippage, 0, 0, Order_Comment, Magic, 0, Red);
            Sleep(3000);
            f0_4();
         }
      } else {
         if (li_24 == 1) f0_14(Symbol(), 0, lot, NormalizeDouble(Ask, Digits), Slippage, 0, 0, Order_Comment, Magic, 0, Blue);
         if (li_24 == 2) f0_14(Symbol(), 1, lot, NormalizeDouble(Bid, Digits), Slippage, 0, 0, Order_Comment, Magic, 0, Red);
      }
   }
   if (gi_196 == TRUE) f0_11();
   if (li_28 > 0) {
      if ((!IsOptimization()) && !IsTesting()) f0_12();
      f0_7();
   }
   return (0);
}

int f0_15() {
   if (g_time_216 != Time[0]) {
      g_time_216 = Time[0];
      return (1);
   }
   return (0);
}

int f0_8() {
   double ld_0;
   if (Digits == 5 || Digits == 3) ld_0 = 10.0 * Point;
   else ld_0 = Point;
   double ibands_8 = iBands(NULL, 0, g_str2int_124, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double ibands_16 = iBands(NULL, 0, g_str2int_124, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   if (ibands_8 - ibands_16 < g_str2int_148 * ld_0) return (0);
   double iopen_24 = iOpen(NULL, 0, 1);
   double iclose_32 = iClose(NULL, 0, 1);
   //double ld_ret_40 = tr(ibands_8, ibands_16, iopen_24, iclose_32, 0, 5, 6, 3, 4);
   if ( (ibands_16 < iclose_32) && (ibands_16 > iopen_24) ) {return(1);}
    else {
      if ( (ibands_8 > iclose_32) && (ibands_8 < iopen_24) ) {return(2);}
       else {return(0);}
   }
}

int f0_1() {
   double ibands_0 = iBands(NULL, 0, g_str2int_140, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double ibands_8 = iBands(NULL, 0, g_str2int_140, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double iopen_16 = iOpen(NULL, 0, 1);
   double iclose_24 = iClose(NULL, 0, 1);
   if (Close[2] > ibands_0 && Close[1] < ibands_0) return (1);
   if (Close[2] < ibands_8 && Close[1] > ibands_8) return (2);
   return (0);
}

int f0_11() {
   int li_4 = f0_1();
   for (int pos_0 = OrdersTotal() - 1; pos_0 > -1; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_BUY && OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         if (li_4 == 1) f0_17(OrderTicket(), OrderLots(), Bid, Slippage, Violet);
         gi_196 = FALSE;
         return (0);
      }
      if (OrderType() == OP_SELL && OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         if (li_4 == 2) f0_17(OrderTicket(), OrderLots(), Ask, Slippage, Violet);
         gi_196 = FALSE;
         return (0);
      }
   }
   gi_196 = FALSE;
   return (0);
}

int f0_7() {
   double ld_4;
   if (Digits == 5 || Digits == 3) ld_4 = 10.0 * Point;
   else ld_4 = Point;
   double ibands_12 = iBands(NULL, 0, g_str2int_140, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double ibands_20 = iBands(NULL, 0, g_str2int_140, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   for (int pos_0 = OrdersTotal() - 1; pos_0 > -1; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_BUY && OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         if (OrderOpenPrice() - Bid >= gd_188 * ld_4 && Stealth == TRUE) f0_17(OrderTicket(), OrderLots(), Bid, Slippage, Violet);
         gi_196 = FALSE;
         return (0);
      }
      if (OrderType() == OP_SELL && OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         if (Ask - OrderOpenPrice() >= gd_188 * ld_4 && Stealth == TRUE) f0_17(OrderTicket(), OrderLots(), Ask, Slippage, Violet);
         gi_196 = FALSE;
         return (0);
      }
   }
   gi_196 = FALSE;
   return (0);
}

void f0_12() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 > -1; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_BUY && OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         if (OrderProfit() > 0.0 && gd_200 == 222222.0) {
            f0_17(OrderTicket(), OrderLots(), Bid, Slippage, Violet);
            gi_196 = FALSE;
            return;
         }
         if (OrderProfit() < 0.0 && gd_200 == 222333.0) {
            f0_17(OrderTicket(), OrderLots(), Bid, Slippage, Violet);
            gi_196 = FALSE;
            return;
         }
         if (gd_200 == 222444.0) {
            f0_17(OrderTicket(), OrderLots(), Bid, Slippage, Violet);
            gi_196 = FALSE;
            return;
         }
      }
      if (OrderType() == OP_SELL && OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         if (OrderProfit() > 0.0 && gd_200 == 222222.0) {
            f0_17(OrderTicket(), OrderLots(), Ask, Slippage, Violet);
            gi_196 = FALSE;
            return;
         }
         if (OrderProfit() < 0.0 && gd_200 == 222333.0) {
            f0_17(OrderTicket(), OrderLots(), Ask, Slippage, Violet);
            gi_196 = FALSE;
            return;
         }
         if (gd_200 == 222444.0) {
            f0_17(OrderTicket(), OrderLots(), Ask, Slippage, Violet);
            gi_196 = FALSE;
            return;
         }
      }
   }
}

double f0_0() {
   //--- Параметры для автолота
   double MinLot = 0.01;
   double MaxLot = 0.01;
   double LotStep = 0.01;
   int LotValue = 100000;
   double FreeMargin = 1000.0;
   double LotPrice = 1;
   double LotSize;

   MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   LotValue = MarketInfo(Symbol(), MODE_LOTSIZE);
   LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   FreeMargin = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   
   lot = MathMax(MinLot, MathMin(MaxLot, MathCeil(MathMin(Risk_Max, Risk) / LotPrice / 100.0 * AccountFreeMargin() / LotStep / (LotValue / 100)) * LotStep));
   
   return (lot);
}

int f0_2() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) count_0++;
   }
   return (count_0);
}

void f0_10(int ai_0) {
   if (ai_0 == 0) gi_196 = FALSE;
   if (gi_196 == FALSE && ai_0 > 0 && f0_1() > 0) gi_196 = TRUE;
}

int f0_13() {
   string ls_8 = Symbol();
   if (!IsDllsAllowed()) {
      Comment("ERROR: DLL import failed. Please read the documentation in order to configure your MT4 correctly.");
      Print("ERROR: DLL import failed. Please read the documentation in order to configure your MT4 correctly.");
      return (-1);
   }
   if (StringFind(ls_8, "EURUSD", 0) < 0) {
      Comment("ERROR: Forex Cleaner runs on EURUSD only. Please attach it to EURUSD, M30 chart.");
      Print("ERROR: Forex Cleaner runs on EURUSD only. Please attach it to EURUSD, M30 chart.");
      return (-1);
   }
  if (Period() != PERIOD_M30) {
      Comment("ERROR: Please attach Forex Cleaner to EURUSD, M30 chart.");
      Print("ERROR: Please attach Forex Cleaner to EURUSD, M30 chart.");
      return (-1);
   }
   Comment("Everything looks fine, Forex Cleaner is ready to go!");
   Print("Everything looks fine, Forex Cleaner is ready to go!");
   return (0);
}

int f0_16() {
   
   string ls_8 = Symbol();
   if (!IsDllsAllowed()) {
      Comment("ERROR: DLL import failed. Please read the documentation in order to configure your MT4 correctly.");
      Print("ERROR: DLL import failed. Please read the documentation in order to configure your MT4 correctly.");
      return (-1);
   }
   if (StringFind(ls_8, "EURUSD", 0) < 0) {
      Comment("ERROR: Forex Cleaner runs on EURUSD only. Please attach it to EURUSD, M30 chart.");
      Print("ERROR: Forex Cleaner runs on EURUSD only. Please attach it to EURUSD, M30 chart.");
      return (-1);
   }
   if (Period() != PERIOD_M30) {
      Comment("ERROR: Please attach Forex Cleaner to EURUSD, M30 chart.");
      Print("ERROR: Please attach Forex Cleaner to EURUSD, M30 chart.");
      return (-1);
   }
   return (0);
}

int f0_3() {
   double spread_0 = MarketInfo(Symbol(), MODE_SPREAD);
   double digits_8 = Digits;
   double minlot_16 = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot_24 = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotstep_32 = MarketInfo(Symbol(), MODE_LOTSTEP);
   Comment("\n\nFOREX CLEANER is up and running, no errors detected!\n\nSpread: ", spread_0, 
      "\nNumber of digits: ", digits_8, 
      "\nMinimum lot allowed: ", minlot_16, 
      "\nMaximum lot allowed: ", maxlot_24, 
      "\nStep for changing lots: ", lotstep_32, 
      "\nBid: ", Bid, 
      "\nAsk: ", Ask, 
   "\n\nFor any questions, suggestions or advices please contact the vendor.\n\n");
   return (0);
}

int f0_14(string a_symbol_0, int ai_8, double a_lots_12, double ad_unused_20, int a_slippage_28, double ad_32, double ad_40, string a_comment_48 = "", int a_magic_56 = 0, int a_datetime_60 = 0, color a_color_64 = -1) {
   int ticket_80;
   int ticket_84;
   int li_unused_68 = MarketInfo(a_symbol_0, MODE_STOPLEVEL);
   double ld_unused_72 = 0;
   int count_88 = 0;
   switch (ai_8) {
   case 0:
      if ((!IsTradeContextBusy()) && IsTradeAllowed()) {
         while (count_88 < 5) {
            RefreshRates();
            ticket_80 = OrderSend(a_symbol_0, OP_BUY, a_lots_12, Ask, a_slippage_28, NormalizeDouble(ad_32, Digits), NormalizeDouble(ad_40, Digits), a_comment_48, a_magic_56,
               a_datetime_60, a_color_64);
            if (ticket_80 <= 0) {
               Print("Error Occured : " + f0_9(GetLastError()));
               count_88++;
            } else count_88 = 5;
            Sleep(5000);
         }
      }
      ticket_84 = ticket_80;
      break;
   case 1:
      if ((!IsTradeContextBusy()) && IsTradeAllowed()) {
         while (count_88 < 5) {
            RefreshRates();
            ticket_80 = OrderSend(a_symbol_0, OP_SELL, a_lots_12, Bid, a_slippage_28, NormalizeDouble(ad_32, Digits), NormalizeDouble(ad_40, Digits), a_comment_48, a_magic_56,
               a_datetime_60, a_color_64);
            if (ticket_80 <= 0) {
               Print("Error Occured : " + f0_9(GetLastError()));
               count_88++;
            } else count_88 = 5;
            Sleep(5000);
         }
      }
      ticket_84 = ticket_80;
      break;
   default:
      ticket_84 = -1;
   }
   return (ticket_84);
}

int f0_17(int a_ticket_0, double a_lots_4, double ad_12, int a_slippage_20, color a_color_24 = -1) {
   int is_closed_36;
   double ld_unused_28 = 0;
   int count_44 = 0;
   if ((!IsTradeContextBusy()) && IsTradeAllowed()) {
      while (count_44 < 5) {
         RefreshRates();
         is_closed_36 = OrderClose(a_ticket_0, a_lots_4, NormalizeDouble(ad_12, Digits), a_slippage_20, a_color_24);
         if (is_closed_36 == 0) {
            Print("Error Occured : " + f0_9(GetLastError()));
            count_44++;
         } else count_44 = 5;
         Sleep(5000);
      }
   }
   int is_closed_40 = is_closed_36;
   return (is_closed_40);
}

int f0_4() {
   bool bool_8;
   bool bool_12;
   int count_16;
   double ld_24;
   double ld_unused_0 = 0;
   if (Digits == 5 || Digits == 3) ld_24 = 10.0 * Point;
   else ld_24 = Point;
   for (int pos_20 = OrdersTotal() - 1; pos_20 > -1; pos_20--) {
      OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         count_16 = 0;
         if ((!IsTradeContextBusy()) && IsTradeAllowed()) {
            while (count_16 < 5) {
               RefreshRates();
               if (OrderType() == OP_BUY) bool_8 = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() - gd_188 * ld_24, Digits), OrderTakeProfit(), 0, CLR_NONE);
               if (OrderType() == OP_SELL) bool_8 = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() + gd_188 * ld_24, Digits), OrderTakeProfit(), 0, CLR_NONE);
               if (bool_8 == FALSE) {
                  Print("Error Occured : " + f0_9(GetLastError()));
                  count_16++;
               } else count_16 = 5;
               Sleep(5000);
            }
         }
         bool_12 = bool_8;
         return (bool_12);
      }
   }
   return (0);
}

string f0_9(int ai_0) {
   string ls_ret_4;
   switch (ai_0) {
   case 0:
   case 1:
      ls_ret_4 = "no error";
      break;
   case 2:
      ls_ret_4 = "common error";
      break;
   case 3:
      ls_ret_4 = "invalid trade parameters";
      break;
   case 4:
      ls_ret_4 = "trade server is busy";
      break;
   case 5:
      ls_ret_4 = "old version of the client terminal";
      break;
   case 6:
      ls_ret_4 = "no connection with trade server";
      break;
   case 7:
      ls_ret_4 = "not enough rights";
      break;
   case 8:
      ls_ret_4 = "too frequent requests";
      break;
   case 9:
      ls_ret_4 = "malfunctional trade operation";
      break;
   case 64:
      ls_ret_4 = "account disabled";
      break;
   case 65:
      ls_ret_4 = "invalid account";
      break;
   case 128:
      ls_ret_4 = "trade timeout";
      break;
   case 129:
      ls_ret_4 = "invalid price";
      break;
   case 130:
      ls_ret_4 = "invalid stops";
      break;
   case 131:
      ls_ret_4 = "invalid trade volume";
      break;
   case 132:
      ls_ret_4 = "market is closed";
      break;
   case 133:
      ls_ret_4 = "trade is disabled";
      break;
   case 134:
      ls_ret_4 = "not enough money";
      break;
   case 135:
      ls_ret_4 = "price changed";
      break;
   case 136:
      ls_ret_4 = "off quotes";
      break;
   case 137:
      ls_ret_4 = "broker is busy";
      break;
   case 138:
      ls_ret_4 = "requote";
      break;
   case 139:
      ls_ret_4 = "order is locked";
      break;
   case 140:
      ls_ret_4 = "long positions only allowed";
      break;
   case 141:
      ls_ret_4 = "too many requests";
      break;
   case 145:
      ls_ret_4 = "modification denied because order too close to market";
      break;
   case 146:
      ls_ret_4 = "trade context is busy";
      break;
   case 4000:
      ls_ret_4 = "no error";
      break;
   case 4001:
      ls_ret_4 = "wrong function pointer";
      break;
   case 4002:
      ls_ret_4 = "array index is out of range";
      break;
   case 4003:
      ls_ret_4 = "no memory for function call stack";
      break;
   case 4004:
      ls_ret_4 = "recursive stack overflow";
      break;
   case 4005:
      ls_ret_4 = "not enough stack for parameter";
      break;
   case 4006:
      ls_ret_4 = "no memory for parameter string";
      break;
   case 4007:
      ls_ret_4 = "no memory for temp string";
      break;
   case 4008:
      ls_ret_4 = "not initialized string";
      break;
   case 4009:
      ls_ret_4 = "not initialized string in array";
      break;
   case 4010:
      ls_ret_4 = "no memory for array\' string";
      break;
   case 4011:
      ls_ret_4 = "too long string";
      break;
   case 4012:
      ls_ret_4 = "remainder from zero divide";
      break;
   case 4013:
      ls_ret_4 = "zero divide";
      break;
   case 4014:
      ls_ret_4 = "unknown command";
      break;
   case 4015:
      ls_ret_4 = "wrong jump (never generated error)";
      break;
   case 4016:
      ls_ret_4 = "not initialized array";
      break;
   case 4017:
      ls_ret_4 = "dll calls are not allowed";
      break;
   case 4018:
      ls_ret_4 = "cannot load library";
      break;
   case 4019:
      ls_ret_4 = "cannot call function";
      break;
   case 4020:
      ls_ret_4 = "expert function calls are not allowed";
      break;
   case 4021:
      ls_ret_4 = "not enough memory for temp string returned from function";
      break;
   case 4022:
      ls_ret_4 = "system is busy (never generated error)";
      break;
   case 4050:
      ls_ret_4 = "invalid function parameters count";
      break;
   case 4051:
      ls_ret_4 = "invalid function parameter value";
      break;
   case 4052:
      ls_ret_4 = "string function internal error";
      break;
   case 4053:
      ls_ret_4 = "some array error";
      break;
   case 4054:
      ls_ret_4 = "incorrect series array using";
      break;
   case 4055:
      ls_ret_4 = "custom indicator error";
      break;
   case 4056:
      ls_ret_4 = "arrays are incompatible";
      break;
   case 4057:
      ls_ret_4 = "global variables processing error";
      break;
   case 4058:
      ls_ret_4 = "global variable not found";
      break;
   case 4059:
      ls_ret_4 = "function is not allowed in testing mode";
      break;
   case 4060:
      ls_ret_4 = "function is not confirmed";
      break;
   case 4061:
      ls_ret_4 = "send mail error";
      break;
   case 4062:
      ls_ret_4 = "string parameter expected";
      break;
   case 4063:
      ls_ret_4 = "integer parameter expected";
      break;
   case 4064:
      ls_ret_4 = "double parameter expected";
      break;
   case 4065:
      ls_ret_4 = "array as parameter expected";
      break;
   case 4066:
      ls_ret_4 = "requested history data in update state";
      break;
   case 4099:
      ls_ret_4 = "end of file";
      break;
   case 4100:
      ls_ret_4 = "some file error";
      break;
   case 4101:
      ls_ret_4 = "wrong file name";
      break;
   case 4102:
      ls_ret_4 = "too many opened files";
      break;
   case 4103:
      ls_ret_4 = "cannot open file";
      break;
   case 4104:
      ls_ret_4 = "incompatible access to a file";
      break;
   case 4105:
      ls_ret_4 = "no order selected";
      break;
   case 4106:
      ls_ret_4 = "unknown symbol";
      break;
   case 4107:
      ls_ret_4 = "invalid price parameter for trade function";
      break;
   case 4108:
      ls_ret_4 = "invalid ticket";
      break;
   case 4109:
      ls_ret_4 = "trade is not allowed";
      break;
   case 4110:
      ls_ret_4 = "longs are not allowed";
      break;
   case 4111:
      ls_ret_4 = "shorts are not allowed";
      break;
   case 4200:
      ls_ret_4 = "object is already exist";
      break;
   case 4201:
      ls_ret_4 = "unknown object property";
      break;
   case 4202:
      ls_ret_4 = "object is not exist";
      break;
   case 4203:
      ls_ret_4 = "unknown object type";
      break;
   case 4204:
      ls_ret_4 = "no object name";
      break;
   case 4205:
      ls_ret_4 = "object coordinates error";
      break;
   case 4206:
      ls_ret_4 = "no specified subwindow";
      break;
   default:
      ls_ret_4 = "unknown error";
   }
   return (ls_ret_4);
}

void f0_6() {
   gd_unused_172 = 58;
   gd_unused_180 = 14;
   gd_unused_164 = 120;
   gd_188 = 135;
   gd_200 = 222100;
}


