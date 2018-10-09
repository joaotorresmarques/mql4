extern int SignalLevel = 30;
extern int NormalAskDistance = 20;
extern int Magic = 10001;
extern double Lots = 0.2;
extern int maxDeals = 10;
extern double minSignalValue = 10.0;
extern int slShift = 30;
extern int Kperiod = 5;
extern int Dperiod = 3;
extern int slowing = 3;
extern int stLevel = 20;
extern int minProfitFix = 200;
int g_period_132 = 24;
int g_period_136 = 6;
int g_slowing_140 = 3;
int gi_144 = MODE_SIGNAL;
string g_symbol_148;
int g_timeframe_156;
int g_timeframe_160;
int g_timeframe_164;
int g_timeframe_168;
int g_count_172;
int g_count_176;
int g_count_180;
int g_count_184;
double gd_188;
double gd_196;
double g_istochastic_204;
double g_istochastic_212;
double g_istochastic_220;
double g_istochastic_228;
datetime g_time_236;
datetime g_time_240;
datetime g_time_244;
datetime g_time_248;
datetime g_time_252;
int gi_unused_256;
int gi_unused_260;

int init() {
   g_symbol_148 = Symbol();
   g_timeframe_156 = Period();
   g_timeframe_160 = NextTimeframe(g_timeframe_156);
   g_timeframe_164 = NextTimeframe(g_timeframe_160);
   g_timeframe_168 = NextTimeframe(g_timeframe_164);
   g_time_236 = 0;
   GetValues(0);
   gi_unused_256 = 0;
   g_time_240 = 0;
   g_time_244 = 0;
   if (gd_188 != EMPTY_VALUE) {
      gi_unused_256 = 1;
      g_time_240 = Time[0];
   }
   gi_unused_260 = 0;
   g_time_248 = 0;
   g_time_252 = 0;
   if (gd_196 != EMPTY_VALUE) {
      gi_unused_260 = 1;
      g_time_248 = Time[0];
   }
   return (0);
}

int deinit() {
   Comment("");
   if (ObjectFind("normask") >= 0) ObjectDelete("normask");
   return (0);
}

int start() 
{
   double ld_0;
   double ld_8;
//   if (IsEvaluationOver() == 0) 
//     {
      ShowNormalAskLine();
      GetValues(1);
      ld_0 = gd_188;
      ld_8 = gd_196;
      GetValues(0);
      mstOutput();
      if (ld_0 == EMPTY_VALUE && gd_188 != EMPTY_VALUE) {
         ShowLine(0, 1);
         gi_unused_256 = 1;
         g_time_240 = Time[0];
         g_time_244 = 0;
      }
      if (ld_8 == EMPTY_VALUE && gd_196 != EMPTY_VALUE) {
         ShowLine(1, 1);
         gi_unused_260 = 1;
         g_time_248 = Time[0];
         g_time_252 = 0;
      }
      if (ld_0 != EMPTY_VALUE && gd_188 == EMPTY_VALUE) {
         ShowLine(0, 0);
         gi_unused_256 = 0;
         g_time_244 = Time[0];
      }
      if (ld_8 != EMPTY_VALUE && gd_196 == EMPTY_VALUE) {
         ShowLine(1, 0);
         gi_unused_260 = 0;
         g_time_252 = Time[0];
      }
      if (g_time_236 != Time[0]) {
         g_time_236 = Time[0];
         CountOrders();
         onBar();
      }
//   } else mstEvOutput();
   return (0);
}

void onBar() {
   FixProfit();
   if (gd_188 != EMPTY_VALUE) {
      if (gd_188 >= minSignalValue && g_count_172 < maxDeals) {
         GetStoch();
         if (g_istochastic_212 < stLevel && g_istochastic_212 <= g_istochastic_228 && g_istochastic_204 > g_istochastic_220) BuyAtMarket(Lots);
      }
      if (gd_188 < minSignalValue && g_count_172 > 1 && g_count_172 == g_count_180) DoCloseAll(OP_BUY);
   }
   if (gd_188 == EMPTY_VALUE && g_count_172 > 0) ZoneClose(OP_BUY);
   if (gd_196 != EMPTY_VALUE) {
      if (gd_196 >= minSignalValue && g_count_176 < maxDeals) {
         GetStoch();
         if (g_istochastic_212 > 100 - stLevel && g_istochastic_212 >= g_istochastic_228 && g_istochastic_204 < g_istochastic_220) SellAtMarket(Lots);
      }
      if (gd_196 < minSignalValue && g_count_176 > 1 && g_count_176 == g_count_184) DoCloseAll(OP_SELL);
   }
   if (gd_196 == EMPTY_VALUE && g_count_176 > 0) ZoneClose(OP_SELL);
}

void FixProfit() {
   int lia_8[100];
   int cmd_36;
   int ticket_40;
   double ld_44;
   double order_open_price_52;
   int ticket_0 = 0;
   int index_4 = 0;
   double ld_12 = -1000000;
   double ld_20 = 1000000;
   int order_total_28 = OrdersTotal();
   for (int pos_32 = order_total_28 - 1; pos_32 >= 0; pos_32--) {
      if (OrderSelect(pos_32, SELECT_BY_POS) && OrderSymbol() == g_symbol_148 && OrderMagicNumber() == Magic) {
         cmd_36 = OrderType();
         ticket_40 = OrderTicket();
         order_open_price_52 = OrderOpenPrice();
         if (cmd_36 == OP_BUY) ld_44 = (Bid - order_open_price_52) / Point;
         else ld_44 = (order_open_price_52 - Ask) / Point;
         if (ld_44 > 5.0) {
            lia_8[index_4] = ticket_40;
            index_4++;
         }
         if (ld_44 > ld_12) ld_12 = ld_44;
         if (ld_44 < 0.0 && ld_44 < ld_20) {
            ld_20 = ld_44;
            ticket_0 = ticket_40;
         }
      }
   }
   if (ld_12 >= minProfitFix) {
      for (pos_32 = 0; pos_32 < index_4; pos_32++) DoClose(lia_8[pos_32]);
      if (ticket_0 > 0) DoClose(ticket_0);
   }
}

void ZoneClose(int a_cmd_0) {
   double price_4;
   int shift_12;
   int shift_16;
   if (a_cmd_0 == OP_BUY) {
      shift_12 = iBarShift(g_symbol_148, 0, g_time_240);
      shift_16 = iBarShift(g_symbol_148, 0, g_time_244);
      price_4 = Low[iLowest(g_symbol_148, 0, MODE_LOW, shift_12 - shift_16, shift_16)] - slShift * Point;
   } else {
      shift_12 = iBarShift(g_symbol_148, 0, g_time_248);
      shift_16 = iBarShift(g_symbol_148, 0, g_time_252);
      price_4 = High[iHighest(g_symbol_148, 0, MODE_HIGH, shift_12 - shift_16, shift_16)] + slShift * Point;
   }
   int order_total_20 = OrdersTotal();
   for (int pos_24 = order_total_20 - 1; pos_24 >= 0; pos_24--)
      if (OrderSelect(pos_24, SELECT_BY_POS) && OrderSymbol() == g_symbol_148 && OrderMagicNumber() == Magic && OrderType() == a_cmd_0 && OrderProfit() < 0.0 && OrderStopLoss() == 0.0) OrderModify(OrderTicket(), OrderOpenPrice(), price_4, OrderTakeProfit(), 0);
}

void mstOutput() {
   string dbl2str_0 = "---";
   if (gd_188 != EMPTY_VALUE) dbl2str_0 = DoubleToStr(gd_188, 1);
   string dbl2str_8 = "---";
   if (gd_196 != EMPTY_VALUE) dbl2str_8 = DoubleToStr(gd_196, 1);
   string ls_16 = "EA_mstSignal_v2mm by astrovlad\n" + "details: http://astrotrade.ru/viewtopic.php?id=70\n" + "BUY signal: " + dbl2str_0 
      + "\n" 
      + "SELL signal: " + dbl2str_8 
   + "\n";
   Comment(ls_16);
}

void ShowLine(int ai_0, int ai_4) {
   color color_16;
   int style_20;
   int li_28;
   string name_8 = "mstsignal_" + ai_0 + "_" + ai_4;
   if (ai_0 == 0) color_16 = RoyalBlue;
   else color_16 = Red;
   if (ai_4 == 1) style_20 = 4;
   else style_20 = 2;
   bool li_24 = FALSE;
   if (ObjectFind(name_8) < 0) {
      li_24 = TRUE;
      ObjectCreate(name_8, OBJ_VLINE, 0, Time[0], 0);
      ObjectSet(name_8, OBJPROP_STYLE, style_20);
      ObjectSet(name_8, OBJPROP_COLOR, color_16);
   } else {
      li_28 = ObjectGet(name_8, OBJPROP_TIME1);
      if (li_28 != Time[0]) {
         li_24 = TRUE;
         ObjectSet(name_8, OBJPROP_TIME1, Time[0]);
      }
   }
   if (li_24) {
      if (ai_4 == 1) PlaySound("alert2.wav");
      else PlaySound("timeout.wav");
   }
}

void GetValues(int ai_0) {
   double istochastic_4 = iStochastic(g_symbol_148, g_timeframe_156, g_period_132, g_period_136, g_slowing_140, MODE_SMA, 0, gi_144, iBarShift(g_symbol_148, g_timeframe_156,
      Time[ai_0]));
   double istochastic_12 = iStochastic(g_symbol_148, g_timeframe_160, g_period_132, g_period_136, g_slowing_140, MODE_SMA, 0, gi_144, iBarShift(g_symbol_148, g_timeframe_160,
      Time[ai_0]));
   double istochastic_20 = iStochastic(g_symbol_148, g_timeframe_164, g_period_132, g_period_136, g_slowing_140, MODE_SMA, 0, gi_144, iBarShift(g_symbol_148, g_timeframe_164,
      Time[ai_0]));
   double istochastic_28 = iStochastic(g_symbol_148, g_timeframe_168, g_period_132, g_period_136, g_slowing_140, MODE_SMA, 0, gi_144, iBarShift(g_symbol_148, g_timeframe_168,
      Time[ai_0]));
   double ld_36 = (istochastic_4 + istochastic_12 + istochastic_20 + istochastic_28) / 4.0;
   double ld_44 = istochastic_4 - ld_36;
   double ld_52 = istochastic_12 - ld_36;
   double ld_60 = istochastic_20 - ld_36;
   double ld_68 = istochastic_28 - ld_36;
   double ld_76 = MathSqrt((ld_44 * ld_44 + ld_52 * ld_52 + ld_60 * ld_60 + ld_68 * ld_68) / 3.0);
   gd_188 = EMPTY_VALUE;
   if (ld_36 <= SignalLevel && ld_76 != 0.0) {
      gd_188 = (SignalLevel - ld_36) / (2.0 * ld_76);
      if (gd_188 > 1.0) gd_188 = 1;
      gd_188 = 100.0 * gd_188;
   }
   gd_196 = EMPTY_VALUE;
   if (ld_36 >= 100 - SignalLevel && ld_76 != 0.0) {
      gd_196 = (ld_36 - 100.0 + SignalLevel) / (2.0 * ld_76);
      if (gd_196 > 1.0) gd_196 = 1;
      gd_196 = 100.0 * gd_196;
   }
}

int NextTimeframe(int ai_0) {
   int li_ret_4 = 0;
   switch (ai_0) {
   case 1:
      li_ret_4 = 5;
      break;
   case 5:
      li_ret_4 = 15;
      break;
   case 15:
      li_ret_4 = 60;
      break;
   case 30:
      li_ret_4 = 60;
      break;
   case 60:
      li_ret_4 = 240;
      break;
   case 240:
      li_ret_4 = 1440;
      break;
   case 1440:
      li_ret_4 = 10080;
      break;
   case 10080:
      li_ret_4 = 43200;
   }
   return (li_ret_4);
}

void ShowNormalAskLine() {
   double price_0;
   if (NormalAskDistance > 0) {
      price_0 = Bid + NormalAskDistance * Point;
      if (ObjectFind("normask") < 0) {
         ObjectCreate("normask", OBJ_HLINE, 0, 0, price_0);
         ObjectSet("normask", OBJPROP_STYLE, STYLE_DOT);
         ObjectSet("normask", OBJPROP_COLOR, Maroon);
         return;
      }
      ObjectSet("normask", OBJPROP_PRICE1, price_0);
      return;
   }
   if (ObjectFind("normask") >= 0) ObjectDelete("normask");
}

int IsEvaluationOver() {
   bool li_ret_0 = FALSE;
   if (IsDemo() == FALSE && Year() > 2011) li_ret_0 = TRUE;
   return (li_ret_0);
}

void mstEvOutput() {
   string ls_0 = "EA_mstSignal_v2mm by astrovlad\n" + "details: http://astrotrade.ru/viewtopic.php?id=70\n" + "EA evaluation period is over";
   Comment(ls_0);
}

void CountOrders() {
   int cmd_8;
   double order_profit_12;
   int order_total_0 = OrdersTotal();
   g_count_172 = 0;
   g_count_176 = 0;
   g_count_180 = 0;
   g_count_184 = 0;
   for (int pos_4 = order_total_0 - 1; pos_4 >= 0; pos_4--) {
      if (OrderSelect(pos_4, SELECT_BY_POS) && OrderSymbol() == g_symbol_148 && OrderMagicNumber() == Magic) {
         cmd_8 = OrderType();
         order_profit_12 = OrderProfit();
         if (cmd_8 == OP_BUY) {
            g_count_172++;
            if (order_profit_12 > 0.0) g_count_180++;
         }
         if (cmd_8 == OP_SELL) {
            g_count_176++;
            if (order_profit_12 > 0.0) g_count_184++;
         }
      }
   }
}

void GetStoch() {
   g_istochastic_204 = iStochastic(g_symbol_148, 0, Kperiod, Dperiod, slowing, MODE_SMA, 0, MODE_MAIN, 1);
   g_istochastic_212 = iStochastic(g_symbol_148, 0, Kperiod, Dperiod, slowing, MODE_SMA, 0, MODE_MAIN, 2);
   g_istochastic_220 = iStochastic(g_symbol_148, 0, Kperiod, Dperiod, slowing, MODE_SMA, 0, MODE_SIGNAL, 1);
   g_istochastic_228 = iStochastic(g_symbol_148, 0, Kperiod, Dperiod, slowing, MODE_SMA, 0, MODE_SIGNAL, 2);
}

int MarketReady() {
   bool li_ret_0 = TRUE;
   int count_4 = 0;
   while (!IsTradeAllowed()) {
      if (IsTradeContextBusy()) {
         if (count_4 < 5) {
            count_4++;
            Print("TradeContext is busy");
            PlaySound("tick.wav");
            Sleep(3000);
            continue;
         }
         Print("TradeContext is permanently busy");
         li_ret_0 = FALSE;
         break;
      }
      Print("Trade is not allowed");
      PlaySound("timeout.wav");
      li_ret_0 = FALSE;
      break;
   }
   return (li_ret_0);
}

int BuyAtMarket(double a_lots_0) {
   int ticket_8;
   string ls_12;
   int count_20 = 0;
   while (MarketReady()) {
      ls_12 = "Buy " + DoubleToStr(a_lots_0, 2) + " at market: ";
      ticket_8 = OrderSend(g_symbol_148, OP_BUY, a_lots_0, MarketInfo(g_symbol_148, MODE_ASK), 3, 0, 0, "Magic: " + Magic, Magic);
      if (ticket_8 == -1) {
         if (count_20 < 5) {
            count_20++;
            Print(ls_12 + "error = " + GetLastError() + ", will try again");
            PlaySound("tick.wav");
            Sleep(1000);
            RefreshRates();
            continue;
         }
         Print(ls_12 + "GENERAL FAULT, position is not opened");
         PlaySound("timeout.wav");
         break;
      }
      Print(ls_12 + "done, order ticket = " + ticket_8 + ", Magic = " + Magic);
      PlaySound("news.wav");
      break;
   }
   return (ticket_8);
}

int SellAtMarket(double a_lots_0) {
   int ticket_8;
   string ls_12;
   int count_20 = 0;
   while (MarketReady()) {
      ls_12 = "Sell " + DoubleToStr(a_lots_0, 2) + " at market: ";
      ticket_8 = OrderSend(g_symbol_148, OP_SELL, a_lots_0, MarketInfo(g_symbol_148, MODE_BID), 3, 0, 0, "Magic: " + Magic, Magic);
      if (ticket_8 == -1) {
         if (count_20 < 5) {
            count_20++;
            Print(ls_12 + "error = " + GetLastError() + ", will try again");
            PlaySound("tick.wav");
            Sleep(1000);
            RefreshRates();
            continue;
         }
         Print(ls_12 + "GENERAL FAULT, position is not opened");
         PlaySound("timeout.wav");
         break;
      }
      Print(ls_12 + "done, order ticket = " + ticket_8 + ", Magic = " + Magic);
      PlaySound("news.wav");
      break;
   }
   return (ticket_8);
}

void DoCloseAll(int a_cmd_0) {
   int order_total_4 = OrdersTotal();
   for (int pos_8 = order_total_4 - 1; pos_8 >= 0; pos_8--)
      if (OrderSelect(pos_8, SELECT_BY_POS) && OrderSymbol() == g_symbol_148 && OrderMagicNumber() == Magic && a_cmd_0 == -1 || OrderType() == a_cmd_0) DoClose(OrderTicket());
}

int DoClose(int a_ticket_0) {
   bool li_ret_4 = FALSE;
   if (OrderSelect(a_ticket_0, SELECT_BY_TICKET)) for (int count_8 = 0; li_ret_4 == FALSE && count_8 < 5; count_8++) li_ret_4 = _DoClose();
   return (li_ret_4);
}

int _DoClose() {
   double price_0;
   if (OrderType() == OP_BUY) price_0 = MarketInfo(g_symbol_148, MODE_BID);
   else price_0 = MarketInfo(g_symbol_148, MODE_ASK);
   bool is_closed_8 = OrderClose(OrderTicket(), OrderLots(), price_0, 3);
   if (is_closed_8) PlaySound("expert.wav");
   else PlaySound("tick.wav");
   Sleep(300);
   return (is_closed_8);
}