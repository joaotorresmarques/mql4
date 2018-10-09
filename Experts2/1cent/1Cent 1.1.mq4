/*========DESCRIÇÃO 1cent====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================

 TAKEPROFIT = Spread+Pips?
 
Lot nao posso mecher porque nao tenho gnahos consecutivos.  { se account 100 - 1.0 se account 150 - 2.0 }

ifPipsCandle==40 então mesma ordem reversa de posição?!
========================================================================================================================*/
string Robo = "1CENT";

extern int Slippage = 3;
extern int MagicNumber = 9090909;
extern int StopLoss = 5;
extern int TakeProfit = 5;
extern int Tralling = 3;
extern int PipsCandle=10;
extern int DistancePips=2;
extern int MinuteEnd = 5;
extern double Lots = 1.0;

int ticket;
double Spread=MarketInfo(Symbol(),MODE_SPREAD);

void OnTick()
  {
  
//=========================CONTADOR DE ORDENS ABERTAS  
   int count,countsellstop,countbuystop,countsell,countbuy;
   
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
         if (OrderType() == OP_SELLSTOP) countsellstop++; 
         if (OrderType() == OP_BUYSTOP) countbuystop++; 
         if (OrderType() == OP_SELL) countsell++; 
         if (OrderType() == OP_BUY) countbuy++;    
   }

//=========================CALCULO DE POINT
     double MyPoint=Point;                                      
     if(Digits==3 || Digits==5) MyPoint=Point*10;               
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++SEND ORDERS++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
if(OrdersTotal()<=2){
   if(countbuy==0 && countbuystop==0)
   {
      if(High[0]-Low[0]>PipsCandle*MyPoint)
      {
         ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots, High[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue); 
      }
   }//FIM BUYSTOP

   if(countsell==0 && countsellstop==0)
   {
      if(High[0]-Low[0]>PipsCandle*MyPoint)
      {
         ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Low[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Red);   
      }
   }//FIM SELLSTOP
   }
   
//++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR ORDENS PENDENTES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    for (int trade7=OrdersTotal()-1; trade7>=0; trade7--) 
   {
      if (OrderSelect(trade7,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
            if(OrderType()==OP_BUYSTOP)
            {   
               if(OrderOpenTime()<Time[0]-3*60) ticket = OrderDelete(OrderTicket(),Green);  /*OrderOpenTime()<+MinuteEnd*60==TimeCurrent()*/
            }//FIM OP_BUYSTOP
            
            if(OrderType()==OP_SELLSTOP)
            {  
               if(OrderOpenTime()<Time[0]-3*60) ticket = OrderDelete(OrderTicket(),Green); 
            }//FIM OP_SELLSTOP
            
            
         }//FIM MAGIC
      }//FIM ORDERSELECT
    }//FIM CONTADOR
   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {  
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
                  
                  if(SL==0 && Ask-TakeProfit*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+(TakeProfit)*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+Tralling*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+(Tralling)*MyPoint,0,0,clrLightGreen);
                  
                  if(Ask+StopLoss*MyPoint<OrderOpenPrice())  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrAliceBlue);
                    
                  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-TakeProfit*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-(TakeProfit)*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-Tralling*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-(Tralling)*MyPoint,0,0,clrLightGreen);
                  
                  if(Bid-StopLoss*MyPoint>OrderOpenPrice())     ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrAliceBlue);
                   
               
               }//FIM OP_SELL
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR   
   
  }//fim ONTICK


