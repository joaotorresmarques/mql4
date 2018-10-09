#property copyright "ProfFX"
#property link      "http://euronis-free.com/"

//---- input parameters
extern string    A1 = "Orders volume";
extern double    Lots = 0.1;
extern string    A2 = "Periods of fast and slow average";
extern int       FastPeriod = 13;
extern int       SlowPeriod = 21;
extern string    A3 = "Method of calculating the average: 0-SMA, 1-EMA, 2-SMMA, 3-LWMA";
extern int       MAMethod = MODE_EMA;
extern string    A4 = "Calculation of the average price: 0-Close, 1-Open, 2-High, 3-Low, 4-Median..";
extern int       MAPrice = PRICE_TYPICAL;
extern string    A5 = "The number of bars to register flat market (minimum - 2)";
extern int       FlatDuration = 3;
extern string    A6 = "The difference between the center lines in the paragraph shall be deemed Flat";
extern int       FlatPoints = 2;
extern string    A7 = "Margin to stop a percentage of the width of the channel";
extern double    StopMistake = 20.0;
extern string    A8 = "Margin for profit as a percentage of the width of the channel";
extern double    TakeProfitMistake = 0.0;
extern string    A9 = "Other Parameters";
extern string    OpenOrderSound = "ok.wav";        // Звуковой сигнал при открытии..
                                                   // ..позиции
extern int       MagicNumber = 11259;              // Уникальный идентификатор своих..
                                                   // ..ордеров

bool Activate, FreeMarginAlert, FatalError, Signal;
double Tick, Spread, StopLevel, MinLot, MaxLot, LotStep, FreezeLevel, 
       Minimum,                                    // Минимум обнаруженного канала
       Maximum;                                    // Максимум обнаруженного канала
int maxbars;                                       // Максимальное количество..
                                                   // ..обрабатываемых баров       
datetime LastBar,                                  // Время открытия бара, на котором..
                                                   // ..были произведены все расчеты и ..
                                                   // ..торговые операции
         LastSignal;                               // Время открытия бара, на котором..
                                                   // ..был произведен последний расчет..
                                                   // ..сигнала

//+-------------------------------------------------------------------------------------+
//| Функция инициализации эксперта                                                      |
//+-------------------------------------------------------------------------------------+
int init()
  {
   FatalError = False;
// - 1 - == Сбор информации об условиях торговли ========================================   
   Tick = MarketInfo(Symbol(), MODE_TICKSIZE);                         // минимальный тик    
   Spread = ND(MarketInfo(Symbol(), MODE_SPREAD)*Point);                 // текущий спрэд
   StopLevel = ND(MarketInfo(Symbol(), MODE_STOPLEVEL)*Point);  // текущий уровень стопов
   FreezeLevel = ND(MarketInfo(Symbol(), MODE_FREEZELEVEL)*Point);   // уровень заморозки
   MinLot = MarketInfo(Symbol(), MODE_MINLOT);    // минимальный разрешенный объем сделки
   MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);   // максимальный разрешенный объем сделки
   LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);          // шаг приращения объема сделки
// - 1 - == Окончание блока =============================================================

// - 2 - == Приведение объема сделки к допустимому и проверка корректности объема =======   
   Lots = LotRound(Lots);                  // округление объема до ближайшего допустимого
// - 2 - == Окончание блока =============================================================

// - 3 - ==================== Проверка корректности входных параметров ==================
   if (FastPeriod < 1)
   {
      Comment("FastPeriod value must be positive. Advisor is disabled!");
      Print("FastPeriod value must be positive. Advisor is disabled!");
      return(0);
   }
   if (SlowPeriod < 1)
   {
      Comment("FastPeriod value must be positive. Advisor is disabled!");
      Print("FastPeriod value must be positive. Advisor is disabled!");
      return(0);
   }
   if (SlowPeriod == FastPeriod)
   {
      Comment("Values FastPeriod and SlowPeriod, can not be equal. Advisor is disabled!");
      Print("Values FastPeriod and SlowPeriod, can not be equal. Advisor is disabled!");
      return(0);
   }
   if (MAMethod < 0 || MAMethod > 3)
   {
      Comment("MAMethod value should be from 0 to 3. Advisor is disabled!");
      Print("MAMethod value should be from 0 to 3. Advisor is disabled!");
      return(0);
   }
   if (MAPrice < 0 || MAPrice > 6)
   {
      Comment("MAPrice value should be from 0 to 6. Advisor is disabled!");
      Print("MAPrice value should be from 0 to 6. Advisor is disabled!");
      return(0);
   }
   if (FlatDuration < 2)
   {
      Comment("FlatDuration value should be 2 or more. Advisor is disabled!");
      Print("FlatDuration value should be 2 or more. Advisor is disabled!");
      return(0);
   }
   if (StopMistake <= 0)
   {
      Comment("StopMistake value must be positive +. Advisor is disabled!");
      Print("StopMistake value must be positive +. Advisor is disabled!");
      return(0);
   }
// - 3 - =========================== Окончание блока ====================================

   Activate = True; // Все проверки успешно завершены, возводим флаг активизации эксперта

   return(0);
  }
  
//+-------------------------------------------------------------------------------------+
//| Функция деинициализации эксперта                                                    |
//+-------------------------------------------------------------------------------------+
int deinit()
{
 Comment("");
 return(0);
}
  

//+-------------------------------------------------------------------------------------+
//| Проверка объема на корректность и округление                                        |
//+-------------------------------------------------------------------------------------+
double LotRound(double L)
{
 return(MathRound(MathMin(MathMax(L, MinLot), MaxLot)/LotStep)*LotStep);
}

//+-------------------------------------------------------------------------------------+
//| Приведение значений к точности одного пункта                                        |
//+-------------------------------------------------------------------------------------+
double ND(double A)
{
 return(NormalizeDouble(A, Digits));
}  

//+-------------------------------------------------------------------------------------+
//| Расшифровка сообщения об ошибке                                                     |
//+-------------------------------------------------------------------------------------+
string ErrorToString(int Error)
{
 switch(Error)
   {
    case 2: return("fixed total error, please contact technical support."); 
    case 5: return("you have an older version of the terminal, update them."); 
    case 6: return("no communication with the server, try to restart the terminal."); 
    case 64: return("account is blocked, please contact technical support.");
    case 132: return("the market is closed."); 
    case 133: return("trade is prohibited."); 
    case 149: return("Blocking is prohibited."); 
   }
}

//+-------------------------------------------------------------------------------------+
//| Ожидание торгового потока. Если поток свободен, то результат True, иначе - False    |
//+-------------------------------------------------------------------------------------+  
bool WaitForTradeContext()
{
 int P = 0;
 // цикл "пока"
 while(IsTradeContextBusy() && P < 5)
   {
    P++;
    Sleep(1000);
   }
 // -------------  
 if(P == 5)
   return(False);
 return(True);    
}

//+-------------------------------------------------------------------------------------+
//| "Правильное" открытие позиции                                                       |
//| В отличие от OpenOrder проверяет соотношение текущих уровней и устанавливаемых      |
//| Возвращает:                                                                         |
//|   0 - нет ошибок                                                                    |
//|   1 - Ошибка открытия                                                               |
//|   2 - Ошибка значения Price                                                         |
//|   3 - Ошибка значения SL                                                            |
//|   4 - Ошибка значения TP                                                            |
//|   5 - Ошибка значения Lot                                                           |
//+-------------------------------------------------------------------------------------+
int OpenOrderCorrect(int Type, double Lot, double Price, double SL, double TP,
                     bool Redefinition = True)
// Redefinition - при True доопределять параметры до минимально допустимых
//                при False - возвращать ошибку
{
// - 1 - == Проверка достаточности свободных средств ====================================
 if(AccountFreeMarginCheck(Symbol(), OP_BUY, Lot) <= 0 || GetLastError() == 134) 
  {
   if(!FreeMarginAlert)
    {
     Print("Enough money to open position. Free Margin = ", 
           AccountFreeMargin());
     FreeMarginAlert = True;
    } 
   return(5);  
  }
 FreeMarginAlert = False;  
// - 1 - == Окончание блока =============================================================

// - 2 - == Корректировка значений Price, SL и TP или возврат ошибки ====================   
 RefreshRates();
 switch (Type)
   {
    case OP_BUY: 
                string S = "BUY"; 
                if (MathAbs(Price-Ask)/Point > 3)
                  if (Redefinition) Price = ND(Ask);
                  else              return(2);
                if (ND(TP-Bid) <= StopLevel && TP != 0)
                  if (Redefinition) TP = ND(Bid+StopLevel+Tick);
                  else              return(4);
                if (ND(Bid-SL) <= StopLevel)
                  if (Redefinition) SL = ND(Bid-StopLevel-Tick);
                  else              return(3);
                break;
    case OP_SELL: 
                 S = "SELL"; 
                 if (MathAbs(Price-Bid)/Point > 3)
                   if (Redefinition) Price = ND(Bid);
                   else              return(2);
                 if (ND(Ask-TP) <= StopLevel) 
                   if (Redefinition) TP = ND(Ask-StopLevel-Tick);
                   else              return(4);
                 if (ND(SL-Ask) <= StopLevel && SL != 0)
                   if (Redefinition) SL = ND(Ask+StopLevel+Tick);
                   else              return(3);
                 break;
    case OP_BUYSTOP: 
                    S = "BUYSTOP";
                    if (ND(Price-Ask) <= StopLevel)
                      if (Redefinition) Price = ND(Ask+StopLevel+Tick);
                      else              return(2);
                    if (ND(TP-Price) <= StopLevel && TP != 0)
                      if (Redefinition) TP = ND(Price+StopLevel+Tick);
                      else              return(4);
                    if (ND(Price-SL) <= StopLevel)
                      if (Redefinition) SL = ND(Price-StopLevel-Tick);
                      else              return(3);
                    break;
    case OP_SELLSTOP: 
                     S = "SELLSTOP";
                     if (ND(Bid-Price) <= StopLevel)
                       if (Redefinition) Price = ND(Bid-StopLevel-Tick);
                       else              return(2);
                     if (ND(Price-TP) <= StopLevel)
                       if (Redefinition) TP = ND(Price-StopLevel-Tick);
                       else              return(4);
                     if (ND(SL-Price) <= StopLevel && SL != 0)
                       if (Redefinition) SL = ND(Price+StopLevel+Tick);
                       else              return(3);
                     break;
    case OP_BUYLIMIT: 
                     S = "BUYLIMIT";
                     if (ND(Ask-Price) <= StopLevel)
                      if (Redefinition) Price = ND(Ask-StopLevel-Tick);
                      else              return(2);
                     if (ND(TP-Price) <= StopLevel && TP != 0)
                       if (Redefinition) TP = ND(Price+StopLevel+Tick);
                       else              return(4);
                     if (ND(Price-SL) <= StopLevel)
                       if (Redefinition) SL = ND(Price-StopLevel-Tick);
                       else              return(3);
                     break;
    case OP_SELLLIMIT: 
                     S = "SELLLIMIT";
                     if (ND(Price - Bid) <= StopLevel) 
                       if (Redefinition) Price = ND(Bid+StopLevel+Tick);
                       else              return(2);
                     if (ND(Price-TP) <= StopLevel)
                       if (Redefinition) TP = ND(Price-StopLevel-Tick);
                       else              return(4);
                     if (ND(SL-Price) <= StopLevel && SL != 0)
                       if (Redefinition) SL = ND(Price+StopLevel+Tick);
                       else              return(3);
                     break;
   }
// - 2 - == Окончание блока =============================================================
 
// - 3 - == Открытие ордера с ожидание торгового потока =================================   
 if(WaitForTradeContext())  // ожидание освобождения торгового потока
   {  
    Comment("Sent a request to open an order ", S, " ...");  
    int ticket=OrderSend(Symbol(), Type, Lot, Price, 3, 
               SL, TP, NULL, MagicNumber, 0);// открытие позиции
    // Попытка открытия позиции завершилась неудачей
    if(ticket<0)
      {
       int Error = GetLastError();
       if(Error == 2 || Error == 5 || Error == 6 || Error == 64 
          || Error == 132 || Error == 133 || Error == 149)     // список фатальных ошибок
         {
          Comment("Fatal error when opening a position because "+
                   ErrorToString(Error)+" Advisor is disabled!");
          FatalError = True;
         }
        else 
         Comment("Error opening position ", S, ": ", Error);       // нефатальная ошибка
       return(1);
      }
    // ---------------------------------------------
    
    // Удачное открытие позиции   
    Comment("position ", S, " opened successfully!"); 
    PlaySound(OpenOrderSound); 
    return(0); 
    // ------------------------
   }
  else
   {
    Comment("Waiting time until the trade flow is up!");
    return(1);  
   } 
// - 3 - == Окончание блока =============================================================
}

//+-------------------------------------------------------------------------------------+
//| Приведение значений к точности одного тика                                          |
//+-------------------------------------------------------------------------------------+
double NP(double A)
{
 return(MathRound(A/Tick)*Tick);
}  

//+-------------------------------------------------------------------------------------+
//| Определение флэтовой составляющей рынка                                             |
//+-------------------------------------------------------------------------------------+
void FlatDetect()
{
// - 1 - ========================= Вычисление разности средних ==========================
   int i = 1;
   maxbars = Bars - MathMax(FastPeriod, SlowPeriod);
   while (true)                                    // Цикл выполняется, пока.. 
   {                                               // ..регистрируется флэт
      double MAFast = iMA(NULL, 0, FastPeriod, 0, MAMethod, MAPrice, i);// Медленная..
                                                                        // ..средняя
      double MASlow = iMA(NULL, 0, SlowPeriod, 0, MAMethod, MAPrice, i);// Быстрая..
                                                                        // ..средняя
      if (MathAbs(MAFast - MASlow) > FlatPoints*Point) // Если разность средних больше..
         break;                                    // ..допустимого предела, то..
                                                   // ..регистрация флэта прекращается
      i++;                                                   
      if (i > maxbars || i > FlatDuration)
         break;
   }                                                   
// - 1 - ================================ Окончание блока ===============================

// - 2 - =========================== Генерация бокса покупки ============================
   if (i >= FlatDuration+1)                       // Если разность средних на ближайших..
   {                                              // ..FlatDuration барах была в пределах
      Signal = true;                              // ..допустимой величины, то..
      Maximum = High[iHighest(NULL, 0, MODE_HIGH, i-1, 1)];// ..регистрируется флэт с..
      Minimum = Low[iLowest(NULL, 0, MODE_LOW, i-1, 1)];// ..расчетом его границ
   }      
   else                                           // Иначе флэт не регистрируется
      Signal = false;                             
// - 2 - ================================ Окончание блока ===============================
}

//+-------------------------------------------------------------------------------------+
//| Функция поиска своих ордеров                                                        |
//+-------------------------------------------------------------------------------------+
bool FindOrders()
{
// - 1 - ====================== Инициализация переменных перед поиском ==================
   int total = OrdersTotal() - 1;
// - 1 - ================================== Окончание блока =============================
 
// - 2 - ================================ Произведение поиска ===========================
   for (int i = total; i >= 0; i--)                // Используется весь список ордеров
      if (OrderSelect(i, SELECT_BY_POS))           // Убедимся, что ордер выбран
         if (OrderMagicNumber() == MagicNumber &&  // Ордер открыт экспертом,
             OrderSymbol() == Symbol())            // ..который прикреплен к текущей.. 
            return(true);                          // Вернем - ордер существует
// - 2 - ================================== Окончание блока =============================
   return(false);                                  // Вернем - ордер не существует
}

//+-------------------------------------------------------------------------------------+
//| Открытие позиций                                                                    |
//+-------------------------------------------------------------------------------------+
bool Trade()
{
// - 1 - ========================= Подготовка исходных значений =========================
   double average = (Maximum + Minimum)/2;         // Уровень середины канала
   double bid = MarketInfo(Symbol(), MODE_BID);    // Текущая цена Bid
   double ask = MarketInfo(Symbol(), MODE_ASK);    // Текущая цена Ask
   double slmistake = (Maximum - Minimum)*StopMistake/100; // Запас для стопа
   double tpmistake = (Maximum - Minimum)*TakeProfitMistake/100; // Запас для профита
   int type = -1;                                  // Тип сделки не определен
// - 1 - ================================== Окончание блока =============================

// - 2 - ======================= Подготовка данных для открытия длинной =================
   if (bid < average)                              // Текущая цена в нижней части канала
   {
      type = OP_BUY;                               // Поэтому тип сделки - Buy
      double price = NP(ask);                      // Цена открытия сделки - Ask
      double sl = NP(Minimum - slmistake);         // Стоп-приказ - за минимумом канала
      double tp = NP(Maximum + tpmistake);         // Профит - ниже максимума или выше на
                                                   // ..TakeProfitMistake процентов
      if (tp - price <= StopLevel)                 // Если размер профита слишком мал, то
         type = -1;                                // ..сделка совершена не будет
   }      
// - 2 - ============================= Окончание блока ==================================
           
// - 3 - ====================== Подготовка данных для открытия короткой =================
   if (bid > average)                              // Текущая цена в верхней части канала
   {
      type = OP_SELL;                              // Поэтому тип сделки - Sell
      price = NP(bid);                             // Цена открытия сделки - Bid
      sl = NP(Maximum + Spread + slmistake);       // Стоп-приказ - за максимумом канала
      tp = NP(Minimum + Spread - tpmistake);       // Профит - выше или ниже минимума на
                                                   // ..TakeProfitMistake процентов
      if (price - tp <= StopLevel)                 // Если размер профита слишком мал, то
         type = -1;                                // ..сделка совершена не будет
   }    
// - 3 - ============================= Окончание блока ==================================

// - 4 - ============================ Совершение сделки =================================
   if (type >= 0)
      if (OpenOrderCorrect(type, Lots, price, sl, tp) != 0) // Если сделка не была.. 
         return(false);                            // ..совершена, то вернем ошибку
// - 4 - ============================= Окончание блока ==================================
 
   return(True);                                   // Все операции завершены 
}

//+-------------------------------------------------------------------------------------+
//| Функция start эксперта                                                              |
//+-------------------------------------------------------------------------------------+
int start()
{
// - 1 - ========================== Можно ли работать эксперту? =========================
   if (!Activate || FatalError) return(0);
// - 1 - ============================= Окончание блока ==================================

// - 2 - ========================== Контроль открытия нового бара =======================
   if (LastBar == Time[0])                         // Если на текущем баре уже были..
      return(0);                                   // ..произведены необходимые действия,
                                                   // ..то прерываем работу до..
                                                   // ..следующего тика
// - 2 - ============================= Окончание блока ==================================

// - 3 - ====================== Обновление информации о торговых условиях ===============
   if (!IsTesting())
   {
      Tick = MarketInfo(Symbol(), MODE_TICKSIZE);  // минимальный тик    
      Spread = ND(MarketInfo(Symbol(), MODE_SPREAD)*Point);// текущий спрэд
      StopLevel = ND(MarketInfo(Symbol(), MODE_STOPLEVEL)*Point);//текущий уровень стопов
      FreezeLevel = ND(MarketInfo(Symbol(), MODE_FREEZELEVEL)*Point);// уровень заморозки
   } 
// - 3 - ============================= Окончание блока ==================================

// - 4 - ========================== Расчет сигналов открытия и закрытия =================
   if (LastSignal != Time[0])                      // На текущем баре еще не был..
   {                                               // ..произведен поиск флэта
      FlatDetect();                                // Определяем, есть ли флэт
      LastSignal = Time[0];                        // Определение флэта на текущем баре..
   }                                               // ..произведено
// - 4 - ============================= Окончание блока ==================================
   
// - 5 - ================== Выполнение операций при обнаружении нового бокса ============
   if (Signal && !FindOrders())                    // Если есть сигнал и нет своей сделки
      if (!Trade()) return(0);                     // Открытие сделки
// - 5 - ============================= Окончание блока ==================================

   LastBar = Time[0];

   return(0);
}

