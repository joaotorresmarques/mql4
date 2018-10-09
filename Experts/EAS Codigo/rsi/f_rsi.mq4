//+------------------------------------------------------------------+
//|                                                        F_RSI.mq4 |
//|                                               Yuriy Tokman (YTG) |
//|                                               http://ytg.com.ua/ |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman (YTG)"
#property link      "http://ytg.com.ua/"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1  30
#property indicator_level2  70
#property indicator_level3  50
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Lime
#property indicator_color3 Lime
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Modz
  {
   SMMA,
   SMA,
  };
//---- input parameters
extern ENUM_APPLIED_PRICE Price=0;
// O-Close; 1-Open; 2-High; 3-Low; 4-Median; 5-Typical; 6-Weighted 
extern int                RSI_PERIOD=14;
// Period of RSI
extern double             K=1;
// Deviation ratio
input Modz                Mode=0;
// RSI mode : 0 - typical(smoothed by SMMA); 1- clssic (smoothed by SMA)
//---- buffers
double B0[];
double B1[];
double B2[];
double B3[];
double B4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   string short_name;
//----
   IndicatorBuffers(5);
   SetIndexBuffer(3,B3);
   SetIndexBuffer(4,B4);
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,B0);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,B1);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,B2);
//---- 
   short_name="F_RSI";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"RSI");
   SetIndexLabel(1,"UP_LEVEL");
   SetIndexLabel(2,"DN_LEVEL");
//----
   SetIndexDrawBegin(0,RSI_PERIOD);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//----
   int    i,limit=0,counted_bars=prev_calculated;
   double rl,ng=0,ps=0;
//----
   if(Bars<=RSI_PERIOD) return(0);
//----
   if(counted_bars>0) limit=Bars-counted_bars;
   if( counted_bars < 0 )  return(0);
   if(counted_bars==0) limit=Bars-RSI_PERIOD-1;

   for(i=limit;i>=0;i--)
     {
      double sn=0.0,sp=0.0;
      if(i==Bars-RSI_PERIOD-1)
        {
         int k=Bars-2;
         //----
         while(k>=i)
           {
            rl=iMA(NULL,0,1,0,MODE_SMA,Price,k)-iMA(NULL,0,1,0,MODE_SMA,Price,k+1);
            if(rl>0) sp+=rl;
            else      sn-=rl;
            k--;
           }
         ps=sp/RSI_PERIOD;
         ng=sn/RSI_PERIOD;
        }
      else
        {
         //----
         if(Mode==0)
           {
            rl=iMA(NULL,0,1,0,MODE_SMA,Price,i)-iMA(NULL,0,1,0,MODE_SMA,Price,i+1);
            if(rl>0) sp=rl;
            else      sn=-rl;

            ps=(B3[i+1]*(RSI_PERIOD-1)+sp)/RSI_PERIOD;
            ng=(B4[i+1]*(RSI_PERIOD-1)+sn)/RSI_PERIOD;
           }
         else
         if(Mode==1)
           {
            sn=0.0;sp=0.0;
            for(int k=RSI_PERIOD-1;k>=0;k--)
              {
               rl=iMA(NULL,0,1,0,MODE_SMA,Price,i+k)-iMA(NULL,0,1,0,MODE_SMA,Price,i+k+1);
               if(rl>0) sp+=rl;
               else      sn-=rl;
              }
            ps=sp/RSI_PERIOD;
            ng=sn/RSI_PERIOD;
           }
        }
      B3[i]=ps;
      B4[i]=ng;
      if(ng==0.0) B0[i]=100.0;
      else B0[i]=100.0-100.0/(1+ps/ng);

      double S_RSI=0;
      for(int k=RSI_PERIOD-1;k>=0;k--) S_RSI+=B0[i+k];
      double A_RSI=S_RSI/RSI_PERIOD;

      double S_Sqr=0;
      for(int k=RSI_PERIOD-1;k>=0;k--) S_Sqr+=(B0[i+k]-A_RSI) *(B0[i+k]-A_RSI);
      double S_Dv=MathPow(S_Sqr/RSI_PERIOD,0.5);

      B1[i] = 50 + K * S_Dv;
      B2[i] = 50 - K * S_Dv;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
