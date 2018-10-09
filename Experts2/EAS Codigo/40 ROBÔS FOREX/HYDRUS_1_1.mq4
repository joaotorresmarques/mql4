
#property copyright "HYDRUS 1.1 © FOREXAC"
#property link      "http://forexac.com"

extern int period = 156;
extern int channel = 170;
extern int takeprofit1 = 55;
extern int takeprofit2 = 89;
extern int takeprofit3 = 144;
extern int takeprofit4 = 233;
extern int takeprofit5 = 377;
extern int periodMA = 5;
extern int trailing = 0;
extern int risk = 90;
extern int максимум_ордеров = 5;
extern int безубыточность = 0;
extern int Delta_EMA = 10;
extern int Выходной_I = 0;
extern int Выходной_II = 0;
extern int время_старт = 0;
extern int время_конец = 24;
extern int угол_вывода_ордеров = 1;
extern double lot = 1.0;
extern color WhiteColor = Silver;
extern int Key = 0;
int Gi_164;
int Gi_168;
int Gi_172;
int G_acc_number_176;
int G_ticket_180;
int Gi_184;
int G_hour_188;
double Gd_196;
double Gd_204;
double Gd_unused_220;
double Gd_228;
double Gd_236 = 0.0;
double Gd_244;
double G_price_252;
double G_price_260;
double G_price_268;
double G_price_276;
double G_price_284;
double G_price_292;
double Gd_300;
double G_free_magrin_308;
double Gda_unused_316[25][5];
double Gda_320[25][10];
string G_comment_324;
string Gs_332;
string Gs_340;
string G_time2str_348;
string G_time2str_356;
string Gs_364;
bool Gi_372;
bool Gi_376;
int Gi_unused_380;
double Gd_384;
double Gd_392;
bool Gi_400;

// E37F0136AA3FFAF149B351F6A4C948E9
void init() {
   f0_3();
   Gi_164 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   Gd_392 = MarketInfo(Symbol(), MODE_MAXLOT);
   Gd_384 = MarketInfo(Symbol(), MODE_MINLOT);
   if (IsDemo() || IsTesting()) Gi_400 = FALSE;
   else Gi_400 = TRUE;
   G_acc_number_176 = AccountNumber();
   Gs_340 = "HYDRUS 1.1 © FOREXAC" 
      + "\n" 
      + "период усреднения EMA ........ " + period 
      + "\n" 
      + "ширина канала ....................... " + channel 
      + "\n" 
   + "takeprofit  .............................. " + takeprofit1;
   if (максимум_ордеров > 1) Gs_340 = Gs_340 + " " + takeprofit2;
   if (максимум_ордеров > 2) Gs_340 = Gs_340 + " " + takeprofit3;
   if (максимум_ордеров > 3) Gs_340 = Gs_340 + " " + takeprofit4;
   if (максимум_ордеров > 4) Gs_340 = Gs_340 + " " + takeprofit5;
   Gs_340 = Gs_340 
      + "\n" 
   + "период работы ....................... с " + время_старт + " до " + время_конец;
   if (Выходной_I != 0 || Выходной_II != 0) Gs_340 = Gs_340 + " выходной " + f0_6(Выходной_I) + " " + f0_6(Выходной_II);
   if (trailing != 0) {
      if (trailing < Gi_164) trailing = Gi_164;
      Gs_340 = Gs_340 
         + "\n" 
      + "трейлинг ............................... " + trailing;
   }
   Gs_340 = Gs_340 
      + "\n" 
   + "маx ордер .............................. " + максимум_ордеров;
   if (lot != 0.0) {
      if (lot > Gd_392) lot = Gd_392;
      if (lot < Gd_384) lot = Gd_384;
      Gs_340 = Gs_340 
         + "\n" 
      + "фиксированный лот ...............  " + DoubleToStr(lot, 2);
      Gi_376 = TRUE;
   } else {
      lot = AccountFreeMargin() * risk / 100.0 / MarketInfo(Symbol(), MODE_MARGINREQUIRED) / максимум_ордеров;
      if (lot > Gd_392) lot = Gd_392;
      if (lot < Gd_384) lot = Gd_384;
      Gs_340 = Gs_340 
         + "\n" 
      + "плавающий лот ...................... " + DoubleToStr(lot, 2);
      Gi_376 = FALSE;
   }
   if (безубыточность != 0) {
      if (безубыточность < Gi_164) безубыточность = Gi_164;
      Gs_340 = Gs_340 
         + "\n" 
      + "установлена безубыточность   " + безубыточность;
   }
   Comment(Gs_340);
}

// EA2B2676C28C0DB26D39331A336C6B92
void start() {
   if (Gi_400 && Key != 3 * G_acc_number_176 - 11675) {
      Comment("Демо версия,\nДля получения ключа обратитесь http://support.forexac.com/, сообщите ", G_acc_number_176);
      return;
   }
   G_comment_324 = "Ошибка";
   if (ObjectFind("час") != 0) f0_3();
   G_time2str_356 = TimeToStr(TimeCurrent(), TIME_DATE);
   G_hour_188 = Hour();
   int day_of_week_0 = DayOfWeek();
   if (G_hour_188 >= время_старт && G_hour_188 <= время_конец) Gi_372 = TRUE;
   else Gi_372 = FALSE;
   if (day_of_week_0 == Выходной_I || day_of_week_0 == Выходной_II) Gi_372 = FALSE;
   Gs_364 = f0_6(TimeDayOfWeek(TimeCurrent()));
   G_time2str_348 = TimeToStr(TimeCurrent(), TIME_MINUTES);
   if (Gi_164 != MarketInfo(Symbol(), MODE_STOPLEVEL)) {
      Gi_164 = MarketInfo(Symbol(), MODE_STOPLEVEL);
      ObjectSetText("час", Gs_364 + " " + G_time2str_348 + " min SL " + Gi_164, 8, "Arial", Red);
   } else ObjectSetText("час", Gs_364 + " " + G_time2str_348 + " min SL " + Gi_164, 8, "Arial", WhiteColor);
   if (trailing < Gi_164 && trailing != 0) trailing = Gi_164;
   G_free_magrin_308 = AccountFreeMargin();
   Gd_300 = G_free_magrin_308 / MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   Gi_172 = WindowFirstVisibleBar();
   Gd_196 = WindowPriceMax();
   Gd_204 = WindowPriceMin();
   Gd_unused_220 = WindowBarsPerChart() / 80;
   Gd_228 = (Gd_196 - Gd_204) / 50.0;
   if (!Gi_376) {
      lot = NormalizeDouble(G_free_magrin_308 * risk / 100.0 / MarketInfo(Symbol(), MODE_MARGINREQUIRED) / максимум_ордеров, 2);
      if (lot > Gd_392) lot = Gd_392;
      if (lot < Gd_384) lot = Gd_384;
   }
   double Ld_4 = NormalizeDouble(iMA(NULL, 0, period, 0, MODE_EMA, PRICE_CLOSE, 0), Digits);
   if (MathAbs(Gd_236 - Ld_4) / Point > Delta_EMA && Gd_236 != 0.0) {
      Gd_236 = Ld_4;
      f0_9(Ld_4);
   } else
      if (Gd_236 == 0.0) Gd_236 = Ld_4;
   Gi_168 = f0_0();
   f0_5();
   Gi_184 = Gda_320[0][0];
   if (Gi_184 > 0) {
      f0_7();
      f0_8();
   }
   Gd_244 = 0;
   for (int Li_12 = 1; Li_12 <= Gda_320[0][0]; Li_12++) Gd_244 += Gda_320[Li_12][8] * Gda_320[Li_12][5] * MarketInfo(Symbol(), MODE_TICKVALUE);
   if (lot != 0.0) {
      ObjectSetText("БАЛАНС", "  БАЛАНС = " + DoubleToStr(AccountBalance(), 2) + " |своб " + DoubleToStr(G_free_magrin_308, 2) + " " + DoubleToStr(Gd_300, 2), 8, "Arial",
         WhiteColor);
   }
   if (lot == 0.0) ObjectSetText("БАЛАНС", "  БАЛАНС = " + DoubleToStr(AccountBalance(), 2) + " |своб " + DoubleToStr(G_free_magrin_308, 2) + " |  лимит ставок ", 8, "Arial", WhiteColor);
   if (Gd_244 < 0.0) ObjectSetText("доход", StringConcatenate("  доход = ", DoubleToStr(Gd_244, 2)), 8, "Arial", Tomato);
   if (Gd_244 > 0.0) ObjectSetText("доход", StringConcatenate("  доход = ", DoubleToStr(Gd_244, 2)), 8, "Arial", Aqua);
   if (Gi_184 == 0) ObjectSetText("доход", "                ", 8, "Arial", Aqua);
   if (!Gi_372) {
      Comment(Gs_340, 
      "\n\nНе торговое время ");
      f0_1(OP_SELLSTOP);
      f0_1(OP_BUYSTOP);
      return;
   }
   if (lot == 0.0) {
      Comment("Недостаточно средств ");
      Sleep(5000);
      return;
   }
   if (Gi_184 > максимум_ордеров) {
      Comment(Gs_340, 
      "\n\nДостигнуто максимальное кол-во ордеров " + максимум_ордеров);
      Sleep(5000);
      return;
   }
   switch (Gi_168) {
   case 1:
      f0_4(0);
      return;
   case -1:
      f0_4(1);
      return;
      return;
   }
}

// 53CA49C675D40418E8382B3CED1FE227
string f0_6(int Ai_0) {
   switch (Ai_0) {
   case 1:
      return ("Понедельник ");
   case 2:
      return ("Вторник ");
   case 3:
      return ("Среда ");
   case 4:
      return ("Четверг ");
   case 5:
      return ("Пятница ");
   case 6:
      return ("Суббота ");
   case 7:
      return ("Воскресенье ");
   }
   return ("");
}

// 5D0339F115208FDCD8678ECDA5223D7F
void f0_7() {
   string name_0;
   for (int Li_8 = 1; Li_8 <= Gda_320[0][0]; Li_8++) {
      if (Gda_320[Li_8][6] == 1.0) name_0 = "ордер Bay  " + DoubleToStr(Gda_320[Li_8][4], 0);
      if (Gda_320[Li_8][6] == -1.0) name_0 = "ордер Sell " + DoubleToStr(Gda_320[Li_8][4], 0);
      ObjectDelete(name_0);
      ObjectDelete(name_0 + " з");
      if (Gda_320[Li_8][6] == 1.0) {
         ObjectCreate(name_0, OBJ_TREND, 0, Gda_320[Li_8][9], Gda_320[Li_8][1], Time[0], Bid);
         ObjectSet(name_0, OBJPROP_COLOR, LightSkyBlue);
         ObjectCreate(name_0 + " з", OBJ_ARROW, 0, Time[0], Bid, 0, 0, 0, 0);
      }
      if (Gda_320[Li_8][6] == -1.0) {
         ObjectCreate(name_0, OBJ_TREND, 0, Gda_320[Li_8][9], Gda_320[Li_8][1], Time[0], Ask);
         ObjectSet(name_0, OBJPROP_COLOR, Pink);
         ObjectCreate(name_0 + " з", OBJ_ARROW, 0, Time[0], Ask, 0, 0, 0, 0);
      }
      ObjectSet(name_0, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(name_0, OBJPROP_RAY, FALSE);
      ObjectSet(name_0 + " з", OBJPROP_ARROWCODE, 3);
      ObjectSet(name_0 + " з", OBJPROP_COLOR, WhiteColor);
   }
}

// 514D8A494F087C0D549B9536C2EF3BD9
void f0_5() {
   int x_8;
   int cmd_16;
   double Ld_20;
   string name_28;
   int index_0 = 0;
   int Li_unused_4 = 0;
   string Ls_unused_36 = "";
   ArrayInitialize(Gda_320, 0);
   if (ObjectFind("заголовок") == 0) {
      x_8 = ObjectGet("заголовок", OBJPROP_XDISTANCE);
      Ld_20 = ObjectGet("заголовок", OBJPROP_YDISTANCE);
   } else {
      x_8 = 10;
      Ld_20 = 10 * index_0 + 60;
   }
   for (int pos_44 = 1; pos_44 <= максимум_ордеров * 2; pos_44++) {
      name_28 = "ОРДЕР " + pos_44;
      ObjectDelete(name_28);
   }
   for (pos_44 = 0; pos_44 < OrdersTotal(); pos_44++) {
      if (OrderSelect(pos_44, SELECT_BY_POS) == TRUE && OrderSymbol() == Symbol()) {
         cmd_16 = OrderType();
         if (cmd_16 < OP_BUYLIMIT) {
            index_0++;
            Gda_320[index_0][1] = NormalizeDouble(OrderOpenPrice(), Digits);
            Gda_320[index_0][2] = NormalizeDouble(OrderStopLoss(), Digits);
            Gda_320[index_0][3] = NormalizeDouble(OrderTakeProfit(), Digits);
            Gda_320[index_0][4] = OrderTicket();
            Gda_320[index_0][5] = OrderLots();
            if (cmd_16 == OP_BUY) {
               Gda_320[index_0][6] = 1;
               Gs_332 = "Buy ";
            } else {
               Gda_320[index_0][6] = -1;
               Gs_332 = "Sell ";
            }
            Gda_320[index_0][7] = OrderMagicNumber();
            Gda_320[index_0][9] = OrderOpenTime();
            if (Gda_320[index_0][6] == 1.0) Gda_320[index_0][8] = NormalizeDouble((Bid - Gda_320[index_0][1]) / Point, 0);
            else Gda_320[index_0][8] = NormalizeDouble((Gda_320[index_0][1] - Ask) / Point, 0);
            name_28 = "ОРДЕР " + index_0;
            ObjectDelete(name_28);
            ObjectCreate(name_28, OBJ_LABEL, 0, 0, 0);
            ObjectSet(name_28, OBJPROP_CORNER, угол_вывода_ордеров);
            ObjectSet(name_28, OBJPROP_XDISTANCE, x_8);
            ObjectSet(name_28, OBJPROP_YDISTANCE, Ld_20 + 10 * index_0);
            ObjectSetText(name_28, StringConcatenate("  ", DoubleToStr(Gda_320[index_0][8], 0), "  ", Gs_332, "  ", Gda_320[index_0][4], "   ", DoubleToStr(Gda_320[index_0][1],
               Digits), "  ", DoubleToStr(Gda_320[index_0][5], 2), "  ", DoubleToStr((Bid - Gda_320[index_0][2]) / Point, 0), "  ", DoubleToStr((Bid - Gda_320[index_0][3]) / Point,
               0), "  ", TimeToStr(TimeCurrent() - Gda_320[index_0][9], TIME_MINUTES)), 8, "Arial", WhiteColor);
         }
      }
   }
   Gda_320[0][0] = index_0;
   if (Gda_320[0][0] != 0.0) ObjectSetText("заголовок", "      п    тип      ОРДЕР     ц откр   лот  SL  ТР  время", 8, "Arial", Aquamarine);
   else ObjectSetText("заголовок", " ", 8, "Arial", Aquamarine);
   ObjectSet("заголовок", OBJPROP_CORNER, угол_вывода_ордеров);
}

// 4A3B8FD957E15C31B3C3B31B23CE1182
void f0_3() {
   ObjectCreate("час", OBJ_LABEL, 0, 0, 0);
   ObjectSet("час", OBJPROP_CORNER, 1);
   ObjectSet("час", OBJPROP_XDISTANCE, 10);
   ObjectSet("час", OBJPROP_YDISTANCE, 13);
   ObjectCreate("заголовок", OBJ_LABEL, 0, 0, 0);
   ObjectSet("заголовок", OBJPROP_CORNER, угол_вывода_ордеров);
   ObjectSet("заголовок", OBJPROP_XDISTANCE, 10);
   ObjectSet("заголовок", OBJPROP_YDISTANCE, 60);
   ObjectCreate("БАЛАНС", OBJ_LABEL, 0, 0, 0);
   ObjectSet("БАЛАНС", OBJPROP_CORNER, 1);
   ObjectSet("БАЛАНС", OBJPROP_XDISTANCE, 10);
   ObjectSet("БАЛАНС", OBJPROP_YDISTANCE, 25);
   ObjectCreate("доход", OBJ_LABEL, 0, 0, 0);
   ObjectSet("доход", OBJPROP_CORNER, 1);
   ObjectSet("доход", OBJPROP_XDISTANCE, 10);
   ObjectSet("доход", OBJPROP_YDISTANCE, 35);
}

// 7E3AB1595197CD47BE16B078E07D628C
void f0_8() {
   double Ld_0;
   double Ld_8;
   int Li_16;
   for (int Li_20 = 1; Li_20 <= Gi_184; Li_20++) {
      Li_16 = Gda_320[Li_20][4];
      if (Gda_320[Li_20][8] > trailing && trailing != 0) {
         G_comment_324 = "TrailingStop ";
         Gi_unused_380 = 25600;
         if (Gda_320[Li_20][6] == 1.0) {
            Ld_0 = NormalizeDouble(Bid - trailing * Point, Digits);
            Ld_8 = Gda_320[Li_20][3];
            if (Ld_0 <= Gda_320[Li_20][2]) continue;
            f0_11(Li_16, Li_20, Ld_0, Ld_8);
            continue;
         }
         if (Gda_320[Li_20][6] == -1.0) {
            Ld_0 = NormalizeDouble(Ask + trailing * Point, Digits);
            Ld_8 = Gda_320[Li_20][3];
            if (Ld_0 >= Gda_320[Li_20][2]) continue;
            f0_11(Li_16, Li_20, Ld_0, Ld_8);
            continue;
         }
      }
      if ((Gi_168 == 1 && Gda_320[Li_20][6] == -1.0) || (Gi_168 == -1 && Gda_320[Li_20][6] == 1.0)) {
         if (Gi_168 == -1) f0_2(0);
         if (Gi_168 == 1) f0_2(1);
      } else {
         if (Gda_320[Li_20][8] > безубыточность && безубыточность != 0) {
            G_comment_324 = "Граница безубыточности";
            Gi_unused_380 = 25600;
            if (Gda_320[Li_20][6] == 1.0) {
               Ld_8 = Gda_320[Li_20][3];
               if (Gda_320[Li_20][2] < Gda_320[Li_20][1]) {
                  Ld_0 = NormalizeDouble(Bid - безубыточность * Point, Digits);
                  if (Ld_0 > Gda_320[Li_20][2] && Ld_0 > Gda_320[Li_20][1]) {
                     f0_11(Li_16, Li_20, Ld_0, Ld_8);
                     continue;
                  }
               }
               if (Gda_320[Li_20][8] > takeprofit2 - channel) {
                  Ld_0 = NormalizeDouble(Gda_320[Li_20][1] + (takeprofit1 - channel) * Point, Digits);
                  if (Ld_0 > Gda_320[Li_20][2]) {
                     f0_11(Li_16, Li_20, Ld_0, Ld_8);
                     continue;
                  }
               }
            }
            if (Gda_320[Li_20][6] == -1.0) {
               Ld_8 = Gda_320[Li_20][3];
               if (Gda_320[Li_20][2] > Gda_320[Li_20][1]) {
                  Ld_0 = NormalizeDouble(Ask + безубыточность * Point, Digits);
                  if (Ld_0 < Gda_320[Li_20][2] && Ld_0 < Gda_320[Li_20][1]) {
                     f0_11(Li_16, Li_20, Ld_0, Ld_8);
                     continue;
                  }
               }
               if (Gda_320[Li_20][8] > takeprofit2 - channel) {
                  Ld_0 = NormalizeDouble(Gda_320[Li_20][1] - (takeprofit1 - channel) * Point, Digits);
                  if (Ld_0 < Gda_320[Li_20][2]) f0_11(Li_16, Li_20, Ld_0, Ld_8);
               }
            }
         }
      }
   }
}

// ED4958821F4F92C0507F50146EB3CD6E
void f0_11(int A_ticket_0, int Ai_4, double A_price_8, double A_price_16) {
   Gs_332 = G_comment_324 + " " + G_time2str_348;
   OrderSelect(A_ticket_0, SELECT_BY_TICKET);
   if (A_price_8 == NormalizeDouble(OrderStopLoss(), Digits) && A_price_16 == NormalizeDouble(OrderTakeProfit(), Digits)) return;
   if (OrderType() == OP_BUY && Bid - Gi_164 * Point < A_price_8 || Ask + Gi_164 * Point > A_price_16) return;
   if (OrderType() == OP_SELL && Ask + Gi_164 * Point > A_price_8 || Bid - Gi_164 * Point < A_price_16) return;
   if (!OrderModify(A_ticket_0, OrderOpenPrice(), A_price_8, A_price_16, 0, WhiteColor)) Print(Symbol(), "Ошибка ", GetLastError(), " ордер ", A_ticket_0, "   SL ", Gda_320[Ai_4][2], " -> ", A_price_8, "   TP ", Gda_320[Ai_4][3], " -> ", A_price_16);
}

// 4DCDA4F04E70FBAC30A9E95BCB0A0A98
void f0_4(int Ai_0) {
   double price_4;
   for (int magic_12 = 1; magic_12 <= максимум_ордеров; magic_12++) {
      switch (magic_12) {
      case 1:
         price_4 = G_price_260;
         break;
      case 2:
         price_4 = G_price_268;
         break;
      case 3:
         price_4 = G_price_276;
         break;
      case 4:
         price_4 = G_price_284;
         break;
      default:
         price_4 = G_price_292;
      }
      if (f0_10(1) >= максимум_ордеров) break;
      if (Ai_0 == 0) G_ticket_180 = OrderSend(Symbol(), OP_BUY, lot, NormalizeDouble(Ask, Digits), 2, G_price_252, price_4, G_comment_324, magic_12, 3);
      if (Ai_0 == 1) G_ticket_180 = OrderSend(Symbol(), OP_SELL, lot, NormalizeDouble(Bid, Digits), 2, G_price_252, price_4, G_comment_324, magic_12, 3);
      if (G_ticket_180 > 0) {
         if (Ai_0 == 0) {
            ObjectCreate("Bay " + G_time2str_348, OBJ_ARROW, 0, Time[0], Ask, 0, 0, 0, 0);
            ObjectSet("Bay " + G_time2str_348, OBJPROP_ARROWCODE, 2);
            ObjectSet("Bay " + G_time2str_348, OBJPROP_COLOR, WhiteColor);
         }
         if (Ai_0 == 1) {
            ObjectCreate("Sell " + G_time2str_348, OBJ_ARROW, 0, Time[0], Bid, 0, 0, 0, 0);
            ObjectSet("Sell " + G_time2str_348, OBJPROP_ARROWCODE, 2);
            ObjectSet("Sell " + G_time2str_348, OBJPROP_COLOR, WhiteColor);
         }
         ObjectCreate(G_comment_324 + "  " + G_time2str_348, OBJ_TREND, 0, Time[0], Low[0], Time[0], Low[0] - Point);
         ObjectSet(G_comment_324 + "  " + G_time2str_348, OBJPROP_COLOR, SteelBlue);
         ObjectSet(G_comment_324 + "  " + G_time2str_348, OBJPROP_STYLE, STYLE_DOT);
         ObjectSet(G_comment_324 + "  " + G_time2str_348, OBJPROP_WIDTH, 1);
         ObjectSet(G_comment_324 + "  " + G_time2str_348, OBJPROP_RAY, TRUE);
      } else Print("неудачная покупка ERROR ", Symbol(), " Ошибка ", GetLastError());
   }
}

// 085FEA7ABDC5D904FE69A3081EFD7398
int f0_0() {
   double price_68;
   int Li_76;
   color color_0 = Orange;
   color color_4 = Aqua;
   double Ld_8 = NormalizeDouble(iMA(NULL, 0, periodMA, 0, MODE_SMMA, PRICE_MEDIAN, 0), Digits);
   double Ld_16 = NormalizeDouble(iMA(NULL, 0, periodMA, 0, MODE_SMMA, PRICE_MEDIAN, 1), Digits);
   double Ld_24 = NormalizeDouble(iMA(NULL, 0, period, 0, MODE_EMA, PRICE_CLOSE, 1), Digits);
   double Ld_32 = NormalizeDouble(Ld_24 + channel * Point, Digits);
   double Ld_40 = NormalizeDouble(Ld_24 - channel * Point, Digits);
   Ld_24 = NormalizeDouble(iMA(NULL, 0, period, 0, MODE_EMA, PRICE_CLOSE, 0), Digits);
   double price_48 = NormalizeDouble(Ld_24 + channel * Point, Digits);
   double price_56 = NormalizeDouble(Ld_24 - channel * Point, Digits);
   int Li_ret_64 = 0;
   if (price_48 >= Ld_8 && price_48 <= Ld_8 && Ld_16 < Ld_32) Li_ret_64 = 1;
   if (price_56 >= Ld_8 && price_56 <= Ld_8 && Ld_16 > Ld_40) Li_ret_64 = -1;
   if (Ld_24 >= Ld_8 && Ld_24 <= Ld_8) Li_ret_64 = 2;
   ObjectDelete(" Price_Resistance");
   ObjectCreate(" Price_Resistance", OBJ_ARROW, 0, Time[0], price_48, 0, 0, 0, 0);
   ObjectSet(" Price_Resistance", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
   ObjectSet(" Price_Resistance", OBJPROP_COLOR, color_0);
   ObjectDelete(" Price_Support");
   ObjectCreate(" Price_Support", OBJ_ARROW, 0, Time[0], price_56, 0, 0, 0, 0);
   ObjectSet(" Price_Support", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
   ObjectSet(" Price_Support", OBJPROP_COLOR, color_4);
   if (Li_ret_64 != 0) {
      if (Li_ret_64 == 2) {
         Li_76 = максимум_ордеров - f0_10(2);
         for (int magic_80 = 1; magic_80 <= Li_76; magic_80++) {
            switch (magic_80) {
            case 1:
               price_68 = NormalizeDouble(Ld_24 - takeprofit1 * Point, Digits);
               break;
            case 2:
               price_68 = NormalizeDouble(Ld_24 - takeprofit2 * Point, Digits);
               break;
            case 3:
               price_68 = NormalizeDouble(Ld_24 - takeprofit3 * Point, Digits);
               break;
            case 4:
               price_68 = NormalizeDouble(Ld_24 - takeprofit4 * Point, Digits);
               break;
            default:
               price_68 = NormalizeDouble(Ld_24 - takeprofit5 * Point, Digits);
            }
            if (NormalizeDouble((Bid - price_56) / Point, Digits) >= Gi_164) OrderSend(Symbol(), OP_SELLSTOP, lot, price_56, 2, price_48, price_68, "SELLSTOP", magic_80, 0, Red);
         }
         Li_76 = максимум_ордеров - f0_10(3);
         for (magic_80 = 1; magic_80 <= Li_76; magic_80++) {
            switch (magic_80) {
            case 1:
               price_68 = NormalizeDouble(Ld_24 + takeprofit1 * Point, Digits);
               break;
            case 2:
               price_68 = NormalizeDouble(Ld_24 + takeprofit2 * Point, Digits);
               break;
            case 3:
               price_68 = NormalizeDouble(Ld_24 + takeprofit3 * Point, Digits);
               break;
            case 4:
               price_68 = NormalizeDouble(Ld_24 + takeprofit4 * Point, Digits);
               break;
            default:
               price_68 = NormalizeDouble(Ld_24 + takeprofit5 * Point, Digits);
            }
            if (NormalizeDouble((price_48 - Ask) / Point, Digits) >= Gi_164) OrderSend(Symbol(), OP_BUYSTOP, lot, price_48, 2, price_56, price_68, "BUYSTOP", magic_80, 0, Blue);
         }
      }
      if (Li_ret_64 == 1) {
         ObjectCreate("Пересечение " + Time[0], OBJ_ARROW, 0, Time[0], Ask, 0, 0, 0, 0);
         ObjectSet("Пересечение " + Time[0], OBJPROP_WIDTH, 0);
         ObjectSet("Пересечение " + Time[0], OBJPROP_COLOR, color_4);
         ObjectSet("Пересечение " + Time[0], OBJPROP_ARROWCODE, 233);
         G_comment_324 = " Пересечение верхней границы ";
         G_price_252 = price_56;
         G_price_260 = NormalizeDouble(price_48 + takeprofit1 * Point, Digits);
         G_price_268 = NormalizeDouble(price_48 + takeprofit2 * Point, Digits);
         G_price_276 = NormalizeDouble(price_48 + takeprofit3 * Point, Digits);
         G_price_284 = NormalizeDouble(price_48 + takeprofit4 * Point, Digits);
         G_price_292 = NormalizeDouble(price_48 + takeprofit5 * Point, Digits);
         f0_1(OP_SELLSTOP);
         return (1);
      }
      if (Li_ret_64 == -1) {
         ObjectCreate("Пересечение " + Time[0], OBJ_ARROW, 0, Time[0], Bid, 0, 0, 0, 0);
         ObjectSet("Пересечение " + Time[0], OBJPROP_WIDTH, 0);
         ObjectSet("Пересечение " + Time[0], OBJPROP_ARROWCODE, 234);
         ObjectSet("Пересечение " + Time[0], OBJPROP_COLOR, color_0);
         G_comment_324 = " Пересечение нижней границы ";
         G_price_252 = price_48;
         G_price_260 = NormalizeDouble(price_48 - takeprofit1 * Point, Digits);
         G_price_268 = NormalizeDouble(price_48 - takeprofit2 * Point, Digits);
         G_price_276 = NormalizeDouble(price_48 - takeprofit3 * Point, Digits);
         G_price_284 = NormalizeDouble(price_48 - takeprofit4 * Point, Digits);
         G_price_292 = NormalizeDouble(price_48 - takeprofit5 * Point, Digits);
         f0_1(OP_BUYSTOP);
         return (-1);
      }
   }
   return (Li_ret_64);
}

// 3132FBA84668739FA4096003C326DE49
void f0_2(int Ai_0) {
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY && Ai_0 == 0) OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 3, CLR_NONE);
            if (OrderType() == OP_SELL && Ai_0 == 1) OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 3, CLR_NONE);
         }
      }
   }
}

// 0D18349D57E328E35ED38A395AE0A963
void f0_1(int A_cmd_0) {
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol())
            if (OrderType() == A_cmd_0) OrderDelete(OrderTicket());
      }
   }
}

// 916FAFB3582B3E63F9D434BBDE71B0DD
int f0_10(int Ai_0) {
   int count_4 = 0;
   int count_8 = 0;
   int count_12 = 0;
   for (int pos_16 = 0; pos_16 < OrdersTotal(); pos_16++) {
      if (OrderSelect(pos_16, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol()) {
            count_4++;
            if (OrderType() == OP_SELLSTOP || OrderType() == OP_SELL) count_8++;
            if (OrderType() == OP_BUYSTOP || OrderType() == OP_BUY) count_12++;
         }
      }
   }
   if (Ai_0 == 1) return (count_4);
   if (Ai_0 == 2) return (count_8);
   if (Ai_0 == 3) return (count_12);
   return (0);
}

// 80B5A943476889553D3B08BB416B52C1
void f0_9(double Ad_0) {
   int cmd_8;
   int magic_12;
   double price_16;
   double order_open_price_24;
   for (int pos_32 = 0; pos_32 < OrdersTotal(); pos_32++) {
      if (OrderSelect(pos_32, SELECT_BY_POS, MODE_TRADES) == TRUE) {
         if (OrderSymbol() == Symbol()) {
            cmd_8 = OrderType();
            order_open_price_24 = OrderOpenPrice();
            G_comment_324 = "Измененме ЕМА ";
            Gi_unused_380 = 9109504;
            magic_12 = OrderMagicNumber();
            switch (cmd_8) {
            case OP_BUY:
               G_price_252 = NormalizeDouble(Ad_0 - channel * Point, Digits);
               switch (magic_12) {
               case 1:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit1 * Point, Digits);
                  break;
               case 2:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit2 * Point, Digits);
                  break;
               case 3:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit3 * Point, Digits);
                  break;
               case 4:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit4 * Point, Digits);
                  break;
               default:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit5 * Point, Digits);
               }
               if (!(G_price_252 > OrderStopLoss() && Bid - Gi_164 * Point > G_price_252 && Ask + Gi_164 * Point < price_16 && G_price_252 != OrderStopLoss() || price_16 != OrderTakeProfit())) break;
               f0_11(OrderTicket(), 0, G_price_252, price_16);
               break;
            case OP_SELL:
               G_price_252 = NormalizeDouble(Ad_0 + channel * Point, Digits);
               switch (magic_12) {
               case 1:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit1 * Point, Digits);
                  break;
               case 2:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit2 * Point, Digits);
                  break;
               case 3:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit3 * Point, Digits);
                  break;
               case 4:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit4 * Point, Digits);
                  break;
               default:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit5 * Point, Digits);
               }
               if (!(G_price_252 < OrderStopLoss() && Ask + Gi_164 * Point < G_price_252 && Bid - Gi_164 * Point > price_16 && G_price_252 != OrderStopLoss() || price_16 != OrderTakeProfit())) break;
               f0_11(OrderTicket(), 0, G_price_252, price_16);
               break;
            case OP_BUYSTOP:
               G_price_252 = NormalizeDouble(Ad_0 - channel * Point, Digits);
               switch (magic_12) {
               case 1:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit1 * Point, Digits);
                  break;
               case 2:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit2 * Point, Digits);
                  break;
               case 3:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit3 * Point, Digits);
                  break;
               case 4:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit4 * Point, Digits);
                  break;
               default:
                  price_16 = NormalizeDouble(Ad_0 + takeprofit5 * Point, Digits);
               }
               if (!(NormalizeDouble(order_open_price_24 - Gi_164 * Point, Digits) > G_price_252 && NormalizeDouble(order_open_price_24 + Gi_164 * Point, Digits) < price_16 && G_price_252 != OrderStopLoss() ||
                  price_16 != OrderTakeProfit())) break;
               if (!(!OrderModify(OrderTicket(), order_open_price_24, G_price_252, price_16, 0, Black))) break;
               Print("Ошибка   SL", G_price_252, "  TP ", price_16, "   OOP ", order_open_price_24);
               break;
            case OP_SELLSTOP:
               G_price_252 = NormalizeDouble(Ad_0 + channel * Point, Digits);
               switch (magic_12) {
               case 1:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit1 * Point, Digits);
                  break;
               case 2:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit2 * Point, Digits);
                  break;
               case 3:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit3 * Point, Digits);
                  break;
               case 4:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit4 * Point, Digits);
                  break;
               default:
                  price_16 = NormalizeDouble(Ad_0 - takeprofit5 * Point, Digits);
               }
               if (!(NormalizeDouble(order_open_price_24 + Gi_164 * Point, Digits) < G_price_252 && NormalizeDouble(order_open_price_24 - Gi_164 * Point, Digits) > price_16 && G_price_252 != OrderStopLoss() ||
                  price_16 != OrderTakeProfit())) break;
               if (!(!OrderModify(OrderTicket(), order_open_price_24, G_price_252, price_16, 0, Black))) break;
               Print("Ошибка   SL", G_price_252, "  TP ", price_16, "   OOP ", order_open_price_24);
            }
         }
      }
   }
}
