
#property copyright "ForexHacked 2.3"
#property link      "http://www.ForexHacked.com"


extern string _________ = "Magic Number Must be UNIQUE for each chart!";
extern int MagicNumber = 133714;
extern double Lots = 0.01;
extern double TakeProfit = 132.0;
extern double Booster = 2.0;
extern int PipStarter = 170;
double gd_124 = 0.0;
int gi_unused_132 = 0;
int gi_136 = 0;
extern int MaxBuyOrders = 9;
extern int MaxSellOrders = 9;
extern bool AllowiStopLoss = FALSE;
extern int iStopLoss = 300;
extern int StartHour = 0;
extern int StartMinute = 0;
extern int StopHour = 23;
extern int StopMinute = 55;
extern int StartingTradeDay = 0;
extern int EndingTradeDay = 7;
extern int slippage = 3;
extern bool allowTrending = TRUE;
extern int trendTrigger = 3;
extern int trendPips = 5;
extern int trendStoploss = 5;
int gi_200 = 5000;
int gi_204 = 0;
int gi_208 = 0;
extern double StopLossPct = 100.0;
extern double TakeProfitPct = 100.0;
extern bool PauseNewTrades = FALSE;
extern int StoppedOutPause = 600;
double gd_236;
bool gi_252;
int g_period_256 = 7;
int gi_260 = 0;
int g_ma_method_264 = MODE_LWMA;
int g_applied_price_268 = PRICE_WEIGHTED;
double gd_272 = 0.25;
double gd_280 = 0.2;
extern bool SupportECN = TRUE;
extern bool MassHedge = FALSE;
extern double MassHedgeBooster = 1.01;
extern int TradesDeep = 5;
extern string EA_Name = "ForexHacked 2.2";
int g_datetime_316;
double g_point_320;
int gi_328;
bool gi_unused_332 = FALSE;
string gs_dummy_336;
int gi_344;
int gi_348;
int gi_352 = 0;
int gi_356 = 1;
int gi_unused_360 = 3;
int gi_364 = 250;
string gs_368;
bool gi_376;
bool gi_380;
bool gi_384;
bool gi_388;
int g_ticket_392;
int g_cmd_396;
string gs__hedged_400 = " hedged";
int g_file_408;

void Log(string as_0) {
   if (g_file_408 >= 0) FileWrite(g_file_408, TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + ": " + as_0);
}

int GetLotDigits() {
   double ld_4 = MarketInfo(Symbol(), MODE_MINLOT);
   for (int l_count_0 = 0; ld_4 < 1.0; l_count_0++) ld_4 = 10.0 * ld_4;
   return (l_count_0);
}

double CalcLots(double a_minlot_0) {
   double l_minlot_32;
   double ld_8 = AccountEquity() - gi_200;
   double ld_16 = gi_204;
   double ld_24 = gi_208;
   if (gi_204 == 0 || gi_208 == 0) l_minlot_32 = a_minlot_0;
   else {
      ld_16 = gi_200 * ld_16 / 100.0;
      Print("tmp=" + ld_8 + ",AccountEquity()=" + AccountEquity() + ",InitEquity=" + gi_200);
      ld_24 /= 100.0;
      if (ld_8 > 0.0) ld_8 = MathPow(ld_24 + 1.0, ld_8 / ld_16);
      else {
         if (ld_8 < 0.0) ld_8 = MathPow(1 - ld_24, MathAbs(ld_8 / ld_16));
         else ld_8 = 1;
      }
      l_minlot_32 = NormalizeDouble(a_minlot_0 * ld_8, GetLotDigits());
      if (l_minlot_32 < MarketInfo(Symbol(), MODE_MINLOT)) l_minlot_32 = MarketInfo(Symbol(), MODE_MINLOT);
   }
   if (l_minlot_32 < 0.0) Print("ERROR tmp=" + ld_8 + ",a=" + ld_16 + ",b=" + ld_24 + ",AccountEquity()=" + AccountEquity());
   Log("Equity=" + AccountEquity() + ",lots=" + l_minlot_32);
   return (l_minlot_32);
}


int deinit() {
   FileClose(g_file_408);
   return (0);
}

int init() {
   if (Digits == 3) {
      gd_124 = 10.0 * TakeProfit;
      gi_unused_132 = 10.0 * PipStarter;
      gi_136 = 10.0 * iStopLoss;
      g_point_320 = 0.01;
   } else {
      if (Digits == 5) {
         gd_124 = 10.0 * TakeProfit;
         gi_unused_132 = 10.0 * PipStarter;
         gi_136 = 10.0 * iStopLoss;
         g_point_320 = 0.0001;
      } else {
         gd_124 = TakeProfit;
         gi_unused_132 = PipStarter;
         gi_136 = iStopLoss;
         g_point_320 = Point;
      }
   }
   if (Digits == 3 || Digits == 5) {
      trendTrigger = 10 * trendTrigger;
      trendPips = 10 * trendPips;
      trendStoploss = 10 * trendStoploss;
   }
   gi_328 = MathRound((-MathLog(MarketInfo(Symbol(), MODE_LOTSTEP))) / 2.302585093);
   gi_376 = FALSE;
   gi_380 = FALSE;
   gi_384 = FALSE;
   gi_388 = FALSE;
   g_ticket_392 = -1;
   gi_252 = FALSE;
   g_file_408 = FileOpen(WindowExpertName() + "_" + Time[0] + "_" + Symbol() + "_" + MagicNumber + ".log", FILE_WRITE);
   g_cmd_396 = -1;
   gs_368 = "approved";
   return (0);
}

int IsTradeTime() {
   int li_8;
   if (DayOfWeek() < StartingTradeDay || DayOfWeek() > EndingTradeDay) return (0);
   int li_0 = 60 * TimeHour(TimeCurrent()) + TimeMinute(TimeCurrent());
   int li_4 = 60 * StartHour + StartMinute;
   li_8 = 60 * StopHour + li_8;
   if (li_4 == li_8) return (1);
   if (li_4 < li_8) {
      if (!(li_0 >= li_4 && li_0 < li_8)) return (0);
      return (1);
   }
   if (li_4 > li_8) {
      if (!(li_0 >= li_4 || li_0 < li_8)) return (0);
      return (1);
   }
   return (0);
}

double GetLastLotSize(int ai_0) {
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      if (OrderSelect(l_pos_4, SELECT_BY_POS)) {
         if (OrderMagicNumber() == MagicNumber) {
            if (StringFind(OrderComment(), gs__hedged_400) == -1) {
               Log("GetLastLotSize " + ai_0 + ",OrderLots()=" + OrderLots());
               return (OrderLots());
            }
         }
      }
   }
   Log("GetLastLotSize " + ai_0 + " wasnt found");
   return (0);
}

bool OpenBuy(bool ai_0 = FALSE) {
   int l_ticket_4;
   double l_lots_40;
   double l_price_8 = 0;
   double l_price_16 = 0;
   string ls_24 = "";
   bool li_ret_32 = TRUE;
   if (TimeCurrent() - g_datetime_316 < 60) return (FALSE);
   if (ai_0 && (!gi_384)) return (FALSE);
   if (!GlobalVariableCheck("PERMISSION")) {
      GlobalVariableSet("PERMISSION", TimeCurrent());
      if (!SupportECN) {
         if (ai_0) {
            if (OrderSelect(g_ticket_392, SELECT_BY_TICKET)) l_price_16 = OrderTakeProfit() - MarketInfo(Symbol(), MODE_SPREAD) * Point;
         } else l_price_8 = Ask + gd_124 * Point;
      }
      if (ai_0) ls_24 = gs__hedged_400;
      if (AllowiStopLoss == TRUE) l_price_16 = Ask - gi_136 * Point;
      if (ai_0) l_lots_40 = NormalizeDouble(GetLastLotSize(1) * MassHedgeBooster, 2);
      else l_lots_40 = CalcLots(gd_236);
      if (!SupportECN) l_ticket_4 = OrderSend(Symbol(), OP_BUY, l_lots_40, Ask, slippage, l_price_16, l_price_8, EA_Name + ls_24, MagicNumber, 0, Green);
      else {
         l_ticket_4 = OrderSend(Symbol(), OP_BUY, l_lots_40, Ask, slippage, 0, 0, EA_Name + ls_24, MagicNumber, 0, Green);
         Sleep(1000);
         OrderModify(l_ticket_4, OrderOpenPrice(), l_price_16, l_price_8, 0, Black);
      }
      g_datetime_316 = TimeCurrent();
      if (l_ticket_4 != -1) {
         if (!ai_0) {
            g_ticket_392 = l_ticket_4;
            Log("BUY hedgedTicket=" + g_ticket_392);
         } else {
            Log("BUY Hacked_ticket=" + l_ticket_4);
            g_cmd_396 = 0;
         }
      } else {
         Log("failed sell");
         li_ret_32 = FALSE;
      }
   }
   GlobalVariableDel("PERMISSION");
   return (li_ret_32);
}

bool OpenSell(bool ai_0 = FALSE) {
   int l_ticket_4;
   double l_lots_36;
   double l_price_8 = 0;
   double l_price_16 = 0;
   string ls_24 = "";
   bool li_ret_32 = TRUE;
   if (TimeCurrent() - g_datetime_316 < 60) return (FALSE);
   if (ai_0 && (!gi_388)) return (FALSE);
   if (!GlobalVariableCheck("PERMISSION")) {
      GlobalVariableSet("PERMISSION", TimeCurrent());
      if (!SupportECN) {
         if (ai_0) {
            if (OrderSelect(g_ticket_392, SELECT_BY_TICKET)) l_price_16 = OrderTakeProfit() + MarketInfo(Symbol(), MODE_SPREAD) * Point;
         } else l_price_8 = Bid - gd_124 * Point;
      }
      if (ai_0) ls_24 = gs__hedged_400;
      if (AllowiStopLoss == TRUE) l_price_16 = Bid + gi_136 * Point;
      if (ai_0) l_lots_36 = NormalizeDouble(GetLastLotSize(0) * MassHedgeBooster, 2);
      else l_lots_36 = CalcLots(gd_236);
      if (!SupportECN) l_ticket_4 = OrderSend(Symbol(), OP_SELL, l_lots_36, Bid, slippage, l_price_16, l_price_8, EA_Name + ls_24, MagicNumber, 0, Pink);
      else {
         l_ticket_4 = OrderSend(Symbol(), OP_SELL, l_lots_36, Bid, slippage, 0, 0, EA_Name + ls_24, MagicNumber, 0, Pink);
         Sleep(1000);
         OrderModify(l_ticket_4, OrderOpenPrice(), l_price_16, l_price_8, 0, Black);
      }
      g_datetime_316 = TimeCurrent();
      if (l_ticket_4 != -1) {
         if (!ai_0) {
            g_ticket_392 = l_ticket_4;
            Log("SELL hedgedTicket=" + g_ticket_392);
         } else {
            Log("SELL Hacked_ticket=" + l_ticket_4);
            g_cmd_396 = 1;
         }
      } else {
         Log("failed sell");
         li_ret_32 = FALSE;
      }
   }
   GlobalVariableDel("PERMISSION");
   return (li_ret_32);
}

void ManageBuy() {
   int l_datetime_0 = 0;
   double l_ord_open_price_4 = 0;
   double l_ord_lots_12 = 0;
   double l_ord_takeprofit_20 = 0;
   int l_cmd_28 = -1;
   int l_ticket_32 = 0;
   int l_pos_36 = 0;
   int l_count_40 = 0;
   for (l_pos_36 = 0; l_pos_36 < OrdersTotal(); l_pos_36++) {
      if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
            l_count_40++;
            if (OrderOpenTime() > l_datetime_0) {
               l_datetime_0 = OrderOpenTime();
               l_ord_open_price_4 = OrderOpenPrice();
               l_cmd_28 = OrderType();
               l_ticket_32 = OrderTicket();
               l_ord_takeprofit_20 = OrderTakeProfit();
            }
            if (OrderLots() > l_ord_lots_12) l_ord_lots_12 = OrderLots();
         }
      }
   }
   int li_44 = MathRound(MathLog(l_ord_lots_12 / Lots) / MathLog(Booster)) + 1.0;
   if (li_44 < 0) li_44 = 0;
   gd_236 = NormalizeDouble(Lots * MathPow(Booster, li_44), gi_328);
   if (li_44 == 0 && StrategySignal() == 1 && IsTradeTime()) {
      if (OpenBuy())
         if (MassHedge) gi_376 = TRUE;
   } else {
      if (l_ord_open_price_4 - Ask > PipStarter * g_point_320 && l_ord_open_price_4 > 0.0 && l_count_40 < MaxBuyOrders) {
         if (!(OpenBuy())) return;
         if (!(MassHedge)) return;
         gi_376 = TRUE;
         return;
      }
   }
   for (l_pos_36 = 0; l_pos_36 < OrdersTotal(); l_pos_36++) {
      OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() != MagicNumber || OrderType() != OP_BUY || OrderTakeProfit() == l_ord_takeprofit_20 || l_ord_takeprofit_20 == 0.0) continue;
      OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), l_ord_takeprofit_20, 0, Pink);
      Sleep(1000);
   }
}

int StrategySignal() {
   double l_isar_0 = iSAR(NULL, 0, gd_272, gd_280, 0);
   double l_ima_8 = iMA(NULL, 0, g_period_256, gi_260, g_ma_method_264, g_applied_price_268, 0);
   if (l_isar_0 > l_ima_8) return (-1);
   if (l_isar_0 < l_ima_8) return (1);
   return (0);
}

void ManageSell() {
   int l_datetime_0 = 0;
   double l_ord_open_price_4 = 0;
   double l_ord_lots_12 = 0;
   double l_ord_takeprofit_20 = 0;
   int l_cmd_28 = -1;
   int l_ticket_32 = 0;
   int l_pos_36 = 0;
   int l_count_40 = 0;
   for (l_pos_36 = 0; l_pos_36 < OrdersTotal(); l_pos_36++) {
      if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
            l_count_40++;
            if (OrderOpenTime() > l_datetime_0) {
               l_datetime_0 = OrderOpenTime();
               l_ord_open_price_4 = OrderOpenPrice();
               l_cmd_28 = OrderType();
               l_ticket_32 = OrderTicket();
               l_ord_takeprofit_20 = OrderTakeProfit();
            }
            if (OrderLots() > l_ord_lots_12) l_ord_lots_12 = OrderLots();
         }
      }
   }
   int li_44 = MathRound(MathLog(l_ord_lots_12 / Lots) / MathLog(Booster)) + 1.0;
   if (li_44 < 0) li_44 = 0;
   gd_236 = NormalizeDouble(Lots * MathPow(Booster, li_44), gi_328);
   if (li_44 == 0 && StrategySignal() == -1 && IsTradeTime()) {
      if (OpenSell())
         if (MassHedge) gi_380 = TRUE;
   } else {
      if (Bid - l_ord_open_price_4 > PipStarter * g_point_320 && l_ord_open_price_4 > 0.0 && l_count_40 < MaxSellOrders) {
         if (!(OpenSell())) return;
         if (!(MassHedge)) return;
         gi_380 = TRUE;
         return;
      }
   }
   for (l_pos_36 = 0; l_pos_36 < OrdersTotal(); l_pos_36++) {
      if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
            if (OrderTakeProfit() == l_ord_takeprofit_20 || l_ord_takeprofit_20 == 0.0) continue;
            OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), l_ord_takeprofit_20, 0, Pink);
         }
      }
   }
}

int start() {
   double l_ord_takeprofit_20;
   double l_price_28;
   double l_price_36;

   if (allowTrending) {
      for (int l_pos_0 = 0; l_pos_0 < OrdersTotal(); l_pos_0++) {
         if (OrderSelect(l_pos_0, SELECT_BY_POS)) {
            if (MagicNumber == OrderMagicNumber()) {
               if (OrderType() == OP_BUY)
                  if (OrderTakeProfit() - Bid <= trendTrigger * Point && Bid < OrderTakeProfit()) OrderModify(OrderTicket(), 0, Bid - trendStoploss * Point, OrderTakeProfit() + trendPips * Point, 0, White);
               if (OrderType() == OP_SELL)
                  if (Ask - OrderTakeProfit() <= trendTrigger * Point && Ask > OrderTakeProfit()) OrderModify(OrderTicket(), 0, Ask + trendStoploss * Point, OrderTakeProfit() - trendPips * Point, 0, White);
            }
         }
      }
   }
   int l_count_4 = 0;
   int l_count_8 = 0;
   for (int l_pos_12 = 0; l_pos_12 < OrdersTotal(); l_pos_12++) {
      if (OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == MagicNumber) {
            if (StringFind(OrderComment(), gs__hedged_400) == -1) {
               if (OrderType() == OP_BUY) l_count_4++;
               else
                  if (OrderType() == OP_SELL) l_count_8++;
            }
         }
      }
   }
   if (l_count_4 >= TradesDeep) {
      if (!gi_388) {
         Log("Allow long hedge! trades=" + l_count_4 + ",TradesDeep=" + TradesDeep);
         gi_388 = TRUE;
      }
   }
   if (l_count_8 >= TradesDeep) {
      if (!gi_384) {
         Log("Allow short hedge! trades=" + l_count_8 + ",TradesDeep=" + TradesDeep);
         gi_384 = TRUE;
      }
   }
   bool li_16 = FALSE;
   if ((100 - StopLossPct) * AccountBalance() / 100.0 >= AccountEquity()) {
      Log("AccountBalance=" + AccountBalance() + ",AccountEquity=" + AccountEquity());
      gi_252 = TRUE;
      li_16 = TRUE;
   }
   if ((TakeProfitPct + 100.0) * AccountBalance() / 100.0 <= AccountEquity()) gi_252 = TRUE;
   if (gi_252) {
      for (l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
         if (OrderSelect(l_pos_0, SELECT_BY_POS)) {
            if (OrderMagicNumber() == MagicNumber) {
               Log("close #" + OrderTicket());
               if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), MarketInfo(Symbol(), MODE_SPREAD), White)) {
                  Log("error");
                  return (0);
               }
            }
         }
      }
      gi_252 = FALSE;
      if (li_16) {
         Sleep(1000 * StoppedOutPause);
         li_16 = FALSE;
      }
      gi_388 = FALSE;
      gi_384 = FALSE;
   }
   if (SupportECN) {
      l_ord_takeprofit_20 = 0;
      if (OrderSelect(g_ticket_392, SELECT_BY_TICKET)) l_ord_takeprofit_20 = OrderTakeProfit();
      for (l_pos_0 = 0; l_pos_0 < OrdersTotal(); l_pos_0++) {
         if (OrderSelect(l_pos_0, SELECT_BY_POS)) {
            if (OrderMagicNumber() == MagicNumber) {
               if (OrderTakeProfit() == 0.0 && StringFind(OrderComment(), gs__hedged_400) == -1) {
                  if (OrderType() == OP_BUY) OrderModify(OrderTicket(), 0, OrderStopLoss(), OrderOpenPrice() + gd_124 * Point, 0, White);
                  else
                     if (OrderType() == OP_SELL) OrderModify(OrderTicket(), 0, OrderStopLoss(), OrderOpenPrice() - gd_124 * Point, 0, White);
               } else {
                  if (StringFind(OrderComment(), gs__hedged_400) != -1 && g_cmd_396 == OrderType()) {
                     l_price_28 = l_ord_takeprofit_20 - MarketInfo(Symbol(), MODE_SPREAD) * Point;
                     l_price_36 = l_ord_takeprofit_20 + MarketInfo(Symbol(), MODE_SPREAD) * Point;
                     if (OrderStopLoss() == 0.0 || (OrderType() == OP_BUY && OrderStopLoss() != l_price_28) || (OrderType() == OP_SELL && OrderStopLoss() != l_price_36)) {
                        if (OrderType() == OP_BUY) OrderModify(OrderTicket(), 0, l_price_28, OrderTakeProfit(), 0, White);
                        else
                           if (OrderType() == OP_SELL) OrderModify(OrderTicket(), 0, l_price_36, OrderTakeProfit(), 0, White);
                     }
                  }
               }
            }
         }
      }
   }
   if (Check() != 0) {
      ManageBuy();
      ManageSell();
      if ((!PauseNewTrades) && IsTradeTime()) {
         if (gi_380)
            if (OpenBuy(1)) gi_380 = FALSE;
         if (gi_376)
            if (OpenSell(1)) gi_376 = FALSE;
      }
      ChartComment();
      return (0);
   }
   return (0);
}

void ChartComment() {
   string l_dbl2str_0 = DoubleToStr(balanceDeviation(2), 2);
   Comment(" \nForexHacked V2.3 Loaded Successfully™ ", 
      "\nAccount Leverage  :  " + "1 : " + AccountLeverage(), 
      "\nAccount Type  :  " + AccountServer(), 
      "\nServer Time  :  " + TimeToStr(TimeCurrent(), TIME_SECONDS), 
      "\nAccount Equity  = ", AccountEquity(), 
      "\nFree Margin     = ", AccountFreeMargin(), 
   "\nDrawdown  :  ", l_dbl2str_0, "%\n");
}

int Check() {
   return (1);
}

double balanceDeviation(int ai_0) {
   double ld_ret_4;
   if (ai_0 == 2) {
      ld_ret_4 = (AccountEquity() / AccountBalance() - 1.0) / (-0.01);
      if (ld_ret_4 > 0.0) return (ld_ret_4);
      return (0);
   }
   if (ai_0 == 1) {
      ld_ret_4 = 100.0 * (AccountEquity() / AccountBalance() - 1.0);
      if (ld_ret_4 > 0.0) return (ld_ret_4);
      return (0);
   }
   return (0.0);
}