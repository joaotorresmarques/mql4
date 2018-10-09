//+------------------------------------------------------------------+
//|                                                 OrderHistory.mq4 |
//|        Copyright © 2005, Arunas Pranckevicius(T-1000), Lithuania |
//|                                      irc://irc.omnitel.net/forex |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Arunas Pranckevicius(T-1000), Lithuania"
#property link      "irc://irc.omnitel.net/forex"

extern bool Arrows = 1;

#include <stdlib.mqh>

void SetArrow(datetime ArrowTime, double Price, double ArrowCode, color ArrowCollor)
{
 if (!Arrows)  return;
 int err;
 string ArrowName = TimeToStr(ArrowTime)+"_"+DoubleToStr(Price,4);
   if (ObjectFind(ArrowName) != -1) ObjectDelete(ArrowName);
   if(!ObjectCreate(ArrowName, OBJ_ARROW, 0, ArrowTime, Price))
    {
     err=GetLastError();
     Print("error: can't create Arrow! code #",err," ",ErrorDescription(err));
     return;
    }
   else
   { 
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, ArrowCode);
   ObjectSet(ArrowName, OBJPROP_COLOR , ArrowCollor);
   ObjectSet(ArrowName, OBJPROP_WIDTH  , 1);
   ObjectSetText(ArrowName,DoubleToStr(ArrowCode,1), 8, "Arial", ArrowCollor);
   ObjectsRedraw();
   }
}

void DelArrow(datetime ArrowTime, double Price)
{
 if (!Arrows)  return;
 string ArrowName = TimeToStr(ArrowTime)+"_"+DoubleToStr(Price,4);
 if (ObjectFind(ArrowName) != -1) ObjectDelete(ArrowName);
// if (Symbol() == "EURUSD") Print("DEBUG: Deleting "+ArrowName);
 ObjectsRedraw();
}

void SetObject(string ObjName,int ObjType,datetime ObjTime1,double ObjPrice1,datetime ObjTime2=0,double ObjPrice2=0,color ObjColor=Red,int ObjSize=1,int ObjStyle=STYLE_SOLID,datetime ObjTime3=0,double ObjPrice3=0)
{

if (!Arrows || IsTesting())  return;
if (ObjectFind(ObjName) != -1) ObjectDelete(ObjName);
ObjectCreate(ObjName, ObjType, 0,ObjTime1 , ObjPrice1, ObjTime2, ObjPrice2, ObjTime3, ObjPrice3);
ObjectSet(ObjName,OBJPROP_COLOR,ObjColor); 
ObjectSet(ObjName,OBJPROP_STYLE,ObjStyle); 
ObjectSet(ObjName,OBJPROP_WIDTH,ObjSize); 
}

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//---- 
// retrieving info from trade history
  int i,hstTotal=HistoryTotal();
  int HistoryOrderType; 
  int HistoryOrderTicket; 
  int HistoryOrderCloseTime;
  double HistoryOrderClosePrice;
  int HistoryOrderOpenTime;
  double HistoryOrderOpenPrice;
  double HistoryOrderOpenProfit;
  double HistoryOrderOpenStopLoss;
  string OrderName;
  for(i=0;i<hstTotal;i++)
    {
     //---- check selection result
     if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
       {
        Print("Access to history failed with error (",GetLastError(),")");
        break;
       }
     HistoryOrderType = OrderType();
     if (OrderSymbol() == Symbol())
     {
         HistoryOrderCloseTime=OrderCloseTime();
         HistoryOrderClosePrice=OrderClosePrice();
         HistoryOrderOpenTime=OrderOpenTime();
         HistoryOrderOpenPrice=OrderOpenPrice();
         HistoryOrderOpenProfit=OrderProfit();
         HistoryOrderOpenStopLoss=OrderStopLoss();
         HistoryOrderTicket=OrderTicket();
         OrderName=DoubleToStr(HistoryOrderTicket,0)+" "+TimeToStr(HistoryOrderOpenTime)+" "+DoubleToStr(HistoryOrderOpenPrice,4);
          if(!ObjectCreate(DoubleToStr(HistoryOrderTicket,0), OBJ_TEXT, 0, HistoryOrderOpenTime, (HistoryOrderOpenPrice+HistoryOrderOpenStopLoss)/2))
          {
            Print("error: can't create text_object! code #",GetLastError());
            return(0);
          }
         
         ObjectSetText(DoubleToStr(HistoryOrderTicket,0),OrderName,10,"Times New Roman", Yellow);
        if (HistoryOrderType == OP_BUY)
        {
         Print("Order ",OrderName,": BUY t/p ",HistoryOrderOpenProfit," s/l ",HistoryOrderOpenStopLoss);
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice,233,Blue);  
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice + HistoryOrderOpenProfit * Point,177,Blue);
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenStopLoss,251,Yellow);
         if (HistoryOrderClosePrice >= HistoryOrderOpenProfit) 
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,252,Blue);  
         if (HistoryOrderClosePrice <= HistoryOrderOpenStopLoss) 
         {
            if (HistoryOrderClosePrice <= HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,78,Yellow);                
            if (HistoryOrderClosePrice > HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,254,Blue);                          
         }   
        }
        if (HistoryOrderType == OP_BUYSTOP)
        {
         Print("Order ",OrderName,": BUYSTOP t/p ",HistoryOrderOpenProfit," s/l ",HistoryOrderOpenStopLoss);
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice,228,Blue);  
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice + HistoryOrderOpenProfit * Point,177,Blue);           
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenStopLoss,251,Yellow);
         if (HistoryOrderClosePrice >= HistoryOrderOpenProfit) 
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,252,Blue);  
         if (HistoryOrderClosePrice <= HistoryOrderOpenStopLoss) 
         {
            if (HistoryOrderClosePrice <= HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,78,Yellow);                
            if (HistoryOrderClosePrice > HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,254,Blue);                          
         }   
        }
        if (HistoryOrderType == OP_BUYLIMIT)
        {
         Print("Order ",OrderName,": BUYLIMIT t/p ",HistoryOrderOpenProfit," s/l ",HistoryOrderOpenStopLoss);
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice,200,Blue);  
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice + HistoryOrderOpenProfit * Point,177,Blue);           
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenStopLoss,251,Yellow);
         if (HistoryOrderClosePrice >= HistoryOrderOpenProfit) 
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,252,Blue);  
         if (HistoryOrderClosePrice <= HistoryOrderOpenStopLoss) 
         {
            if (HistoryOrderClosePrice <= HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,78,Yellow);                
            if (HistoryOrderClosePrice > HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,254,Blue);                          
         }   
        }
     
        if (HistoryOrderType == OP_SELL)
        {
         Print("Order ",OrderName,": SELL t/p ",HistoryOrderOpenProfit," s/l ",HistoryOrderOpenStopLoss);
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice,234,Red);  
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice - HistoryOrderOpenProfit * Point,177,Red);           
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenStopLoss,251,Yellow);
         if (HistoryOrderClosePrice <= HistoryOrderOpenProfit) 
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,252,Red);  
         if (HistoryOrderClosePrice >= HistoryOrderOpenStopLoss) 
         {
            if (HistoryOrderClosePrice >= HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,78,Yellow);                
            if (HistoryOrderClosePrice < HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,254,Red);                          
         }   
        }
        if (HistoryOrderType == OP_SELLSTOP)
        {
         Print("Order ",OrderName,": SELLSTOP t/p ",HistoryOrderOpenProfit," s/l ",HistoryOrderOpenStopLoss);
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice,230,Red);  
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice - HistoryOrderOpenProfit * Point,177,Red);           
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenStopLoss,251,Yellow);
         if (HistoryOrderClosePrice <= HistoryOrderOpenProfit) 
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,252,Red);  
         if (HistoryOrderClosePrice >= HistoryOrderOpenStopLoss) 
         {
            if (HistoryOrderClosePrice >= HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,78,Yellow);                
            if (HistoryOrderClosePrice < HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,254,Red);                          
         }   
        }
        if (HistoryOrderType == OP_SELLLIMIT)
        {
         Print("Order ",OrderName,": SELLIMIT t/p ",HistoryOrderOpenProfit," s/l ",HistoryOrderOpenStopLoss);
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice,202,Red);  
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenPrice - HistoryOrderOpenProfit * Point,177,Red);           
         SetArrow(HistoryOrderOpenTime,HistoryOrderOpenStopLoss,251,Yellow);
         if (HistoryOrderClosePrice <= HistoryOrderOpenProfit) 
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,252,Red);  
         if (HistoryOrderClosePrice >= HistoryOrderOpenStopLoss) 
         {
            if (HistoryOrderClosePrice >= HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,78,Yellow);                
            if (HistoryOrderClosePrice < HistoryOrderOpenPrice)
            SetArrow(HistoryOrderCloseTime,HistoryOrderClosePrice,254,Red);                          
         }   
        }
     
     }   
     {
     
     
     }
    }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+