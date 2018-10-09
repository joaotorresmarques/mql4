
#property copyright "Copyright © 2013, euronis-free.com"
#property link      "euronis-free.com"

//int g_acc_number_76 =
double g_maxlot_80 = 0.0;
string gs_88 = "AP_v.3.0";
double gd_96 = 2.0;
string gs_104 = "AutoP_v.3.0";
int gi_unused_112 = 1;
extern string __1__ = " Martingale 1 - on. 2 - off.";
extern int MMType = 1;
bool gi_128 = TRUE;
extern string __2__ = "Modifier next lot";
extern double LotMultiplikator = 1.667;
double gd_148;
double g_slippage_156 = 5.0;
extern string __3__ = "initial lot:";
extern string _____ = "true - permanent, false - deposit";
extern bool LotConst_or_not = FALSE;
extern double Lot = 0.01;
extern double RiskPercent = 30.0;
double gd_200;
extern string __4__ = "profit in pips - ТР";
extern double TakeProfit = 5.0;
double gd_224;
double g_pips_232 = 0.0;
double gd_240 = 10.0;
double gd_248 = 10.0;
extern string __5__ = "distance in pips";
extern double Step = 5.0;
double gd_272;
extern string __6__ = "МАX trades";
extern int MaxTrades = 30;
extern string __7__ = "limit losses";
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
bool gi_312 = FALSE;
bool gi_316 = FALSE;
bool gi_320 = FALSE;
double gd_324 = 48.0;
bool gi_332 = FALSE;
int gi_336 = 2;
int gi_340 = 16;
extern string __8__ = "order identifier";
extern int Magic = 1111111;
int gi_356;
extern string __9__ = "logo and output";
extern bool ShowTableOnTesting = TRUE;
extern string _ = "(true-on.,false-off.)";
double g_price_380;
double gd_388;
double gd_unused_396;
double gd_unused_404;
double g_price_412;
double g_bid_420;
double g_ask_428;
double gd_436;
double gd_444;
double gd_452;
bool gi_460;
int g_time_464 = 0;
int gi_468;
int gi_472 = 0;
double gd_476;
int g_pos_484 = 0;
int gi_488;
double gd_492 = 0.0;
bool gi_500 = FALSE;
bool gi_504 = FALSE;
bool gi_508 = FALSE;
int gi_512;
bool gi_516 = FALSE;
int g_datetime_520 = 0;
int g_datetime_524 = 0;
double gd_528;
double gd_536;
int g_fontsize_544 = 14;
int g_color_548 = Gold;
int g_color_552 = Orange;
int g_color_556 = Gray;
int gi_unused_560 = 5197615;

int init() {
   gd_452 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   if (IsTesting() == TRUE) f0_9();
   if (IsTesting() == FALSE) f0_9();
   return (0);
}

int deinit() {
   return (0);
}

int start() {
if(AccountNumber() !=123456) {Comment("No license for your account. Write on support@euronis-free.com"); return(0);}
   double order_lots_52;
   double order_lots_60;
   double iclose_68;
   double iclose_76;
   int li_unused_0 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   int li_unused_4 = MarketInfo(Symbol(), MODE_SPREAD);
   double point_8 = MarketInfo(Symbol(), MODE_POINT);
   double bid_16 = MarketInfo(Symbol(), MODE_BID);
   double ask_24 = MarketInfo(Symbol(), MODE_ASK);
   int li_unused_32 = MarketInfo(Symbol(), MODE_DIGITS);
   if (g_maxlot_80 == 0.0) g_maxlot_80 = MarketInfo(Symbol(), MODE_MAXLOT);
   double minlot_36 = MarketInfo(Symbol(), MODE_MINLOT);
   double lotstep_44 = MarketInfo(Symbol(), MODE_LOTSTEP);
  /* if (AccountNumber() != g_acc_number_76 && (!IsDemo())) {
      Comment("Советник может работать только на счёте " + g_acc_number_76 + ", для бесплатного подключения к другому счёту перейдите на сайт invest-system.net");
      Sleep(1000);
      Print("Советник может работать только на счёте " + g_acc_number_76 + ", для подключения к другому счёту проидите на сайт invest-system.net");
      return;
   }*/
   if (((!IsOptimization()) && !IsTesting() && (!IsVisualMode())) || (ShowTableOnTesting && IsTesting() && (!IsOptimization()))) {
      f0_13();
      f0_10();
   }
   if (LotConst_or_not) gd_200 = Lot;
   else gd_200 = AccountBalance() * RiskPercent / 100.0 / 10000.0;
   if (gd_200 < minlot_36) Print("Estimated lot  " + gd_200 + "  less than the minimum trading  " + minlot_36);
   if (gd_200 > g_maxlot_80 && g_maxlot_80 > 0.0) Print("Estimated lot  " + gd_200 + "  more than the maximum allowed for trade  " + g_maxlot_80);
   gd_148 = LotMultiplikator;
   gd_224 = TakeProfit;
   gd_272 = Step;
   gi_356 = Magic;
   string ls_84 = "false";
   string ls_92 = "false";
   if (gi_332 == FALSE || (gi_332 && (gi_340 > gi_336 && (Hour() >= gi_336 && Hour() <= gi_340)) || (gi_336 > gi_340 && (!(Hour() >= gi_340 && Hour() <= gi_336))))) ls_84 = "true";
   if (gi_332 && (gi_340 > gi_336 && (!(Hour() >= gi_336 && Hour() <= gi_340))) || (gi_336 > gi_340 && (Hour() >= gi_340 && Hour() <= gi_336))) ls_92 = "true";
   if (gi_316) f0_18(gd_240, gd_248, g_price_412);
   if (gi_320) {
      if (TimeCurrent() >= gi_468) {
         f0_3();
         Print("Closed All due to TimeOut");
      }
   }
   if (g_time_464 == Time[0]) return (0);
   g_time_464 = Time[0];
   double ld_100 = f0_5();
   if (UseEquityStop) {
      if (ld_100 < 0.0 && MathAbs(ld_100) > TotalEquityRisk / 100.0 * f0_7()) {
         f0_3();
         Print("Closed All due to Stop Out");
         gi_516 = FALSE;
      }
   }
   gi_488 = f0_16();
   if (gi_488 == 0) gi_460 = FALSE;
   for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
      OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
         if (OrderType() == OP_BUY) {
            gi_504 = TRUE;
            gi_508 = FALSE;
            order_lots_52 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
         if (OrderType() == OP_SELL) {
            gi_504 = FALSE;
            gi_508 = TRUE;
            order_lots_60 = OrderLots();
            break;
         }
      }
   }
   if (gi_488 > 0 && gi_488 <= MaxTrades) {
      RefreshRates();
      gd_436 = f0_2();
      gd_444 = f0_6();
      if (gi_504 && gd_436 - Ask >= gd_272 * Point) gi_500 = TRUE;
      if (gi_508 && Bid - gd_444 >= gd_272 * Point) gi_500 = TRUE;
   }
   if (gi_488 < 1) {
      gi_508 = FALSE;
      gi_504 = FALSE;
      gi_500 = TRUE;
      gd_388 = AccountEquity();
   }
   if (gi_500) {
      gd_436 = f0_2();
      gd_444 = f0_6();
      if (gi_508) {
         if (gi_312 || ls_92 == "true") {
            f0_1(0, 1);
            gd_476 = NormalizeDouble(gd_148 * order_lots_60, gd_96);
         } else gd_476 = f0_14(OP_SELL);
         if (gi_128 && ls_84 == "true") {
            gi_472 = gi_488;
            if (gd_476 > 0.0) {
               RefreshRates();
               gi_512 = f0_15(1, gd_476, Bid, g_slippage_156, Ask, 0, 0, Symbol() + "-" + gs_88 + "-" + gi_472, gi_356, 0, HotPink);
               if (gi_512 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_444 = f0_6();
               gi_500 = FALSE;
               gi_516 = TRUE;
            }
         }
      } else {
         if (gi_504) {
            if (gi_312 || ls_92 == "true") {
               f0_1(1, 0);
               gd_476 = NormalizeDouble(gd_148 * order_lots_52, gd_96);
            } else gd_476 = f0_14(OP_BUY);
            if (gi_128 && ls_84 == "true") {
               gi_472 = gi_488;
               if (gd_476 > 0.0) {
                  gi_512 = f0_15(0, gd_476, Ask, g_slippage_156, Bid, 0, 0, Symbol() + "-" + gs_88 + "-" + gi_472, gi_356, 0, Lime);
                  if (gi_512 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  gd_436 = f0_2();
                  gi_500 = FALSE;
                  gi_516 = TRUE;
               }
            }
         }
      }
   }
   if (gi_500 && gi_488 < 1) {
      iclose_68 = iClose(Symbol(), 0, 2);
      iclose_76 = iClose(Symbol(), 0, 1);
      g_bid_420 = Bid;
      g_ask_428 = Ask;
      if ((!gi_508) && !gi_504 && ls_84 == "true") {
         gi_472 = gi_488;
         if (iclose_68 > iclose_76) {
            gd_476 = f0_14(OP_SELL);
            if (gd_476 > 0.0) {
               gi_512 = f0_15(1, gd_476, g_bid_420, g_slippage_156, g_bid_420, 0, 0, Symbol() + "-" + gs_88 + "-" + gi_472, gi_356, 0, HotPink);
               if (gi_512 < 0) {
                  Print(gd_476, "Error: ", GetLastError());
                  return (0);
               }
               gd_436 = f0_2();
               gi_516 = TRUE;
            }
         } else {
            gd_476 = f0_14(OP_BUY);
            if (gd_476 > 0.0) {
               gi_512 = f0_15(0, gd_476, g_ask_428, g_slippage_156, g_ask_428, 0, 0, Symbol() + "-" + gs_88 + "-" + gi_472, gi_356, 0, Lime);
               if (gi_512 < 0) {
                  Print(gd_476, "Error: ", GetLastError());
                  return (0);
               }
               gd_444 = f0_6();
               gi_516 = TRUE;
            }
         }
      }
      if (gi_512 > 0) gi_468 = TimeCurrent() + 60.0 * (60.0 * gd_324);
      gi_500 = FALSE;
   }
   gi_488 = f0_16();
   g_price_412 = 0;
   double ld_108 = 0;
   for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
      OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_412 += OrderOpenPrice() * OrderLots();
            ld_108 += OrderLots();
         }
      }
   }
   if (gi_488 > 0) g_price_412 = NormalizeDouble(g_price_412 / ld_108, Digits);
   if (gi_516) {
      for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
         OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
            if (OrderType() == OP_BUY) {
               g_price_380 = g_price_412 + gd_224 * Point;
               gd_unused_396 = g_price_380;
               gd_492 = g_price_412 - g_pips_232 * Point;
               gi_460 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
            if (OrderType() == OP_SELL) {
               g_price_380 = g_price_412 - gd_224 * Point;
               gd_unused_404 = g_price_380;
               gd_492 = g_price_412 + g_pips_232 * Point;
               gi_460 = TRUE;
            }
         }
      }
   }
   if (gi_516) {
      if (gi_460 == TRUE) {
         for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
            OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) OrderModify(OrderTicket(), g_price_412, OrderStopLoss(), g_price_380, 0, Yellow);
            gi_516 = FALSE;
         }
      }
   }
   return (0);
}

double f0_11(double ad_0) {
   return (NormalizeDouble(ad_0, Digits));
}

int f0_1(bool ai_0 = TRUE, bool ai_4 = TRUE) {
   int li_ret_8 = 0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      if (OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
            if (OrderType() == OP_BUY && ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), f0_11(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_520 == iTime(NULL, 0, 0)) return (-2);
                  g_datetime_520 = iTime(NULL, 0, 0);
                  Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!(!OrderClose(OrderTicket(), OrderLots(), f0_11(Ask), 5, CLR_NONE))) continue;
                  Print("Error close SELL " + OrderTicket());
                  li_ret_8 = -1;
                  continue;
               }
               if (g_datetime_524 == iTime(NULL, 0, 0)) return (-2);
               g_datetime_524 = iTime(NULL, 0, 0);
               Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
               return (-2);
            }
         }
      }
   }
   return (li_ret_8);
}

double f0_14(int a_cmd_0) {
   double ld_ret_4;
   int datetime_12;
   switch (MMType) {
   case 0:
      ld_ret_4 = gd_200;
      break;
   case 1:
      ld_ret_4 = NormalizeDouble(gd_200 * MathPow(gd_148, gi_472), gd_96);
      break;
   case 2:
      datetime_12 = 0;
      ld_ret_4 = gd_200;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (!(OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY))) return (-3);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
            if (datetime_12 < OrderCloseTime()) {
               datetime_12 = OrderCloseTime();
               if (OrderProfit() < 0.0) {
                  ld_ret_4 = NormalizeDouble(OrderLots() * gd_148, gd_96);
                  continue;
               }
               ld_ret_4 = gd_200;
               continue;
               return (-3);
            }
         }
      }
   }
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0, ld_ret_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (ld_ret_4);
}

int f0_16() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}

void f0_3() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_156, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_156, Red);
         }
         Sleep(1000);
      }
   }
}

int f0_15(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_unused_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 2:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, f0_12(ad_24, g_pips_232), f0_17(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52,
            a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, f0_12(ad_24, g_pips_232), f0_17(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52,
            a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         RefreshRates();
         ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, f0_12(Bid, g_pips_232), f0_17(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, f0_0(ad_24, g_pips_232), f0_4(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52,
            a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, f0_0(ad_24, g_pips_232), f0_4(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52,
            a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_68 = 0; count_68 < li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, f0_0(Ask, g_pips_232), f0_4(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (ticket_60);
}

double f0_12(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double f0_0(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double f0_17(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double f0_4(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double f0_5() {
   double ld_ret_0 = 0;
   for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
      OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

void f0_18(int ai_0, int ai_4, double a_price_8) {
   int li_16;
   double order_stoploss_20;
   double price_28;
   if (ai_4 != 0) {
      for (int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--) {
         if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == gi_356) {
               if (OrderType() == OP_BUY) {
                  li_16 = NormalizeDouble((Bid - a_price_8) / Point, 0);
                  if (li_16 < ai_0) continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Bid - ai_4 * Point;
                  if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20)) OrderModify(OrderTicket(), a_price_8, price_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16 = NormalizeDouble((a_price_8 - Ask) / Point, 0);
                  if (li_16 < ai_0) continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Ask + ai_4 * Point;
                  if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20)) OrderModify(OrderTicket(), a_price_8, price_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double f0_7() {
   if (f0_16() == 0) gd_528 = AccountEquity();
   if (gd_528 < gd_536) gd_528 = gd_536;
   else gd_528 = AccountEquity();
   gd_536 = AccountEquity();
   return (gd_528);
}

double f0_2() {
   double order_open_price_0;
   int ticket_8;
   double ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356 && OrderType() == OP_BUY) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

double f0_6() {
   double order_open_price_0;
   int ticket_8;
   double ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356 && OrderType() == OP_SELL) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

void f0_9() {
   Comment("            AutoProfit v.3.0  " + Symbol() + "  " + Period(), 
      "\n", "            Forex Account Server:", AccountServer(), 
      "\n", "            Lots:  ", gd_200, 
      "\n", "            Symbol: ", Symbol(), 
      "\n", "            Price:  ", NormalizeDouble(Bid, 4), 
      "\n", "            Date: ", Month(), "-", Day(), "-", Year(), " Server Time: ", Hour(), ":", Minute(), ":", Seconds(), 
   "\n");
}

void f0_13() {
   double ld_0 = f0_8(0);
   string name_8 = gs_104 + "1";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText(name_8, "Earnings today: " + DoubleToStr(ld_0, 2), g_fontsize_544, "Courier New", g_color_548);
   ld_0 = f0_8(1);
   name_8 = gs_104 + "2";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 33);
   }
   ObjectSetText(name_8, "Earnings yesterday: " + DoubleToStr(ld_0, 2), g_fontsize_544, "Courier New", g_color_548);
   ld_0 = f0_8(2);
   name_8 = gs_104 + "3";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 51);
   }
   ObjectSetText(name_8, "Earnings before yesterday: " + DoubleToStr(ld_0, 2), g_fontsize_544, "Courier New", g_color_548);
   name_8 = gs_104 + "4";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_8, "Balance : " + DoubleToStr(AccountBalance(), 2), g_fontsize_544, "Courier New", g_color_548);
}

void f0_10() {
   string name_0 = gs_104 + "L_1";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 390);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 10);
   }
   ObjectSetText(name_0, "I N V E S T", 28, "Arial", g_color_552);
   name_0 = gs_104 + "L_2";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
   }
   ObjectSetText(name_0, "  S Y S T E M", 16, "Arial", g_color_552);
   name_0 = gs_104 + "L_3";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 397);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(name_0, "euronis-free.com", 12, "Arial", g_color_556);
   name_0 = gs_104 + "L_4";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 57);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", Gray);
   name_0 = gs_104 + "L_5";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", Gray);
}

double f0_8(int ai_0) {
   double ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersHistoryTotal(); pos_12++) {
      if (!(OrderSelect(pos_12, SELECT_BY_POS, MODE_HISTORY))) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, ai_0) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, ai_0) + 86400) ld_ret_4 = ld_ret_4 + OrderProfit() + OrderCommission() + OrderSwap();
   }
   return (ld_ret_4);
}