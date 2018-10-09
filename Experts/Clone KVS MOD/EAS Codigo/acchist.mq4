//+------------------------------------------------------------------+
//|                                                      AccHist.mq4 |
//|                                                           Marcus |
//|                                            andrewqaz@hotmail.com |
//|                                                                  |
//|  Creates CSV file in ..\experts\files of account history         |
//+------------------------------------------------------------------+

#include <WinUser32.mqh> //add if using comitsuicide

#property copyright "Marcus Meldrum - freeware"
#property link      "andrewqaz@hotmail.com"
extern string FileName="AcctHist.CSV" ;

int handle ;

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
  handle=FileOpen("myaccthist.csv",FILE_CSV|FILE_WRITE,",");   
  if(handle>0)
    {
     Print("History total",OrdersHistoryTotal() ) ;
     FileWrite(handle, "Ticket","Magic","OTime","Type","Lots","Symbol","OPrice","S/L","T/P","CTime","CPrice","Swap","Profit","Comment");     
     for(int i=0;i<OrdersHistoryTotal();i++)
      {       
       OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) ;
       FileWrite(
         handle,
         OrderTicket(),                //int
         OrderMagicNumber(),           //int
         TimeToStr(OrderOpenTime()),   //datetime
         oType2str(OrderType()),       //int
         OrderLots(),                  //double
         OrderSymbol(),                //string
         OrderOpenPrice(),             //double
         OrderStopLoss(),              //double
         OrderTakeProfit(),            //double
         TimeToStr(OrderCloseTime()),  //int
         OrderClosePrice(),            //double
         OrderSwap(),                  //double
         OrderProfit(),                //double
         OrderComment()                //string         
        ) ; //end file write
      } //end for
     FileClose(handle);
     Alert("FileWrite Done") ; 
     commitSuicide() ;
    }
//----
   return(0);
  }
//+------------------------------------------------------------------+
/////////////////////////    
void commitSuicide() //Don't forget to use #include <WinUser32.mqh> for this function
 {
  int h = WindowHandle(Symbol(), Period());
  if (h != 0) PostMessageA(h, WM_COMMAND, 33050, 0);
 }
///////////
string oType2str(int type)
{
switch (type)
  {
   case OP_BUY : return("Buy") ;// - buying position,
   case OP_SELL : return("Sell") ; //- selling position,
   case OP_BUYLIMIT : return("Buy Limit") ; //- buy limit pending position,
   case OP_BUYSTOP : return("Buy Stop") ; //- buy stop pending position,
   case OP_SELLLIMIT : return("Sell Limit") ; //- sell limit pending position,
   case OP_SELLSTOP : return("Sell Stop") ; //- sell stop pending position.
  }
} //end oType2str
///////////////