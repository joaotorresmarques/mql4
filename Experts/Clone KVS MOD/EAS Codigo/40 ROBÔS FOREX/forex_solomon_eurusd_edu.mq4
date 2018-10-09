
#property copyright "Copyright @ Rita Lasker"
#property link      "http://www.ritalasker.com"

#include <WinUser32.mqh>

#import "kernel32.dll"
   void GetSystemTime(int& a0[]);
#import

string g_comment_76 = "forex_solomon_eurusd";
int gi_84 = 40;
bool gi_88 = FALSE;
int gi_92 = 3;
int gi_96 = 0;
double gd_100 = 10.0;
extern double Lot = 0.1;
extern bool avtoGMT = TRUE;
extern int Ofset = 0;
int gi_124 = 0;
int gi_128 = 21;
int gi_132 = 8;
//string gs_136 = "2011.01.26";
int gi_144 = 31;
extern int MAGIC = 14071;
double gd_152;
int gi_160 = 2;
int g_slippage_164;
double g_maxlot_168;
double g_minlot_176;
double g_lotstep_184;
int gi_192;
bool gi_196 = TRUE;
double gd_200;
int gi_224;
int gi_228;
double gd_248;
double gd_256;
double gd_264;
double gd_272;
double gd_280;
double gd_288;
int gi_304;
int gi_308 = 10;
bool gi_312 = TRUE;
bool gi_316 = TRUE;

int init() {
  /* if (gs_136 != "") {
      if (TimeCurrent() > StrToTime(gs_136) + 86400 * gi_144) {
         Alert("Your version is expired!");
         Comment("Your version is expired!");
         gi_196 = FALSE;
         return (0);
      }
   } */
   if (IsTesting() && !IsVisualMode()) gi_88 = FALSE;
   g_maxlot_168 = MarketInfo(Symbol(), MODE_MAXLOT);
   g_minlot_176 = MarketInfo(Symbol(), MODE_MINLOT);
   g_lotstep_184 = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (g_lotstep_184 == 0.1) gi_192 = 1;
   if (g_lotstep_184 == 0.01) gi_192 = 2;
   g_slippage_164 = gi_160;
   gd_152 = Point;
   if (Digits == 5 || Digits == 3) {
      gd_152 = 10.0 * gd_152;
      g_slippage_164 = 10 * g_slippage_164;
   }
   return (0);
}

int deinit() {
   string l_name_8;
   int l_objs_total_0 = ObjectsTotal();
   for (int li_4 = l_objs_total_0 - 1; li_4 >= 0; li_4--) {
      l_name_8 = ObjectName(li_4);
      if (StringFind(l_name_8, "[Calc]", 0) >= 0 || StringFind(l_name_8, "ARROW", 0) >= 0) ObjectDelete(l_name_8);
   }
   Comment("");
   return (0);
}

int start() {
   double ld_0;
   double ld_8;
   double ld_16;
   int li_24;
   double ld_28;
   double ld_36;
   double ld_44;
   int li_56;
   int l_shift_64;
   double ld_68;
   string l_name_76;
   if (!gi_196) return (0);
 /*  if (gs_136 != "") {
      if (TimeCurrent() > StrToTime(gs_136) + 86400 * gi_144) {
         Alert("Your version is expired!");
         Comment("Your version is expired!");
         gi_196 = FALSE;
         return (0);
      }
   } */
   gd_200 = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point / gd_152;
   int li_52 = bTradeTime();
   if (gi_84 > 0) {
      li_56 = gi_84;
      if (li_56 < gd_200 + 3.0) li_56 = gd_200 + 3.0;
      for (int l_pos_60 = 0; l_pos_60 < OrdersTotal(); l_pos_60++) {
         if (OrderSelect(l_pos_60, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderMagicNumber() == MAGIC && Symbol() == OrderSymbol()) {
               if (!IsTesting()) RefreshRates();
               if (OrderType() == OP_BUY) {
                  if (OrderOpenPrice() + li_56 * gd_152 < Bid && OrderStopLoss() < OrderOpenPrice()) {
                     if (OrderModify(OrderTicket(), OrderOpenPrice(), ND(OrderOpenPrice() + 3.0 * gd_152), OrderTakeProfit(), 0, Blue))
                        if (!IsOptimization()) Print("Order Modify Error ", GetLastError());
                  }
               }
               if (OrderType() == OP_SELL) {
                  if (OrderOpenPrice() - li_56 * gd_152 > Ask && OrderStopLoss() > OrderOpenPrice() || OrderStopLoss() == 0.0) {
                     if (OrderModify(OrderTicket(), OrderOpenPrice(), ND(OrderOpenPrice() - 3.0 * gd_152), OrderTakeProfit(), 0, Red))
                        if (!IsOptimization()) Print("Order Modify Error ", GetLastError());
                  }
               }
            }
         }
      }
   }
   if (IsTesting()) {
      if (avtoGMT) {
         MessageBoxA(0, "AutoTimeSettings should be (false) at the test mode. Using ManualGMT_Offset", "Error", 0);
         gi_196 = FALSE;
         return (0);
      }
      gi_224 = Ofset;
   }
   gi_224 = Ofset;
   if (avtoGMT) gi_224 = get_UTC_OFFSET();
   gi_228 = 3600 * gi_224;
   if (li_24 < iTime(Symbol(), PERIOD_D1, 0) + gi_228) {
      if (TimeCurrent() >= iTime(Symbol(), PERIOD_D1, 0) + gi_228) li_24 = iTime(Symbol(), PERIOD_D1, 0) + gi_228;
      else li_24 = iTime(Symbol(), PERIOD_D1, 1) + gi_228;
   }
   if (gi_228 >= 0) {
      if (gi_304 < iTime(Symbol(), PERIOD_D1, 0) + gi_228 && TimeCurrent() >= iTime(Symbol(), PERIOD_D1, 0) + gi_228) {
         gi_304 = iTime(Symbol(), PERIOD_D1, 0) + gi_228;
         CloseOrders();
         gi_312 = TRUE;
         gi_316 = TRUE;
         l_shift_64 = iBarShift(Symbol(), 0, li_24);
         ld_0 = High[iHighest(Symbol(), 0, MODE_HIGH, 1440 / Period(), l_shift_64 + 1)];
         ld_8 = Low[iLowest(Symbol(), 0, MODE_LOW, 1440 / Period(), l_shift_64 + 1)];
         ld_16 = Close[l_shift_64 + 1];
         ld_44 = ld_16;
         ld_28 = ld_0;
         ld_36 = ld_8;
         ld_68 = (ld_28 + ld_36 + ld_44) / 3.0;
         gd_248 = ND(2.0 * ld_68 - ld_36);
         gd_264 = ND((ld_68 + gd_248) / 2.0);
         gd_280 = ND(ld_68 + (ld_28 - ld_36));
         gd_256 = ND(2.0 * ld_68 - ld_28);
         gd_272 = ND((ld_68 + gd_256) / 2.0);
         gd_288 = ND(ld_68 - (ld_28 - ld_36));
      }
   } else {
      if (gi_304 < iTime(Symbol(), PERIOD_D1, 1) + 86400 + gi_228 && TimeCurrent() >= iTime(Symbol(), PERIOD_D1, 1) + 86400 + gi_228) {
         gi_304 = iTime(Symbol(), PERIOD_D1, 1) + 86400 + gi_228;
         CloseOrders();
         gi_312 = TRUE;
         gi_316 = TRUE;
      }
   }
   if (bTradeTime()) {
      if (Open[1] < gd_264 && Close[1] < gd_264 && Close[0] >= gd_264 && gi_312) {
         gi_312 = FALSE;
         if (iCountMarket_Orders(OP_BUY) == 0) vOpenMarketOrder(OP_BUY);
         if (!IsTesting() || IsVisualMode()) {
            l_name_76 = "BuyARROW" + Time[0];
            ObjectCreate(l_name_76, OBJ_ARROW, 0, 0, 0);
            ObjectSet(l_name_76, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
            ObjectSet(l_name_76, OBJPROP_COLOR, Blue);
            ObjectSet(l_name_76, OBJPROP_PRICE1, Low[0] - 50.0 * gd_152);
            ObjectSet(l_name_76, OBJPROP_TIME1, Time[0]);
         }
      }
      if (Open[1] > gd_272 && Close[1] > gd_272 && Close[0] <= gd_272 && gi_316) {
         gi_316 = FALSE;
         if (iCountMarket_Orders(OP_SELL) == 0) vOpenMarketOrder(OP_SELL);
         if (!IsTesting() || IsVisualMode()) {
            l_name_76 = "SellARROW" + Time[0];
            ObjectCreate(l_name_76, OBJ_ARROW, 0, 0, 0);
            ObjectSet(l_name_76, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
            ObjectSet(l_name_76, OBJPROP_COLOR, Red);
            ObjectSet(l_name_76, OBJPROP_PRICE1, High[0] + 50.0 * gd_152);
            ObjectSet(l_name_76, OBJPROP_TIME1, Time[0]);
         }
      }
   }
   if (gi_88) {
      SetLevel("BuyLine", gd_264, Blue, li_24);
      SetLevel("BuyTPLine", gd_280, Blue, li_24);
      SetLevel("SellLine", gd_272, Red, li_24);
      SetLevel("SellTPLine", gd_288, Red, li_24);
   }
   if (!IsTesting() || IsVisualMode()) Comment("OFFSET = " + gi_224);
   return (0);
}

void vOpenMarketOrder(int a_cmd_0) {
   color l_color_12;
   double l_price_20;
   string ls_28;
   int l_ticket_36;
   double l_price_40;
   double l_price_48;
   double ld_4 = dAutoLot();
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0, ld_4) <= 0.0) {
      if (!IsOptimization()) Alert("We have no money!");
      gi_196 = FALSE;
      return;
   }
   if (a_cmd_0 == OP_BUY) l_color_12 = Blue;
   if (a_cmd_0 == OP_SELL) l_color_12 = Red;
   for (int l_count_16 = 0; l_count_16 <= gi_92; l_count_16++) {
      if (!IsTesting()) {
         while (!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
      }
      if (a_cmd_0 == OP_BUY) {
         l_price_20 = ND(Ask);
         ls_28 = "Buy";
      }
      if (a_cmd_0 == OP_SELL) {
         l_price_20 = ND(Bid);
         ls_28 = "Sell";
      }
      l_ticket_36 = OrderSend(Symbol(), a_cmd_0, ld_4, l_price_20, g_slippage_164, 0, 0, g_comment_76, MAGIC, 0, l_color_12);
      if (l_ticket_36 > 0) {
         if (!(OrderSelect(l_ticket_36, SELECT_BY_TICKET, MODE_TRADES))) break;
         if (!IsOptimization()) Print("Market Order ", ls_28, " ¹ ", l_ticket_36, " is opening!");
         if (a_cmd_0 == OP_BUY) l_price_40 = dGet_SL(0, OrderOpenPrice());
         if (a_cmd_0 == OP_SELL) l_price_40 = dGet_SL(1, OrderOpenPrice());
         if (!OrderModify(l_ticket_36, OrderOpenPrice(), l_price_40, 0, 0, l_color_12))
            if (!IsOptimization()) Print("StartModify StopLoss Error", GetLastError());
         if (a_cmd_0 == OP_BUY) l_price_48 = dGet_TP(0, OrderOpenPrice());
         if (a_cmd_0 == OP_SELL) l_price_48 = dGet_TP(1, OrderOpenPrice());
         if (!(!OrderModify(l_ticket_36, OrderOpenPrice(), l_price_40, l_price_48, 0, l_color_12))) break;
         if (!(!IsOptimization())) break;
         Print("StartModify TakeProfit Error ", GetLastError());
         return;
      }
      if (iCheckError(GetLastError(), a_cmd_0) != 1) break;
   }
}

double dAutoLot() {
   double ld_ret_0;
   double l_marginrequired_8;
   double ld_16;
   if (gi_96 == 0) ld_ret_0 = Lot;
   if (gi_96 == 1) ld_ret_0 = NormalizeDouble(AccountEquity() / 100000.0 * gd_100, gi_192);
   if (gi_96 == 2) ld_ret_0 = NormalizeDouble(AccountFreeMargin() / 100000.0 * gd_100, gi_192);
   if (gi_96 == 3) ld_ret_0 = NormalizeDouble(AccountBalance() / 100000.0 * gd_100, gi_192);
   if (gi_96 == 4) {
      l_marginrequired_8 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
      ld_16 = AccountEquity() * gd_100 / 100.0;
      ld_ret_0 = NormalizeDouble(ld_16 / l_marginrequired_8, gi_192);
   }
   if (ld_ret_0 > g_maxlot_168) ld_ret_0 = g_maxlot_168;
   if (ld_ret_0 < g_minlot_176) ld_ret_0 = g_minlot_176;
   return (ld_ret_0);
}

double dGet_TP(int ai_0, double ad_unused_4) {
   double ld_ret_12;
   if (ai_0 == 0) {
      ld_ret_12 = ND(gd_280);
      if (!IsTesting()) RefreshRates();
      if (ld_ret_12 < ND(Bid + gd_200 * gd_152) && ld_ret_12 > 0.0) ld_ret_12 = ND(Bid + gd_200 * gd_152);
   }
   if (ai_0 == 1) {
      ld_ret_12 = ND(gd_288);
      if (!IsTesting()) RefreshRates();
      if (ld_ret_12 > ND(Ask - gd_200 * gd_152)) ld_ret_12 = ND(Ask - gd_200 * gd_152);
   }
   return (ld_ret_12);
}

double dGet_SL(int ai_0, double ad_unused_4) {
   double ld_ret_12;
   if (ai_0 == 0) {
      ld_ret_12 = ND(gd_272);
      if (!IsTesting()) RefreshRates();
      if (ld_ret_12 > ND(Bid - gd_200 * gd_152)) ld_ret_12 = ND(Bid - gd_200 * gd_152);
   }
   if (ai_0 == 1) {
      ld_ret_12 = ND(gd_264);
      if (!IsTesting()) RefreshRates();
      if (ld_ret_12 < ND(Ask + gd_200 * gd_152) && ld_ret_12 > 0.0) ld_ret_12 = ND(Ask + gd_200 * gd_152);
   }
   return (ld_ret_12);
}

int iCheckError(int ai_0, int ai_4) {
   switch (ai_0) {
   case 4:
      Alert(Symbol(), ": Trade server is busy. Try repeat...");
      Sleep(3000);
      return (1);
   case 6:
      Alert(Symbol(), ": No connection with trade server. Try repeat...");
      Sleep(5000);
      return (1);
   case 128:
      Alert(Symbol(), ": Trade timeout. Try repeat...");
      Sleep(66000);
      if (ai_4 <= 1)
         if (iCountMarket_Orders(ai_4) > 0) return (0);
      return (1);
   case 130:
      Alert(Symbol(), ": Invalid stops. Try repeat...");
      gd_200 += 0.5;
      return (1);
   case 142:
      Alert(Symbol(), ": Trade timeout. Try repeat...");
      Sleep(66000);
      if (ai_4 <= 1)
         if (iCountMarket_Orders(ai_4) > 0) return (0);
      return (1);
   case 143:
      Alert(Symbol(), ": Trade timeout. Try repeat...");
      Sleep(66000);
      if (ai_4 <= 1)
         if (iCountMarket_Orders(ai_4) > 0) return (0);
      return (1);
   case 129:
      Alert(Symbol(), ": Invalid price. Try repeat...");
      Sleep(3000);
      return (1);
   case 135:
      Alert(Symbol(), ": Price changed. Try repeat...");
      RefreshRates();
      return (1);
   case 136:
      Alert(Symbol(), ": Off quotes. Wait new tick...");
      while (!RefreshRates()) Sleep(1);
      return (1);
   case 137:
      Alert(Symbol(), ": Broker is busy. Try repeat...");
      Sleep(3000);
      return (1);
   case 138:
      Alert(Symbol(), ": Requote. Try repeat...");
      Sleep(5000);
      return (1);
   case 146:
      Alert(Symbol(), ": Trade context is busy. Try repeat...");
      Sleep(500);
      return (1);
   case 2:
      Alert("Common error.");
      return (0);
   case 5:
      Alert("Old version of the client terminal.");
      gi_196 = FALSE;
      return (0);
   case 64:
      Alert("Account disabled.");
      gi_196 = FALSE;
      return (0);
   case 133:
      Alert("Trade is disabled.");
      return (0);
   case 134:
      Alert(Symbol(), ": Not enough money.");
      return (0);
   }
   Alert(Symbol(), ": Is other error ", ai_0);
   return (0);
}

double ND(double ad_0) {
   return (NormalizeDouble(ad_0, Digits));
}

bool bTradeTime() {
   if (gi_124 == 0) return (TRUE);
   int li_0 = gi_128 + 1 + gi_224;
   if (li_0 > 23) li_0 -= 24;
   int li_4 = gi_132 + gi_224;
   if (li_4 > 23) li_4 -= 24;
   bool li_ret_8 = FALSE;
   if (li_0 < li_4) {
      if (li_0 <= Hour() && Hour() < li_4) li_ret_8 = TRUE;
   } else
      if (li_0 <= Hour() || Hour() < li_4) li_ret_8 = TRUE;
   return (li_ret_8);
}

int iCountMarket_Orders(int a_cmd_0 = -1) {
   int l_count_4 = 0;
   int l_ord_total_8 = OrdersTotal();
   for (int l_pos_12 = 0; l_pos_12 < l_ord_total_8; l_pos_12++) {
      if (OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() <= OP_SELL)
            if (OrderType() == a_cmd_0 || a_cmd_0 == -1) l_count_4++;
      }
   }
   return (l_count_4);
}

void CloseOrders(int a_cmd_0 = -1) {
   color l_color_8;
   double l_price_12;
   string ls_20;
   bool l_ord_close_28;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      while (iCheckError(GetLastError(), OrderType()) == 1) {
         if (!IsTesting()) {
            while (!IsTradeAllowed()) Sleep(5000);
            RefreshRates();
         }
         if (OrderType() == OP_BUY) {
            l_color_8 = Blue;
            l_price_12 = ND(Bid);
            ls_20 = "Buy";
            if (l_price_12 >= OrderTakeProfit() && OrderTakeProfit() != 0.0 || OrderTicket() == 0) return;
         }
         if (OrderType() == OP_SELL) {
            l_color_8 = Red;
            l_price_12 = ND(Ask);
            ls_20 = "Sell";
            if (l_price_12 <= OrderTakeProfit() || OrderTicket() == 0) return;
         }
         l_ord_close_28 = OrderClose(OrderTicket(), OrderLots(), l_price_12, g_slippage_164, l_color_8);
         if (l_ord_close_28) {
            if (!(!IsOptimization())) break;
            Print("Market Order ", ls_20, " ¹ ", OrderTicket(), " is closing.");
            break;
         }
      }
   }
}

int get_UTC_time() {
   int lia_0[4];
   GetSystemTime(lia_0);
   string ls_4 = (lia_0[0] & 65535) + "." + (lia_0[0] >> 16) + "." + (lia_0[1] >> 16) + " " + (lia_0[2] & 65535) + ":" + (lia_0[2] >> 16) + ":" + (lia_0[3] & 65535);
   return (StrToTime(ls_4));
}

int get_UTC_OFFSET() {
   int li_0 = get_UTC_time();
   double ld_4 = TimeCurrent() - li_0;
   ld_4 /= 3600.0;
   ld_4 = MathRound(ld_4);
   int li_ret_12 = ld_4;
   return (li_ret_12);
}

void SetLevel(string as_0, double a_price_8, color a_color_16, int ai_20) {
   string l_name_24 = "[Calc] " + as_0 + " Label";
   string l_name_32 = "[Calc] " + as_0;
   int li_unused_40 = MarketInfo(Symbol(), MODE_DIGITS);
   if (ObjectFind(l_name_24) != 0) ObjectCreate(l_name_24, OBJ_TEXT, 0, MathMin(Time[gi_308], ai_20), a_price_8);
   else ObjectMove(l_name_24, 0, MathMin(Time[gi_308], ai_20), a_price_8);
   ObjectSetText(l_name_24, " " + as_0 + ": " + DoubleToStr(a_price_8, Digits), 8, "Arial", White);
   if (ObjectFind(l_name_32) != 0) {
      ObjectCreate(l_name_32, OBJ_TREND, 0, ai_20, a_price_8, ai_20 + 86400, a_price_8);
      ObjectSet(l_name_32, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet(l_name_32, OBJPROP_COLOR, a_color_16);
      return;
   }
   ObjectMove(l_name_32, 1, ai_20 + 86400, a_price_8);
   ObjectMove(l_name_32, 0, ai_20, a_price_8);
}