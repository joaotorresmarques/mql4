#property copyright "Copyright © 2013, diary-speculator.ru | trader-today.ru"
#property link      "admin@diary-speculator.ru"

extern string _ = "M15 15 | M30 30 | H1 60 | H4 240 | D1 1440 | W1 10080 | MN1 43200";
extern int TimeCandle = 1440;
extern int Delta = 100;
extern string Start_Trade = "00:01";
extern string Stop_Trade = "19:00";
int Gl_stoplevel_108 = 0;
int Gl_stoplevel_112 = 0;
int Gli_116 = 0;
int Gl_stoplevel_120 = 0;
int Gl_stoplevel_124 = 0;
extern double Lot = 2.0;
extern int MaxOrders = 3;
extern color color_BAR = Bisque;
extern string ___ = "Параметр ProfitClose НЕ МЕНЯТЬ!!!";
extern double ProfitClose = 1000000.0;
extern string coment = "600";
extern string фильтрМА = "если FastMA выше SlowMA то только Buy";
extern int periodFastMA = 0;
extern int periodSlowMA = 0;
double Gld_184;
double Gld_192;
int Gl_stoplevel_200;
int Gl_magic_204 = 5;
int Gl_cmd_208;
int Gl_datetime_212;
int Gl_datetime_216;
string Gl_str_concat_224;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   TimeCandle = f0_3(TimeCandle);
   Gl_stoplevel_200 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (Gl_stoplevel_108 < Gl_stoplevel_200) Gl_stoplevel_108 = Gl_stoplevel_200;
   if (Gl_stoplevel_112 < Gl_stoplevel_200) Gl_stoplevel_112 = Gl_stoplevel_200;
   if (Gl_stoplevel_120 < Gl_stoplevel_200 && Gl_stoplevel_120 != 0) Gl_stoplevel_120 = Gl_stoplevel_200;
   if (Gl_stoplevel_124 < Gl_stoplevel_200 && Gl_stoplevel_124 != 0) Gl_stoplevel_124 = Gl_stoplevel_200;
   Gl_str_concat_224 = StringConcatenate("Copyright © 2013, diary-speculator.ru | trader-today.ru\nУстановленные параметры BOOM " 
      + "\n" 
      + "TimeCandle  ", f0_6(TimeCandle), 
      "\n", "Отступ            ", Delta, 
      "\n", "MaxOrders   ", MaxOrders, 
      "\n", "Инвестиция               ", DoubleToStr(Lot, 2), 
   "\n");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double Lcd_0;
   int Lci_8;
   int Lci_12;
   double ima_28;
   double ima_36;
   double price_44;
   double price_52;
   if (Lcd_0 >= ProfitClose) f0_1();
   for (int pos_16 = 0; pos_16 < OrdersTotal(); pos_16++) {
      if (OrderSelect(pos_16, SELECT_BY_POS)) {
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gl_magic_204) continue;
         Gl_cmd_208 = OrderType();
         if (Gl_cmd_208 == OP_BUY) {
            Lci_8++;
            Lcd_0 += OrderProfit();
         }
         if (Gl_cmd_208 == OP_SELL) {
            Lci_12++;
            Lcd_0 += OrderProfit();
         }
      }
   }
   Comment(Gl_str_concat_224, 
      "\nБаланс ", DoubleToStr(AccountBalance(), 2), 
      "\nЭквити ", DoubleToStr(AccountEquity(), 2), 
      "\nПрофит ", DoubleToStr(Lcd_0, 2), 
      "\nCALL ", Lci_8, 
   "\nPUT ", Lci_12);
   if (Lci_8 > 0 || Lci_12 > 0) {
      if (Gl_stoplevel_124 != 0) f0_2(Gl_stoplevel_124);
      if (Gl_stoplevel_120 != 0) f0_7(Gl_stoplevel_120);
   }
   bool Lci_20 = TRUE;
   bool Lci_24 = TRUE;
   if (periodFastMA != 0 && periodSlowMA != 0) {
      ima_28 = iMA(NULL, 0, periodFastMA, 0, MODE_EMA, PRICE_OPEN, 0);
      ima_36 = iMA(NULL, 0, periodSlowMA, 0, MODE_EMA, PRICE_OPEN, 0);
      Lci_20 = ima_28 > ima_36;
      Lci_24 = ima_28 < ima_36;
   }
   Gld_184 = f0_4();
   Gld_192 = f0_0();
   if (Gli_116 != 0) Lot = f0_5();
   if (Lci_8 < MaxOrders && Gl_datetime_212 != iTime(NULL, TimeCandle, 0) && Lci_20 && Ask >= Gld_184 && TimeCurrent() >= StrToTime(Start_Trade) && TimeCurrent() < StrToTime(Stop_Trade)) {
      if (Gl_stoplevel_112 != 0) price_44 = NormalizeDouble(Gld_184 + Gl_stoplevel_112 * Point, Digits);
      else price_44 = 0;
      if (Gl_stoplevel_108 != 0) price_52 = NormalizeDouble(Gld_184 - Gl_stoplevel_108 * Point, Digits);
      else price_52 = 0;
      if (!OrderSend(Symbol(), OP_BUY, Lot, NormalizeDouble(Ask, Digits), 3, price_52, price_44, coment, Gl_magic_204, 0, Blue)) Print("Error BUYSTOP ", GetLastError(), "   ", Symbol(), "   Lot ", Lot, "   Price ", Gld_184, "   SL ", price_52, "   TP ", price_44);
      else Gl_datetime_212 = iTime(NULL, TimeCandle, 0);
   }
   if (Lci_12 < MaxOrders && Gl_datetime_216 != iTime(NULL, TimeCandle, 0) && Lci_24 && Bid <= Gld_192 && TimeCurrent() >= StrToTime(Start_Trade) && TimeCurrent() < StrToTime(Stop_Trade)) {
      if (Gl_stoplevel_112 != 0) price_44 = NormalizeDouble(Gld_192 - Gl_stoplevel_112 * Point, Digits);
      else price_44 = 0;
      if (Gl_stoplevel_108 != 0) price_52 = NormalizeDouble(Gld_192 + Gl_stoplevel_108 * Point, Digits);
      else price_52 = 0;
      if (!OrderSend(Symbol(), OP_SELL, Lot, NormalizeDouble(Bid, Digits), 3, price_52, price_44, coment, Gl_magic_204, 0, Red)) Print("Error SELLSTOP ", GetLastError(), "   ", Symbol(), "   Lot ", Lot, "   Price ", Gld_192, "   SL ", price_52, "   TP ", price_44);
      else Gl_datetime_216 = iTime(NULL, TimeCandle, 0);
   }
   if (Lci_8 < MaxOrders && Lci_12 < MaxOrders) {
      ObjectDelete("bar0");
      ObjectCreate("bar0", OBJ_RECTANGLE, 0, 0, 0, 0, 0);
      ObjectSet("bar0", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("bar0", OBJPROP_COLOR, color_BAR);
      ObjectSet("bar0", OBJPROP_BACK, TRUE);
      ObjectSet("bar0", OBJPROP_TIME1, iTime(NULL, TimeCandle, 1));
      ObjectSet("bar0", OBJPROP_PRICE1, Gld_184);
      ObjectSet("bar0", OBJPROP_TIME2, TimeCurrent());
      ObjectSet("bar0", OBJPROP_PRICE2, Gld_192);
   }
   return (0);
}

// 8866550EFA9D927B1CD257A8CAD1F257
double f0_4() {
   if (TimeCandle != PERIOD_D1) return (NormalizeDouble(iHigh(NULL, TimeCandle, 1) + Delta * Point, Digits));
   if (TimeDayOfWeek(TimeCurrent()) == 0) return (100000);
   if (TimeDayOfWeek(TimeCurrent()) > 1) return (NormalizeDouble(iHigh(NULL, TimeCandle, 1) + Delta * Point, Digits));
   if (TimeDayOfWeek(TimeCurrent()) == 1 && TimeDayOfWeek(iTime(NULL, TimeCandle, 1)) == 0) return (NormalizeDouble(iHigh(NULL, TimeCandle, 2) + Delta * Point, Digits));
   return (NormalizeDouble(iHigh(NULL, TimeCandle, 1) + Delta * Point, Digits));
}

// 1A97154A4C7E4D1C95D765D4A9C6DEE5
double f0_0() {
   if (TimeCandle != PERIOD_D1) return (NormalizeDouble(iLow(NULL, TimeCandle, 1) - Delta * Point, Digits));
   if (TimeDayOfWeek(TimeCurrent()) == 0) return (0);
   if (TimeDayOfWeek(TimeCurrent()) > 1) return (NormalizeDouble(iLow(NULL, TimeCandle, 1) - Delta * Point, Digits));
   if (TimeDayOfWeek(TimeCurrent()) == 1 && TimeDayOfWeek(iTime(NULL, TimeCandle, 1)) == 0) return (1);
   return (NormalizeDouble(iLow(NULL, TimeCandle, 1) - Delta * Point, Digits));
}

// 3AB2799732588E34138D987B460B8019
void f0_2(int Ari_0) {
   double price_4;
   double Lcd_12;
   double Lcd_20;
   int cmd_28;
   bool bool_32 = TRUE;
   int pos_40 = 0;
   while (pos_40 < OrdersTotal()) {
      if (OrderSelect(pos_40, SELECT_BY_POS)) {
         cmd_28 = OrderType();
         if (cmd_28 < OP_BUYLIMIT && OrderSymbol() == Symbol() && OrderMagicNumber() == Gl_magic_204) {
            Lcd_12 = NormalizeDouble(OrderStopLoss(), Digits);
            Lcd_20 = NormalizeDouble(OrderOpenPrice(), Digits);
            if (cmd_28 == OP_BUY) {
               price_4 = NormalizeDouble(Bid - Ari_0 * Point, Digits);
               if (price_4 >= Lcd_20)
                  if (price_4 > Lcd_12) bool_32 = OrderModify(OrderTicket(), OrderOpenPrice(), price_4, OrderTakeProfit(), 0, White);
            }
            if (cmd_28 == OP_SELL) {
               price_4 = NormalizeDouble(Ask + Ari_0 * Point, Digits);
               if (price_4 <= Lcd_20)
                  if (price_4 < Lcd_12 || Lcd_12 == 0.0) bool_32 = OrderModify(OrderTicket(), OrderOpenPrice(), price_4, OrderTakeProfit(), 0, White);
            }
            if (!bool_32) Alert("Error TrailingStop ", GetLastError(), "   ", Symbol(), "   SL ", price_4);
         }
      }
      pos_40++;
   }
}

// 995300535F52F2AF36E77BEA0739E9C5
double f0_5() {
   double Lcd_0 = MarketInfo(Symbol(), MODE_MINLOT);
   double Lcd_ret_8 = AccountFreeMargin() * Gli_116 / 100.0 / MarketInfo(Symbol(), MODE_MARGINREQUIRED) / 15.0;
   if (Lcd_ret_8 > MarketInfo(Symbol(), MODE_MAXLOT)) Lcd_ret_8 = MarketInfo(Symbol(), MODE_MAXLOT);
   if (Lcd_ret_8 < Lcd_0) Lcd_ret_8 = Lcd_0;
   if (Lcd_0 < 0.1) Lcd_ret_8 = NormalizeDouble(Lcd_ret_8, 2);
   else Lcd_ret_8 = NormalizeDouble(Lcd_ret_8, 1);
   return (Lcd_ret_8);
}

// EAF75EB8D1895D31932FBF741EF09E5A
void f0_7(int Ari_0) {
   double price_4;
   double Lcd_12;
   int cmd_20;
   bool bool_24 = TRUE;
   int pos_32 = 0;
   while (pos_32 < OrdersTotal()) {
      if (OrderSelect(pos_32, SELECT_BY_POS)) {
         cmd_20 = OrderType();
         if (cmd_20 < OP_BUYLIMIT && OrderSymbol() == Symbol() && OrderMagicNumber() != Gl_magic_204) {
            price_4 = NormalizeDouble(OrderOpenPrice(), Digits);
            Lcd_12 = NormalizeDouble(OrderStopLoss(), Digits);
            if (cmd_20 == OP_BUY)
               if ((Bid - price_4) / Point >= Ari_0 && price_4 > Lcd_12) bool_24 = OrderModify(OrderTicket(), price_4, price_4, OrderTakeProfit(), 0, White);
            if (cmd_20 == OP_SELL)
               if ((price_4 - Ask) / Point >= Ari_0 && price_4 < Lcd_12 || Lcd_12 == 0.0) bool_24 = OrderModify(OrderTicket(), price_4, price_4, OrderTakeProfit(), 0, White);
            if (!bool_24) Alert("Error No_Loss ", GetLastError(), "   ", Symbol());
         }
      }
      pos_32++;
   }
}

// 4CEF47202C318359E58492821436342B
int f0_3(int Ari_0) {
   if (Ari_0 > 43200) return (0);
   if (Ari_0 > 10080) return (43200);
   if (Ari_0 > 1440) return (10080);
   if (Ari_0 > 240) return (1440);
   if (Ari_0 > 60) return (240);
   if (Ari_0 > 30) return (60);
   if (Ari_0 > 15) return (30);
   if (Ari_0 > 5) return (15);
   if (Ari_0 > 1) return (5);
   if (Ari_0 == 1) return (1);
   if (Ari_0 == 0) return (Period());
   return (0);
}

// A9E80DEDFA897CFD8F98BAD01077E0A7
string f0_6(int Ari_0) {
   if (Ari_0 == 1) return ("M1");
   if (Ari_0 == 5) return ("M5");
   if (Ari_0 == 15) return ("M15");
   if (Ari_0 == 30) return ("M30");
   if (Ari_0 == 60) return ("H1");
   if (Ari_0 == 240) return ("H4");
   if (Ari_0 == 1440) return ("D1");
   if (Ari_0 == 10080) return ("W1");
   if (Ari_0 == 43200) return ("MN1");
   return ("ошибка периода");
}

// 3132FBA84668739FA4096003C326DE49
void f0_1() {
   bool is_closed_0;
   int Lci_8;
   int cmd_12;
   int Lci_unused_4 = 1;
   while (true) {
      is_closed_0 = TRUE;
      for (int pos_16 = OrdersTotal() - 1; pos_16 >= 0; pos_16--) {
         if (OrderSelect(pos_16, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gl_magic_204) {
               cmd_12 = OrderType();
               if (cmd_12 == OP_BUY) is_closed_0 = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 3, CLR_NONE);
               if (cmd_12 == OP_SELL) is_closed_0 = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 3, CLR_NONE);
            }
         }
      }
      if (!is_closed_0) {
         Lci_8++;
         Print("CLOSEORDER Error ", GetLastError());
         Sleep(2000);
         RefreshRates();
      }
      if (is_closed_0 || Lci_8 > 10) break;
   }
}