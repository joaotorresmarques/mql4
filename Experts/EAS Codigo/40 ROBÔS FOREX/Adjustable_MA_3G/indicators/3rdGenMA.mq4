//+------------------------------------------------------------------+
//|                                                3rd Generation MA |
//|                                      Copyright © 2011, EarnForex |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, EarnForex"
#property link      "http://www.earnforex.com"

/*

3rd Generation MA based on research paper by Dr. Mafred Durschner:
http://www.vtad.de/node/1441 (in German)
Offers least possible lag but still provides price smoothing

*/

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red 

//---- indicator parameters
extern int MA_Period = 50;
extern int MA_Method = 1; //0 - SMA, 1 - EMA, 2 - SMMA, 3 - LWMA
extern int MA_Applied_Price = 5; // 0 - PRICE_CLOSE, 1 - PRICE_OPEN, 2 - PRICE_HIGH, 3 - PRICE_LOW, 4 - PRICE_MEDIAN, 5 - PRICE_TYPICAL, 6 - PRICE_WEIGHTED

//---- indicator buffers
double MA3G[];
double MA1[];

//----
double Lambda, Alpha;
int MA_Sampling_Period;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   int    draw_begin;
   string short_name;

   MA_Sampling_Period = 2 * MA_Period;
   
   IndicatorBuffers(3);

//---- drawing settings
   SetIndexStyle(0, DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   
   draw_begin = MA_Sampling_Period - 1;

//---- indicator short name
   switch(MA_Method)
   {
      case 1:
         short_name="3GEMA(";  
         draw_begin=0;
         break;
      case 2:
         short_name="3GSMMA(";
         break;
      case 3:
         short_name="3GLWMA(";
         break;
      default:
         MA_Method = 0;
         short_name = "3GSMA(";
   }
   IndicatorShortName(short_name + MA_Period + ")");

   SetIndexDrawBegin(0, draw_begin);

//---- indicator buffers mapping
   SetIndexBuffer(0, MA3G);
   SetIndexBuffer(1, MA1);

   Lambda = 1.0 * MA_Sampling_Period / (1.0 * MA_Period);
   Alpha = Lambda * (MA_Sampling_Period - 1) / (MA_Sampling_Period - Lambda);

   Print("Lambda = ", Lambda, "; Alpha = ", Alpha);

//---- initialization done
   return(0);
}

//+------------------------------------------------------------------+
//| 3rd Generation Moving Average Custom Indicator                   |
//+------------------------------------------------------------------+
int start()
{
   int i;
   
   if (Bars <= MA_Sampling_Period + MA_Period) return(0);
   int ExtCountedBars = IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars < 0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars > 0) ExtCountedBars--;
   if (ExtCountedBars < MA_Sampling_Period) ExtCountedBars = MA_Sampling_Period;
//----

   for (i = Bars - ExtCountedBars - 1; i >= 0; i--)
      MA1[i] = iMA(NULL, 0, MA_Sampling_Period, 0, MA_Method, MA_Applied_Price, i);
   
   for (i = Bars - ExtCountedBars - 1; i >= 0; i--)
   {
      double MA2 = iMAOnArray(MA1, 0, MA_Period, 0, MA_Method, i);
      MA3G[i] = (Alpha + 1) * MA1[i] - Alpha * MA2;
   }

//---- done
   return(0);
}
//+------------------------------------------------------------------+

