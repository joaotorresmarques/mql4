/*========DESCRIÇÃO 1cent 1.1====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================


========================================================================================================================*/
string Robo = "1CENT";

extern int Slippage = 3;
extern int MagicNumber = 9090909;
extern int StopLoss = 20;
extern int TakeProfit = 2;
extern int Tralling = 3;
extern int PipsCandle=15;
extern int DistancePips=2;
extern int MinuteEnd = 5;
extern double Lots = 1.0;
int ticket;
double Spread = (Ask-Bid);

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
if(OrdersTotal()==0){
            ticket = OrderSend(Symbol(), OP_BUY,Lots,Ask,Slippage,0,0,Robo,MagicNumber,0,Blue); 
   
          
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
                  
                  if(SL==0 && Ask+(Spread+TakeProfit*MyPoint)>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+(Spread+TakeProfit*MyPoint),0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+Tralling*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+Tralling*MyPoint,0,0,clrLightGreen);
                  
                  if(Ask+StopLoss*MyPoint<OrderOpenPrice())  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrAliceBlue);
                    
                  
               }//FIM OP_BUY
               
                
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR   
   
  }//fim ONTICK


