
//+------------------------------------------------------------------+
//|                                                                  |
#define   ProgramName    "EuroW" //                                |
#define   Version        1.0 //                                      |
#property copyright      "2013, © ProfFX" //                      |
//|                                                                  |
//+------------------------------------------------------------------+
//| Developed:                                                ProfFX |
//|                                         support@euronis-free.com |
//|                                         http://euronis-free.com/ |
//+------------------------------------------------------------------+



/*

Сигналы на вход формируются за счет ослабления скорости движения цены до допустимого 
низкого уровня. 

Дальнейшая сторона на вход, стоп, тейк расcчитываются в зависимости от скоростей 
движения сформированного сигнала.

Symbol:      EURUSD;
TimeFrame:   M15;
Period:      01.01.2000 - 01.01.2013;

*/




//--- externs  
                        
extern string   _TS_Settings              = "TS Settings:"; 
extern double   _Max_Orders_Total         = 3;  // макс. кол. одновременно открытых ордеров

extern double   _Stops_Min                = 10; // мин.  стопы в пунктах (по старым знакам)
extern double   _Stops_Max                = 40; // макс. стопы в пунктах (по старым знакам)

extern int      _Max_Speed_Bars           = 53; // измерение макс. скорости в барах для сигнала
extern double   _AvSpeed_Level            = 37; // диапазон движения для формирования сигнала
extern int      _Min_Best_Dev             = -23;// мин. отклонение в пунктах (по старым знакам) 
                                                // наисильнейшего движения в диапазоне _Max_Speed_Bars, 
                                                // знак это сторона движения
extern int      _Max_Worse_Dev            = 20; // мaкс. отклонение в пунктах (по старым знакам) 
                                                // наихудшего движения. Положительное число.
extern int      _AvSpeedBars              = 100;// количество баров для расчета средней скорости
extern int      _Quote_Perm_Error         = 84; // минимальная допустимая погрешность котировок текущей пары



extern string   _MM_Settings              = "MM Settings:"; 
extern int      _MM_Type                  = 0;  // режим управления капиталом: 0-фиксированный лот; 
                                                //                             1-% от свободных средств

extern string   _MM_Type_0                = "MM: Fixed Lot Settings:";                                    
extern double   _MM_Fix_Lot_Size          = 0.1;// размер фиксированного лота   

extern string   _MM_Type_1                = "MM: % in Account Free Margin Settings:";                     
extern double   _MM_Percent               = 3;  // % от свободных средств

extern string   _Trading_Settings         = "Trading Settings:"; 
extern double   _Slipage                  = 7;  // макс. допустимое откл. цены для ордеров в пунктах (по старым знакам)
extern int      _Trading_Magic_Number     = 0;  // магический номер для ордеров
extern string   _Trading_Comment          = ProgramName; // комментарий для ордеров






//--- globals

double   G_Point       = 1.0;
int      G_PointRatio  = 1.0;  
 
double   G_OpenSi;   
double   G_OpenSL;           
double   G_OpenTP; 

int      G_SignalType = 0;
int      G_HBar = 0;
int      G_LBar = 0;
double   G_SignalSpeed = 0;




//--- mql functions

//--------------
int init()
{
 G_Point = Point;
 G_PointRatio = 1.0;
   
 if(Digits == 5 || Digits == 3)
 {
  G_Point *= 10.0;
  G_PointRatio *= 10.0; 
 } 
}
//--------------

//--------------
int start()
{ if(AccountNumber() !=123456) {Comment("No license for your account. Write on support@euronis-free.com"); return(0);}
 if(TF_F_NewBar()) 
    F_TradeCalc();
}
//--------------

//--------------
int deinit()
{ 

}
//--------------






//--- user functions

//---------------------------------------------------------------------------------------------
bool TF_F_NewBar()               
{   
 static datetime TimeLast;  
                                  
 if(TimeLast!=Time[0])   
 {
  TimeLast=Time[0];   
  return(true);                              
 }

 return(false);
}
//---------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------
void F_TradeCalc()
{
 G_OpenSi = 0;
 G_OpenSL = 0;
 G_OpenTP = 0;
   
 int SignalType = F_SignalType(0);
   
 if(SignalType != 0)
 {
  F_CalcTradeChars();

  if(G_OpenSL < _Stops_Min)
     G_OpenSL = _Stops_Min;
  if(G_OpenTP < _Stops_Min)
     G_OpenTP = _Stops_Min;

  if(G_OpenSL > _Stops_Max)
     G_OpenSL = _Stops_Max;
  if(G_OpenTP > _Stops_Max)
     G_OpenTP = _Stops_Max;
  
  G_OpenSL = G_OpenSL*G_PointRatio;
  G_OpenTP = G_OpenTP*G_PointRatio;
 }
     
 if(G_OpenSi > 0) 
    F_Buy();  
 else
 if(G_OpenSi < 0) 
    F_Sell(); 
}
//---------------------------------------------------------------------------------------------


double G_LotSize = 0.01;

//---------------------------------------------------------------------------------------------
void F_CalcLotSize()
{
 if(_MM_Type==1)
 {
  G_LotSize = MathFloor(NormalizeDouble(AccountFreeMargin()*_MM_Percent/100.0/MarketInfo(Symbol(),MODE_MARGINREQUIRED),2)/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);
 }
 else 
 {
  G_LotSize = _MM_Fix_Lot_Size;
 }
 
 if(G_LotSize > MarketInfo(Symbol(),MODE_MAXLOT))
    G_LotSize = MarketInfo(Symbol(),MODE_MAXLOT);
 if(G_LotSize < MarketInfo(Symbol(),MODE_MINLOT))
    G_LotSize = MarketInfo(Symbol(),MODE_MINLOT);
}
//---------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------
int F_OrdersTotal()
{
 int OrdersTotalResult = 0;
 
 for(int i=0;i<OrdersTotal();i++)
 { 
  if(OrderSelect(i, SELECT_BY_POS))
  { 
   if(OrderMagicNumber() == _Trading_Magic_Number) 
   {
    OrdersTotalResult++;
   }  
  }
 }
 
 return(OrdersTotalResult);
}
//---------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------
bool F_Buy()
{ 
 F_CalcLotSize();
 
 if(F_OrdersTotal() < _Max_Orders_Total) 
 { 
  if(OrderSend(Symbol(), OP_BUY, G_LotSize, NormalizeDouble(Ask,Digits), _Slipage*G_PointRatio,  NormalizeDouble(Bid - G_OpenSL*Point,Digits),  NormalizeDouble(Bid + G_OpenTP*Point,Digits),  _Trading_Comment, _Trading_Magic_Number) < 0)
  {
   Print("OrderSend(BUY) Error Code #",GetLastError());
   return(false);
  }
 }
 else
 {
  Print("OrdersTotal > "+_Max_Orders_Total);
 }

 return(true);
}
//---------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------
bool F_Sell()
{  
 F_CalcLotSize();
 
 if(F_OrdersTotal() < _Max_Orders_Total) 
 {
  if(OrderSend(Symbol(), OP_SELL, G_LotSize, NormalizeDouble(Bid,Digits), _Slipage*G_PointRatio,  NormalizeDouble(Ask + G_OpenSL*Point,Digits),  NormalizeDouble(Ask - G_OpenTP*Point,Digits),  _Trading_Comment, _Trading_Magic_Number) < 0)
  {
   Print("OrderSend(SELL) Error Code #",GetLastError());
   return(false);
  }
 }
 else
 {
  Print("OrdersTotal > "+_Max_Orders_Total);
 }
 return(true);
}
//---------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------
int F_SignalType(int bar_0)
{
 int SigType = F_SignalChar(bar_0);
 
 if(SigType != 0)
 {
  bool CorrrectSig = true;
  
  for(int s1=0;s1<50;s1++)
  {
    int SigType1 = F_SignalChar(bar_0+1+s1);
    
    if(SigType1 != 0)
    {
     CorrrectSig = false;
     break;
    }
  }
  
  if(CorrrectSig)
     return(SigType);
 }
 
 return(0);
}
//---------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------
int F_SignalChar(int bar_0)
{
  G_HBar = iHighest(Symbol(), 0, MODE_HIGH, _Max_Speed_Bars, bar_0+1);
  G_LBar = iLowest(Symbol(), 0, MODE_LOW, _Max_Speed_Bars, bar_0+1);
  
  G_SignalSpeed = (High[G_HBar] - Low[G_LBar])/G_Point;
   
  if(G_SignalSpeed < _AvSpeed_Level)
  {
   if(G_HBar <= G_LBar) 
      G_SignalType = 1;
   else
      G_SignalType = -1;
  }
  else
  {
   G_SignalType = 0;
  }
 
  return(G_SignalType);
}
//---------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------
void F_CalcTradeChars()
{
  int    b1,i1;
  double PossibleNegativeDev;

  int SignalType = F_SignalChar(0);
  
  double NearestPriceWidth = 0;
  double FurtherPriceWidth = 0;

  if(G_HBar < G_LBar)
  {
   NearestPriceWidth = (High[G_HBar] - Close[1])/G_Point;
   FurtherPriceWidth = (Low[G_LBar] - Close[1])/G_Point;
  }
  else
  {
   NearestPriceWidth = (Low[G_LBar] - Close[1])/G_Point;
   FurtherPriceWidth = (High[G_HBar] - Close[1])/G_Point;
  }
  
  double AvSpeedBar = 0;
  int AvSpeedBarsTotal = 0;
  
  for(b1=1;b1<1+_AvSpeedBars;b1++)
  {
   if(b1 >= Bars)
     break;
     
   AvSpeedBar += (High[b1] - Low[b1])/G_Point;
   
   AvSpeedBarsTotal++;
  }
  
  if(AvSpeedBarsTotal > 0)
     AvSpeedBar /= AvSpeedBarsTotal;
  
  double NearestPriceHeight = 0;
  double FurtherPriceHeight = 0;
  
  if(MathAbs(Close[1] - High[G_HBar]) <= MathAbs(Close[1] - Low[G_LBar]))
  {
   NearestPriceHeight = (Close[1] - High[G_HBar])/G_Point;
   FurtherPriceHeight = (Close[1] - Low[G_LBar])/G_Point;
  }
  else 
  {
   NearestPriceHeight = (Close[1] - Low[G_LBar])/G_Point;
   FurtherPriceHeight = (Close[1] - High[G_HBar])/G_Point;
  }
   
  if(NearestPriceWidth > AvSpeedBar)
  {
   PossibleNegativeDev = NearestPriceHeight;
   PossibleNegativeDev += SignalType;
  }
  else
  {
   PossibleNegativeDev = -225.4;
  }
   
  double PositivDevsDBar = 0;
  double NegativeDevsDBar = 0;

  int BarsTrendL = MathAbs(G_HBar-G_LBar);
  
  for(b1=1;b1<1+BarsTrendL;b1++)
  {
   if(b1 >= Bars)
     break;
     
   if(Close[b1]>=Close[b1+1]) 
      PositivDevsDBar+=Close[b1]-Close[b1+1];
   else
      NegativeDevsDBar+=Close[b1+1]-Close[b1];  
  }
  
  if(NearestPriceWidth < PositivDevsDBar/G_Point)
  {
   PossibleNegativeDev = MathAbs(PossibleNegativeDev);
   PossibleNegativeDev *= PositivDevsDBar/G_Point;
  }
  
  double AvSpeedBarSpeed = 0;
  int AvSpeedBarsSpeedTotal = 0;
  
  for(b1=1;b1<1+_Max_Speed_Bars;b1++)
  {
   if(b1 >= Bars)
     break;
     
   AvSpeedBarSpeed += (High[b1] - Low[b1])/G_Point;
   
   AvSpeedBarsSpeedTotal++;
  }
  
  if(AvSpeedBarsSpeedTotal > 0)
     AvSpeedBarSpeed /= AvSpeedBarsSpeedTotal;
  
  double Perm_Error = _Quote_Perm_Error;
     
  if(AvSpeedBarSpeed > 0 && FurtherPriceHeight >= _Min_Best_Dev)
     Perm_Error+=MathMin(_Max_Worse_Dev,MathFloor(AvSpeedBarSpeed));
   
  if(AvSpeedBarSpeed > PositivDevsDBar/G_Point)
  {
   double PositivDevsMS = 0;
   double NegativeDevsMS = 0;
  
   BarsTrendL = _Max_Speed_Bars;
  
   for(b1=1;b1<1+BarsTrendL;b1++)
   {
    if(b1 >= Bars)
      break;
     
    if(Close[b1]>=Close[b1+1]) 
       PositivDevsMS+=Close[b1]-Close[b1+1];
    else
       NegativeDevsMS+=Close[b1+1]-Close[b1];  
   }
   
   PossibleNegativeDev += -NegativeDevsMS/G_Point*2;
  }

  double PositivDevsAV = 0;
  double NegativeDevsAV = 0;
  
  BarsTrendL = _AvSpeedBars;
  
  for(b1=1;b1<1+BarsTrendL;b1++)
  {
   if(b1 >= Bars)
      break;
     
   if(Close[b1]>=Close[b1+1]) 
      PositivDevsAV+=Close[b1]-Close[b1+1];
   else
      NegativeDevsAV+=Close[b1+1]-Close[b1];  
  }
  
  if(PossibleNegativeDev > 0)
     G_OpenTP = MathCeil(-NegativeDevsAV/G_Point + MathMin(_Max_Worse_Dev,PossibleNegativeDev))-1;
  else
     G_OpenTP = _Min_Best_Dev;

  if(Perm_Error > PositivDevsDBar/G_Point)
  if(PossibleNegativeDev > 0 && PossibleNegativeDev > _AvSpeed_Level && PositivDevsDBar/G_Point > NearestPriceHeight)
     PossibleNegativeDev = MathMin(PossibleNegativeDev,FurtherPriceHeight);

  if(G_OpenTP > FurtherPriceWidth)
  {
   if(Perm_Error != 0)
      PossibleNegativeDev /= Perm_Error;
  }
  
  G_OpenTP += Perm_Error;
  G_OpenTP = MathAbs(G_OpenTP);
  
  int ShiftNearest = MathMin(_Max_Worse_Dev,NearestPriceWidth);
 
  for(i1=0;i1<ShiftNearest;i1++)
  {
   PossibleNegativeDev *= NearestPriceHeight;
   PossibleNegativeDev += -NegativeDevsAV/G_Point+i1;
  }

  if(PossibleNegativeDev >= 0)
     G_OpenSi = 1;
  else
     G_OpenSi = -1;
    
  G_OpenSL = MathAbs(PossibleNegativeDev);
}
//---------------------------------------------------------------------------------------------













