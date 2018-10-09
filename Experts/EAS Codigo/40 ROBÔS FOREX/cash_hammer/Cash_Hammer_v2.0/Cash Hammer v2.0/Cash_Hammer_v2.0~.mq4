
#property copyright "Forex Invest Group & Yuriy Tokman"
#property link      "trader@forexinvest.ee, yuriytokman@gmail.com"

#include <stdlib.mqh>

extern string __1__ = "Настройка анализа вечи";
extern int TF = 0;
extern int pips = 0;
extern string ____2___ = "Торговые настройки";
extern bool op_BUY = TRUE;
extern bool op_SELL = TRUE;
extern double Lots = 0.0;
extern bool Choice_method = TRUE;
extern double Risk = 0.0;
extern int StopLoss = 0;
extern int TakeProfit = 0;
extern int MagicNumber = 0;
extern int Slippage = 0;
extern int NumberOfTry = 0;
extern bool MarketWatch = FALSE;
extern string _____Трал_______ = "______Настройки трала __________________";
extern bool Traling = TRUE;
extern bool TSProfitOnly = TRUE;
extern int TStop.Buy = 0;
extern int TStop.Sell = 0;
extern int TrailingStep = 0;
extern string _____Averag_____ = "______Настройки ордеров усреднения_____";
extern bool AVERAGES = TRUE;
extern int Averag = 0;
extern double koef_averag = 0.0;
extern int alfa_lot = 0;
extern double koef_lot = 0.0;
extern double StopLoss_Av = 0.0;
extern int TakeProfit_Av = 0;
extern bool Close_and_TRL = FALSE;
extern int TRL = 0;
extern int MagNum_Av = 0;
extern color clCloseBuy = Aqua;
extern color clCloseSell = Tomato;
extern string NameCloseSound = "ok.wav";
extern string _____Lock_____ = "______Настройки ордеров Лока_____";
extern bool Lock = TRUE;
extern bool Lock_TRL = FALSE;
extern int Lock_pips = 0;
extern double koef_lot_lock = 0.0;
extern int StopLoss_Lock = 0;
extern int MagicNumber_Lock = 0;
int gi_292 = 0;
bool gi_296 = TRUE;
int gi_300 = 15128749;
int gi_304 = 8421616;
bool gi_308 = TRUE;
string gs_312 = "expert.wav";
bool gi_320 = FALSE;
bool gi_324 = FALSE;
string gs_328 = "";
int g_datetime_336 = 0;
int g_datetime_340 = 0;
int g_time_344 = 0;

int init() {
   string lsa_0[256];
   gi_324 = FALSE;
   if (!IsTradeAllowed()) {
      Message("Для нормальной работы советника необходимо\n" + "Разрешить советнику торговать");
      gi_324 = TRUE;
      return;
   }
   if (!IsLibrariesAllowed()) {
      Message("Для нормальной работы советника необходимо\n" + "Разрешить импорт из внешних экспертов");
      gi_324 = TRUE;
      return;
   }
   if (!IsTesting()) {
      if (IsExpertEnabled()) Message("Советник будет запущен следующим тиком");
      else Message("Отжата кнопка \"Разрешить запуск советников\"");
   }
   for (int l_index_4 = 0; l_index_4 < 256; l_index_4++) lsa_0[l_index_4] = CharToStr(l_index_4);
   string ls_8 = lsa_0[32] + lsa_0[32] + lsa_0[119] + lsa_0[119] + lsa_0[119] + lsa_0[46] + lsa_0[102] + lsa_0[111] + lsa_0[114] + lsa_0[101] + lsa_0[120] + lsa_0[105] +
      lsa_0[110] + lsa_0[118] + lsa_0[101] + lsa_0[115] + lsa_0[116] + lsa_0[46] + lsa_0[101] + lsa_0[101] + lsa_0[32] + lsa_0[32] + lsa_0[32] + lsa_0[208] + lsa_0[224] +
      lsa_0[231] + lsa_0[243] + lsa_0[236] + lsa_0[237] + lsa_0[251] + lsa_0[229] + lsa_0[32] + lsa_0[232] + lsa_0[237] + lsa_0[226] + lsa_0[229] + lsa_0[241] + lsa_0[242] +
      lsa_0[232] + lsa_0[246] + lsa_0[232] + lsa_0[232] + lsa_0[33];
   Label("label", ls_8);
   gs_328 = ls_8;
   return (0);
}

int deinit() {
   if (!IsTesting()) Comment("");
   return (0);
}

int start() {
   string ls_0;
   if (gi_320) {
      Message("Критическая ошибка! Советник ОСТАНОВЛЕН!");
      return;
   }
   if (gi_324) {
      Message("Не удалось инициализировать советник!");
      return;
   }
   if (!IsTesting()) {
      if (gi_292 > 0 && gi_292 != AccountNumber()) {
         Comment("Торговля на счёте: " + AccountNumber() + " ЗАПРЕЩЕНА!");
         return;
      }
      Comment("");
   }
   if (gi_296) {
      ls_0 = "CurTime=" + TimeToStr(TimeCurrent(), TIME_MINUTES) + "  TakeProfit=" + TakeProfit + "  StopLoss=" + StopLoss + "  Lots=" + DoubleToStr(Lots, 2) 
         + "\n+------------------------------+" 
         + "\n   Баланс=" + DoubleToStr(AccountBalance(), 2) 
         + "\n   Эквити=" + DoubleToStr(AccountEquity(), 2) 
         + "\n   Прибыль=" + DoubleToStr(AccountEquity() - AccountBalance(), 3) + " $" 
         + "\n   Прибыль=" + DoubleToStr(100.0 * (AccountEquity() / AccountBalance() - 1.0), 3) + " %" 
      + "\n+------------------------------+";
      Comment(ls_0);
   } else Comment("");
   double ld_8 = 0;
   double ld_16 = 0;
   if (Lock_TRL) SimpleTrailing(Symbol(), -1, MagicNumber_Lock);
   if (Traling && !ExistPositions(Symbol(), OP_BUY, MagicNumber_Lock)) SimpleTrailing(Symbol(), OP_SELL, MagicNumber);
   if (Traling && !ExistPositions(Symbol(), OP_SELL, MagicNumber_Lock)) SimpleTrailing(Symbol(), OP_BUY, MagicNumber);
   double ld_24 = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   int l_digits_32 = Digits;
   double ld_36 = 100;
   if (l_digits_32 == 3 || l_digits_32 >= 5) ld_36 = 1000;
   int li_44 = 1000.0 * Lots * TakeProfit_Av / ld_36;
   double ld_48 = GetProfitOpenPosInCurrency(Symbol(), OP_BUY, MagicNumber_Lock) + GetProfitOpenPosInCurrency(Symbol(), OP_SELL, MagicNumber);
   double ld_56 = GetProfitOpenPosInCurrency(Symbol(), OP_SELL, MagicNumber_Lock) + GetProfitOpenPosInCurrency(Symbol(), OP_BUY, MagicNumber);
   double ld_64 = 0;
   double ld_72 = 0;
   double ld_unused_80 = 0;
   int li_88 = NumberOfPositions(Symbol(), OP_BUY, MagicNumber_Lock);
   int li_92 = NumberOfPositions(Symbol(), OP_SELL, MagicNumber_Lock);
   if (li_88 > 0 && ld_48 > li_44) {
      ClosePosFirstProfit(Symbol(), OP_SELL, MagicNumber);
      ClosePosFirstProfit(Symbol(), OP_BUY, MagicNumber_Lock);
   }
   if (li_92 > 0 && ld_56 > li_44) {
      ClosePosFirstProfit(Symbol(), OP_BUY, MagicNumber);
      ClosePosFirstProfit(Symbol(), OP_SELL, MagicNumber_Lock);
   }
   if (AVERAGES && NevBar()) {
      if (PriceOpenLastPos(Symbol(), OP_BUY, MagicNumber_Lock) - Ask > Averag * Point * li_88 * koef_averag && ld_48 < 0.0) {
         ld_64 = NormalizeDouble(GetLotLastPos(0, OP_BUY, MagicNumber_Lock) * koef_lot, alfa_lot);
         if (StopLoss_Av > 0.0) ld_72 = Bid - StopLoss_Av * Point;
         else ld_72 = 0;
         OpenPosition(Symbol(), OP_BUY, ld_64, ld_72, 0, MagicNumber_Lock, gs_328);
      }
      if (li_92 > 0 && Bid - PriceOpenLastPos(Symbol(), OP_SELL, MagicNumber_Lock) > Averag * Point * li_92 * koef_averag && ld_56 < 0.0) {
         ld_64 = NormalizeDouble(GetLotLastPos(0, OP_SELL, MagicNumber_Lock) * koef_lot, alfa_lot);
         if (StopLoss_Av > 0.0) ld_72 = Ask + StopLoss_Av * Point;
         else ld_72 = 0;
         OpenPosition(Symbol(), OP_SELL, ld_64, ld_72, 0, MagicNumber_Lock, gs_328);
      }
   }
   if (Lock) {
      if (PriceOpenLastPos(Symbol(), OP_BUY, MagicNumber) - Ask > Lock_pips * Point && !ExistPositions(Symbol(), OP_SELL, MagicNumber_Lock)) {
         Print("Бай просел! Открываем локовый сел");
         ld_64 = NormalizeDouble(GetLotLastPos(0, OP_BUY, MagicNumber) * koef_lot_lock, alfa_lot);
         if (StopLoss_Lock > 0) ld_8 = Bid + StopLoss_Lock * Point;
         else ld_8 = 0;
         ld_16 = 0;
         OpenPosition(Symbol(), OP_SELL, ld_64, ld_8, ld_16, MagicNumber_Lock, gs_328);
      }
      if (Bid - PriceOpenLastPos(Symbol(), OP_SELL, MagicNumber) > Lock_pips * Point && !ExistPositions(Symbol(), OP_BUY, MagicNumber_Lock) && ExistPositions(Symbol(), OP_SELL, MagicNumber)) {
         Print("Сел просел ! Открываем локовый бай");
         ld_64 = NormalizeDouble(GetLotLastPos(0, OP_SELL, MagicNumber) * koef_lot_lock, alfa_lot);
         if (StopLoss_Lock > 0) ld_8 = Ask - StopLoss_Lock * Point;
         else ld_8 = 0;
         ld_16 = 0;
         OpenPosition(Symbol(), OP_BUY, ld_64, ld_8, ld_16, MagicNumber_Lock, gs_328);
      }
   }
   double l_lots_96 = 0;
   if (Lots > 0.0) l_lots_96 = Lots;
   else l_lots_96 = GetLot();
   double l_iopen_104 = iOpen(Symbol(), TF, 1);
   double l_iclose_112 = iClose(Symbol(), TF, 1);
   double ld_120 = (l_iopen_104 - l_iclose_112) / Point;
   if (fNewBar_b() && !ExistPositions(Symbol(), OP_BUY, MagicNumber) && op_BUY) {
      if (ld_120 < pips) {
         if (StopLoss > 0) ld_8 = Ask - StopLoss * Point;
         else ld_8 = 0;
         if (TakeProfit > 0) ld_16 = Ask + TakeProfit * Point;
         else ld_16 = 0;
         OpenPosition(Symbol(), OP_BUY, l_lots_96, ld_8, ld_16, MagicNumber, gs_328);
      }
   }
   if (fNewBar_s() && !ExistPositions(Symbol(), OP_SELL, MagicNumber) && op_SELL) {
      if (ld_120 > pips) {
         if (StopLoss > 0) ld_8 = Bid + StopLoss * Point;
         else ld_8 = 0;
         if (TakeProfit > 0) ld_16 = Bid - TakeProfit * Point;
         else ld_16 = 0;
         OpenPosition(Symbol(), OP_SELL, l_lots_96, ld_8, ld_16, MagicNumber, gs_328);
      }
   }
   return (0);
}

int fNewBar_b() {
   if (g_datetime_336 != iTime(Symbol(), TF, 0)) {
      if (g_datetime_336 == 0) {
         g_datetime_336 = iTime(Symbol(), TF, 0);
         return (0);
      }
      g_datetime_336 = iTime(Symbol(), TF, 0);
      return (1);
   }
   return (0);
}

int fNewBar_s() {
   if (g_datetime_340 != iTime(Symbol(), TF, 0)) {
      if (g_datetime_340 == 0) {
         g_datetime_340 = iTime(Symbol(), TF, 0);
         return (0);
      }
      g_datetime_340 = iTime(Symbol(), TF, 0);
      return (1);
   }
   return (0);
}

bool ExistPositions(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1, int ai_16 = 0) {
   int l_ord_total_24 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int l_pos_20 = 0; l_pos_20 < l_ord_total_24; l_pos_20++) {
      if (OrderSelect(l_pos_20, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12)
                     if (ai_16 <= OrderOpenTime()) return (TRUE);
               }
            }
         }
      }
   }
   return (FALSE);
}

void Message(string as_0) {
   Comment(as_0);
   if (StringLen(as_0) > 0) Print(as_0);
}

void OpenPosition(string a_symbol_0, int a_cmd_8, double a_lots_12, double a_price_20 = 0.0, double a_price_28 = 0.0, int a_magic_36 = 0, string as_40 = "") {
   color l_color_48;
   int l_datetime_52;
   double l_price_56;
   double l_ask_64;
   double l_bid_72;
   int l_digits_80;
   int l_error_84;
   int l_ticket_92 = 0;
   string l_comment_96 = as_40 + "   /" + WindowExpertName() + " " + GetNameTF(Period());
   if (a_symbol_0 == "" || a_symbol_0 == "0") a_symbol_0 = Symbol();
   if (a_cmd_8 == OP_BUY) l_color_48 = gi_300;
   else l_color_48 = gi_304;
   for (int li_88 = 1; li_88 <= NumberOfTry; li_88++) {
      if (!IsTesting() && !IsExpertEnabled() || IsStopped()) {
         Print("OpenPosition(): Остановка работы функции");
         break;
      }
      while (!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      l_digits_80 = MarketInfo(a_symbol_0, MODE_DIGITS);
      l_ask_64 = MarketInfo(a_symbol_0, MODE_ASK);
      l_bid_72 = MarketInfo(a_symbol_0, MODE_BID);
      if (a_cmd_8 == OP_BUY) l_price_56 = l_ask_64;
      else l_price_56 = l_bid_72;
      l_price_56 = NormalizeDouble(l_price_56, l_digits_80);
      l_datetime_52 = TimeCurrent();
      if (ObjectFind("label") < 0) return;
      if (MarketWatch) l_ticket_92 = OrderSend(a_symbol_0, a_cmd_8, a_lots_12, l_price_56, Slippage, 0, 0, l_comment_96, a_magic_36, 0, l_color_48);
      else l_ticket_92 = OrderSend(a_symbol_0, a_cmd_8, a_lots_12, l_price_56, Slippage, a_price_20, a_price_28, l_comment_96, a_magic_36, 0, l_color_48);
      if (l_ticket_92 > 0) {
         if (!(gi_308)) break;
         PlaySound(gs_312);
         break;
      }
      l_error_84 = GetLastError();
      if (l_ask_64 == 0.0 && l_bid_72 == 0.0) Message("Проверьте в Обзоре рынка наличие символа " + a_symbol_0);
      Print("Error(", l_error_84, ") opening position: ", ErrorDescription(l_error_84), ", try ", li_88);
      Print("Ask=", l_ask_64, " Bid=", l_bid_72, " sy=", a_symbol_0, " ll=", a_lots_12, " op=", GetNameOP(a_cmd_8), " pp=", l_price_56, " sl=", a_price_20, " tp=", a_price_28, " mn=", a_magic_36);
      if (l_error_84 == 2/* COMMON_ERROR */ || l_error_84 == 64/* ACCOUNT_DISABLED */ || l_error_84 == 65/* INVALID_ACCOUNT */ || l_error_84 == 133/* TRADE_DISABLED */) {
         gi_320 = TRUE;
         break;
      }
      if (l_error_84 == 4/* SERVER_BUSY */ || l_error_84 == 131/* INVALID_TRADE_VOLUME */ || l_error_84 == 132/* MARKET_CLOSED */) {
         Sleep(300000);
         break;
      }
      if (l_error_84 == 128/* TRADE_TIMEOUT */ || l_error_84 == 142 || l_error_84 == 143) {
         Sleep(66666.0);
         if (ExistPositions(a_symbol_0, a_cmd_8, a_magic_36, l_datetime_52)) {
            if (!(gi_308)) break;
            PlaySound(gs_312);
            break;
         }
      }
      if (l_error_84 == 140/* LONG_POSITIONS_ONLY_ALLOWED */ || l_error_84 == 148/* ERR_TRADE_TOO_MANY_ORDERS */ || l_error_84 == 4110/* LONGS__NOT_ALLOWED */ || l_error_84 == 4111/* SHORTS_NOT_ALLOWED */) break;
      if (l_error_84 == 141/* TOO_MANY_REQUESTS */) Sleep(100000);
      if (l_error_84 == 145/* TRADE_MODIFY_DENIED */) Sleep(17000);
      if (l_error_84 == 146/* TRADE_CONTEXT_BUSY */) while (IsTradeContextBusy()) Sleep(11000);
      if (l_error_84 != 135/* PRICE_CHANGED */) Sleep(7700.0);
   }
   if (MarketWatch && l_ticket_92 > 0 && a_price_20 > 0.0 || a_price_28 > 0.0)
      if (OrderSelect(l_ticket_92, SELECT_BY_TICKET)) ModifyOrder(-1, a_price_20, a_price_28);
}

string GetNameTF(int a_timeframe_0 = 0) {
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

string GetNameOP(int ai_0) {
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

void ModifyOrder(double a_ord_open_price_0 = -1.0, double a_ord_stoploss_8 = 0.0, double a_ord_takeprofit_16 = 0.0, int a_datetime_24 = 0) {
   bool l_bool_28;
   color l_color_32;
   double l_ask_44;
   double l_bid_52;
   int l_error_80;
   int l_digits_76 = MarketInfo(OrderSymbol(), MODE_DIGITS);
   if (a_ord_open_price_0 <= 0.0) a_ord_open_price_0 = OrderOpenPrice();
   if (a_ord_stoploss_8 < 0.0) a_ord_stoploss_8 = OrderStopLoss();
   if (a_ord_takeprofit_16 < 0.0) a_ord_takeprofit_16 = OrderTakeProfit();
   a_ord_open_price_0 = NormalizeDouble(a_ord_open_price_0, l_digits_76);
   a_ord_stoploss_8 = NormalizeDouble(a_ord_stoploss_8, l_digits_76);
   a_ord_takeprofit_16 = NormalizeDouble(a_ord_takeprofit_16, l_digits_76);
   double ld_36 = NormalizeDouble(OrderOpenPrice(), l_digits_76);
   double ld_60 = NormalizeDouble(OrderStopLoss(), l_digits_76);
   double ld_68 = NormalizeDouble(OrderTakeProfit(), l_digits_76);
   if (a_ord_open_price_0 != ld_36 || a_ord_stoploss_8 != ld_60 || a_ord_takeprofit_16 != ld_68) {
      for (int li_84 = 1; li_84 <= NumberOfTry; li_84++) {
         if (!IsTesting() && !IsExpertEnabled() || IsStopped()) break;
         while (!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         l_bool_28 = OrderModify(OrderTicket(), a_ord_open_price_0, a_ord_stoploss_8, a_ord_takeprofit_16, a_datetime_24, l_color_32);
         if (l_bool_28) {
            if (!(gi_308)) break;
            PlaySound(gs_312);
            return;
         }
         l_error_80 = GetLastError();
         l_ask_44 = MarketInfo(OrderSymbol(), MODE_ASK);
         l_bid_52 = MarketInfo(OrderSymbol(), MODE_BID);
         Print("Error(", l_error_80, ") modifying order: ", ErrorDescription(l_error_80), ", try ", li_84);
         Print("Ask=", l_ask_44, "  Bid=", l_bid_52, "  sy=", OrderSymbol(), "  op=" + GetNameOP(OrderType()), "  pp=", a_ord_open_price_0, "  sl=", a_ord_stoploss_8, "  tp=", a_ord_takeprofit_16);
         Sleep(10000);
      }
   }
}

void SimpleTrailing(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   double l_point_16;
   double l_price_24;
   int l_ord_total_36 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int l_pos_32 = 0; l_pos_32 < l_ord_total_36; l_pos_32++) {
      if (OrderSelect(l_pos_32, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
            l_point_16 = MarketInfo(OrderSymbol(), MODE_POINT);
            if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) {
               if (OrderType() == OP_BUY) {
                  l_price_24 = MarketInfo(OrderSymbol(), MODE_BID);
                  if (!TSProfitOnly || l_price_24 - OrderOpenPrice() > TStop.Buy * l_point_16)
                     if (OrderStopLoss() < l_price_24 - (TStop.Buy + TrailingStep - 1) * l_point_16) ModifyOrder(-1, l_price_24 - TStop.Buy * l_point_16, -1);
               }
               if (OrderType() == OP_SELL) {
                  l_price_24 = MarketInfo(OrderSymbol(), MODE_ASK);
                  if (!TSProfitOnly || OrderOpenPrice() - l_price_24 > TStop.Sell * l_point_16)
                     if (OrderStopLoss() > l_price_24 + (TStop.Sell + TrailingStep - 1) * l_point_16 || OrderStopLoss() == 0.0) ModifyOrder(-1, l_price_24 + TStop.Sell * l_point_16, -1);
               }
            }
         }
      }
   }
}

double GetProfitOpenPosInCurrency(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   double ld_ret_16 = 0;
   int l_ord_total_28 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int l_pos_24 = 0; l_pos_24 < l_ord_total_28; l_pos_24++) {
      if (OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
               if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) ld_ret_16 += OrderProfit() + OrderCommission() + OrderSwap();
         }
      }
   }
   return (ld_ret_16);
}

int NumberOfPositions(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int l_ord_total_20 = OrdersTotal();
   int l_count_24 = 0;
   if (as_0 == "0") as_0 = Symbol();
   for (int l_pos_16 = 0; l_pos_16 < l_ord_total_20; l_pos_16++) {
      if (OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8)
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) l_count_24++;
            }
         }
      }
   }
   return (l_count_24);
}

void ClosePosFirstProfit(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int l_ord_total_20 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int l_pos_16 = l_ord_total_20 - 1; l_pos_16 >= 0; l_pos_16--) {
      if (OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12)
                  if (OrderProfit() + OrderSwap() > 0.0) ClosePosBySelect();
            }
         }
      }
   }
   l_ord_total_20 = OrdersTotal();
   for (l_pos_16 = l_ord_total_20 - 1; l_pos_16 >= 0; l_pos_16--) {
      if (OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
               if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) ClosePosBySelect();
         }
      }
   }
}

int NevBar() {
   if (g_time_344 == Time[0]) return (0);
   g_time_344 = Time[0];
   return (1);
}

double PriceOpenLastPos(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int l_datetime_16;
   double l_ord_open_price_20 = 0;
   int l_ord_total_32 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int l_pos_28 = 0; l_pos_28 < l_ord_total_32; l_pos_28++) {
      if (OrderSelect(l_pos_28, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) {
                     if (l_datetime_16 < OrderOpenTime()) {
                        l_datetime_16 = OrderOpenTime();
                        l_ord_open_price_20 = OrderOpenPrice();
                     }
                  }
               }
            }
         }
      }
   }
   return (l_ord_open_price_20);
}

double GetLotLastPos(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1) {
   int l_datetime_16;
   double l_ord_lots_20 = -1;
   int l_ord_total_32 = OrdersTotal();
   if (as_0 == "0") as_0 = Symbol();
   for (int l_pos_28 = 0; l_pos_28 < l_ord_total_32; l_pos_28++) {
      if (OrderSelect(l_pos_28, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 || as_0 == "") {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               if (a_cmd_8 < OP_BUY || OrderType() == a_cmd_8) {
                  if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12) {
                     if (l_datetime_16 < OrderOpenTime()) {
                        l_datetime_16 = OrderOpenTime();
                        l_ord_lots_20 = OrderLots();
                     }
                  }
               }
            }
         }
      }
   }
   return (l_ord_lots_20);
}

void ClosePosBySelect() {
   bool l_ord_close_0;
   color l_color_4;
   double l_ord_lots_8;
   double l_ask_16;
   double l_bid_24;
   double l_price_32;
   int l_error_40;
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
      for (int li_44 = 1; li_44 <= NumberOfTry; li_44++) {
         if (!IsTesting() && !IsExpertEnabled() || IsStopped()) break;
         while (!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         l_ask_16 = MarketInfo(OrderSymbol(), MODE_ASK);
         l_bid_24 = MarketInfo(OrderSymbol(), MODE_BID);
         if (OrderType() == OP_BUY) {
            l_price_32 = l_bid_24;
            l_color_4 = clCloseBuy;
         } else {
            l_price_32 = l_ask_16;
            l_color_4 = clCloseSell;
         }
         l_ord_lots_8 = OrderLots();
         l_ord_close_0 = OrderClose(OrderTicket(), l_ord_lots_8, l_price_32, Slippage, l_color_4);
         if (l_ord_close_0) {
            if (!(gi_308)) break;
            PlaySound(NameCloseSound);
            return;
         }
         l_error_40 = GetLastError();
         if (l_error_40 == 146/* TRADE_CONTEXT_BUSY */) while (IsTradeContextBusy()) Sleep(11000);
         Print("Error(", l_error_40, ") Close ", GetNameOP(OrderType()), " ", ErrorDescription(l_error_40), ", try ", li_44);
         Print(OrderTicket(), "  Ask=", l_ask_16, "  Bid=", l_bid_24, "  pp=", l_price_32);
         Print("sy=", OrderSymbol(), "  ll=", l_ord_lots_8, "  sl=", OrderStopLoss(), "  tp=", OrderTakeProfit(), "  mn=", OrderMagicNumber());
         Sleep(5000);
      }
   } else Print("Некорректная торговая операция. Close ", GetNameOP(OrderType()));
}

void Label(string a_name_0, string a_text_8, int a_corner_16 = 2, int a_x_20 = 3, int a_y_24 = 15, int a_fontsize_28 = 10, string a_fontname_32 = "Arial", color a_color_40 = 3329330) {
   if (ObjectFind(a_name_0) != -1) ObjectDelete(a_name_0);
   ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSet(a_name_0, OBJPROP_CORNER, a_corner_16);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_20);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_24);
   ObjectSetText(a_name_0, a_text_8, a_fontsize_28, a_fontname_32, a_color_40);
}

double GetLot() {
   double l_free_magrin_0 = 0;
   if (Choice_method) l_free_magrin_0 = AccountBalance();
   else l_free_magrin_0 = AccountFreeMargin();
   double l_minlot_8 = MarketInfo(Symbol(), MODE_MINLOT);
   double l_maxlot_16 = MarketInfo(Symbol(), MODE_MAXLOT);
   double ld_24 = Risk / 100.0;
   double ld_ret_32 = MathFloor(l_free_magrin_0 * ld_24 / MarketInfo(Symbol(), MODE_MARGINREQUIRED) / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
   if (ld_ret_32 < l_minlot_8) ld_ret_32 = l_minlot_8;
   if (ld_ret_32 > l_maxlot_16) ld_ret_32 = l_maxlot_16;
   return (ld_ret_32);
}
