/*========DESCRIÇÃO 3.0====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
Versão que colocará limit. OK! ta no começo. sem expectativa OK!
nao da sotpando tudo !
========================================================================================================================*/


static input string Option1 = "oii";
extern int Slippage = 3;
extern int MagicNumber = 9090909;
extern int StopLoss = 10;
extern int TakeProfit =10;
extern int Tralling = 5;
extern int TakeProfitMartingale = 30;
extern int TrallingMartingale = 10;

extern int PipsCandle=20;
extern int DistancePips=2;
extern int MinuteFinish = 5;

extern double LotsMult = 0.02;
extern double Lots = 0.01;
extern int MaxOrders = 100;

string Robo = "1.0";
int ticket,takes;
double iLots,lote;
datetime espera;

int OnInit()
{
return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
      
                
      
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

//=========================LOTES
      
     iLots = count*LotsMult;
         

//++++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR TODAS AS ORDENS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               if(OrderMagicNumber()==MagicNumber)
               {  
                  
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice())  bool STOPTUDO = true; espera = OrderCloseTime()+MinuteFinish*60; 

                  }//FIM OP_SELL
               
                  if(OrderType()==OP_BUY)
                  {
                     if(OrderOpenPrice()<OrderClosePrice())  bool STOPTUDOb = true; espera = OrderCloseTime()+MinuteFinish*60; 

                  }//FIM OP_BUY
                     
               }//FIM MAGICNUMBER 
           }//FIM ORDERSELECT
        }//FIM ORDERHISTORY 
            
            int v, totalv=OrdersTotal();
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(v,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                      if( STOPTUDO==true || STOPTUDOb==true )  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                  }//FIM ORDERMAGIC 
                }//FIM SELECT 
           
            }//FIM CONTADOR  
     
              
                           
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  
    if(countbuy==0 && countbuystop==0)
    {
      if(Bid+PipsCandle*MyPoint<Open[1] && Ask-8*MyPoint>Open[0] )
      {
         ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots, High[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue); 
      }
   
    }//FIM BUYSTOP
    
    if(countsell==0 && countsellstop==0)
    {
     if(Bid+PipsCandle*MyPoint<Open[1] && Bid+8*MyPoint<High[0])
      {
          ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Red);
      }    
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
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green); 
            }//FIM OP_BUYSTOP
            
            if(OrderType()==OP_SELLSTOP)
            {  
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green); 
            }//FIM OP_SELLSTOP
             
         }//FIM MAGIC
      }//FIM ORDERSELECT
    }//FIM CONTADOR
    
       
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ENVIO DE ORDEM MARTINGAE++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
   if(count<MaxOrders)
   {       
   for (int trade1=OrdersTotal()-1; trade1>=0; trade1--) 
   {
      if (OrderSelect(trade1,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
             if(OrderType()==OP_SELL)
             {
                if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,0,NULL,MagicNumber,0,clrGreenYellow);
                break; 
             }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,0,NULL,MagicNumber,0,clrGreenYellow);
               break;                                                                           
            }//FIM OP_BUY 
                 
         }//FIM MAGICNUMBER 
      }//FIM ORDERSELECT     
   }//FIM CONTADOR  
}
   
   switch(count) 
   {
      case 1: takes = TakeProfit*1; break;
      case 2: takes = TakeProfit*1; break;
      case 3: takes = TakeProfit*2; break;
      case 4: takes = TakeProfit*2; break;
      case 5: takes = TakeProfit*2; break;
      case 6: takes = TakeProfit*2; break;
      case 7: takes = TakeProfit*2; break;
      case 8: takes = TakeProfit*3; break;
      case 9: takes = TakeProfit*3; break;
      
      case 0: takes = 0; break;
   }     
   
   if(count > 10) takes = TakeProfit*3; 
    
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
                  
                  if(SL==0 && Ask+takes*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+takes*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+Tralling*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+Tralling*MyPoint,0,0,clrLightGreen);
                  
  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-takes*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-takes*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-Tralling*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-Tralling*MyPoint,0,0,clrLightGreen);

               
               }//FIM OP_SELL
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  
    
  


  }//FIM ONTICK
  

