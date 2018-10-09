//+------------------------------------------------------------------+
//|                                                       DayRSI.mq4 |
//|                                 Copyright 2010-2015, Excstrategy |
//|                                        http://www.ExcStrategy.ru |
//+------------------------------------------------------------------+
#property copyright "ExcStrategy"
#property link      "http://www.ExcStrategy.ru"
#property version   "1.1"
#property description "RSI"
#property strict
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_width1 1
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//----
extern int Applied_price=0;
//----
extern int DaysForCalculation=2;
//---- buffers
double Buffer1[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(1);
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buffer1);
//---- 
   SetIndexLabel(0,"RSI");
//---
   DaysForCalculation=DaysForCalculation+1;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Period()>1400)
     {
      Alert("Error! Period can not be greater than D1");
      return(0);
     }
//----
   int counted_bars=IndicatorCounted();
   int barsday;
   bool rangeday;
   datetime Time1=Time[0],Time2;
//----
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
//----
   for(int i=0; i<limit; i++)
     {
      //----
      rangeday= false;
      barsday = 0;
      //----
      Time2=Time[i]+(1440*60*DaysForCalculation);
      if(Time1<Time2)
         if(i<Bars-MathRound(1500/Period()))
            for(int a=i; a<i+1441; a++)
              {
               //----
               barsday++;
               //----
               if(TimeDayOfYear(Time[a])!=TimeDayOfYear(Time[a+1])) a=i+1442;
              }
      //----
      Buffer1[i]=iRSI(NULL,0,barsday,Applied_price,i);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
