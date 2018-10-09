//+------------------------------------------------------------------+
//|                                                  X trader v3.mq4 |
//|                            Copyright © 2013, www.FxAutomated.com |
//|                                       http://www.FxAutomated.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, www.FxAutomated.com"
#property link      "http://www.FxAutomated.com"

//---- input parameters
extern double    Lots=0.1;
extern int       Slip=5;
extern string    StopSettings="Set stops below";
extern double    TakeProfit=150;
extern double    StopLoss=100;
extern bool      AllowBuy=true;
extern bool      AllowSell=true;
extern bool      CloseOnReverseSignal=true;
extern string    TimeSettings="Set the time range the EA should trade";
extern string    StartTime="00:00";
extern string    EndTime="23:59";
extern string    Ma1="First Ma settings";
extern int       Ma1Period=16;
extern int       Ma1Shift=8;
extern int       Ma1Method=MODE_SMA;
extern int       Ma1AppliedPrice=PRICE_MEDIAN;
extern string    Ma2="Second Ma settings";
extern int       Ma2Period=1;
extern int       Ma2Shift=0;
extern int       Ma2Method=MODE_SMA;
extern int       Ma2AppliedPrice=PRICE_MEDIAN;
extern string    MagicNumbers="Set different magicnumber for each timeframe of a pair";
extern int       MagicNumber=103;


string freeze;


int init()
{
return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----

  }
//+--------------------------------End----------------------------------+








































































































int deinit()
{
  Alert("Visit www.fxautomated.com for more forex tools");
  return;
}